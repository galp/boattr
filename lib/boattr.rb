#!/usr/bin/ruby
require 'json'
require 'time'
require 'yaml'
require 'couchrest'
require 'simple-graphite'
require 'socket'
require 'open-uri'
require 'httparty'
require 'nokogiri'
require 'beaglebone'

require File.dirname(__FILE__)+'/boattr/sensors/sensors.rb'
require File.dirname(__FILE__)+'/boattr/sensors/temp.rb'
require File.dirname(__FILE__)+'/boattr/sensors/voltage.rb'
require File.dirname(__FILE__)+'/boattr/sensors/current.rb'
require File.dirname(__FILE__)+'/boattr/data/data.rb'
require File.dirname(__FILE__)+'/boattr/dashing/dashing.rb'
require File.dirname(__FILE__)+'/boattr/config/config.rb'
require File.dirname(__FILE__)+'/boattr/control/control.rb'
require File.dirname(__FILE__)+'/boattr/control/stove.rb'
require File.dirname(__FILE__)+'/boattr/control/pump.rb'
