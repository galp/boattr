require './boattr.rb'

config = Boattr::Config.read('/root/boattr/config.yml')

v = Boattr::Data.new(config)
@sensor_data = []
config['sensors'].each() { |k,v| v.each() { |x| @sensor_data << x[1].merge!({'type' => k, 'name' => x[0] }) }}



v.create_views(@sensor_data,'current')

v.create_views(@sensor_data,'temp')
v.create_views(@sensor_data,'voltage')
