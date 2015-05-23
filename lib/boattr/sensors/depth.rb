module Boattr
  class Depth < Sensors
    attr_reader :name, :address, :offset
    def initialize(name, address)
      @name     = name
      @address  = address
      @offset   = 50
    end

    def read
      return if @@data.nil? || @@data.empty? || @@data[address['adc']].nil?
      @raw     = @@data[address['adc']][address['pin']]
      @depth  = (@raw.to_i-@offset) * 0.95
      @depth  = 0 if @depth < 0
      { 'name' => name, 'type' => 'depth', 'raw' => @raw, 'value' => @depth.round(2) }
    end
  end
end
