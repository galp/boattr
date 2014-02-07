#!/usr/bin/ruby

require 'time'

tempSensor = { 
  'beagle'   => '10-0008029674ee', 
  'out'      => '10-000802964c0d', 
  'cylinder' => '10-000802961f0d', 
  'stove'    => '10-00080296978d', 
  'canal'    => '28-000004ee99a8' 
}

def getTemp(sensor,address)
  puts sensor #, tempSensor[sensor]
end

def getAmps(sensor)
  raw = rand(10.0)
  raw = 1.5
end
minutes=0
ampMin=0.0
total=0
while true do 
  raw=getAmps('solar')
  #puts raw
  sleep 1
  minutes+=1
  total+=raw
  puts "#{total},in #{minutes} minutes"
  ampMin=total/minutes
  puts "Am :#{ampMin}"
  ampHours = ampMin/60
  puts ampHours
  #getTemp('beagle')
end




