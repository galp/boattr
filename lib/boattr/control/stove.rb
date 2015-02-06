module Boattr
  class Control
    class Stove < Control
      attr_reader :hot_threshold, :temp_sensors
      def initialize(temp_sensors)
        @temp_sensors  = temp_sensors
        @hot_threshold = 40
      end
      def is_hot
        @stove_temp = Hash[*temp_sensors.select() { |x| x['name'] == 'stove'  }]
        if @stove_temp['value'] > hot_threshold
          return true
        else
          return false
        end
      end
    end
  end
end
