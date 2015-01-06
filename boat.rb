require '/root/boattr/boattr.rb'
hostname = Socket.gethostname
p hostname

config = Boattr::Config.read('/root/boattr/config.yml')

sensors=Boattr::Sensors.new(config)
allowance = Boattr::Data.new(config)

@current_sensor_data = []
@temp_sensor_data    = []
@sensor_data         = []


config['sensors']['temp'].each() do |k,v|
  @temp_sensor_data <<  sensors.temperature(k,v['address'])
end
config['sensors']['current'].each() do |k,v|
  @current_sensor_data  <<  sensors.current(k,v['address'],model=v['model'],type=v['type'])
end

@misc_sensor_data = [ 
  sensors.voltage('batteries',6),
  allowance.get_remaining_data('ee') ,
]

@sensor_data.concat(@current_sensor_data)
@sensor_data.concat(@temp_sensor_data)
@sensor_data.concat(@misc_sensor_data)

Boattr::Data.new(config).to_db(@sensor_data)
Boattr::Data.new(config).to_graphite(@sensor_data)

dash = Boattr::Dashing.new(config)
dash.list_to_dashboard(@current_sensor_data,'amps')
dash.list_to_dashboard(@temp_sensor_data,'temps')
dash.to_dashboard(@sensor_data)

@stove_temp = @temp_sensor_data[3]['value']
@cylinder_temp = @temp_sensor_data[2]['value']
Boattr::Control.new().pump('calorifier pump', @stove_temp, @cylinder_temp, 30, 40, 22)





