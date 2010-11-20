#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'light_remote'

class HomeScene
  def run
    LightRemote::Dsl.new.for_light('192.168.1.162') do |dsl|
      dsl.black

      while true do
        now = Time.now
        wday = now.wday
        # Weekend cutoff is 5pm Friday to 5pm Sunday.
        if wday == 6 || wday == 0 && now.hour < 17 || wday == 5 && now.hour >= 17
          weekend(dsl)
        else
          weekday(dsl)
        end
      end

    end
  end

  def weekday(dsl)
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
      dsl.flame_until('23:00')
    else
      puts 'off at night'
      t = Time.now + 60*60*24
      dsl.fade_out.wait_until(Time.local(t.year, t.month, t.day))
    end
  end

  def weekend(dsl)
    if dsl.between_times('0:00', '1:00')
      puts "flame until 1:00"
      dsl.flame_until('1:00')
    elsif dsl.before('10:00')
      puts 'off at night'
      dsl.fade_out.wait_until('10:00')
    elsif dsl.before('12:00')
      puts 'wake up'
      dsl.fade_to(0, 0.667, 1)  # sky blue
      dsl.wait_until('12:00')
    elsif dsl.before('16:30')
      puts 'off in day'
      dsl.fade_out.wait_until('16:30')
    elsif dsl.before('21:00')
      puts 'white'
      dsl.fade_to(1, 0.6, 0.082)  # white light, a little soft
      dsl.wait_until('21:00')
    else
      puts 'flame at night'
      t = Time.now + 60*60*24
      dsl.flame_until(Time.local(t.year, t.month, t.day))
    end
  end

end

HomeScene.new.run
