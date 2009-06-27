# Module : feedback_while_loop.py
# Package: pcp.events.tests
# Unit test for feedback-while-loop event.

import unittest
from sequencer.constants import *
from sequencer.pcp.events import *
from sequencer.pcp.events.feedback_while_loop import *
from sequencer.pcp.instructions.nop import *

#------------------------------------------------------------------------------
class Test_FeedbackWhileLoop_Event(unittest.TestCase):

  def setUp(self):
    self.e1 = Event()
    self.e2 = Event()
    self.e3 = Event()
    self.fwl = FeedbackWhileLoop_Event([self.e1, self.e2, self.e3],
                                       [Start_Trigger])
    # Create an empty instance to test methods

  def test_init(self):
    self.assertEquals(4, self.fwl.get_size())

  def test_event_generator(self):
    iterator = self.fwl.event_generator()
    self.assertEquals(self.e1, iterator.next()) 
    self.assertEquals(self.e2, iterator.next())
    self.assertEquals(self.e3, iterator.next())
    f = iterator.next()
    self.assertEquals(FeedbackBranch_Event, f.__class__)
    self.assertEquals(f.get_target(),
                      self.fwl)
    self.assertRaises(StopIteration, iterator.next)

  def test_set_added(self):
    self.fwl.set_added()
    f = self.fwl.get_feedback_branch()
    self.assertRaises(EventError, f.set_added)

  def tearDown(self):
    del self.e1
    del self.e2
    del self.e3
    del self.fwl
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_FeedbackWhileLoop_Event)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)

