require '/root/boattr/boattr.rb'
hostname = Socket.gethostname
p hostname
config         = Boattr::Config.read('/root/boattr/config.yml')
enabled_sensors = Boattr::Config.enabled_sensors(config)
sensors        = Boattr::Sensors.new(config)
allowance      = Boattr::Data.new(config)

@current_sensor_data = []
@temp_sensor_data    = []
@sensor_data         = []
@voltage_sensor_data = []

enabled_sensors.each do |v|
  next unless v['type'] == 'temp'
  @temp_sensor_data <<  sensors.temperature(v['name'], v['address'])
end

enabled_sensors.each do |v|
  next unless v['type'] == 'current'
  @current_sensor_data  <<  sensors.current(v['name'], v['address'], model = v['model'], mode = v['mode'])
end

enabled_sensors.each do |v|
  next unless v['type'] == 'voltage'
  @voltage_sensor_data  <<  sensors.voltage(v['name'],v['address'])
end
               
@misc_sensor_data = [
  allowance.get_remaining_data('ee')
]

@sensor_data.concat(@current_sensor_data)
@sensor_data.concat(@temp_sensor_data)
@sensor_data.concat(@voltage_sensor_data)
@sensor_data.concat(@misc_sensor_data)

Boattr::Data.new(config).to_db(@sensor_data)
Boattr::Data.new(config).to_graphite(@sensor_data)

dash = Boattr::Dashing.new(config)
dash.list_to_dashboard(@current_sensor_data, 'amps')
dash.list_to_dashboard(@temp_sensor_data, 'temps')
dash.to_dashboard(@sensor_data)

@stove_temp = @temp_sensor_data[3]['value']
@cylinder_temp = @temp_sensor_data[2]['value']
Boattr::Control.new.pump('calorifier pump', @stove_temp, @cylinder_temp, 30, 40, 23)
