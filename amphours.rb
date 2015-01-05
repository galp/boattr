require '/root/boattr/boattr.rb'

brain01 = {
  'description' => 'analog/i2c from brain01',
  'basename'    => 'boat',
  'i2cAddress'  => 0x28,
  'i2cBus'      => '/dev/i2c-1',
  'couchdb'     => '192.168.8.1',
  'dashboard'   => '192.168.8.1',
  'graphite'    => '10.70.60.1',
  'dash_auth'   => 'YOUR_AUTH_TOKEN'
}
brain01 = Boattr::Config.read('/root/boattr/config.yml')
sensor_data = [{ 'name' => 'solar', 'type' => 'current', 'mode' => 'src' },
               { 'name' => 'lights', 'type' => 'current', 'mode' => 'load' },
               { 'name' => 'ring', 'type' => 'current', 'mode' => 'load' },
               { 'name' => 'out', 'address' => '10-000802964c0d', 'type' => 'temp' },
               { 'name' => 'in', 'address' => '10-0008029674ee', 'type' => 'temp' },
               { 'name' => 'stove', 'address' => '10-00080296978d', 'type' => 'temp' },
               { 'name' => 'cylinder', 'address' => '10-00080296978d', 'type' => 'temp' }
              ]

@week  = 720 # 1 week
@hours = 24
a = Boattr::Data.new(brain01)

@boat_amph = a.amphours(sensor_data, @hours)
@balance  = a.amphourBalance(@boat_amph)
@balance.concat(@boat_amph)
d = Boattr::Dashing.new(brain01)
d.list_to_dashboard(@balance, 'amphours')
