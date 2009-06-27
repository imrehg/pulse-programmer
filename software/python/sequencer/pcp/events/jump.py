# Module : jump
# Package: pcp.events
# Class definition for a jump event.

from sequencer.pcp.events import *

# Classes

#==============================================================================
class Jump_Event(Target_Event):
  """
  Base class for an abstract jump event, usually to implement an infinite
  loop or escape from data words.
  """
  #----------------------------------------------------------------------------
  def __str__(self):
    return "Jump_Event:"

