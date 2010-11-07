#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'light_remote'

LightRemote::Dsl.new.for_light('192.168.1.162') do |dsl|
  dsl.black

  while true do
    if dsl.between_times('0:00', '6:45')
      puts 'off in morning'
      dsl.fade_out.wait_until('6:45')
    elsif dsl.before('9:00')
      puts 'wake up'
      dsl.fade_to(0, 0.667, 1)  # sky blue
      dsl.wait_until('9:00')
    elsif dsl.before('18:00')
      puts 'off in day'
      dsl.fade_out.wait_until('18:00')
    elsif dsl.before('21:00')
      puts 'white'
      dsl.fade_to(1, 0.6, 0.082)  # white light, a little soft
      dsl.wait_until('21:00')
    elsif dsl.before('23:00')
      puts 'flame'
      run_until_callback = lambda {|r,g,b| dsl.before('23:00') }
      # TODO: change Flame module to use multiple lights.
      LightRemote::Flame.new(dsl.current_lights.first, run_until_callback).run(dsl.last_rgb)
    else
      puts 'off at night'
      dsl.fade_out.wait_until('0:00')
    end
  end

end
