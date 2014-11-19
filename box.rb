require '/root/boatmon/boattr.rb'
hostname = Socket.gethostname

brain02 = {
  'description' => 'analog/i2c from brain2',
  'basename'    => 'mmcamp',
  'i2cAddress'  => 0x28,
  'i2cBus'      => '/dev/i2c-1',
  'couchdb'     => 'localhost',
  'dashboard'   => 'localhost',
  'graphite'    => '10.70.60.1',

}

p hostname


sensors=Boattr::Sensors.new(brain02)

brain02_sensors =
  [ sensors.current('solar',0),
    sensors.voltage('batteries',1),
    sensors.temperature('box','10-0008029675f2'),
    sensors.temperature('outside','28-000005661bfa'),
]


Boattr::Data.new(brain02).to_db(brain02_sensors)
#Boattr::Data.new(brain02).to_graphite(brain02_sensors)
#Boattr::Data.new(brain02).create_views('foo')
#data =  Boattr::Data.new(brain02).amphours('solar',1)
#p data
