require '/root/boattr/boattr.rb'
config = Boattr::Config.read('/root/boattr/config.yml')
current_sensors = []
conf = config['sensors']['current']
p conf
conf.each do |k, v|
  current_sensors  <<  { 'name' => k, 'address' => v['address'], 'type' => 'current', 'mode' => v['mode'] }
end
p current_sensors
@week  = 720 # 1 week
@hours = 24
a = Boattr::Data.new(config)

@boat_amphours = a.amphours(current_sensors, @hours)
p @boat_amphours
@balance       = a.amphour_balance(@boat_amphours)
@balance.concat(@boat_amphours)
d = Boattr::Dashing.new(config)
d.list_to_dashboard(@balance, 'amphours')
