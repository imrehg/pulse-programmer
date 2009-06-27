# Module : device
# Package: sequencer.devices

import sequencer.constants
from sequencer.pcp.output_mask import *

###############################################################################
class Device:
  "Abstract parent class for devices."

  def __init__(self, parent, chain_address):
    """
    Device(parent, chain_address):
      parent        - the factory that made us and keeps all of our constants.
      chain_address - our chain address (a number)
    """
    self.parent        = parent
    self.chain_address = chain_address
    if (parent.is_chainable()):
      mask = OutputMask(mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
                        bit_tuples = [(parent.CHAIN_ADDRESS_MASK,
                                       chain_address)])
      self.chain_address_mask = mask
    else:
      self.chain_address_mask = None

  def internal_get_setup_events(self):
    return self.parent.create_setup_events(device = self)

  def create_reset_events(chain_address):
    return [] # No reset events by default
