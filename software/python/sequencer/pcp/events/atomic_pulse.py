# Module : atomic_pulse
# Package: pcp.events
# Class definition for an atomic pulse event.

from sequencer.pcp.events import Event

#==============================================================================
class AtomicPulse_Event(Event):
  """
  Base class for an abstract atomic pulse event.
  """
  #----------------------------------------------------------------------------
  def __init__(self, output_mask, duration = 0x00, is_min_duration = False):
    """
    AtomicPulse_Event(output_mask, duration):
      output_mask = mask used to generate pulse output
      duration = duration of output
    """
    Event.__init__(self)
    if (not output_mask.is_output_mask()):
      raise RuntimeError("Given input is not an output mask.")
    if (is_min_duration and (duration != 0x00)):
      raise RuntimeError("Cannot specify both is_min_duration and duration.")
    self.output_mask     = output_mask
    self.duration        = duration
    self.is_min_duration = is_min_duration
  #----------------------------------------------------------------------------
  def merge_mask(self, new_mask):
    self.output_mask = self.output_mask.merge(new_mask)
  #----------------------------------------------------------------------------
  def get_is_min_duration(self):
    return self.is_min_duration
  #----------------------------------------------------------------------------
  def get_duration(self):
    return self.duration
  #----------------------------------------------------------------------------
  def get_output_mask(self):
    return self.output_mask
  #----------------------------------------------------------------------------
  def __str__(self):
    return "ap_evt:" \
           " o_m=" + str(self.output_mask) + \
           " dur=" + hex(self.duration)    + \
           " imd=" + str(self.is_min_duration)
#==============================================================================

