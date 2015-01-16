#!/usr/bin/ruby
require 'json'
require 'time'
require 'yaml'
require 'i2c'
require 'gpio'
require 'couchrest'
require 'simple-graphite'
require 'socket'
require 'open-uri'
require 'httparty'
require 'nokogiri'

module Boattr
  class Sensors
    attr_reader :i2c_adc_address, :i2c_device, :data, :basename, :onewire_devices
    def initialize(params)
      @basename        = params['boattr']['basename']
      @i2c_adc         = params['i2c']['i2cAdc']
      @i2c_device      = ::I2C.create(params['i2c']['i2cBus'])
      read_i2c_adc(@i2c_adc)
      read_onewire_bus
    end

    def read_i2c_adc(address)
      @data     = {}
      @iterate  = 16
      p address
      address.each do |k,v|
        next if v['disabled'] 
        d            = []
        @data_set    = Array.new(10) { Array.new }
        @adc_samples = []
        @iterate.times do # we take @iterate samples
          # read 20 bytes from slave, convert to decimals, and finaly in 10bit values.
          begin
            @adc = i2c_device.read(v['address'], 0x14, 0x00).unpack('C*').map { |e| e.to_s 10 }
          rescue
            puts "i2c device #{k} at address #{v['address']} not responding"
            return
          end
          sleep(0.1)
          # slice the 20 byte array into pairs (MSB,LSB) and convert decimal.
          @adc.each_slice(2) { |a| @adc_samples << a[0].to_i * 256 + a[1].to_i }
          @data_set.each_with_index { |d, i| d << @adc_samples[i] }
          @adc_samples = []
        end
        # take the average (array.inject(:+) ? )
        @data_set.each_with_index do |d, _i|
          # sort and remove max and min
          d = d.sort
          d.pop(2)
          d.shift(2)
          d << d.inject { |sum, x| sum + x } / (@iterate - 4)
          @data[k] = d
        end
      end
      p @data
    end

    def read_onewire_bus
      @basedir  = '/sys/bus/w1/devices/'
      Dir.chdir(@basedir)
      @onewire_devices = Dir['*-*']
    end

    def pressure(name, address)
      return if data.empty?
      @name    = name
      @raw     = data[address['adc']][address['pin']]
      @volts = @raw * 0.015357
      { 'name' => @name, 'type' => 'pressure', 'raw' => @raw, 'value' => @volts.round(2) }
    end
    def constrain(x,min,max)
      x = min if x < min
      x = max if x > max
    end
    def voltage(name, address)
      return if data.empty?
      @name    = name
      @raw     = data[address['adc']][address['pin']]
      @volts = @raw * 0.015357
      { 'name' => @name, 'type' => 'volts', 'raw' => @raw, 'value' => @volts.round(2) }
    end

    def current(name, address, model = 'acs714', mode = 'both')
      return if data.empty?
      @supported_models = { 'acs714' => 0.066, 'acs709' => 0.028, 'acs712' => 0.185 }
      @name    = name
      @mode    = mode
      @divider = @supported_models[model]
      @raw     = data[address['adc']][address['pin']]
      @volts   = (@raw * 0.004887)
      # a load should only be negative and  a source should be possitive
      @volts   = 2.5 if @mode == 'src' && @volts < 2.5 || @mode == 'load' && @volts > 2.5
      @amps    = (@volts - 2.5) / @divider
      { 'name' => @name, 'type' => 'current', 'mode' => @mode, 'raw' => @raw, 'value' => @amps.round(2) }
    end

    def temperature(name, address)
      @name     = name
      @address  = address
      @basedir  = '/sys/bus/w1/devices/'
      return unless onewire_devices.include?(@address)
      @file = File.open("#{@basedir}/#{address}/w1_slave", 'r')
      return unless @file.readline.include?('YES') # Is CRC valid in the first line?
      @temp = @file.readline.split[-1].split('=')[-1].to_i / 1000.0
      { 'name' => @name, 'type' => 'temp', 'address' => @address,  'value' => @temp.round(2) }
    end
  end

  class Data
    attr_reader :basename
    def initialize(params)
      @graphite    = params['graphite']['host']
      @couchdb     = params['couchdb']['host']
      @basename    = params['boattr']['basename']
      unless @graphite.nil? || @graphite.empty?
        @g         = Graphite.new(host: "#{@graphite}", port: 2003)
      end
      unless @couchdb.nil? || @couchdb.empty?
        @sensorsdb = CouchRest.database!("http://#{@couchdb}:5984/#{@basename}-sensors")
        @statsdb   = CouchRest.database!("http://#{@couchdb}:5984/#{@basename}-stats")
      end
    end

    def to_db(sensor_data)
      @data  = sensor_data
      @data.each do |x|
        next if x.nil?
        p x
        @doc = { '_id' => now }.merge x
        @sensorsdb.save_doc(@doc)
      end
    end


def create_views(sensor_data,type)
      # at this point this only creates  views of the same type, in one design doc.
      @data       = sensor_data
      @views      = {}
      @data.each do |x|
        next if x.nil? || x['type'] != type
        @name  = x['name']
        @type  = x['type']
        @view  = { "#{@name}".to_sym => {
          map: "function(doc) {  if (doc.name == \"#{@name}\" && doc.type == \"#{@type}\" ) {  emit(doc._id, doc.value);  }}",
          reduce: '_stats' }
        }
        @views.merge!(@view)
      end
      begin
        doc = @sensorsdb.get("_design/#{type}")
        doc['views'] = @views
        @sensorsdb.save_doc(doc)
      rescue
        @sensorsdb.save_doc(
          '_id' => "_design/#{@type}",
          :language => 'javascript',
          :views    =>  @views
        )
      end
    end

    def amphours(sensor_data, hours = 24)
      @data  = sensor_data
      @hours = hours
      @from = Time.now.to_i - @hours * 60 * 60
      @merged = []
      @data.each do |x|
        if x.nil? || x['type'] != 'current'
          next
        end
        @name   = x['name']
        @type   = x['type']
        @mode   = x['mode']
        @view   = URI.escape("current/#{@name}?startkey=\"#{@from}\"")
        @result =  @sensorsdb.view(@view)['rows'][0]['value']
        @sum    = @result['sum']
        @count  = @result['count']
        @amph   = @sum / (@hours * 60 / @hours) # is this correct?
        @sensor = { 'name' => @name,  'type' => 'amphours', 'mode' => @mode, 'hours' => @hours, 'value' => @amph.round(2) }
        @merged << @sensor
      end
      @merged
    end
    def amphour_balance(amphours_data)
      @loads, @sources = 0, 0
      @amphours       = amphours_data
      @amphours.each do |x|
        if x['type'] == 'amphours' &&  x['mode'] == 'src'
          @sources += x['value']
        end
        if x['type'] == 'amphours' && x['mode'] == 'load'
          @loads += x['value']
        end
      end
      [{ 'name' => 'sources', 'type' => 'amphours', 'hours' => @hours, 'value' => @sources.round(2) },
       { 'name' => 'loads', 'type' => 'amphours', 'hours' => @hours, 'value' => @loads.round(2) }]
    end

    def to_graphite(sensor_data)
      @basename  = basename
      p @basename
      @data      = sensor_data
      @data.each do |x|
        next if x.nil?
        @type  = x['type']
        @name  = x['name']
        @value = x['value']
        @g.push_to_graphite do |graphite|
          graphite.puts "#{@basename}.#{@type}.#{@name} #{@value} #{@g.time_now}"
        end
      end
    end

    def now
      # used by to_db()
      Time.now.to_f.round(2).to_s
    end

    def get_remaining_data(name)
      @name = name
      @butes = 0
      begin
        @page = Nokogiri::HTML(open('http://add-on.ee.co.uk/status'))
        @data = @page.css('span')[0].text
      rescue
        return
      end
      @unit = @data.slice(-2..-1)
      if @unit == 'GB'
        @bytes = @data.slice(0..-3).to_f
      else
        @bytes = @data.slice(0..-3).to_f / 1000.0
      end
      { 'name' => @name, 'type' => 'data', 'value' => @bytes }
    end
  end
  class Dashing
    attr_reader :host
    def initialize(params)
      @host      = params['dashing']['host']
      @dash_auth = params['dashing']['auth']
    end

    def to_dashboard(sensor_data)
      @data = sensor_data
      @data.each do |x|
        next if x.nil?
        @type  = x['type']
        @name  = x['name']
        @value = x['value']
        HTTParty.post("http://#{@host}:3030/widgets/#{@type}#{@name}",
                      body: {
                        auth_token: "#{@dash_auth}",
                        current: @value,
                        moreinfo: @type,
                        title: @name }.to_json
                      )
      end
    end

    def list_to_dashboard(sensor_data, widget)
      @data   = sensor_data
      @widget = widget
      @items  = []
      @data.each do |x|
        next if x.nil?
        @name  = x['name']
        @value = x['value']
        @hours = x['hours']
        @items << { label: @name, value: @value }
      end
      HTTParty.post("http://#{@host}:3030/widgets/#{@widget}",
                    body: {
                      auth_token: "#{@dash_auth}",
                      items: @items,
                      moreinfo: "last #{@hours} hours",
                      title: @widget }.to_json
                    )
    end
  end
  class Config
    attr_reader :enabled_sensors, :read
    def self.read(config_file = 'config.yml')
      parsed = begin
                 YAML.load(File.open(config_file))
               rescue ArgumentError => e
                 puts "Could not parse config file: #{e.message}"
               end
    end
    def self.enabled_sensors(config = self.read)
      @data = []
      config['sensors'].each() do |k,v| 
        v.each() do |x| 
          next if x[1]['disabled']
          @data <<  x[1].merge!({'type' => k, 'name' => x[0] })
        end
      end
      return @data
    end
  end
  class Control
    def pump(name, stove_temp, cal_temp, pin, stove_thres = 40, cal_thres = 22)
      @name  = name
      @stove_temp = stove_temp
      @cal_temp    = cal_temp
      @pin         = pin
      @cal_thres   = cal_thres
      @stove_thres = stove_thres
      @pump = ::GPIO::Relay.new(device: :BeagleboneBlack, pin: @pin)
      if @cal_temp.nil? || @stove_temp.nil? ||  @stove_temp < @stove_thres || @cal_temp > @cal_thres
        puts "#{@name} off,  stove :#{@stove_temp}, cal : #{@cal_temp}"
        @pump.off 
      else
        p "#{@name} on,  stove :#{@stove_temp}, cal : #{@cal_temp}"
        @pump.on 
      end
    end
  end
end
