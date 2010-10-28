#!/usr/bin/env ruby
require 'rubygems'
require 'serialport'
require 'osc'

class LightRemote

  attr_accessor :host, :port, :osc

  def initialize(host, port, use_serial=true)
    @host = host
    @port = port
    @sp = SerialPort.new("/dev/tty.usbserial-A600akVG", 19200) if use_serial
    @osc = OSC::UDPSocket.new
  end

  def send_light(r, g, b)
    #puts "sending #{r}, #{g}, #{b}"
    m = OSC::Message.new('/foo', 'fff', r, g, b)
    @osc.send(m, 0, @host, @port)
  end

  def read_triple
    line = @sp.readline
    puts line
    vals = line.split(',')
    return nil if vals.nil? || vals.size != 3
    vals.map(&:to_i)
  end

  def run
    while true do
      triple = read_triple
      send_light(*triple.map {|v| v / 400.0 }) if triple
    end
  end

end

l = LightRemote.new(ARGV[0] || '192.168.1.162', 2222, false)
p l

255.times do |r|
  l.send_light(r / 255.0, 0.5, 0.5)
  sleep(0.1)
end
