require './boattr.rb'


@sensor_data = Boattr::Config.sensors
v = Boattr::Data.new(@config)

p @sensor_data
v.create_views(@sensor_data,'current')
v.create_views(@sensor_data,'temp')
v.create_views(@sensor_data,'voltage')
