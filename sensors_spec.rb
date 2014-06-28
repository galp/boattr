require "./sensors.rb"
describe Sensors do
  describe '#i2c' do
    it 'returns the values of the i2c sensors' do
      expect(Sensors.new.i2c('address'))
    end
  end
  describe '#1wire' do
    it 'returns the values of the 1wire sensors' do
      expect(Sensors.new.1wire('address'))
    end
  end
  
end
