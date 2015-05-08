require '/home/ag/dev/boatmon/boattr.rb'
hostname = Socket.gethostname
puts hostname

brain01 = {
  'description' => 'analog/i2c from brain01',
  'basename'    => 'boat',
  'i2cAddress'  => 0x28,
  'i2cBus'      => '/dev/i2c-1',
  'couchdb'     => 'localhost',
  'dashboard'   => 'localhost',
  'graphite'    => '10.70.60.1'
}

sensors = Boattr::Sensors.new(brain01)

# p sensors.read()
brain01_sensors =
  [sensors.current('solar', 0),
   sensors.current('genny', 1),
   sensors.current('lights', 2),
   # sensors.current('pumps',3),
   sensors.current('ring', 4),
   sensors.current('fridge', 5),
   sensors.voltage('batteries', 6),
   # sensors.waterlevel('tank',7),
   sensors.temperature('out', '10-000802964c0d'),
   sensors.temperature('in', '10-0008029674ee'),
   sensors.temperature('cylinder', '10-000802961f0d'),
   sensors.temperature('stove', '10-00080296978d'),
   sensors.temperature('canal', '28-000004ee99a8')
  ]

# Boattr::Data.new(brain01).to_db(brain01_sensors)
# Boattr::Data.new(brain01).to_graphite(brain01_sensors)
# Boattr::Data.new(brain01).to_dashboard([sensors.voltage('batteries',6), sensors.temperature('in','10-0008029674ee'), sensors.temperature('out','10-000802964c0d')])

# Boattr::Data.new(brain01).to_dashboard(brain01_sensors)
dataAllowance = Boattr::Data.new(brain01).getRemainingData
Boattr::Data.new(brain01).to_dashboard(dataAllowance)
