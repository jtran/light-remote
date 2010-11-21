#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'light_remote'

class SceneHome
  attr_accessor :state

  STATES = [:off, :wake, :flame]

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
        [lambda { 21 <= @dsl.time.hour }, :flame],
      ]
    when :wake
      [ [lambda { @dsl.time.weekend? && 12 <= @dsl.time.hour }, :off],
        [lambda { @dsl.time.weekday? && 9 <= @dsl.time.hour }, :off],
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
      # Try to transition to new state based on any triggers.
      new_state = @state
      triggers_for_state.each do |trigger_fn, transition_to_state|
        next unless trigger_fn.call
        new_state = if transition_to_state.is_a?(Proc)
                      transition_to_state.call(self)
                    else
                      transition_to_state
                    end
        break
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

end

SceneHome.new.run
