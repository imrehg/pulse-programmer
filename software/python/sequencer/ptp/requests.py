# requests.py module
# Module for handling request frames and opcodes for the
# Pulse Transfer Protocol.

from sequencer.util          import *
from sequencer.ptp.constants import *

###############################################################################
class Frame:
  "A class that encapsulates a Pulse Transfer Protocol frame."

  HEADER_LENGTH = 10

  def __init__(self):
    self.opcode = 0x00 # The null opcode
    self.payload = ''

  def get_opcode(self):
    return self.opcode

  def get_payload(self):
    return self.payload

  def get_payload_length(self):
    return len(self.payload)

###############################################################################
class Status_Request_Frame(Frame):
  "A Pulse Transfer Protocol frame with a status request opcode."

  def __init__(self):
    self.opcode = 0x01 # The status request opcode
    self.payload = ''  # No payload

###############################################################################
class Write_Request_Frame(Frame):
  "A Pulse Transfer Protocol frame with a memory write request opcode."

  def __init__(self, start_address, write_data):
    """
    Write_Request_Frame(start_address, write_data):
      start_address = starting address for the requested write.
      write_data = list of one-character strings representing bytes to write.
    """
    self.opcode = 0x02    # The status request opcode
    self.subopcode = 0x01 # Write subopcode
#    self.start_address = start_address
#    self.write_data = write_data
    self.payload = hex_char_list(0x01, 1) # Write request subopcode
    self.payload += hex_char_list(start_address, 3)
    self.payload += write_data
#    self.payload.extend([chr(x) for x in write_data])

###############################################################################
class Read_Request_Frame(Frame):
  "A Pulse Transfer Protocol frame with a memory read request opcode."

  def __init__(self, start_address, read_length):
    self.opcode = 0x02    # The status request opcode
#    self.subopcode = 0x02 # Read subopcode
#    self.start_address = start_address
#    self.write_data = write_data
    self.payload = hex_char_list(0x02, 1) # Read request subopcode
    self.payload += hex_char_list(start_address, 3)
    self.payload += hex_char_list(read_length, 2)

###############################################################################
class Start_Request_Frame(Frame):
  "A Pulse Transfer Protocol frame with a start request opcode."

  def __init__(self, processor, operation):
    "processor = {'pcp'|'avr'}, operation = {'start'|'stop'}"
    self.opcode = 0x04    # The start request opcode
    if (processor == 'pcp'):
      if (operation == 'start'):
        self.subopcode = 0x01 # Resume/start the PCP
      else:
        self.subopcode = 0x02 # Suspend/stop the PCP
    else:
      if (operation == 'start'):
        self.subopcode = 0x03 # Resume/start the AVR
      else:
        self.subopcode = 0x04 # Suspend/stop the AVR
    
    self.payload = hex_char_list(self.subopcode, 1)

###############################################################################
class Trigger_Request_Frame(Frame):
  "A Pulse Transfer Protocol frame with a trigger request opcode."

  def __init__(self, trigger_source, start_address, read_length):
    """
    Trigger_Request_Frame(trigger_source, start_address, read_length)
      trigger_source = number whose lower 8 bits are used as start trigger
                       source
      start_address  = number whose lowers 24 bits are used as start address
      read_length    = number whose lower 16 bits are taken as the pulse
                       program length.
    """
    self.opcode = 0x05    # The trigger request opcode
    self.payload = hex_char_list(trigger_source, 1)
    self.payload += hex_char_list(start_address, 3)
    self.payload += hex_char_list(read_length, 2)

###############################################################################
class I2C_Request_Frame(Frame):
  "A Pulse Transfer Protocol frame with an I2C request opcode."

  def __init__(self, slave_address, read_length, write_data):
    """
    I2C_Request_Frame(slave_address, read_length, write_data)
      slave_address = number whose lower 7 bits are taken as I2C slave address
      read_length   = expected number of bytes to read from slave
      write_data    = list of one-character strings representing bytes to
                      to write to slave before reading
    """
    self.opcode = 0x07    # The I2C request opcode
    self.payload = hex_char_list(slave_address & 0x7f, 1)
    self.payload += hex_char_list(read_length, 2)
    self.payload += write_data
#    self.payload.extend([chr(x) for x in write_data])

###############################################################################
class Debug_Request_Frame(Frame):
  "A Pulse Transfer Protocol frame with a debug request opcode."

  def __init__(self, subopcode, suboperand):
    """
    Debug_Request_Frame(subopcode, suboperand)
      subopcode = identifies which debugging function to perform.
      suboperand = operand to the above subopcode.
    """
    self.opcode = 0x08    # The trigger request opcode
    self.payload = hex_char_list(subopcode, 1)
    self.payload += hex_char_list(suboperand, 1)

###############################################################################
class Discover_Request_Frame(Frame):
  "A Pulse Transfer Protocol frame with a discover request opcode."

  def __init__(self):
    self.opcode = 0x09 # The discover request opcode
    self.payload = hex_char_list(CHAIN_INITIATOR_ID, 1)

from sequencer.ptp.requests import *

#------------------------------------------------------------------------------
# Test frames, some of which are actually useful

STATUS_REQUEST         = Status_Request_Frame()
TEST_WRITE_REQUEST     = Write_Request_Frame(0x1b0000, '\x11\x22\x33\x44')
TEST_READ_REQUEST      = Read_Request_Frame(0x1b0000, 4)
PCP_START_REQUEST      = Start_Request_Frame('pcp', 'start')
PCP_STOP_REQUEST       = Start_Request_Frame('pcp', 'stop')
TRIGGER_REQUEST        = Trigger_Request_Frame(9, 0x1b0000, 4)
TEST_I2C_REQUEST       = I2C_Request_Frame(0x60, 0x00, '\x44\xff')
TEST_DEBUG_LED_REQUEST = Debug_Request_Frame(DEBUG_LED_SUBOPCODE, 0xA5)
DISCOVER_REQUEST       = Discover_Request_Frame()
DEBUG_MAC_REQUEST      = Debug_Request_Frame(DEBUG_MAC_SUBOPCODE, 0x00)

