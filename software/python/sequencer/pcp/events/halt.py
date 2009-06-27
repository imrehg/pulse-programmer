# Module : halt
# Package: pcp.events
# Class definition for a halt event.

from sequencer.pcp.events import *

# Classes

#==============================================================================
class Halt_Event(Target_Event):
  """
  Base class for an abstract halt event, usually at the end of a pulse
  sequence.
  """
  #----------------------------------------------------------------------------
  def __init__(self, branch_delay_slot = None):
    Target_Event.__init__(self,
                          target = self,
                          branch_delay_slot = branch_delay_slot)
  #----------------------------------------------------------------------------
  def __str__(self):
    return "Halt_Event:"
#==============================================================================

