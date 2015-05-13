module Boattr
  class Current < Sensors
    attr_reader :name, :address, :divider
    @@supported_models = { 'acs714' => 0.066, 'acs709' => 0.028, 'acs712-20' => 0.100, 'acs712-05' => 0.185, 'acs712-30' => 0.066 }
    def initialize(name, address, model = 'acs714', mode = 'both')
      @name     = name
      @address  = address
      @divider  = @@supported_models[model]
      @mode     = mode
    end

    def read
      return if @@data.nil? || @@data.empty? || @@data[address['adc']].nil?
      @raw     = @@data[address['adc']][address['pin']]
      @volts   = (@raw.to_i * 0.004887)
      # a load should only be negative and  a source should be positive
      @volts   = 2.5 if @mode == 'src' && @volts < 2.5 || @mode == 'load' && @volts > 2.5 #HACK
      @amps    = (@volts - 2.5) / divider
      { 'name' => @name, 'type' => 'current', 'mode' => @mode, 'raw' => @raw, 'value' => @amps.round(2) }
    end
  end
end
