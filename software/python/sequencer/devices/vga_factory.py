# Module : vga_factory
# Package: sequencer.devices

import math
from sequencer.devices.device_factory import *
from sequencer.devices.vga            import *
from sequencer.pcp                    import *

class VGA_Factory(Device_Factory):
  """
  Factory class for DAC functionality (outputting levels).
  """
  #----------------------------------------------------------------------------
  def __init__(self              ,
               min_gain_db       , # Minimum gain in dB as float (possibly <0)
               min_level_mv      , # Corresponding minimum level in mV
               max_gain_db       , # Maximum gain in dB as float (possibly <0)
               max_level_mv      , # Corresponding maximum level in mV
               dac_slave):         # DAC factory slave for level events.

    Device_Factory.__init__(self,
                            chain_address_mask = dac_slave.CHAIN_ADDRESS_MASK,
                            output_masks    = [])

    self.DAC_FACTORY = dac_slave

    if (min_level_mv >= max_level_mv):
      raise RuntimeError("Minimum voltage level " + str(min_level_mv) + \
                         " must be greater than max voltage level " + \
                         str(max_level_mv))
    if (min_gain_db >= max_gain_db):
      raise RuntimeError("Minimum dB level " + str(min_gain_db) + \
                         " must be greater than max dB level " + \
                         str(max_gain_db))
    self.MIN_LEVEL_MV   = min_level_mv
    self.MAX_LEVEL_MV   = max_level_mv
    self.LEVEL_RANGE_MV = max_level_mv - min_level_mv
    self.MIN_GAIN_DB    = min_gain_db
    self.MAX_GAIN_DB    = max_gain_db
    self.GAIN_RANGE_DB  = max_gain_db - min_gain_db
    self.MV_PER_DB      = self.LEVEL_RANGE_MV / self.GAIN_RANGE_DB

    self.DB_PER_STEP = dac_slave.MV_PER_STEP / self.MV_PER_DB
    debug_print("DAC dB/Step: " + str(self.DB_PER_STEP), 1)
    self.MIN_STEP = math.ceil(self.MIN_LEVEL_MV / dac_slave.MV_PER_STEP)
    debug_print("DAC Min Step: " + str(self.MIN_STEP), 1)
    self.MAX_STEP = math.floor(self.MAX_LEVEL_MV / dac_slave.MV_PER_STEP)
    debug_print("DAC Max Step: " + str(self.MAX_STEP), 1)
    if ((self.MIN_GAIN_DB >= 0) or (self.MAX_GAIN_DB <= 0)):
      raise RuntimeError("Cannot achieve unity gain on this DAC.")
    self.UNITY_STEP = round((-self.MIN_GAIN_DB / self.DB_PER_STEP)+\
                            self.MIN_STEP)
    self.MIN_GAIN = math.pow(10, (self.MIN_GAIN_DB / 10))
    self.MAX_GAIN = math.pow(10, (self.MAX_GAIN_DB / 10))
    debug_print("DAC Unity Step: " + str(self.UNITY_STEP), 1)
  #----------------------------------------------------------------------------
  def internal_create_device(self, chain_address):
    return VGA_Device(parent = self, chain_address = chain_address)
#==============================================================================
