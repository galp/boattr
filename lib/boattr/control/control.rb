module Boattr
  class Control
    class Pump < Control
      attr_reader :name, :pin
      def initialize(name, pin)
        @name = name
        #@pin = ::GPIO::Relay.new(device: :BeagleboneBlack, pin: pin)
      end
      def on
        @pin.on
        puts "#{name} on"
      end
      def off
        @pin.off
        puts "#{name} off"
      end
    end
    def pump(name, params)
      if @stove_temp > 40 &&  bed_temp > 20
        puts "#{@name} on,  stove :#{@stove_temp}, cal : #{@cal_temp}"
        @pump.on 
      else
        p "#{@name} off,  stove :#{@stove_temp}, cal : #{@cal_temp}"
        @pump.off 
      end

  end
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
