# Module : infinite_loop
# Package: pcp.events
# Class definition for an infinite loop event.

from sequencer.pcp.events      import *
from sequencer.pcp.events.jump import *

#==============================================================================
class InfiniteLoop_Event(Sequence_Event):
  """
  Base class for an abstract infinite loop event.
  """
  #----------------------------------------------------------------------------
  def __init__(self, sequence):
    """
    InfiniteLoop_Event(sequence):
      sequence = list of events which make up the loop body.
    """
    Sequence_Event.__init__(self, sequence)
    self.jump_event = Jump_Event(self)
    self.event_list.append(self.jump_event)
    self.event_count += 1 # Add one for the jump event at the end
  #----------------------------------------------------------------------------
  def get_jump(self):
    return self.jump_event
  #----------------------------------------------------------------------------
  def __str__(self):
    return "InfiniteLoop_Event: " \
           "sequence=" + repr(self.event_list)
#==============================================================================
