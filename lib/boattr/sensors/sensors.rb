module Boattr
  class Sensors
    attr_reader :i2c_adc_address, :i2c_device, :data, :basename, :onewire_devices
    def initialize(params)
      @basename        = params['boattr']['basename']
      @i2c_adc         = params['i2c']['i2cAdc']
      @i2c_device      = ::I2C.create(params['i2c']['i2cBus'])
      read_i2c_adc(@i2c_adc)
      read_onewire_bus
    end

    def read_i2c_adc(address)
      @data     = {}
      @iterate  = 16
      address.each do |k,v|
        next if v['disabled'] 
        @adc_data    = []
        @data_set    = Array.new(10) { Array.new }
        @adc_samples = []
        @iterate.times do # we take @iterate samples
          # read 20 bytes from slave, convert to decimals, and finaly in 10bit values.
          begin
            @adc = i2c_device.read(v['address'], 0x14, 0x00).unpack('C*').map { |e| e.to_s 10 }
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

    def read_onewire_bus
      @basedir  = '/sys/bus/w1/devices/'
      Dir.chdir(@basedir)
      @onewire_devices = Dir['*-*']
    end

    def pressure(name, address)
      return if data.empty?
      @name    = name
      @raw     = data[address['adc']][address['pin']]
      @volts = @raw * 0.015357
      { 'name' => @name, 'type' => 'pressure', 'raw' => @raw, 'value' => @volts.round(2) }
    end
    def constrain(x,min,max)
      x = min if x < min
      x = max if x > max
    end
    def voltage(name, address)
      return if data.empty?
      @name    = name
      @raw     = data[address['adc']][address['pin']]
      @volts = @raw * 0.015357
      { 'name' => @name, 'type' => 'volts', 'raw' => @raw, 'value' => @volts.round(2) }
    end

    def current(name, address, model = 'acs714', mode = 'both')
      return if data.empty?
      @supported_models = { 'acs714' => 0.066, 'acs709' => 0.028, 'acs712' => 0.185 }
      @name    = name
      @mode    = mode
      @divider = @supported_models[model]
      @raw     = data[address['adc']][address['pin']]
      @volts   = (@raw * 0.004887)
      # a load should only be negative and  a source should be possitive
      @volts   = 2.5 if @mode == 'src' && @volts < 2.5 || @mode == 'load' && @volts > 2.5
      @amps    = (@volts - 2.5) / @divider
      { 'name' => @name, 'type' => 'current', 'mode' => @mode, 'raw' => @raw, 'value' => @amps.round(2) }
    end

    def temperature(name, address)
      @name     = name
      @address  = address
      @basedir  = '/sys/bus/w1/devices/'
      return unless onewire_devices.include?(@address)
      @file = File.open("#{@basedir}/#{address}/w1_slave", 'r')
      return unless @file.readline.include?('YES') # Is CRC valid in the first line?
      @temp = @file.readline.split[-1].split('=')[-1].to_i / 1000.0
      { 'name' => @name, 'type' => 'temp', 'address' => @address,  'value' => @temp.round(2) }
    end
  end
end
