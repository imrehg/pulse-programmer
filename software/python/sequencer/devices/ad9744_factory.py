# Module : ad9744_factory
# Package: sequencer.devices

from sequencer.devices.dac_factory import *
from sequencer.devices.ad9744      import *
from sequencer.pcp                 import *
import copy

class AD9744_Factory(DAC_Factory):
  """
  Factory class for AD9744 DAC (outputting levels).
  """
  #----------------------------------------------------------------------------
  def __init__(self              ,
               chain_address_mask,
               update_mask,
               data_mask):

    DAC_Factory.__init__(self,
                         min_level_mv       = 0,
                         max_level_mv       = 1000,
                         chain_address_mask = chain_address_mask,
                         update_mask        = update_mask,
                         data_mask          = data_mask)
    self.UPDATE_OUTMASK = OutputMask(
      mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
      bit_tuples = [(self.UPDATE_MASK, 1)])
    self.NOT_UPDATE_OUTMASK = OutputMask(
      mask_width = sequencer.TOTAL_OUTPUT_WIDTH,
      bit_tuples = [(self.UPDATE_MASK, 0)])
  #----------------------------------------------------------------------------
  def create_reset_events(self):
    reset_events = DAC_Factory.create_reset_events(self);

    for device in self.device_map.values():
      # Update is inverted; start off CHAIN_WRB low to make clock high.
      not_update_event  = AtomicPulse_Event(
        output_mask = copy.copy(self.NOT_UPDATE_OUTMASK),
        is_min_duration = True)
      reset_events.extend(self.create_setup_events(device))
      reset_events.append(not_update_event)

    # Reset current device back to None to latch zero level on last device
    not_update_event  = AtomicPulse_Event(
      output_mask     = copy.copy(self.NOT_UPDATE_OUTMASK),
      is_min_duration = True)
    reset_events.extend(self.create_setup_events(None))
    reset_events.append(not_update_event)
      
    return reset_events
  #----------------------------------------------------------------------------
  def internal_create_device(self, chain_address):
    return AD9744_Device(parent = self, chain_address = chain_address)
#==============================================================================
