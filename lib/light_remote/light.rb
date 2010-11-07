require 'osc'

class LightRemote::Light

  attr_accessor :host, :port, :osc

  def initialize(host, options={})
    options = { :port => 2222 }.merge(options)
    @host = host
    @port = options[:port]
    @osc = OSC::UDPSocket.new
  end

  # Sends RGB value in range [0, 1] to light.
  def send_light(r, g, b)
    #puts "sending #{r}, #{g}, #{b}"
    m = OSC::Message.new('/light/color/set', 'fff', r, g, b)
    @osc.send(m, 0, @host, @port)
  end

  # Fades light linearly between two RGB values.
  def fade(r1, g1, b1, r2, g2, b2, steps=10)
    raise "steps must be greater than zero" unless steps > 0
    d_r = (r2 - r1).to_f / steps
    d_g = (g2 - g1).to_f / steps
    d_b = (b2 - b1).to_f / steps
    (steps - 1).times do |s|
      r = r1 + d_r * s
      g = g1 + d_g * s
      b = b1 + d_b * s
      send_light(r, g, b)
      sleep(0.02)
    end
    # Do last step separately so that rounding errors don't prevent us from
    # ending on the correct RGB.
    send_light(r2, g2, b2)
    sleep(0.02)
  end

end
