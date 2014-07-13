#!/usr/bin/ruby
require 'json'
require 'time'
# need 'i2c' gem installed
require "i2c/i2c"
require "i2c/backends/i2c-dev"
require 'couchrest'
require 'simple-graphite'

module Boattr
  class Sensors
    @@data = []
    @@device 
    attr_reader :name, :address, :i2cBus, :data
    def initialize(params)
      @name     = params['name']
      @address  = params['address']
      @@device = ::I2C.create(params['i2cBus'])
      self.read()
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
      return { 'name' => @name, 'type' => 'voltage', 'raw' => @raw, 'volts' => @volts.round(3) }
    end
    def current(name,address)
      @name    = name
      @raw     = @@data[address]
      @volts   = (@raw*0.004887)
      @amps    = (@volts-2.5)/0.066 
      return { 'name' => @name, 'type' => 'current', 'raw' => @raw, 'volts'=> @volts.round(3), 'amps' => @amps.round(3)} 
    end
    def temperature(name,address)
    end
    def waterlevel(name,address)
    end
  end
  class Data  
    def initialize()
      @g  = Graphite.new({:host => "localhost", :port => 2003})
      @db = CouchRest.database!("http://localhost:5984/couchrest-test")
    end
    def to_db(sensor_data)
      @data  = sensor_data
      @data.each() do |x|
        @db.save_doc({ "_id" => now() , "data" => x })
        p x
      end
    end
    def to_graphite
    end
    def now
      return Time.now.to_f.round(2).to_s
    end
  end

end

brain02 = {
  'name'    => 'analog/i2c from brain2',
  'address' => 0x28,
  'i2cBus'  => '/dev/i2c-1',
  'couchdb' => true,
}


sensors=Boattr::Sensors.new(brain02)
#p foo.read()

brain02_sensors=[sensors.voltage('bat',1), sensors.current('amps',0)]

Boattr::Data.new().to_db(brain02_sensors)



