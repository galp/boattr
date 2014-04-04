#!/usr/bin/ruby
require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'simple-graphite'
#require './couch.rb'

#server = Couch::Server.new("192.168.8.1", "5984")

g = Graphite.new
g.host = '10.70.60.1'
g.port = 2003

page = Nokogiri::HTML(open("http://add-on.ee.co.uk/status")) 
#page = Nokogiri::HTML(open("status")) 

data =  page.css('span')[0].text
unit = data.slice(-2..-1)


if unit == 'GB'
  bytes = data.slice(0..-3).to_f*1024
else
  bytes = data.slice(0..-3).to_f
end

puts "#{bytes},#{unit}"

g.push_to_graphite do |graphite|
  graphite.puts "boat.bw #{bytes} #{g.time_now}"
end
