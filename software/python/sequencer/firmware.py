# Module: firmware.py
# Package: sequencer
# Contains a map of features and parameters keyed by firmware version.
# These are useful for importing into site configuration files for your
# particular setup.

from sequencer.pcp.machines.pcp0 import pcp0_Machine
from sequencer.pcp.machines.pcp1 import pcp1_Machine

#==============================================================================
class Firmware_Params:

  def __init__(self,
               pcp_machine_class,
               frame_size_limit
               ):
    self.pcp_machine_class = pcp_machine_class
    self.frame_size_limit  = frame_size_limit

# 984 Bytes per frame = 10-bit address space, (1024 - 20 IP hdr - 20 UDP hdr)
#pcp0 = sequencer.pcp.machines.pcp0.pcp0_Machine()
#pcp1 = sequencer.pcp.machines.pcp1.pcp1_Machine()

FIRMWARE_PARAMS = {
  (0, 01): Firmware_Params(pcp0_Machine, 984),
  (0, 02): Firmware_Params(pcp0_Machine, 984),
  (0, 03): Firmware_Params(pcp0_Machine, 984),
  (0, 05): Firmware_Params(pcp1_Machine, 984),
  (0, 10): Firmware_Params(pcp1_Machine, 984),
  (0, 15): Firmware_Params(pcp1_Machine, 984),
  (0, 20): Firmware_Params(pcp1_Machine, 984),
  (0, 21): Firmware_Params(pcp1_Machine, 984),
  }


# Default version 0.15 for broadcast devices
# The Python interface is v0.19, but we are always compatible with the
# most recent previous firmware release.
current_version = (0x00, 15)

current_params  = FIRMWARE_PARAMS[current_version]

def set_firmware_version(version):
    global current_version, current_params
    current_version    = version
    if (not FIRMWARE_PARAMS.has_key(version)):
      raise RuntimeError("This software does not support firmware version " + \
                         str(version[0]) + "." + ("%02d" % version[1]))
    current_params     = FIRMWARE_PARAMS[current_version]
    
