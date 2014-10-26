#!/usr/bin/ruby
require 'json'
require 'time'
# need 'i2c' gem installed
require "i2c/i2c"
require "i2c/backends/i2c-dev"
require 'couchrest'
require 'simple-graphite'
require 'socket'
require 'uri'

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
    def readold
      @data = []
      # read 20 bytes from slave, convert to decimals, and finaly in 10bit values.
      @adc = @@device.read(i2cAddress, 0x14, 0x00).unpack('C*').map {|e| e.to_s 10}
      #slice the 20 byte array into pairs (MSB,LSB) and convert. 
      @adc.each_slice(2) {|a| @@data << a[0].to_i*256+a[1].to_i}
      return @@data
    end
    def read
      @i2cIter      = 12
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
        d.shift
        @@data << d.inject{|sum,x| sum + x }/(@i2cIter-2)
      end
      #p @@data
      return  @@data
    end

    def voltage(name,address)
      @name    = name
      @raw     = @@data[address]
      @volts = @raw * 0.015357
      return { 'name' => @name, 'type' => 'volts', 'raw' => @raw, 'value' => @volts.round(3) }
    end
    def current(name,address)
      @name    = name
      @raw     = @@data[address]
      @volts   = (@raw*0.004887)
      @amps    = (@volts-2.5)/0.066 
      return { 'name' => @name, 'type' => 'current', 'raw' => @raw, 'value' => @amps.round(3)} 
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
          return { 'name' => @name, 'address' => @address, 'type' => 'temp', 'value' => @temp.round(3) }
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
      @graphite = params['graphite']
      @couchdb  = params['couchdb']
      @@basename = params['basename']
      @g     = Graphite.new({:host => "#{@graphite}", :port => 2003})
      @sensorsdb = CouchRest.database!("http://#{@couchdb}:5984/#{@@basename}-sensors")
      @statsdb   = CouchRest.database!("http://#{@couchdb}:5984/#{@@basename}-stats")
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
      @sensorsdb.save_doc(
                          {
                            "_id" => "_design/current", 
                            :views => {
                              :solar => {
                                :map => "function(doc) {  if (doc.name == \"solar\") {  emit(doc._id, doc.value);  }}"
                              },
                              :ring => {
                                :map => "function(doc) {  if (doc.name == \"ring\") {  emit(doc._id, doc.value);  }}"
                              },
                              :fridge => {
                                :map => "function(doc) {  if (doc.name == \"fridge\") {  emit(doc._id, doc.value);  }}"
                              },
                              :lights => {
                                :map => "function(doc) {  if (doc.name == \"lights\") {  emit(doc._id, doc.value);  }}"
                              }

                            }

                          })
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
      return @amph
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
      @name =  @@basename
      HTTParty.post('http://localhost:3030/widgets/karma',
                    :body => { auth_token: "YOUR_AUTH_TOKEN", current: 1000 }.to_json)
    end
  end

end
