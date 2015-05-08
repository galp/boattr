module Boattr
  class Sensors
    class Temp
      attr_reader :name, :address
      def initialize(name, address)
        @name     = name
        @address  = address
      end

      def read
        begin
          @file = File.open("/sys/bus/w1/devices/#{address}/w1_slave", 'r')
        rescue
          return
        end
        return unless @file.readline.include?('YES') # Is CRC valid in the first line?
        @temp = @file.readline.split[-1].split('=')[-1].to_i / 1000.0
        { 'name' => @name, 'type' => 'temp', 'address' => address,  'value' => @temp.round(2) }
      end
    end
  end
end
