require 'serialport'

class LightRemote::SensorReader

  attr_accessor :serial_port

  def initialize(accelerometer_port)
    @serial_port = SerialPort.new(accelerometer_port, 19200)
  end

  # Reads comma-separated triple from accelerometer.
  def read_accelerometer
    line = @serial_port.readline
    puts line
    vals = line.split(',')
    return nil if vals.nil? || vals.size != 3
    vals.map(&:to_i)
  end

end
