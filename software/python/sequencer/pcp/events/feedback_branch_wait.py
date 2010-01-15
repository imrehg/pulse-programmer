# Module : feedback_branch_wait
# Package: pcp.events
# Class definition for a feedback branch wait event.

from sequencer.pcp.events import *

#==============================================================================
class FeedbackBranchWait_Event(Target_Event):
  """
  Base class for an abstract feedback branch wait event. The branch will be 
  evaluated each cycle until the triggered branch is taken.
  """
  #----------------------------------------------------------------------------
  def __init__(self, target, feedback_sources, branch_delay_slot = None):
    """
    FeedbackBranchWait_Event(target, trigger):
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
    return "FeedbackBranchWait_Event:" \
           " target=" + repr(self.target) + \
           " feedback " + repr(self.feedback_sources)
#==============================================================================
