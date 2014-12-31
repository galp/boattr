require '/root/boattr/boattr.rb'
hostname = Socket.gethostname
p hostname

brain01 = Boattr::Config.read('/root/boattr/config.yml')

sensors=Boattr::Sensors.new(brain01)
dataAllowance = Boattr::Data.new(brain01).get_remaining_data('ee') 

@current_sensors = [ 
                   sensors.current('solar',0,model='acs714',type='src'), 
                   sensors.current('genny',1,model='acs709',type='src'), 
                   sensors.current('lights',2,model='acs714',type='load'),
                   #sensors.current('pumps',3),
                   sensors.current('ring',4,model='acs714',type='load'),
                   sensors.current('fridge',5,model='acs714',type='load'),
                  ]
@cylinder_temp = sensors.temperature('cylinder','10-000802961f0d')
@stove_temp    = sensors.temperature('stove','10-00080296978d')

@temp_sensors = [ sensors.temperature('in','10-0008029674ee'),
                  sensors.temperature('out','10-000802964c0d'),
                  @cylinder_temp,
                  @stove_temp,
                  sensors.temperature('canal','28-000004ee99a8'), 
                  sensors.temperature('bath','28-000005661bfa'), 
                  #sensors.temperature('one','28-0000056b2c1a'), 
                  #sensors.temperature('two','28-000005657712'), 
                  sensors.temperature('bed','28-00000566f3b8'), 
                ]

@brain01_sensors = [ 
                   sensors.voltage('batteries',6),
                   #sensors.waterlevel('tank',7),
                   dataAllowance,
]

@brain01_sensors.concat(@current_sensors)
@brain01_sensors.concat(@temp_sensors)

Boattr::Data.new(brain01).to_db(@brain01_sensors)
Boattr::Data.new(brain01).to_graphite(@brain01_sensors)

@hours = 24


@boat_amph = Boattr::Data.new(brain01).amphours(@brain01_sensors,@hours)
@balance   = Boattr::Data.new(brain01).amphourBalance(@boat_amph)
@balance.concat(@boat_amph)



dash = Boattr::Dashing.new(brain01)
dash.list_to_dashboard(@current_sensors,'amps')
dash.list_to_dashboard(@temp_sensors,'temps')
dash.to_dashboard(@brain01_sensors)

Boattr::Control.new().pump('calorifier pump',@stove_temp['value'],@cylinder_temp['value'],30,40,22)



