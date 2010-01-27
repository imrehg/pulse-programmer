from test_config import *
import sys

setup()
parse_params(('dummy', 'int'))

# Process args
pins = 0

# I2C slave address
# Slave addresses are the following:
# 0x60 sequencer-side LED I2C driver
# 0x61 breakout-side LED I2C driver
#   (this will freeze up PTP firmware if breakout board is not connected)
I2C_SLAVE = 0x61

# Command to write
# write_data consists of two bytes
# First byte: 0x44 means to write the following data and update output
# Second byte: 0xFF means all high (turn on all LEDs), etc.
I2C_COMMAND = "\x44%c"

for a in sys.argv[1:]:
    pins |= 1 << int(a)

# Set the pins
# Remember that a 1 bit turns the signal on.
send_i2c(I2C_SLAVE, I2C_COMMAND % (255^pins))

teardown()
