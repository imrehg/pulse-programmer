# Module : init_frequency
# Package: pcp.events
# Class definition for initializing a frequency.

import math
from sequencer.pcp.events import *

#==============================================================================
class InitFrequency_Event(Event):
  """
  Event for initialization, but not switching to,  an abstract frequency.
  """

  def __init__(self, frequency, ref_freq, phase_width):
    """
    InitFrequency_Event(frequency):
      frequency = abstract frequency object to initialize.
      ref_freq  = reference frequency, in Hertz of device generating this
                  event.
      phase_width = width of tuning words in bits.
    """
    Event.__init__(self)
    if (not frequency.is_abstract_frequency()):
      raise RuntimeError("Given frequency is not an abstract frequency.")
    if (ref_freq < 0):
      raise RuntimeError("Reference frequency should not be negative ("+\
                         str(ref_freq)+")")
    if (phase_width < 0):
      raise RuntimeError("Phase width should not be negative ("+\
                         str(phase_width)+")")
    if (frequency.get_frequency() > ref_freq):
      raise RuntimeError("Given frequency cannot be greater than reference ("+\
                         str(frequency.get_frequency())+")")
    debug_print("relative_phase: "+str(frequency.relative_phase),3)
    self.frequency   = frequency
    self.ref_freq    = ref_freq
    #   self.tuning_word = int((float(frequency.get_frequency()) * (2**phase_width) /
    #                           self.ref_freq) + 0.5)
    # The phase counters are clocked by the sync clock so we have to divide the ref_freq by 8
    # --PS
    debug_print("init frequency phase width: "+str(phase_width),3)
    self.tuning_word = int((float(frequency.get_frequency()) * (2**32) /
                            self.ref_freq))*8

    self.phase_offset = int((frequency.get_relative_phase() *
                             (2**phase_width) / (2*math.pi)) +
                            0.5)
  def get_frequency(self):
    return self.frequency

  def get_tuning_word(self, index, sub_width):
    debug_print("get tuning word "+str(self.tuning_word/8.0), 3)
    return (self.tuning_word >> (index*sub_width)) & generate_mask(sub_width)

  def get_phase_offset(self, index, sub_width):
    return (self.phase_offset >> (index*sub_width)) & generate_mask(sub_width)

