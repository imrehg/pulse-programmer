# __init__ module for ptp package
# Global package definitions for handling Pulse Transfer Protocol operations
# using UDP.

import socket
from sequencer.util import *
from sequencer.ptp.constants import *
from sequencer.ptp.replies import *
from sequencer.ptp.requests import *
#from sequencer.firmware import *

# The one and only UDP client socket
client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client_socket.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, True)

#------------------------------------------------------------------------------
def setup_socket():
  # Bind to localhost
  client_socket.bind(('', CLIENT_PORT))
  client_socket.settimeout(RETRY_TIMEOUT)
#------------------------------------------------------------------------------
def teardown_socket():
  client_socket.close()

###############################################################################
# Module initialisatiovn code

import sequencer.firmware
from sequencer.ptp.devices import Device

broadcast_device = Device(
  id               = CHAIN_INITIATOR_ID,
  frame_size_limit = sequencer.firmware.current_params.frame_size_limit,
  client_socket    = client_socket)

device_list    = []
ip_address_map = {}
mac_byte_map   = {}

the_first_device = None
#this_device      = None

#------------------------------------------------------------------------------
def discover_devices(ip_address = None):
  global device_list, the_first_device, mac_byte_map, ip_address_map

  # Reset all maps and lists
  device_list    = []
  ip_address_map = {}
  mac_byte_map   = {}

  # First create the initial device for discovery.

  # If our client wants to discover devices only on a specific IP address,
  # use that to create a new broadcast device.
  if (ip_address != None):
    specified_device = Device(
      ip_address       = ip_address,
      id               = CHAIN_INITIATOR_ID,
      frame_size_limit = MIN_FRAME_SIZE,
      client_socket    = client_socket)
    try:
      frame_list = specified_device.send_frame(DISCOVER_REQUEST);
    except RuntimeError, e:
      print(str(e))
      raise DeviceError("No reponse to discover frame.")
  else:
    # Otherwise use normal broadcast device
    try:
      frame_list = broadcast_device.send_frame(DISCOVER_REQUEST);
    except RuntimeError, e:
      print(str(e))
      raise DeviceError("No reponse to discover frame.")

  # Then parse the replies from the discovery request to find out the
  # IP addresses and MAC bytes of each device.
  for reply in frame_list:
    firmware_version = (reply.major_version, reply.minor_version)
    # If returned firmware version is not found, default is min frame size.
    frame_size_limit = MIN_FRAME_SIZE

    if (sequencer.firmware.FIRMWARE_PARAMS.has_key(firmware_version)):
      params = sequencer.firmware.FIRMWARE_PARAMS[firmware_version]
      frame_size_limit = params.frame_size_limit

    if (reply.opcode != Discover_Reply_Frame.OPCODE):
      continue

    mac_byte = reply.payload[1]
      
    d = Device(
      ip_address       = reply.get_ip_address(),
      id               = reply.get_source_id(),
      frame_size_limit = frame_size_limit,
      client_socket    = client_socket,
      mac_byte         = mac_byte)    
    device_list.append(d)
    print("Appending reply from " + reply.ip_address)
    if (reply.get_source_id() == CHAIN_INITIATOR_ID):
      ip_address_map[reply.get_ip_address()] = d
#  if (len(device_list) == 0):
#    raise DeviceError("No pulse sequencer device detected on network.")

  # Find MAC addresses of all detected devices.
#  for (ip_address, device) in ip_address_map.iteritems():
#    try:
#      frame_list = device.send_frame(debug_mac_request)
#    except:
#      raise DeviceError("Device at "+str(ip_address)+" is not responding.")
#    if (len(frame_list) == 0):
#      raise DeviceError("Device at "+str(ip_address)+" is not responding.")
#    # Only process first reply
#    reply_payload = frame_list[0].get_payload()
#    if (reply_payload[0] != DEBUG_MAC_SUBOPCODE):
#      raise DeviceError("Device at "+str(ip_address)+" responded incorrectly"\
#                        " to a request for its MAC address.")
    mac_byte_map[reply.payload[1]] = d
    
  if (len(device_list) == 0):
    raise DeviceError("No device gave a valid response.")
      
#  the_first_device = device_list[0]
#------------------------------------------------------------------------------
#def specify_device(ip_address, mac_byte = None):
#  return Device(ip_address       = ip_address,
#                id               = CHAIN_INITIATOR_ID,
#                frame_size_limit = current_params.frame_size_limit,
#                client_socket    = client_socket,
#                mac_byte         = mac_byte)
#------------------------------------------------------------------------------
def get_device_by_mac(least_byte):
  if (mac_byte_map.has_key(least_byte)):
    return mac_byte_map[least_byte]
  else:
    raise DeviceError("No device with MAC address byte " + str(least_byte) + \
                      " has been detected.")
