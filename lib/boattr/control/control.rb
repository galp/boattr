module Boattr
  class Control
    def temp_index(temp_sensors)
      sum = 0
      temp_sensors.each do |x|
        next if x.nil?
        sum +=x['value']
      end
      avg = sum/temp_sensors.length
    end
  end
end

