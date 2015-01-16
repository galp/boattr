require File.dirname(__FILE__)+'/'+'boattr.rb'

config = Boattr::Config.read(File.dirname(__FILE__)+'/config.yml')
enabled_sensors = Boattr::Config.enabled_sensors(config)



@week  = 720 # 1 week
@hours = 24
a = Boattr::Data.new(config)

@boat_amphours = a.amphours(enabled_sensors, @hours)
@balance       = a.amphour_balance(@boat_amphours)
@balance.concat(@boat_amphours)

d = Boattr::Dashing.new(config)
d.list_to_dashboard(@balance, 'amphours')
