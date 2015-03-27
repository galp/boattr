module Boattr
  class Control
    class Pump < Control
      attr_reader :name, :pin
      def initialize(name, pin)
        @name = name
        @pin  = pin.to_sym
        @pump  = ::Beaglebone::GPIOPin.new(@pin, :OUT, :PULLDOWN) 
      end
      def on
        @pump.digital_write(:LOW)
        puts "#{name} on"
      end
      def off
        @pump.digital_write(:HIGH)
        puts "#{name} off"
      end
    end
  end
end
