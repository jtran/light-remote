#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'light_remote'
require 'sinatra'

class SceneHome
  attr_accessor :state

  STATES = [:off, :wake, :white, :flame]

  def initialize
    @state = :init
    @dsl = LightRemote::Dsl.new('192.168.1.162')
  end

  def run
    run_state
    updater
  end

  def run_state
    puts @state
    case @state
    when :init
      @dsl.black
    when :off
      @dsl.fade_out
    when :wake
      @dsl.fade_to(0, 0.667, 1, :in => 60 * 15)  # sky blue, in 15 minutes
    when :white
      @dsl.fade_to(1, 0.6, 0.082)  # white light, a little soft
    when :flame
      @dsl.flame
    end
  end

  def triggers_for_state(state=@state)
    case state
    when :init
      STATES.map {|s| triggers_for_state(s) }.inject([]) {|all, ts| all.concat(ts) }
    when :off
      [ [lambda { @dsl.time.weekend? && 10 == @dsl.time.hour }, :wake],
        [lambda { @dsl.time.weekday? && 6 == @dsl.time.hour && 15 <= @dsl.time.min }, :wake],
        [lambda { 4 <= @dsl.time.hour }, :white],
      ]
    when :wake
      [ [lambda { @dsl.time.weekend? && 12 <= @dsl.time.hour }, :off],
        [lambda { @dsl.time.weekday? && 9 <= @dsl.time.hour }, :off],
      ]
    when :white
      [ [lambda { 21 <= @dsl.time.hour }, :flame],
        [lambda { @dsl.time.weekend? && @dsl.time.hour < 1 }, :flame],
      ]
    when :flame
      [ [lambda { @dsl.time.weekend? && 1 <= @dsl.time.hour && @dsl.time.hour < 10 }, :off],
        [lambda { @dsl.time.weekday? && 23 <= @dsl.time.hour }, :off],
      ]
    else
      []
    end
  end

  def updater
    while true
      new_state = @state

      if @queued_state
        # A new state was set by the user.
        new_state = @queued_state
        @queued_state = nil
      else
        # Try to transition to new state based on any triggers.
        triggers_for_state.each do |trigger_fn, transition_to_state|
          next unless trigger_fn.call
          new_state = if transition_to_state.is_a?(Proc)
                        transition_to_state.call(self)
                      else
                        transition_to_state
                      end
          break
        end
      end

      # Switch states.
      if @state != new_state
        Thread.kill(@last_thread) if @last_thread
        @state = new_state
        # Trigger in a new thread so that long-running operations do not affect updating state.
        @last_thread = Thread.start { run_state }
      end

      # Sleep for a little.
      sleep(30)
    end
  end

  def queue_state(state)
    # Convert keywords to string rather than the other way around to prevent memory leak.
    return nil unless STATES.map(&:to_s).include?(state.to_s)

    @queued_state = state.to_sym
  end

end

scene = SceneHome.new
scene_thread = nil

get '/' do
  buttons = SceneHome::STATES.map {|s|
    str = s.to_s
    %Q[<div style="text-align: center"><input type="submit" name="state" value="#{str}"#{' disabled="disabled"' if scene.state == s} /></div>\n]
  }
  <<-HTML
<html>
<head>
<title>Scene Home</title>
<style type="text/css">
html {font-family: sans-serif;}
input {font-size: xx-large; text-transform: capitalize; padding: 1.5em; margin: 0.5em; min-width: 10em;}
</style>
</head>
<body>
  <form action="/state" method="post">
#{buttons}
  </form>
</body>
</html>
  HTML
end

get '/state' do
  scene.state.to_s
end

post '/state' do
  scene.queue_state(params[:state])
  # Scene might be sleeping, so wake it up to switch states immediately.
  scene_thread.run
  redirect '/'
end

scene_thread = Thread.start { scene.run }
