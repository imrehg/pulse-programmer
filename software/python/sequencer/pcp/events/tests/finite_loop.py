# Module : finite_loop.py
# Package: pcp.events.tests
# Unit test for finite loop event.

import unittest
from sequencer.pcp.events import *
from sequencer.pcp.events.finite_loop import *
from sequencer.pcp.instructions.nop import *

#------------------------------------------------------------------------------
class Test_FiniteLoop_Event(unittest.TestCase):

  def setUp(self):
    self.e1 = Event()
    self.e2 = Event()
    self.e3 = Event()
    self.f = FiniteLoop_Event([self.e1, self.e2, self.e3], 5)

  def test_init(self):
    self.assertEquals(3, self.f.get_size())

  def test_event_generator(self):
    iterator = self.f.event_generator()
    self.assertEquals(self.e1, iterator.next()) 
    self.assertEquals(self.e2, iterator.next())
    self.assertEquals(self.e3, iterator.next())
    self.assertRaises(StopIteration, iterator.next)

  def tearDown(self):
    del self.f
    del self.e1
    del self.e2
    del self.e3
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_FiniteLoop_Event)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)

