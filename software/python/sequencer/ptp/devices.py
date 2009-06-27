# devices.py in the ptp package
# Module for handling pulse sequencer devices.

import socket
import sequencer.ptp
from sequencer.ptp.requests  import *
from sequencer.ptp.replies   import *
from sequencer.ptp.constants import *

# Constants
DEFAULT_SERVER_PORT  = 8736 # 0x2220
MAX_PTP_SERVER_COUNT = 16
DEFAULT_IP_SUBNET    = '192.168.0.'
DEFAULT_IP_HOST_BYTE = 0xDC # 0d220
MAX_RETRY_COUNT      = 5   # Number of times to retry a request

#==============================================================================
class Device:
  "A class that encapsulates a pulse sequencer device."
  #----------------------------------------------------------------------------
  def __init__(self, id, client_socket, frame_size_limit, machine = None,
               ip_address = None, mac_byte = None):
    self.id      = id
    self.machine = machine
    self.broadcast_ports = False

    if (mac_byte == None):
      # We must scan all ports
      self.broadcast_ports = True
      if (ip_address == None):
        self.ip_address = '<broadcast>'
      else:
        self.ip_address = ip_address
    else:
      self.mac_byte = mac_byte
      if (ip_address == None):
        self.ip_address = DEFAULT_IP_SUBNET + \
                          str(DEFAULT_IP_HOST_BYTE + self.mac_byte)
      else:
        self.ip_address = ip_address
      self.server_port = DEFAULT_SERVER_PORT + self.mac_byte

    self.frame_size_limit = frame_size_limit
    self.client_socket    = client_socket
  #----------------------------------------------------------------------------
  def load_program(self, pulse_sequence, starting_address):
    if (self.machine == None):
      raise DeviceError("Device has no associated PCP machine.")
    pulse_program = self.machine.translate_sequence(pulse_sequence)
    sequencer.program_size=pulse_program.get_size()
    debug_print("Pulse program size = " + \
                repr(pulse_program.get_size()) + " words.", 1)
    if (sequencer.params.save):
      sequencer.api.save_program(pulse_program.get_binary_charlist())

    # Stop the processor; safety first kids
    self.send_frame(PCP_STOP_REQUEST)
    # Write the pulse program in chunks, respecting frame size limit
    byte_count = 0
    current_address = starting_address
    charlist = pulse_program.get_binary_charlist()
    charlist_length = len(charlist)
    end_index = byte_count + self.frame_size_limit
    while (byte_count < charlist_length):
      write_data = charlist[byte_count:byte_count+self.frame_size_limit]
      write_frame = Write_Request_Frame(starting_address + byte_count,
                                        write_data)
      self.send_frame(write_frame)
      byte_count += self.frame_size_limit

    # Trigger the pulse program
#    trigger_frame = Trigger_Request_Frame(trigger, starting_address,
#                                          charlist_length)
#    self.send_frame(trigger_frame)
    # Start the pulse program
    self.send_frame(PCP_START_REQUEST)
  #----------------------------------------------------------------------------
  def start_processor(self):
    self.send_frame(PCP_START_REQUEST)
  #----------------------------------------------------------------------------
  def stop_processor(self):
    self.send_frame(PCP_STOP_REQUEST)
  #----------------------------------------------------------------------------
  def recv_frame(self, is_multiple = False):
    # is_multiple=False indicates that the result will be only one word long
    # we don't wait for an timeout then
    frame_list = []
    try:
      while True:
        data = self.client_socket.recvfrom(1024)
        # data is a tuple (string, (ip_address, port))
        returned_frame = create_reply_frame(list(data[0]), data[1][0])
        frame_list.append(returned_frame)
        # Treat every read as returning a complete frame.
        # I think UDP reads behave this way, but it may be implementation-
        # depend, and is probably not the best way to do this.
        if ((not data) or (not is_multiple)):
          return frame_list
    except socket.timeout:
      return frame_list
  #----------------------------------------------------------------------------
  def send_frame(self, frame, is_multiple = False):
    if (sequencer.params.nonet):
      return
    datastring = '';
    datastring += hex_char_list(HOST_ID, 1) # Source (host) ID
    datastring += hex_char_list(self.id, 1) # Destination (device) ID
    # Major version
    datastring += hex_char_list(sequencer.firmware.current_version[0], 1)
    # Minor version
    datastring += hex_char_list(sequencer.firmware.current_version[1], 1)
    datastring += hex_char_list(frame.get_opcode(), 1)
    datastring += hex_char_list(0x00, 1)
    total_length = frame.get_payload_length() + frame.HEADER_LENGTH
    datastring += hex_char_list(total_length, 2) 
    datastring += hex_char_list(0x00, 2) # Unused
    datastring += (frame.get_payload())
    if (self.broadcast_ports):
      debug_print("Scanning ports on " + self.ip_address, 1)
      port_range = [x + DEFAULT_SERVER_PORT
                    for x in range(MAX_PTP_SERVER_COUNT)]
    else:
      port_range = [self.server_port]

    reply_frame_list = []
    for port in port_range:
      if (self.broadcast_ports):
        debug_print("Trying UDP port " + str(port), 1)
      retry_count = 0
      while retry_count < MAX_RETRY_COUNT:
        result = self.client_socket.sendto(datastring,
                                           (self.ip_address, port))
        if (result != total_length):
          raise RuntimeError, "Socket operation did not send all bytes."
        received_frames = self.recv_frame(is_multiple = is_multiple)
        reply_frame_list.extend(received_frames)
        if (len(received_frames) > 0):
          break # Continue with next port in range if this port responded
        retry_count += 1
    if (len(reply_frame_list) > 0):
      return reply_frame_list
    raise RuntimeError, "No Pulse Transfer Protocol reply received."
  #----------------------------------------------------------------------------
  def send_frame_list(self, frame_list):
    "Send a list of request frames and return a list of reply frames."
    return [self.send_frame(x) for x in frame_list]
