# Module : separable_pulse
# Package: pcp.events
# Class definition for separable pulse events.

from sequencer.pcp.events              import *
from sequencer.pcp.events.atomic_pulse import *

#==============================================================================
class SeparablePulse_Event(Sequence_Event):
  """
  Base class for separable abstract pulse events.
  """
  #----------------------------------------------------------------------------
  def __init__(self, pulse_events):
    """
    SeparablePulse_Event(pulse_events):
      pulse_events = list of atomic or simultaneous pulse events
    """
    Sequence_Event.__init__(self, pulse_events)
    width = -1
    duration = -1
    for x in self.event_list:
      output_mask = x.get_output_mask()
      if (width == -1):
        width = output_mask.get_mask_width()
      elif (width != output_mask.get_mask_width()):
        raise WidthError("Some output mask has a different width.",
                         width, output_mask.get_mask_width())
      if (duration == -1):
        duration = x.get_duration()
      elif (duration != x.get_duration()):
        raise RuntimeError("Some pulse event has a different duration.")
    self.duration = duration
  #----------------------------------------------------------------------------
  def get_duration(self):
    return self.duration
