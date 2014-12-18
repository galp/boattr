require '/root/boatmon/boattr.rb'

brain01 = {
  'description' => 'analog/i2c from brain01',
  'basename'    => 'boat',
  'i2cAddress'  => 0x28,
  'i2cBus'      => '/dev/i2c-1',
  'couchdb'     => '192.168.8.1',
  'dashboard'   => '192.168.8.1',
  'graphite'    => '10.70.60.1',
  'dash_auth'   => 'YOUR_AUTH_TOKEN',
}

sensor_data = [{"name"=>"solar", "type"=>"current", "mode"=>"src", "raw"=>513, "value"=>0.11},
               {"name"=>"lights", "type"=>"current", "mode"=>"load", "raw"=>512, "value"=>0.0},
               {"name"=>"ring", "type"=>"current", "mode"=>"load", "raw"=>508, "value"=>-0.26},
               {"name"=>"out", "address"=>"10-000802964c0d", "type"=>"temp", "value"=>2.31},
               {"name"=>"in", "address"=>"10-0008029674ee", "type"=>"temp", "value"=>16.81},
               {"name"=>"stove", "address"=>"10-00080296978d", "type"=>"temp", "value"=>46.31},
               {"name"=>"cylinder", "address"=>"10-00080296978d", "type"=>"temp", "value"=>46.31},
              ]

@week  = 720 # 1 week 
@hours = 24
a = Boattr::Data.new(brain01)

@boat_amph = a.amphours(sensor_data,@hours)
@balance  = a.amphourBalance(@boat_amph)
@balance.concat(@boat_amph)

a.new_to_dashboard(@balance,'amphours')


