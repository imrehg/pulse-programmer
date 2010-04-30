#!/bin/python
# Authored by Jeff Booth

from test_config import *
import sys

# Streaming header for clock divider
CLOCK_DIVIDER_STREAMING = 3 << 13
CLOCK_DIVIDER_FLUSH = 0x232

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

# These are masks that indicate which pin
# corresponds to which data bit.  We'll
# OR them together to turn on multiple bits.

# Clock source pins
LE_PIN            = 1 << 5
DATA_PIN          = 1 << 6
CLOCK_PIN         = 1 << 7

# Clock divider pins
DIVIDER_CE_PIN    = 1 << 4
DIVIDER_CLOCK_PIN = 1 << 3
DIVIDER_DATA_PIN  = 1 << 2

# Contents of clock source register
# We send the R register first, followed by the control
# register, and lastly the N register.
data = [
  '000000000000000011001001', # R_REG
  '100011111111000100001100', # CONTROL_REG
  '000000001111101000000010', # N_REG
]

# Contents of clock divider register.
# The first entries in each list are the addresses of the first
# register to write to, the second entries are the data to write in
# those registers, and the following entries go in subsequent
# registers.
divider_data = [
    [0,0x18,0,0x40,0x11,0],
    [0x10,0x6a,0x1,0,0,0x3,0,0x6,0,0x6,0,0,0,0,0,0,0xe],
    [0xA0,0x1,0,0,0x1,0,0,0x1,0,0,0x1,0,0],
    [0xF0,0xa,0x8,0xa,0xa,0xa,0xa],
    [0x140,0x43,0x43,0x18,0x18],
    [0x190,0,0x80,0,0xbb,0,0,0,0x80,0,0x22,0,0x11,0,0,0x33,0,0x11,0x20,0,0],
    [0x1e0,0,0,0,0,0],
    #[0x232,1] # this will flush the data out!
]

# Set the pins
# Remember that a 1 bit turns the signal on.
def set_pins(pins):
    send_i2c(I2C_SLAVE, I2C_COMMAND % (255^pins))

# Sends the given data to the clock divider,
# MSB first.
def send_clock_divider_bits(data,length):
    MSB = 1 << (length-1);
    for i in xrange(length):
        mask = DIVIDER_DATA_PIN if (data & MSB) else 0
        set_pins(mask)
        set_pins(DIVIDER_CLOCK_PIN | mask)
        data <<= 1
   
# To initialize the clock divider, set up the registers.
def init_clock_divider():
    # Make CE go high.
    set_pins(DIVIDER_CE_PIN)
    set_pins(0)
    
    for entry in divider_data:
        # Send header
        send_clock_divider_bits((entry[0] + len(entry) - 2) | CLOCK_DIVIDER_STREAMING,16)
        
        # Send each data item
        for item in entry[:0:-1]:
            send_clock_divider_bits(item, 8)
                
        # Make CE go high.
        set_pins(DIVIDER_CE_PIN)
        set_pins(0)
    
    # Transfer data from buffers to registers
    send_clock_divider_bits(CLOCK_DIVIDER_FLUSH, 16)
    send_clock_divider_bits(1, 8)
    set_pins(DIVIDER_CE_PIN)

# To initialize the clock source, we need to set up the three
# registers on the board chip.
def init_clock_source():
    # To make sure setup and hold time are met,
    # we'll first set the data pins, then raise the
    # clock pin, then lower the clock pin.  This
    # means each bit will require three commands.
    for entry in data:
        #print entry
        # Transmit bits
        for i in entry:
            bit_mask = DATA_PIN if i == '1' else 0
            
            set_pins(bit_mask)
            set_pins(bit_mask ^ CLOCK_PIN)

        # Set the LE register high to store data in the
        # appropriate register.
        set_pins(0)
        set_pins(LE_PIN)
        
# Display a usage note
def usage():
    print """Usage: python set_clk.py list_of_items
Items may be one of the following:
  source   - initialize the clock source
  divider  - initialize the clock divider
  
Example: to initialize the clock source, then the divider:
  python set_clk.py source divider

WARNING: In order for this script to work, DIP switch 6
  must be enabled on the breakout board.  Otherwise, the
  commands will not actually set the pins.
"""

# Supported script commands
commands = {
    "source" : init_clock_source,
    "divider" : init_clock_divider
}

# Process commands
if len(sys.argv) <= 1:
    print "Missing arguments."
    usage()
    exit()
else:
    for arg in sys.argv[1:]:
        if arg not in commands:
            print "Invalid command: %s" % arg
            usage()
            exit()
    parse_params(('dummy', 'int'))
    setup()
    for arg in sys.argv[1:]:
        fn = commands[arg]
        fn()
    teardown()
