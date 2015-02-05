#!/usr/bin/ruby
require 'json'
require 'time'
require 'yaml'
require 'i2c'
require 'gpio'
require 'couchrest'
require 'simple-graphite'
require 'socket'
require 'open-uri'
require 'httparty'
require 'nokogiri'


require './lib/boattr/sensors/sensors.rb'
require './lib/boattr/data/data.rb'
require './lib/boattr/dashing/dashing.rb'
require './lib/boattr/config/config.rb'
require './lib/boattr/control/control.rb'
