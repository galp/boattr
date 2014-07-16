#!/usr/bin/ruby
require 'json'
require 'time'
# need 'i2c' gem installed
require "i2c/i2c"
require "i2c/backends/i2c-dev"
require 'couchrest'
require 'simple-graphite'
require 'socket'

module Boattr
  class Sensors
    @@data = []
    @@device 
    @@OWdevices = []
    attr_reader :name, :address, :i2cBus, :data
    def initialize(params)
      @name     = params['name']
      @address  = params['address']
      @@device = ::I2C.create(params['i2cBus'])
      self.read()
      self.onewire()
    end
    def read
      @data = []
      # read 20 bytes from slave, convert to decimals, and finaly in 10bit values.
      @adc = @@device.read(address, 0x14, 0x00).unpack('C*').map {|e| e.to_s 10}
      #slice the 20 byte array into pairs (MSB,LSB) and convert. 
      @adc.each_slice(2) {|a| @@data << a[0].to_i*256+a[1].to_i}
      return @@data
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
      return { 'name' => @name, 'type' => 'water', 'value' => @raw }
    end
  end
  class Data  
    def initialize()
      @g     = Graphite.new({:host => "10.70.60.1", :port => 2003})
      @db = CouchRest.database!("http://localhost:5984/couchrest-test")
    end
    def to_db(sensor_data)
      @data  = sensor_data
      @data.each() do |x|
        @db.save_doc({ "_id" => now() , "data" => x })
        p x
      end
    end
    def to_graphite(sensor_data)
      @base  = 'foo'
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
      return Time.now.to_f.round(2).to_s
    end
  end

end
