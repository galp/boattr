require File.dirname(__FILE__)+'/lib/'+'boattr.rb'
hostname = Socket.gethostname
p hostname
config         = Boattr::Config.read(File.dirname(__FILE__)+'/'+'config.yml')
enabled_sensors = Boattr::Config.enabled_sensors(config)
sensors        = Boattr::Sensors.new(config)
allowance      = Boattr::Data.new(config)

@current_sensor_data = []
@temp_sensor_data    = []
@sensor_data         = []
@voltage_sensor_data = []

enabled_sensors.each do |v|
  next unless v['type'] == 'temp'
  @temp_sensor_data <<  Boattr::Sensors::Temp.new(v['name'], v['address']).read
end

enabled_sensors.each do |v|
  next unless v['type'] == 'current'
  @current_sensor_data  <<  Boattr::Current.new(v['name'], v['address'], model = v['model'], mode = v['mode']).read
end

enabled_sensors.each do |v|
  next unless v['type'] == 'voltage'
  @voltage_sensor_data  <<  Boattr::Voltage.new(v['name'], v['address']).read
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


pump  = Boattr::Control::Pump.new('calorifier pump', '30')
stove = Boattr::Control::Stove.new(@temp_sensor_data)
control = Boattr::Control.new
temp_index = control.temp_index(@temp_sensor_data)


puts "temp index : #{temp_index} stove hot : #{stove.is_hot}"

pump.on if temp_index > 19 && stove.is_hot
pump.off if temp_index < 19   
pump.off unless stove.is_hot


