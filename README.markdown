Controls lights made by [saikoLED](http://saikoled.com/) which have an 802.11b WiFi card. These
lights run using an Arduino Uno and use all [open source
software](http://github.com/saikoLED/saiko5) and open standards.

# Install

Install gem dependencies.

`gem install serialport rosc`

The home scene uses additional gems.

`gem install sinatra`

# Use

Execute one of the "run" files.

`./run_scene_home.rb`

Go to http://localhost:4567/ to change the state of the scene.

Send interrupt to quit.
