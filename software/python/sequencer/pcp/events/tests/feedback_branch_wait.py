# Module : feedback_branch_wait.py
# Package: pcp.events.tests
# Unit test for feedback branch wait event.

import unittest
from sequencer.constants import *
from sequencer.pcp.events import *
from sequencer.pcp.events.feedback_branch_wait import *
from sequencer.pcp.instructions.nop import *

#------------------------------------------------------------------------------
class Test_FeedbackBranchWait_Event(unittest.TestCase):

  def setUp(self):
    self.e = Event()
    self.f = FeedbackBranchWait_Event(self.e, [Start_Trigger])
    # Create an empty instance to test methods

  def test_init(self):
    self.assertRaises(RuntimeError, FeedbackBranchWait_Event, self.e, [])
    self.assertRaises(AttributeError, FeedbackBranchWait_Event, self.e,
                      [self.e])
    f2 = FeedbackBranchWait_Event(self.e, [Input_0_Trigger, Input_1_Trigger,
                                       Input_0_Trigger, Input_3_Trigger])
    self.assertEquals(3, len(f2.feedback_sources))

  def test_feedback_source_generator(self):
    iterator = self.f.feedback_source_generator()
    self.assertEquals(Start_Trigger, iterator.next())
    self.assertRaises(StopIteration, iterator.next)
    
  def tearDown(self):
    del self.f
    del self.e
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_FeedbackBranchWait_Event)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
