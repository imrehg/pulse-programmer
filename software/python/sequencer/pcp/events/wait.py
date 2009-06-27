# Module : wait
# Package: pcp.events
# Class definition for a wait event.

from sequencer.pcp.events import *
from sequencer.pcp.events.data import *

#==============================================================================
class Wait_Event(Event):
  """
  Base class for an abstract wait event, which inserts delays between other
  events.
  """

  def __init__(self, duration):
    """
    Wait_Event(duration):
      duration = duration of wait
    """
    Event.__init__(self)
    self.duration = duration

  def get_duration(self):
    return self.duration

