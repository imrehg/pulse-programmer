# Module : wait
# Package: pcp.events
# Class definition for inserting nops

from sequencer.pcp.events import *
from sequencer.pcp.events.data import *

#==============================================================================
class ins_nop_Event(Event):
  """
  Base class for an abstract wait event, which inserts delays between other
  events.
  """

  def __init__(self, number):
    """
    ins_nop_event(number):
      duration = duration of wait
    """
    Event.__init__(self)
    self.number = number

  def get_umber(self):
    return self.number

