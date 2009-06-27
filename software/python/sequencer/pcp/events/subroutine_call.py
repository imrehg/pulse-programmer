# Module : subroutine_call
# Package: pcp.events
# Class definition for calling a subroutine.

from sequencer.pcp.events import *

#==============================================================================
class SubroutineCall_Event(Target_Event):
  """
  Base class for calling a subroutine and pushing the current program counter
  onto an abstract register stack.
  """
  #----------------------------------------------------------------------------
  def __init__(self, target):
    """
    SubroutineCall_Event(target):
      target = subroutine event that should be called by this event.
    """
    Target_Event.__init__(self, target, None)
    if (not target.is_abstract_subroutine()):
      raise RuntimeError("Given target is not an abstract subroutine.")
  #----------------------------------------------------------------------------
  def __str__(self):
    return "SubroutineCall_Event: " \
           "tgt=" + repr(self.target)
#==============================================================================
