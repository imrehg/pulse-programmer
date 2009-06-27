# Module : vga
# Package: sequencer.devices

import math
from sequencer.util           import *
from sequencer.devices.device import *

###############################################################################
class VGA_Device(Device):
  "Class for variable-gain amplifier devices."

  #----------------------------------------------------------------------------
  def __init__(self, parent, chain_address):
    """
    Device(parent, chain_address):
      parent        - the factory that made us and keeps all of our constants.
      chain_address - our chain address (a number)
    """
    Device.__init__(self, parent = parent, chain_address = chain_address)
    # Parent's DAC slave is actually a factory we can use to make our own.
    self.dac_slave = self.parent.DAC_FACTORY.create_device(chain_address)

  #----------------------------------------------------------------------------
  def create_gain_events(self, gain):
    # Convert linear gain to logarithmic (dB) (power, not voltage)
    self.log_gain = 10 * math.log(gain, 10)
    # Convert to steps as unsigned value from 0 to DAC step_range
    self.step_level = int((self.log_gain / self.parent.DB_PER_STEP)+0.5) + \
                      self.parent.UNITY_STEP
    # Check if within valid range for this VGA
    if ((self.step_level < self.parent.MIN_STEP) or
        (self.step_level > self.parent.MAX_STEP)):
      raise RangeError("Step size is out of range.", self.parent.MIN_STEP,
                       self.parent.MAX_STEP, self.step_level)
    # We store the signed level, since this is the actual value written
    # so we use it for diffs.
    level_events = self.dac_slave.create_level_events(self.step_level)
    return level_events
