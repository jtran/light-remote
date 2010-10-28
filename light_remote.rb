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

  # Sends RGB value in range [0, 1] to light.
  def send_light(r, g, b)
    #puts "sending #{r}, #{g}, #{b}"
    m = OSC::Message.new('/foo', 'fff', r, g, b)
    @osc.send(m, 0, @host, @port)
  end

  # Fades light linearly between two RGB values.
  def fade(r1, g1, b1, r2, g2, b2, steps=10)
    raise "steps must be greater than zero" unless steps > 0
    d_r = (r2 - r1) / steps
    d_g = (g2 - g1) / steps
    d_b = (b2 - b1) / steps
    steps.times do |s|
      r = r1 + d_r * s
      g = g1 + d_g * s
      b = b1 + d_b * s
      send_light(r, g, b)
      sleep(0.02)
    end
  end

  # Reads comma-separated triple from sensor.
  def read_triple
    line = @sp.readline
    puts line
    vals = line.split(',')
    return nil if vals.nil? || vals.size != 3
    vals.map(&:to_i)
  end

  # Loops forever sending sensor input to light.
  def run
    while true do
      triple = read_triple
      send_light(*triple.map {|v| v / 400.0 }) if triple
    end
  end

end
