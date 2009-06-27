# replies.py module for ptp package
# Module for handling reply frames and opcodes for the Pulse Transfer Protocol.

from sequencer.util import *
from sequencer.ptp.requests import *

###############################################################################
class Reply_Frame(Frame):
  "A Pulse Transfer Protocol frame in response to a request."

  def __init__(self, frame_parent=None, frame_data=None, ip_address=None):
    # Convert string into list of ints
    if (frame_parent == None):
      frame_data = [ord(x) for x in frame_data]
      self.src_id  = frame_data[0]
      self.dest_id = frame_data[1]
      self.major_version = frame_data[2]
      self.minor_version = frame_data[3]
      self.opcode = frame_data[4]
      # frame_data[5] is a zero
      total_length = (frame_data[6] << 8) + frame_data[7]
      self.payload_length = total_length - Reply_Frame.HEADER_LENGTH
      # frame_data[8:9] are unused
      self.payload = frame_data[10:total_length]
      self.ip_address = ip_address
    else:
      self.src_id = frame_parent.src_id
      self.dest_id = frame_parent.dest_id
      self.major_version = frame_parent.major_version
      self.minor_version = frame_parent.minor_version
      self.opcode = frame_parent.opcode
      self.payload = frame_parent.payload
      self.ip_address = frame_parent.ip_address

  def get_source_id(self):
    return self.src_id

  def get_dest_id(self):
    return self.dest_id

  def get_major_version(self):
    return self.major_version

  def get_minor_version(self):
    return self.minor_version

  def get_opcode(self):
    return self.opcode

  def get_ip_address(self):
    return self.ip_address

  def get_payload(self):
    return self.payload

###############################################################################
class Status_Reply_Frame(Reply_Frame):
  "A Pulse Transfer Protocol frame in response to a status request."

  OPCODE = 0x11

  def __init__(self, frame_parent):
    Reply_Frame.__init__(self, frame_parent)
    self.trigger_source = (frame_parent.payload[0] >> 4) & 0x0f
    self.avr_reset  = (((frame_parent.payload[0] >> 3) & 0x01) == 0x01)
    self.pcp_reset  = (((frame_parent.payload[0] >> 2) & 0x01) == 0x01)
    self.chain_init = (((frame_parent.payload[0] >> 1) & 0x01) == 0x01)
    self.chain_term = (((frame_parent.payload[0] >> 0) & 0x01) == 0x01)
    self.pcp_halted = (((frame_parent.payload[1] >> 7) & 0x01) == 0x01)

  def get_trigger_source(self):
    return self.trigger_source

  def get_avr_reset(self):
    return self.avr_reset

  def get_pcp_reset(self):
    return self.pcp_reset

  def get_chain_init(self):
    return self.chain_init

  def get_chain_term(self):
    return self.chain_term

  def get_pcp_halted(self):
    return self.pcp_halted

###############################################################################
class Memory_Reply_Frame(Reply_Frame):
  "A Pulse Transfer Protocol frame in response to a memory request."

  OPCODE = 0x12

  def __init__(self, frame_parent):
    Reply_Frame.__init__(self, frame_parent)
    self.subopcode = frame_parent.payload[0]

  def get_subopcode(self):
    return self.subopcode

  def get_read_data(self):
    return payload[11:]

###############################################################################
class Start_Reply_Frame(Reply_Frame):
  "A Pulse Transfer Protocol frame in response to a start request."

  OPCODE = 0x14

  def __init__(self, frame_parent):
    Reply_Frame.__init__(self, frame_parent)
    self.subopcode = frame_parent.payload[0]

  def get_subopcode(self):
    return self.subopcode

###############################################################################
class Trigger_Reply_Frame(Reply_Frame):
  "A Pulse Transfer Protocol frame in response to a trigger request."

  OPCODE = 0x15

  def __init__(self, frame_parent):
    Reply_Frame.__init__(self, frame_parent)
    self.trigger_source = frame_parent.payload[0]

  def get_trigger_source(self):
    return self.trigger_source

###############################################################################
class I2C_Reply_Frame(Reply_Frame):
  "A Pulse Transfer Protocol frame in response to an I2C request."

  OPCODE = 0x16

  def __init__(self, frame_parent):
    Reply_Frame.__init__(self, frame_parent)
    self.slave_address = frame_parent.payload[0] & 0x7f

  def get_slave_address(self):
    return self.slave_address

  def get_read_data(self):
    return self.payload[11:]

###############################################################################
class Debug_Reply_Frame(Reply_Frame):
  "A Pulse Transfer Protocol frame in response to a debug request."

  OPCODE = 0x18

  def __init__(self, frame_parent):
    Reply_Frame.__init__(self, frame_parent)
    self.subopcode = frame_parent.payload[0]

  def get_subopcode(self):
    return self.subopcode

###############################################################################
class Discover_Reply_Frame(Reply_Frame):
  "A Pulse Transfer Protocol frame in response to a discover request."

  OPCODE = 0x19

  def __init__(self, frame_parent):
    Reply_Frame.__init__(self, frame_parent)
    self.slave_address = frame_parent.payload[0]

  def get_slave_address(self):
    return self.slave_address

###############################################################################
# Module definitions
  
reply_opcodes = {
  Status_Reply_Frame.OPCODE  : Status_Reply_Frame  ,
  Memory_Reply_Frame.OPCODE  : Memory_Reply_Frame  ,
  Start_Reply_Frame.OPCODE   : Start_Reply_Frame   ,
  Trigger_Reply_Frame.OPCODE : Trigger_Reply_Frame ,
  I2C_Reply_Frame.OPCODE     : I2C_Reply_Frame     ,
  Debug_Reply_Frame.OPCODE   : Debug_Reply_Frame   ,
  Discover_Reply_Frame.OPCODE: Discover_Reply_Frame
  }

def create_reply_frame(frame_data, ip_address):
  frame_parent = Reply_Frame(frame_data=frame_data, ip_address=ip_address)
  opcode = frame_parent.get_opcode();
  if (reply_opcodes.has_key(opcode)):
    # Instantiate specific reply frame
    return reply_opcodes[opcode](frame_parent=frame_parent)
  else:
    return frame_parent

