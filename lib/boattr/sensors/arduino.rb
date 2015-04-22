module Boattr
  class Sensors
    class Arduino
      attr_reader :i2c_address, :i2c_device, :data
      def initialize(params)
        @i2c_device  = ::Beaglebone::I2CDevice.new(:I2C2)
        @i2c_address = 0x20
        @@data = read()
        read()
      end
      def read()
        begin
          @i2c_device.write(i2c_address, 0x00)
          @data        = i2c_device.read(i2c_address, 4).unpack('C*').map { |e| e.to_s 10 }
          @i2c_device.disable
        rescue
          puts "i2c device at address #{i2c_address} not responding"
          return
        end
        p @data
      end
    end
  end
end
