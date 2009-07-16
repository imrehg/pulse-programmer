from test_config import *

parse_params(('dummy', 'int'))

# Slave addresses are the following:
# 0x60 sequencer-side LED I2C driver
# 0x61 breakout-side LED I2C driver
#   (this will freeze up PTP firmware if breakout board is not connected)
 
setup()
send_i2c(slave_address = 0x60,
         write_data = '\x44\xFF')

# write_data consists of two bytes
# First byte: 0x44 means to write the following data and update output
# Second byte: 0xFF means all high (turn on all LEDs), etc.

teardown()


