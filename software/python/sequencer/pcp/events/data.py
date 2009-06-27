# Module : data
# Package: pcp.events
# Class definition for a data event.

from sequencer.pcp.events import *
from sequencer.pcp.events.data import *

#==============================================================================
class Data_Event(Event):
  """
  Base class for an abstract data event, which is a target for load
  events.
  """

  def __init__(self, value):
    """
    Data_Event(value):
      value = value of data word.
    """
    Event.__init__(self)
    self.value = value

  def get_value(self):
    return self.value

