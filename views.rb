require File.dirname(__FILE__) + '/lib/' + 'boattr.rb'

config          = Boattr::Config.read(File.dirname(__FILE__) + '/' + 'config.yml')

@sensor_data = Boattr::Config.enabled_sensors
v = Boattr::Data.new(config)
v.create_views(@sensor_data, 'current')
v.create_views(@sensor_data, 'temp')
v.create_views(@sensor_data, 'voltage')
