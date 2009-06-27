# Module : generic
# Package: devices

from sequencer.pcp                     import *
from sequencer.devices.device_factory  import *
from sequencer.pcp.events.atomic_pulse import *
import copy

###############################################################################
  
class Generic_Device(Device_Factory):
  """
  Generic device which is not chainable and has a single contiguous output
  bitmask.
  """
  #----------------------------------------------------------------------------
  def __init__(self,
               output_mask):

    Device_Factory.__init__(self,
                            output_masks = [output_mask])

  def internal_create_device(self, chain_address):
    raise RuntimeError("Generic devices are not factories.")

  def create_output_events(self, value):
    value=int(value)
    output_mask = OutputMask(
      mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
      bit_tuples = ([(self.OUTPUT_MASKS[0], value)]))
    output_event = AtomicPulse_Event(output_mask     = output_mask,
                                     is_min_duration = True)
    return [output_event]

# just change one bit
# some error checking may be needed
# The bit index should be checked and it should be checked, that the width=1 --PS
  def create_bit_output_events(self, bit, value):
    new_output_mask=copy.copy(self.OUTPUT_MASKS[0])
    new_output_mask.shift += bit
    output_mask = OutputMask(
      mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
      bit_tuples = ([(new_output_mask, value)]))
    output_event = AtomicPulse_Event(output_mask     = output_mask,
                                     is_min_duration = True)
    return [output_event]    
