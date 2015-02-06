module Boattr
  class Control
    class Stove < Control
      def initialize(temp_sensors)
        @@temp_sensors = temp_sensors
        @stove_hot_threshold = 40
      end
      def stove_is_hot
        return unless @@temp_sensors['stove']
        stove_temp = @@temp_sensors.select() { |x| x['name'] == 'stove'  }
        if stove_temp > @stove_hot_threshold
          #stove is hot
          return true
        else
          return false
        end
      end
      def temperature_index
        sum = 0
        @@temp_sensors.each {|x| sum +=x['value'] }
        avg = sum/@@temp_sensors.length
      end
    end
  end
end
