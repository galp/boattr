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
hours = 720 # 1 week 
hours = 6
p Boattr::Data.new(brain01).amphours('solar',hours)
p Boattr::Data.new(brain01).amphours('ring',hours)
p Boattr::Data.new(brain01).amphours('fridge',hours)
p Boattr::Data.new(brain01).amphours('lights',hours)
