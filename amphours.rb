require './boattr.rb'

brain01 = {
  'description' => 'analog/i2c from brain01',
  'basename'    => 'boat',
  'i2cAddress'  => 0x28,
  'i2cBus'      => '/dev/i2c-1',
  'couchdb'     => '192.168.8.1',
  'dashboard'   => 'localhost',
  'graphite'   => '10.70.60.1',
}


current = [{"name"=>"solar", "type"=>"current", "mode"=>"src", "raw"=>513, "value"=>0.11},
           {"name"=>"lights", "type"=>"current", "mode"=>"load", "raw"=>512, "value"=>0.0},
           {"name"=>"ring", "type"=>"current", "mode"=>"load", "raw"=>508, "value"=>-0.26}]



#Boattr::Data.new(brain01).create_views('foo')
hours = 720 # 1 week 
hours = 24
amphours =  Boattr::Data.new(brain01).amphours(current,hours)
@loads,@sources = 0,0
amphours.each() do |x|
  if x['mode'] == "src" then
    @sources+= x['value']
  end
  if x['mode'] == "load" then
    @loads+= x['value']
  end
end
#p amphours
src = {"name" => "sources", "type" => "amphours", "hours" => @hours, "value" => @sources.round(2)}
load = {"name" => "loads", "type" => "amphours", "hours" => @hours, "value" => @loads.round(2)}
#amphours << src
#amphours << load
#Boattr::Data.new(brain01).new_to_dashboard([src,load],'amphours')
Boattr::Data.new(brain01).new_to_dashboard(amphours,'amphours')
