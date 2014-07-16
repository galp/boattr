require './sensors.rb'
hostname = Socket.gethostname

brain02 = {
  'name'    => 'analog/i2c from brain2',
  'address' => 0x28,
  'i2cBus'  => '/dev/i2c-1',
  'couchdb' => 'localhost',

}
brain01 = {
  'description' => 'analog/i2c from brain01',
  'name'        => 'boat'
  'address'     => 0x28,
  'i2cBus'      => '/dev/i2c-1',
  'couchdb'     => 'localhost',
}

OneWireDevices = { 
  'beagle' => '10-0008029674ee', 'out' => '10-000802964c0d', 
  'cylinder' => '10-000802961f0d', 'stove' => '10-00080296978d', 
  'canal' => '28-000004ee99a8', 
}
OneWireSensors = { '10-0008029674ee' => 'in', '10-000802964c0d' => 'out', '10-000802961f0d' => 'cylinder', '10-00080296978d' => 'stove', '28-000004ee99a8' => 'canal' } 

p hostname


sensors=Boattr::Sensors.new(brain01)

brain01_sensors =
  [ sensors.current('solar',0),
    sensors.current('genny',1), 
    sensors.current('lights',2),
    sensors.current('pumps',3),
    sensors.current('ring',4),
    sensors.current('fridge',5),
    sensors.voltage('batteries',6),
    sensors.waterlevel('tank',7),
    sensors.temperature('out','10-000802964c0d'),
    sensors.temperature('in','10-0008029674ee'),
    sensors.temperature('cylinder','10-000802961f0d'),
    sensors.temperature('stove','10-00080296978d'),
    sensors.temperature('calan','28-000004ee99a8'),
]

Boattr::Data.new().to_db(brain01_sensors)
Boattr::Data.new().to_graphite(brain01_sensors)


