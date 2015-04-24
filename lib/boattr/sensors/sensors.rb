
module Boattr
  class Sensors
    attr_reader :i2c_adc, 
    def initialize(params)
      @i2c_adc  = params['i2c']['i2cAdc']
    end
  end
end
