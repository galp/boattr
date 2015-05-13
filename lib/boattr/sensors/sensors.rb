
module Boattr
  class Sensors
    attr_accessor :data
    attr_reader :i2c_adc
    def initialize(enabled_adc)
      @@data = {}
      enabled_adc.each do |k,v|
        next if v['disabled']
        if v['type'] == 'arduino'
          @@data[k] = Boattr::Sensors::Arduino.new(v).read()
        end
      end
    end
  end
end

