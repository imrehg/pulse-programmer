# Module : simul_pulse
# Package: pcp.events
# Class definition for simultaneous pulse events.

from sequencer.pcp.events import *
from sequencer.pcp.events.atomic_pulse import *

#==============================================================================
class SimulPulse_Event(Sequence_Event):
  """
  Base class for simultaneous abstract pulse events.
  """

  def __init__(self, pulse_events):
    """
    SimulPulse_Event(pulse_events):
      pulse_events = list of atomic or simultaneous pulse events
    """
    Sequence_Event.__init__(self, pulse_events)
    width = -1
    duration = -1
    self.merged_mask = None
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
      if (self.merged_mask == None):
        self.merged_mask = x.get_output_mask()
      else:
        # Try merging it; if it fails, the error will get passed up.
        self.merged_mask = self.merged_mask.merge(x.get_output_mask())
    self.duration = duration

  def get_merged_mask(self):
    return self.merged_mask

  def get_duration(self):
    return self.duration
