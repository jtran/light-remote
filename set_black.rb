#!/usr/bin/env ruby
require 'rubygems'
require 'light_remote'

l = LightRemote.new(ARGV[0] || '192.168.1.162', false)
l.send_light(0, 0, 0)
