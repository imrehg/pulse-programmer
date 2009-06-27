# Module : switch_frequency
# Package: pcp.events
# Class definition for switching frequencies in a phase coherent manner.

from sequencer.pcp.events import *

#==============================================================================
class SwitchFrequency_Event(Event):
  """
  Base class for an abstract phase-coherent frequency switching event.
  """

  def __init__(self, frequency, write_mask_list, address_mask_list , phase_offset = 0):
    """
    SwitchFrequency_Event(frequency):
      frequency  = abstract frequency to switch to.
      event_list = atomic pulse events to merge with every (hardware-dependent)
                   subdivision of a phase pulse output.
                   Durations are discarded; only output masks are relevant.
    """
    Event.__init__(self)
    #we should define the phase width somewhere else
    phase_width=32
    self.frequency = frequency
    self.mask_list = write_mask_list
    self.addr_mask_list = address_mask_list
    self.phase_offset = int((phase_offset *(2**phase_width) / (2*math.pi)) + 0.5)


  def get_phase_offset(self, index, sub_width):
    return (self.phase_offset >> (index*sub_width)) & generate_mask(sub_width)


#  def get_frequency(self):
#    return self.frequency

#  def get_mask_list(self):
#    return self.mask_list
