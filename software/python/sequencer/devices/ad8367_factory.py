# Module : ad8367_factory
# Package: sequencer.devices

import math
from sequencer.devices.vga_factory import *
from sequencer.pcp                 import *

class AD8367_Factory(VGA_Factory):
  """
  Factory class for producing AD8367 variable-gain amplifiers.
  """

  def __init__(self              ,
               dac_slave):         # DAC factory slave for level events.

    VGA_Factory.__init__(self,
                         dac_slave          = dac_slave,
                         min_level_mv       = 50,
                         max_level_mv       = 950,
                         min_gain_db        = -2.5,
                         max_gain_db        = 42.5)


