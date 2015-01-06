require '/root/boattr/boattr.rb'
config = Boattr::Config.read('/root/boattr/config.yml')

current_sensors = config['sensors']['current']
@week  = 720 # 1 week
@hours = 24
a = Boattr::Data.new(config)

@boat_amphours = a.amphours(current_sensor, @hours)
@balance       = a.amphour_balance(@boat_amphours)
@balance.concat(@boat_amphours)
d = Boattr::Dashing.new(config)
d.list_to_dashboard(@balance, 'amphours')
