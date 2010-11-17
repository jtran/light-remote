require 'light_remote'

# A DSL to make controlling Lights a little easier.
class LightRemote::Dsl

  def initialize(ips=[])
    @ctx = []
    @last_rgb_of_host = {}
    @last_host = nil
    ips = ips.is_a?(Array) ? ips : [ips]
    @ctx << ips.map {|ip| LightRemote::Light.new(ip) } if ! ips.empty?
  end

  def for_light(*ips)
    ips = ips.is_a?(Array) ? ips : [ips]
    @ctx << ips.map {|ip| LightRemote::Light.new(ip) }
    begin
      yield(self)
    ensure
      @ctx.pop
    end
    self
  end

  # Returns array of Lights.
  def current_lights
    @ctx.last
  end

  def set(r, g, b)
    current_lights.each do |l|
      l.send_light(r, g, b)
      @last_rgb_of_host[l.host] = [r, g, b]
      @last_host = l.host
    end
    self
  end

  # fade_to(0, 0, 0, :in => 5) fades to black over 5 seconds.
  def fade_to(r, g, b, options={})
    options = { :steps => 20 }.merge(options)
    seconds_per_step = 0.02
    steps = options[:in] ? options[:in] / seconds_per_step : options[:steps]
    steps = steps.to_i
    current_lights.each do |l|
      r0, g0, b0 = @last_rgb_of_host[l.host] || [0, 0, 0]
      l.fade(r0, g0, b0, r, g, b, steps)
      @last_rgb_of_host[l.host] = [r, g, b]
      @last_host = l.host
    end
    self
  end

  def last_rgb(host=nil)
    @last_rgb_of_host[host || @last_host]
  end

  def wait(duration_in_seconds)
    sleep(duration_in_seconds)
    self
  end

  def wait_until(time_or_hour, minute=nil)
    t = parse_time(time_or_hour, minute, true)
    wait(t - Time.now)
  end

  # Returns boolean whether the current time is between the two given times.
  def between_times(*args)
    t1 = nil
    t2 = nil
    if args.size == 2
      t1 = parse_time(args[0])
      t2 = parse_time(args[1])
    elsif args.size == 4
      t1 = parse_time(args[0], args[1])
      t2 = parse_time(args[2], args[3])
    elsif args.size == 3
      if args[0].is_a?(Time) || args[0].is_a?(String)
        t1 = parse_time(args[0])
        t2 = parse_time(args[1], args[2])
      else
        t1 = parse_time(args[0], args[1])
        t2 = parse_time(args[2])
      end
    else
      raise "between_time requires 2, 3, or 4 arguments, but you gave #{args.inspect}"
    end
    now = Time.now
    #puts "#{now.inspect} between #{t1.inspect} and #{t2.inspect} == #{t1 <= now && now < t2}"
    t1 <= now && now < t2
  end

  def before(*args)
    t = parse_time(*args)
    now = Time.now
    #puts "#{now.inspect} before #{t.inspect} == #{now < t}"
    now < t
  end

  def flame_until(*time_args)
    run_until_callback = lambda {|r,g,b| before(*time_args) }
    # TODO: change Flame module to use multiple lights.
    LightRemote::Flame.new(current_lights.first, run_until_callback).run(last_rgb)
    self
  end

  def fade_out
    fade_to(0, 0, 0)
  end

  def black
    set(0, 0, 0)
  end

  def white
    set(1, 1, 1)
  end

  private

  def parse_time(time_or_hour, minute=nil, adjust_to_future=false)
    if time_or_hour.is_a?(Time)
      time_or_hour
    elsif time_or_hour.is_a?(String) && minute.nil?
      # Time.parse(time_or_hour)  # only in Ruby 1.9
      h, m = time_or_hour.split(/:/)
      now = Time.now
      t = Time.local(now.year, now.month, now.day, h, m)
      !adjust_to_future || t >= now ? t : t + 60*60*24  # Add a day if it is before now.
    else
      # Time.parse(time_or_hour + ':' + minute)  # only in Ruby 1.9
      now = Time.now
      t = Time.local(now.year, now.month, now.day, time_or_hour, minute)
      !adjust_to_future || t >= now ? t : t + 60*60*24  # Add a day if it is before now.
    end
  end

end
