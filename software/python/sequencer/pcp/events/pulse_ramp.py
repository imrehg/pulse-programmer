# Module : atomic_pulse
# Package: pcp.events
# Class definition for an atomic pulse event.

from sequencer.pcp.events import Event

#==============================================================================
class Pulse_Ramp_Event(Event):
  """
  Base class for an abstract pulse ramp event
  """
  #----------------------------------------------------------------------------
  def __init__(self, charlist , variable_name=''):
    """
    AtomicPulse_Event(output_mask, duration):
      output_mask = mask used to generate pulse output
      duration = duration of output
    """
    Event.__init__(self)
    self.charlist        = charlist
    self.variable_name   = variable_name
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
    return "Ramp Event"
#==============================================================================

