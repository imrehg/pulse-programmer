# Module : dds
# Package: sequencer.devices
# Abstract base class for a DDS device.

from sequencer.util                    import *
from sequencer.pcp.output_mask         import OutputMask
from sequencer.pcp.events.atomic_pulse import AtomicPulse_Event
from sequencer.devices.device          import Device

###############################################################################
  
class DDS_Device(Device):
  #----------------------------------------------------------------------------
  def __init__(self,
               parent,        # Parent factory that created us
               chain_address, # Integer chain address
               ref_freq       # Reference frequency in MHz
               ):
    Device.__init__(self, parent = parent, chain_address = chain_address)
    if ((ref_freq < self.parent.MIN_REF_FREQ) or
        (ref_freq > self.parent.MAX_REF_FREQ)):
      raise RangeError("Reference frequency is out of range.",
                       min_value = self.parent.MIN_REF_FREQ,
                       max_value = self.parent.MAX_REF_FREQ,
                       value = ref_freq)
    self.ref_freq = ref_freq
  #----------------------------------------------------------------------------
  def create_load_profile_events(self,
                                 profile, # Integer between 0 and PROFILE_COUNT
                                 frequency, # Abstract frequency object
                                 ):
    if ((profile < 0) or (profile > self.parent.PROFILE_COUNT)):
      raise RangeError(message = "Profile is out of range.",
                       min_value = 0,
                       max_value = self.parent.PROFILE_COUNT,
                       value = profile)
    return []
  #----------------------------------------------------------------------------
  def create_switch_profile_events(self,
                                   profile, # Integer in [0, PROFILE_COUNT]
                                   ):
    if ((profile < 0) or (profile > self.parent.PROFILE_COUNT)):
      raise RangeError(message = "Profile is out of range.",
                       min_value = 0,
                       max_value = self.parent.PROFILE_COUNT,
                       value = profile)
    return []
  #----------------------------------------------------------------------------
  def create_load_phase_events(self, frequency):
    raise RuntimeError("Not yet implemented")
  #----------------------------------------------------------------------------
  def create_switch_phase_events(self, frequency):
    raise RuntimeError("Not yet implemented")
  #----------------------------------------------------------------------------
  def create_value_events(self, reg_array, old_value, new_value):
    value_events = []
    difference   = old_value ^ new_value
    # We don't write on the first event b/c of setup times.
#    first        = True
#    aux_mask     = None
#    last_index   = len(reg_array) - 1
    diff_map     = {}
    for i in range(len(reg_array)):
#      if (((old_value ^ new_value) >> (self.REGISTER_WIDTH*i)) & 0xFF):
    # Create an event for every register, to make timing uniform
      diff = (new_value >> (self.parent.REGISTER_WIDTH*i)) & 0xFF
      diff_map[i] = diff

    for (index, diff) in diff_map.iteritems():
      event_list = self.parent.create_write_events(
        reg_address_mask = reg_array[index],
        reg_value        = diff)
      value_events.extend(event_list)

    return value_events
  #----------------------------------------------------------------------------
#  def get_overhead(self):
#    # 2 min. durations; one for writing and one for updating
#    return 2*self.min_duration
