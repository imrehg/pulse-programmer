# Module : device1
# Package: test_config

# Generic device 1 for test scripts, TTL level toggling

from sequencer.devices.generic import Generic_Device
from sequencer.pcp.bitmask     import *

###############################################################################
  


class Device_PMT(Generic_Device):
  """
  Generic device 1 for test scripts, TTL level toggling.
  """

  def __init__(self):
    channel=4
    output_mask = Bitmask(label = "Generic Output 3",
                          width = 1,
                          shift = 32+channel)
    Generic_Device.__init__(self, output_mask = output_mask)

class Device1(Generic_Device):
  """
  Generic device 1 for test scripts, TTL level toggling.
  """
  #----------------------------------------------------------------------------
  def __init__(self):
    output_mask = Bitmask(label = "Generic Output 1",
                          width = 4,
                          shift = 32)
    Generic_Device.__init__(self, output_mask = output_mask)


class Device2(Generic_Device):
  """
  Generic device 1 for test scripts, TTL level toggling.
  """
  #----------------------------------------------------------------------------
  def __init__(self):
    output_mask = Bitmask(label = "Generic Output 2",
                          width = 1,
                          shift = 32)
    Generic_Device.__init__(self, output_mask = output_mask)
    
