module Boattr
  class Sensors 
    class Arduino < Sensors
      attr_reader :i2c_address, :i2c_device
      attr_writer :data
      def initialize(params)
        @i2c_device  = ::Beaglebone::I2CDevice.new(params['dev'].to_sym)
        @i2c_address = params['address']   #0x20
      end
      def read()
        @bytes = 4
        begin
          @i2c_device.write(i2c_address, 0x00)
          @data        = @i2c_device.read(i2c_address, 4).unpack('C*').map { |e| e.to_s 10 }
          @i2c_device.disable
        rescue
          puts "i2c device at address #{i2c_address} not responding"
          return
        end
        return @data
      end
    end
  end
end
