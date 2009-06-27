# Module : subroutine
# Package: pcp.events
# Class definition for an abstract subroutine.

from sequencer.pcp.events import *

#==============================================================================
class Subroutine_Event(Sequence_Event):
  """
  Base class for an abstract subroutine object.
  """

  def __init__(self, label, sequence):
    """
    Subroutine_Event(sequence):
      label - descriptive string label for this subroutine.
      sequence - list of events which make up the body of this subroutine.
    """
    Sequence_Event.__init__(self, sequence)
    self.label = label

  def get_label(self):
    return self.label
  
  def is_abstract_subroutine(self):
    return True

  def __str__(self):
    return "sub_evt: " + \
           " lab=" + str(self.label)     + \
           " bdy=" + str(self.sequence)

  def __cmp__(self, other):
    if (self.label < other.label):
      return -1
    elif (self.label > other.label):
      return 1
    else:
      return 0

  def __hash__(self):
    return self.label.__hash__()
