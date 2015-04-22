#!/usr/bin/ruby
require 'daemons'

options = {
  log_output: true,
  backtrace: false,
  output_logfilename: 'boattr.log',
  monitor: true,
  dir_mode: :script,
  dir: 'run'
}
Daemons.run('boattr_server.rb', options)
