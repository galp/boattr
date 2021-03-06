module Boattr
  class Voltage < Sensors
    attr_reader :name, :address
    def initialize(name, address)
      @name     = name
      @address  = address
    end

    def read
      return if @@data.nil? || @@data.empty? || @@data[address['adc']].nil?
      @raw     = @@data[address['adc']][address['pin']]
      @volts   = @raw.to_i * 0.01464 #0.015357
      { 'name' => name, 'type' => 'volts', 'raw' => @raw, 'value' => @volts.round(2) }
    end
  end
end
