module Boattr
  class Max127
    attr_reader :iaddress, :i2c_device, :data
    def initialize(_params)
      @i2c_device = ::Beaglebone::I2CDevice.new(:I2C2)
      @@data = read(@i2c_adc)
      @channel = 0
      read(@channel)
    end

    def read(channel)
      @data   = i2c_device.read(v['address'], channel, 2)
      p @data
    end

    def write
      @i2c_device.write(v['address'], 0x88)
    end
  end
end
