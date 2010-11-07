#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'light_remote'

l = LightRemote::Light.new(ARGV[0] || '192.168.1.162')
p l

l.send_light(0.66, 0.22, 0)
