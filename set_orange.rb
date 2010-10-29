#!/usr/bin/env ruby
require 'rubygems'
require 'light_remote'

l = LightRemote.new(ARGV[0] || '192.168.1.162', false)
p l

l.send_light(0.66, 0.22, 0)
