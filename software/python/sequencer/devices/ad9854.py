# Module : ad9854
# Package: sequencer.dac
# Class definition for the Analog Devices 9854 evaluation board
# and its events.

import math
from sequencer.util        import *
from sequencer.devices     import *
from sequencer.devices.dds import *

class AD9854_Device(DDS_Device):
  """
  Class for the Analog Devices 9854 DDS evaluation board, specifically its
  DAC functionality in driving the AD8367 variable gain amplifier.
  """
  #----------------------------------------------------------------------------
  def create_level_events(self, level):
    if (not self.initialised):
      # If this is the first write, make the difference maximal so that all
      # parts must be written.
      self.initialised = True
      self.level = ~level
    level_events = self.parent.create_value_events(self.parent.mask_qdac,
                                                   self.level, level)
    self.level = level
    return level_events
  #----------------------------------------------------------------------------
  def create_frequency_events(self, freq):
    #    if (not self.initialised):
      # If this is the first write, make the difference maximal so that all
      # parts must be written.
    #      self.initialised = True
    #      self.level = ~level
    if (freq > (self.ref_freq * self.multiplier)):
      raise RuntimeError("Cannot increase frequency beyond max.")
    freq = int((self.ref_freq * self.multiplier) / float(freq))
    debug_print("Freq: " + str(freq), 1)
      
    freq_events = self.parent, create_value_events(self.mask_freq_tune_one,
                                           self.freq, freq)
    self.freq = freq
    return freq_events
  #----------------------------------------------------------------------------
#  def create_ref_mult_events(self, mult):
#    if ((self.ref_freq * mult) > self.MAX_FREQ):
#      raise RuntimeError("Cannot increase ref clock multiplier beyond max.")
#    if ((mult < self.MIN_REF_MULTIPLIER) or (mult > self.MAX_REF_MULTIPLIER)):
#      raise RangeError("Cannot set AD9854 ref clock multiplier out of range.",
#                       self.MIN_REF_MULTIPLIER, self.MAX_REF_MULTIPLIER,
#                       mult)
#    tuple_list = [(self.BITS_PLL_RANGE, 1),
#                  (self.BITS_PLL_BYPASS, 0)]
#    mult_tuple_list = [(i, (mult >> i) & 0x01)
#                       for i in range(self.REF_MULTIPLIER_WIDTH)]
#    tuple_list.extend(mult_tuple_list)
#    
#    mult_events = self.create_write_events_2(self.mask_ref_mult, tuple_list,
#                                             self.min_duration)
#    return mult_events
  #----------------------------------------------------------------------------
  def __init__(self         ,
               parent       ,
               chain_address,
               ref_freq     ,
               ):
    DDS_Device.__init__(
      self,
      parent        = parent,
      chain_address = chain_address,
      ref_freq      = ref_freq)
    self.multiplier = 1
    self.freq  = 0x00
    self.initialised = False
    
#==============================================================================
