module Boattr
  class Sensors
    attr_reader :i2c_adc_address, :i2c_device, :data, :basename
    def initialize(params)
      @i2c_adc  = params['i2c']['i2cAdc']
      @@data    = read_i2c_adc(@i2c_adc)
      @i2c_device = ::Beaglebone::I2CDevice.new(@dev)
    end

    def read_i2c_adc(address)
      @data     = {}
      @iterate  = 16
      address.each do |k, v|
        next if v['disabled']
        @dev         = v['dev'].to_sym
        @adc_data    = []
        @data_set    = Array.new(10) { Array.new }
        @adc_samples = []
        @iterate.times do # we take @iterate samples
          # read 20 bytes from slave, convert to decimals, and finaly in 10bit values.
          begin
            @i2c_device.write(v['address'], 0x00)
            @adc        = i2c_device.read(v['address'], 0x14, 0x00).unpack('C*').map { |e| e.to_s 10 }
            @i2c_device.disable
          rescue
            puts "i2c device #{k} at address #{v['address']} not responding"
            return
          end
          sleep(0.1)
          # slice the 20 byte array into pairs (MSB,LSB) and convert decimal.
          @adc.each_slice(2) { |a| @adc_samples << a[0].to_i * 256 + a[1].to_i }
          @data_set.each_with_index { |d, i| d << @adc_samples[i] }
          @adc_samples = []
        end
        # take the average (array.inject(:+) ? )
        @data_set.each_with_index do |d, _i|
          # sort and remove max and min
          d = d.sort
          d.pop(2)
          d.shift(2)
          @adc_data << d.inject { |sum, x| sum + x } / (@iterate - 4)
          @data[k] = @adc_data
        end
      end
      p @data
    end

    def constrain(x, min, max)
      x = min if x < min
      x = max if x > max
    end
  end
end
