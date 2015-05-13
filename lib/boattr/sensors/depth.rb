module Boattr
  class Depth < Sensors
    attr_reader :name, :address
    def initialize(name, address)
      @name     = name
      @address  = address
    end

    def read
      return if @@data.nil? || @@data.empty? || @@data[address['adc']].nil?
      @raw     = @@data[address['adc']][address['pin']]
      @depth  = (@raw.to_i-50) * 0.95 
      { 'name' => name, 'type' => 'depth', 'raw' => @raw, 'value' => @depth.round(2) }
    end
  end
end
