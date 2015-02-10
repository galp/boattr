module Boattr
  class Control
    class Stove < Control
      attr_reader :hot_threshold, :temp_sensors
      def initialize(temp_sensors)
        @temp_sensors  = temp_sensors
        @hot_threshold = 40
      end
      def is_hot
        @stove_temp = nil
        temp_sensors.each() do  |x|
          next if x.nil?
          @stove_temp = x['value'] if x['name'] == 'stove'
        end
        if @stove_temp > hot_threshold
          return true
        else
          return false
        end
      end
    end
  end
end
