# Module : dac_factory
# Package: sequencer.devices

from sequencer.devices.device_factory import *
from sequencer.pcp                    import *

class DAC_Factory(Device_Factory):
  """
  Factory class for DAC functionality (outputting levels).
  """
  #----------------------------------------------------------------------------
  def __init__(self              ,
               min_level_mv      ,
               max_level_mv      ,
               chain_address_mask,
               update_mask       ,
               data_mask):

    Device_Factory.__init__(self,
                            chain_address_mask    = chain_address_mask,
                            output_masks       = [data_mask, update_mask])

    if (min_level_mv >= max_level_mv):
      raise RuntimeError("Minimum level " + str(min_level_mv) + \
                         " must be greater than max level " + \
                         str(max_level_mv))
    self.MIN_LEVEL_MV   = min_level_mv
    self.MAX_LEVEL_MV   = max_level_mv
    self.LEVEL_RANGE_MV = max_level_mv - min_level_mv
    self.DATA_MASK      = data_mask
    self.UPDATE_MASK    = update_mask

    self.STEP_RANGE     = 0x1 << data_mask.get_width()
    # The apparent step range is the output range of the DAC
    debug_print("Full DAC Step Range: " + str(self.STEP_RANGE), 1)
    self.MV_PER_STEP  = float(self.LEVEL_RANGE_MV) / self.STEP_RANGE
    debug_print("DAC mV/Step: " + str(self.MV_PER_STEP), 1)
  #----------------------------------------------------------------------------
  def internal_create_device(self, chain_address):
    raise RuntimeError("DAC Factory should be subclassed.")
#==============================================================================
