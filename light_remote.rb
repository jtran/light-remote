#!/usr/bin/env ruby
require 'rubygems'
require 'serialport'
require 'osc'

class LightRemote
  Host = '192.168.0.2'
  Port = 2222

  def initialize
    @sp = SerialPort.new("/dev/tty.usbserial-A600akVG", 19200)
    @osc = OSC::UDPSocket.new
  end

  def send_light(r, g, b)
    #puts "sending #{r}, #{g}, #{b}"
    d = 400.0
    r = r / d
    g = g / d
    b = b / d
    m = OSC::Message.new('/light/color/set', 'fff', r, g, b)
    @osc.send(m, 0, Host, Port)
  end

  def loop
    line = @sp.readline
    puts line
    vals = line.split(',')
    return if vals.nil? || vals.size != 3

    send_light(*vals.map(&:to_i))
  end

  def run
    loop while true
  end

end

LightRemote.new.run
