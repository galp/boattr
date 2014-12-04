#!/usr/bin/ruby
require 'json'
require 'time'
# need 'i2c' gem installed
require "i2c/i2c"
require "i2c/backends/i2c-dev"
require 'couchrest'
require 'simple-graphite'
require 'socket'
require 'open-uri'
require 'httparty'
require 'nokogiri'

module Boattr
  class Sensors
    @@data = []
    @@device
    @@OWdevices = []
    attr_reader :location, :i2cAddress, :i2cBus, :data, :basename
    def initialize(params)
      @@basename    = params['basename']
      @i2cAddress   = params['i2cAddress']
      @@device      = ::I2C.create(params['i2cBus'])
      self.read()
      self.onewire()
    end
    def read
      @i2cIter      = 16
      @data = Array.new(10) {Array.new }
      @samples = []
      @i2cIter.times do #we take @i2cIter samples
        # read 20 bytes from slave, convert to decimals, and finaly in 10bit values.
        @adc = @@device.read(i2cAddress, 0x14, 0x00).unpack('C*').map {|e| e.to_s 10}
        sleep(0.1)
        #slice the 20 byte array into pairs (MSB,LSB) and convert decimal.
        @adc.each_slice(2) {|a| @samples << a[0].to_i*256+a[1].to_i}
        #p @samples
        @data.each_with_index() {|d,i| d << @samples[i]}
        @samples = []
      end
      #take the average (array.inject(:+) ? )
      @data.each_with_index() do |d,i|
        # sort and remove max and min
        d = d.sort
        d.pop
        d.pop
        d.shift
        d.shift
        @@data << d.inject{|sum,x| sum + x }/(@i2cIter-4)
      end
      return  @@data
    end

    def voltage(name,address)
      @name    = name
      @raw     = @@data[address]
      @volts = @raw * 0.015357
      return { 'name' => @name, 'type' => 'volts', 'raw' => @raw, 'value' => @volts.round(2) }
    end
    def current(name,address,model='acs714',mode='both')
      @supported_models = { 'acs714' => 0.066, 'acs709' => 0.028}
      @name    = name
      @mode    = mode
      @divider = @supported_models[model]
      @raw     = @@data[address]
      @volts   = (@raw*0.004887)
      if mode == 'src' and @volts < 2.5 then # a source should not show negative values.
        @volts = 2.5
      end
      if mode == 'load' and @volts > 2.5 then # a load should not show possitive values 
        @volts = 2.5
1      end
      @amps    = (@volts-2.5)/@divider
      return { 'name' => @name, 'type' => 'current', 'mode' => @mode, 'raw' => @raw, 'value' => @amps.round(2)}
    end
    def onewire()
      @basedir  = '/sys/bus/w1/devices/'
      Dir.chdir(@basedir)
      @@OWdevices = Dir['*-*']
      return @@OWdevices
    end
    def temperature(name,address)
      @name     = name
      @address  = address
      @basedir  = '/sys/bus/w1/devices/'
      if @@OWdevices.include?(@address) then
        file = File.open("#{@basedir}/#{address}/w1_slave",'r')
        if file.readline().include?('YES') then ## Is CRC valid in the first line? lets read the second and extract the temp
          @temp = file.readline().split()[-1].split('=')[-1].to_i/1000.0
          return { 'name' => @name, 'address' => @address, 'type' => 'temp', 'value' => @temp.round(2) }
        end
      end
    end
    def waterlevel(name,address)
      @name     = name
      @address  = address
      @raw      = @@data[address]
      @volts    = @raw*0.00472
      p @volts
      return { 'name' => @name, 'type' => 'water', 'value' => @raw }
    end
  end

  class Data
    def initialize(params)
      @graphite    = params['graphite']
      @couchdb     = params['couchdb']
      @@basename   = params['basename']
      unless @graphite.nil? || @graphite.empty? then
        @g         = Graphite.new({:host => "#{@graphite}", :port => 2003})        

      end
      unless @couchdb.nil? || @couchdb.empty? then
        @sensorsdb = CouchRest.database!("http://#{@couchdb}:5984/#{@@basename}-sensors")
        @statsdb   = CouchRest.database!("http://#{@couchdb}:5984/#{@@basename}-stats")
      end
    end
    def to_db(sensor_data)
      @data  = sensor_data
      @data.each() do |x|
        if x.nil? then
          next
        end
        p x 
        @doc ={ "_id" => now() }.merge x
        @sensorsdb.save_doc(@doc)
      end
    end
    def create_views(sensor_data)
      @data  = sensor_data
      @data.each() do |x|
        if x.nil? then
          next
        end
        @name  = x['name']
        @type  = x['type']
        @sensorsdb.save_doc(
                            {
                              "_id" => "_design/#{@type}",
                            :views => {
                                "#{@name}".to_sym => {
                                :map => "function(doc) {  if (doc.name == \"#{@name}\") {  emit(doc._id, doc.value);  }}"
                                },
                              }
                            })
      end
    end
    def amphours(name,hours)
      @sum   = 0
      @name  = name
      @hours = hours
      @from = Time.now().to_i-hours*60*60
      @view = URI.escape("current/#{@name}?startkey=\"#{@from}\"")
      @data = @sensorsdb.view(@view)
      @rows_returned = @data['total_rows'] - @data['offset']
      @rows       = @data['rows']
      #p  @rows_returned
      @rows.each() do |r|
        @sum+=r['value']
      end
      @amph = @sum/(@rows_returned/@hours)
      return { 'name' => @name,  'value' => @amph.round(2)}
    end
    def to_graphite(sensor_data)
      @base  = @@basename
      @data  = sensor_data
      #p "#{@base}.#{@type}.#{@name} #{@value} #{@g.time_now}"
      @data.each() do |x|
        if x.nil? then
          next
        end
        @type  = x['type']
        @name  = x['name']
        @value = x['value']
        @g.push_to_graphite do |graphite|
          graphite.puts "#{@base}.#{@type}.#{@name} #{@value} #{@g.time_now}"
        end
      end
    end
    def now
      #used by to_db()
      return Time.now.to_f.round(2).to_s
    end
    def to_dashboard(sensor_data)
      #@name =  @@basename
      @data = sensor_data
      @data.each() do |x|
        if x.nil? then
          next
        end

        @type  = x['type']        
        @name  = x['name']
        @value = x['value']        
        HTTParty.post("http://192.168.8.1:3030/widgets/#{@type}#{@name}",
                      :body => { auth_token: "YOUR_AUTH_TOKEN", current: @value, moreinfo: @type, title: @name }.to_json)
      end
    end
    def get_remaining_data(name)
      @name = name  
      @butes = 0
      @page = Nokogiri::HTML(open("http://add-on.ee.co.uk/status"))
      @data = @page.css('span')[0].text
      p @data
      @unit = @data.slice(-2..-1)
      if @unit == 'GB'
        @bytes = @data.slice(0..-3).to_f
        p @bytes
      else
        @bytes = @data.slice(0..-3).to_f/1000.0
      end
      return { 'name' => @name, 'type' => 'data', 'value' => @bytes }
    end
  end
end
