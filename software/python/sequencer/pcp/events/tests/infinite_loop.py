# Module : infinite_loop.py
# Package: pcp.events.tests
# Unit test for infinite loop event.

import unittest
from sequencer.pcp.events import *
from sequencer.pcp.events.infinite_loop import *
from sequencer.pcp.instructions.nop import *

#------------------------------------------------------------------------------
class Test_InfiniteLoop_Event(unittest.TestCase):

  def setUp(self):
    self.e1 = Event()
    self.e2 = Event()
    self.e3 = Event()
    self.i = InfiniteLoop_Event([self.e1, self.e2, self.e3])

  def test_init(self):
    self.assertEquals(4, self.i.get_size())

#  def test_get_jump(self):

  def test_event_generator(self):
    iterator = self.i.event_generator()
    self.assertEquals(self.e1, iterator.next()) 
    self.assertEquals(self.e2, iterator.next())
    self.assertEquals(self.e3, iterator.next())
    f = iterator.next()
    self.assertEquals(Jump_Event, f.__class__)
    self.assertEquals(f.get_target(), self.i)
    self.assertRaises(StopIteration, iterator.next)

  def test_set_added(self):
    self.i.set_added()
    self.assertRaises(EventError, self.i.get_jump().set_added)

  def tearDown(self):
    del self.i
    del self.e1
    del self.e2
    del self.e3
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_InfiniteLoop_Event)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)

