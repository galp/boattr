require 'rubygems'
require 'nokogiri' 
require 'open-uri'
   
#page = Nokogiri::HTML(open("http://en.wikipedia.org/"))   
page = Nokogiri::HTML(open("status")) 


data =  page.css('span')[0].text
unit = data.slice(-2..-1)


if unit == 'GB'
  bytes = data.slice(0..-3).to_f*1024
else
  bytes = data.slice(0..-3).to_f
end

puts "#{bytes},#{unit}"
