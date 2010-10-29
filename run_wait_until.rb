#!/usr/bin/env ruby

if ARGV.size < 2
  puts "Usage: run_wait_until <hour-in-24-format> <minute>"
  exit
end

Hour = ARGV[0].to_i
Min  = ARGV[1].to_i

while true do
  t = Time.now
  break if t.hour == Hour && t.min == Min
  sleep(30)
end
