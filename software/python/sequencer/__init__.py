# Module : __init__
# Package: sequencer
# Global package definitions for the pulse sequencer Python interface.

import sequencer.constants
import sequencer.firmware
import sequencer.devices
from optparse import OptionParser

# Initialisation code.
# Module/pulse sequencer state that is acted on by scripts

import sequencer.constants

#==============================================================================
# Global data members
current_sequence = None
current_ref_freq         = None
#current_cycle_time       = None
SEQUENCER_CHAIN_LENGTH   = 1 # By default, only one device in the chain
TOTAL_OUTPUT_WIDTH       = sequencer.constants.HARDWARE_OUTPUT_WIDTH * SEQUENCER_CHAIN_LENGTH
params                   = None # Command-line options
args                     = None # Command-line arguments
debug_level              = 0    # Currently no debug output by default
parser                   = OptionParser() # The one and only option parser

standard_params = [
  ('profile', 'string'), # Option for specifying profile output file.
  ('nonet', 'boolean' ), # Option for disabling network operation.
  ('debug', 'int'     ), # Option for setting debug level.
  ('save', 'boolean'  )  # Option for saving generated binaries for debugging.
  ]

#==============================================================================
# Commands for site configuration files
def set_site_params(version, ref_freq, chain_length = 1):
  global SEQUENCER_CHAIN_LENGTH, TOTAL_OUTPUT_WIDTH
  global current_ref_freq
  sequencer.firmware.set_firmware_version(version)
  current_ref_freq   = ref_freq
  if (chain_length <= 0):
    raise RuntimeError("Chain length must be positive.")
  SEQUENCER_CHAIN_LENGTH = chain_length
  TOTAL_OUTPUT_WIDTH = sequencer.constants.HARDWARE_OUTPUT_WIDTH * \
                       SEQUENCER_CHAIN_LENGTH

