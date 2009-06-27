# Module : finite_loop
# Package: pcp.events
# Class definition for a finite loop event.

from sequencer.pcp.events import *
from sequencer.pcp.events.jump import *

#==============================================================================
class FiniteLoop_Event(Sequence_Event):
  """
  Base class for an abstract finite loop event.
  """

  def __init__(self, sequence, loop_count):
    """
    FiniteLoop_Event(sequence, repetitions):
      sequence = list of events which make up the loop body.
      loop_count = number of times to repeat loop
    """
    Sequence_Event.__init__(self, sequence)
    if (loop_count <= 1):
      raise RuntimeError("Loop count must be greater than one.")
    self.loop_count = loop_count

  def get_loop_count(self):
    return self.loop_count
