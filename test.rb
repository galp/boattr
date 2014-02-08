#!/usr/bin/ruby

require 'time'
require 'json'
require './couch.rb'

server = Couch::Server.new("192.168.8.1", "5984")

# doc = {"_id": now , "type" : "current", "source": "solar", "data": {"raw" : raw, "amps" : amps} }
#puts json

epoch = Time.now.to_i
now   = Time.new
fromtime = now - (60*60*6)
puts "#{fromtime} #{now}"
puts "#{fromtime.to_i} #{now.to_i}"
view = "/sensors/_design/amps1/_view/amps1?startkey=\"#{fromtime.to_i}\"&endkey=\"#{now.to_i}\""
minutes=(now.to_i-fromtime.to_i)/60

res = server.get(view)
json = res.body
data = JSON.parse(json)
a=0
data['rows'].each do |item|
  a = item['value']+a
end
ampminutes=a/minutes
amphours=ampminutes/60

puts a,minutes,ampminutes, amphours


#amps = data['rows'].map { |rd| rows.new(rd['_id'], rd['amps']) }
