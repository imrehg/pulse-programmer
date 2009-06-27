# Module : feedback_branch
# Package: pcp.events
# Class definition for a feedback branching event.

from sequencer.pcp.events import *

#==============================================================================
class FeedbackBranch_Event(Target_Event):
  """
  Base class for an abstract feedback branching event, usually at the end of
  a feedback while loop.
  """
  #----------------------------------------------------------------------------
  def __init__(self, target, feedback_sources, branch_delay_slot = None):
    """
    FeedbackBranch_Event(target, trigger):
      target = first instruction (collapsable nop) of target event
      feedback_sources = tuple of positive feedback sources, any of which will
                         take the branch
    """
    Target_Event.__init__(self, target, branch_delay_slot)
    if (len(feedback_sources) <= 0):
      raise RuntimeError("Must have at least one feedback source.")
    for x in feedback_sources:
      if (not x.is_feedback_source()):
        raise RuntimeError("Some item is not a feedback source.")
    self.feedback_sources = set(feedback_sources)
  #----------------------------------------------------------------------------
  def feedback_source_generator(self):
    for x in self.feedback_sources:
      yield x
  #----------------------------------------------------------------------------
  def __str__(self):
    return "FeedbackBranch_Event: " \
           "target=" + repr(self.target) + \
           " feedback " + repr(self.feedback_sources)
#           "trigger=" + repr(self.trigger)
#==============================================================================
