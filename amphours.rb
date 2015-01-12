require '/root/boattr/boattr.rb'
config = Boattr::Config.read('/root/boattr/config.yml')
active_sensors = Boattr::Config.sensors(config)



@week  = 720 # 1 week
@hours = 24
a = Boattr::Data.new(config)

@boat_amphours = a.amphours(active_sensors, @hours)
@balance       = a.amphour_balance(@boat_amphours)
@balance.concat(@boat_amphours)

d = Boattr::Dashing.new(config)
d.list_to_dashboard(@balance, 'amphours')
