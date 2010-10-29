#!/usr/bin/env ruby
require 'rubygems'
require 'light_remote'

l = LightRemote.new(ARGV[0] || '192.168.1.162', false)
p l

# This loop makes a smooth-fading fire.  (A bit too smooth.)
# TODO: Add some flicker.
cur = [0.5, 0.5, 0]
while true do
  # Mostly red with some green to move towards orange and yellow.
  r = 1
  g = 0.15 * rand

  # Amplitude factor (min 0.1, max 1) dims r and g keeping their relative proportions.
  f = 0.1 + 0.9 * rand
  nxt = [r * f, g * f, 0]

  # Vary the transition speed.  Very slow with an occasional flick.
  x = rand(10) + 1
  steps = x > 3 ? 10*x : x

  l.fade(*(cur + nxt + [steps]))
#  STDIN.readline   # uncomment this to pause each iteration.
  cur = nxt
end
