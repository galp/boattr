module Boattr
  class Control
    def stove_is_hot(stove_temp)
      return unless stove_temp
      if stove_temp > 40
        #stove is hot
        return true
      else
        return false
      end
    end
    def temperature_index(temp_sensors)
      sum = 0
      temp_sensors.each {|x| sum +=x }
      avg = sum/temp_sensors.length
    end
  end
end
