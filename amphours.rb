require './sensors.rb'

brain01 = {
  'description' => 'analog/i2c from brain01',
  'basename'    => 'boat',
  'i2cAddress'  => 0x28,
  'i2cBus'      => '/dev/i2c-1',
  'couchdb'     => 'localhost',
  'dashboard'   => 'localhost',
  'graphite'   => '10.70.60.1',
}




#Boattr::Data.new(brain01).create_views('foo')

p Boattr::Data.new(brain01).amphours('solar',168)
p Boattr::Data.new(brain01).amphours('ring',168)
p Boattr::Data.new(brain01).amphours('fridge',168)
p Boattr::Data.new(brain01).amphours('lights',168)
