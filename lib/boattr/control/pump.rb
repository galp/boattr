module Boattr
  class Control
    class Pump < Control
      attr_reader :name, :pin
      def initialize(name, pin)
        @name = name
        @pin  = ::GPIO::Relay.new(device: :BeagleboneBlack, pin: pin)
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
  end
end
