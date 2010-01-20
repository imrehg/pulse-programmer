# Authored by Jeff Booth

from test_config import *

parse_params(('dummy', 'int'))

# Slave addresses are the following:
# 0x60 sequencer-side LED I2C driver
# 0x61 breakout-side LED I2C driver
#   (this will freeze up PTP firmware if breakout board is not connected)
 
setup()
#send_i2c(slave_address = 0x60,
#         write_data = '\x44\x00')

# write_data consists of two bytes
# First byte: 0x44 means to write the following data and update output
# Second byte: 0xFF means all high (turn on all LEDs), etc.

# To initialize the clock source, we need to set up the three
# registers on the board chip.

# We send the R register first, followed by the control
# register, and lastly the N register.
data = [
  '000000000000000011001001', # R_REG
  '100011111111000100001100', # CONTROL_REG
  '000000001111101000000010', # N_REG
]

# I2C slave address
I2C_SLAVE = 0x61

# Command to write
I2C_COMMAND = "\x44%c"

# These are masks that indicate which pin
# corresponds to which data bit.  We'll
# OR them together to turn on multiple bits.
LE_PIN = 1 << 5
CLOCK_PIN = 1 << 7
DATA_PIN = 1 << 6

# To make sure setup and hold time are met,
# we'll first set the data pins, then raise the
# clock pin, then lower the clock pin.  This
# means each bit will require three commands.
for entry in data:
	#print entry
	# Transmit bits
	for i in entry:
		bit_mask = 255^DATA_PIN if i == '1' else 255
		#print list(I2C_COMMAND % bit_mask)

		send_i2c(I2C_SLAVE, I2C_COMMAND % bit_mask)
		send_i2c(I2C_SLAVE, I2C_COMMAND % (bit_mask^CLOCK_PIN))

	# Set the LE register high to store data in the
	# appropriate register.
	send_i2c(I2C_SLAVE, I2C_COMMAND % 255)
	send_i2c(I2C_SLAVE, I2C_COMMAND % (255^LE_PIN))

send_i2c(I2C_SLAVE, "\x44\xFF")

teardown()
