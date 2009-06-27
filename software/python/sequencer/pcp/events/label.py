# Module : label
# Package: pcp.events
# Class definition for a label event.

from sequencer.pcp.events import *
from sequencer.pcp.events.data import *

#==============================================================================
class Label_Event(Event):
  """
  Base class for an abstract label event, which is a target for branches.
  """

  def __init__(self, label=""):
    """
    Label_Event(value):
      label = descriptive text label
    """
    Event.__init__(self)
    self.label = label

  def get_label(self):
    return self.label

