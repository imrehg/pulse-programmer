# Module : feedback_wait
# Package: pcp.events
# Class definition for a wait-on-feedback loop event.

from sequencer.pcp.events import *
from sequencer.pcp.events. import *

#==============================================================================
class FeedbackWait_Event(Sequence_Event):
  """
  Base class for an abstract wait on feedback event. This can halt forever,
  there are no timeouts.
  """
  #----------------------------------------------------------------------------
  def __init__(self, sequence, feedback_sources):
    """
    FeedbackWhileLoop_Event(sequence, feedback):
      sequence = list of events which make up the loop body.
      feedback_sources = tuple of positive feedback sources, the OR of which
                         continue the loop
    """
    Sequence_Event.__init__(self, sequence)
    self.branch_event = FeedbackBranch_Event(self, feedback_sources)
    self.event_list.append(self.branch_event)
    self.event_count += 1 # Add one for the branch event at the end
  #----------------------------------------------------------------------------
  def get_feedback_branch(self):
    return self.branch_event
  #----------------------------------------------------------------------------
  def __str__(self):
    return "FeedbackWhileLoop_Event: " \
           "sequence=" + repr(self.sequence) + \
           "triggers=" + repr(self.feedback_sources)
#==============================================================================
