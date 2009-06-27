# Module : ad9744
# Package: sequencer.devices

import math
import copy
from sequencer.util                    import *
from sequencer.devices.device          import *
from sequencer.pcp                     import *
from sequencer.pcp.events.atomic_pulse import *

#==============================================================================
class AD9744_Device(Device):
  """
  Abstract class for DAC functionality (outputting gain levels)
  """
  #----------------------------------------------------------------------------
  def create_level_events(self, level):
    # Use unsigned step level as is.

    setup_events = self.internal_get_setup_events()
    # Just trying to make some quick fix to fool the subcontainment
    hack_level=1
    hack_mask  = OutputMask(
      mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
      bit_tuples = [(self.parent.DATA_MASK, hack_level)])
    hack_mask = hack_mask.merge(self.parent.UPDATE_OUTMASK)
    hack_event=  AtomicPulse_Event(output_mask     = copy.copy(hack_mask),
                                    is_min_duration = True)
    
    data_mask = OutputMask(
      mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
      bit_tuples = [(self.parent.DATA_MASK, level)])
    data_mask = data_mask.merge(self.parent.UPDATE_OUTMASK)
    # Setting up the data for the AD9744 only requires one cycle before update
    first_event = AtomicPulse_Event(output_mask     = copy.copy(data_mask),
                                    is_min_duration = True)
    if (len(setup_events) == 0):
      setup_events = [first_event]
    else:
      # Only merge into first setup event; succeeding setup events should
      # not change the bits in data mask.
      setup_events.append(first_event)

    # Update is inverted b/c the comparator output is also inverted.
    update_event = AtomicPulse_Event(
      output_mask     = copy.copy(self.parent.UPDATE_OUTMASK),
      duration        = 0x01)
    not_update_event = AtomicPulse_Event(
      output_mask     = copy.copy(self.parent.NOT_UPDATE_OUTMASK),
      is_min_duration = True)
    level_events = [hack_event]+setup_events
    level_events.append(not_update_event)
#    level_events.append(update_event)
    return level_events
  #----------------------------------------------------------------------------
  def __init__(self, parent, chain_address):
    Device.__init__(self,
                    parent = parent,
                    chain_address = chain_address)

#==============================================================================
