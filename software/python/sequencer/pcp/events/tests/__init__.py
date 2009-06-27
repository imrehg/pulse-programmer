# Module : __init__.py
# Package: pcp.events.tests
# Base module for unit tests in this package

import unittest
from sequencer.pcp.events           import *
from sequencer.pcp.events.halt      import *
from sequencer.pcp.instructions.nop import *

#------------------------------------------------------------------------------
class Test_Event(unittest.TestCase):

  def setUp(self):
    self.e = Event()

  def test_get_first_word(self):
    i = self.e.get_first_word()
    self.assertEquals(True, i.is_instruction())
    self.assertEquals(True, i.is_collapsable())

  def test_get_size(self):
    self.assertEquals(1, self.e.get_size())

  def test_is_event(self):
    self.assertEquals(True, self.e.is_event())

  def test_set_added(self):
    self.e.set_added()
    self.assertRaises(EventError, self.e.set_added)

  def tearDown(self):
    del self.e

#------------------------------------------------------------------------------
class Test_Target_Event(unittest.TestCase):

  def setUp(self):
    self.e = Event()
    self.t = Target_Event(self.e) # Empty instance to test methods

  def test_get_target(self):
    self.assertEquals(self.e, self.t.get_target())

  def test_init(self):
    self.assertRaises(AttributeError, Target_Event, None)

  def tearDown(self):
    del self.t
  
#------------------------------------------------------------------------------
class Test_Sequence_Event(unittest.TestCase):

  def setUp(self):
    self.e1 = Event()
    self.e2 = Event()
    self.e3 = Event()
    self.s = Sequence_Event([self.e1, self.e2, self.e3])

  def test_init(self):
    # Taking length of None results in TypeError
    self.assertRaises(TypeError, Sequence_Event, None)
    # Calling is_event on None results in AttributeError
    self.assertRaises(AttributeError, Sequence_Event, [self.e1, None, self.e3])

  def test_event_generator(self):
    iterator = self.s.event_generator()
    self.assertEquals(self.e1, iterator.next())
    self.assertEquals(self.e2, iterator.next())
    self.assertEquals(self.e3, iterator.next())
    self.assertRaises(StopIteration, iterator.next)

  def test_get_size(self):
    self.assertEquals(3, self.s.get_size())

  # Tests that if one subevent is added, adding the whole sequence will fail
  def test_set_added(self):
    e4 = Event()
    e4.set_added()
    s2 = Sequence_Event([self.e1, self.e2, e4])
    self.assertRaises(EventError, s2.set_added)

  # Tests that you can only set_added once for the sequence
  def test_set_added2(self):
    self.s.set_added()
    self.assertRaises(EventError, self.s.set_added)

  def test_get_first_word(self):
    i = self.s.get_first_word()
    self.assertEquals(True, i.is_instruction())
    self.assertEquals(True, i.is_collapsable())

  def tearDown(self):
    del self.e1
    del self.e2
    del self.e3
    
#------------------------------------------------------------------------------
class Test_FeedbackSource(unittest.TestCase):

  def setUp(self):
    self.f = FeedbackSource("bleh", 22)

  def test_init(self):
    self.assertEquals("bleh", str(self.f))
    self.assertEquals(22, self.f.get_bit_index())

  def test_is_feedback_source(self):
    self.assertEquals(True, self.f.is_feedback_source())

  def tearDown(self):
    del self.f

#------------------------------------------------------------------------------
class Test_PulseSequence(unittest.TestCase):

  def setUp(self):
    self.p = PulseSequence()
    self.e1 = Event()
    self.e2 = Event()
    self.e3 = Event()
    self.e4 = Event()
    self.e5 = Sequence_Event([self.e2, self.e3, self.e4])
    self.e6 = Event()
    self.p.add_event(self.e1)
    self.p.add_event(self.e5)
    self.p.add_event(self.e6)

  def test_init(self):
    self.assertEquals(5, self.p.get_size())

  def test_add_event(self):
    self.assertRaises(EventError, self.e6.set_added)
    e7 = Event()
    e7.set_added()
    p2 = PulseSequence()
    self.assertRaises(EventError, p2.add_event, e7)

  def test_event_generator(self):
    iterator = self.p.event_generator()
    self.assertEquals(self.e1, iterator.next())
    self.assertEquals(self.e5, iterator.next())
    self.assertEquals(self.e6, iterator.next())
#    h = iterator.next()
#    self.assertEquals(Halt_Event, h.__class__)
    self.assertRaises(StopIteration, iterator.next)

  def tearDown(self):
    del self.p
    del self.e1
    del self.e2
    del self.e3
    del self.e4
    del self.e5
    del self.e6

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_Event),
  unittest.makeSuite(Test_Target_Event),
  unittest.makeSuite(Test_Sequence_Event),
  unittest.makeSuite(Test_FeedbackSource),
  unittest.makeSuite(Test_PulseSequence)
  ))

# Run all sub-test modules in this package by importing them
import sequencer.pcp.events.tests.atomic_pulse
all_suites.addTest(atomic_pulse.all_suites)
import sequencer.pcp.events.tests.simul_pulse
all_suites.addTest(simul_pulse.all_suites)
import sequencer.pcp.events.tests.separable_pulse
all_suites.addTest(separable_pulse.all_suites)
import sequencer.pcp.events.tests.feedback_branch
all_suites.addTest(feedback_branch.all_suites)
import sequencer.pcp.events.tests.feedback_while_loop
all_suites.addTest(feedback_while_loop.all_suites)
import sequencer.pcp.events.tests.halt
all_suites.addTest(halt.all_suites)
import sequencer.pcp.events.tests.infinite_loop
all_suites.addTest(infinite_loop.all_suites)
import sequencer.pcp.events.tests.finite_loop
all_suites.addTest(finite_loop.all_suites)
import sequencer.pcp.events.tests.jump
all_suites.addTest(jump.all_suites)
import sequencer.pcp.events.tests.init_frequency
all_suites.addTest(init_frequency.all_suites)
import sequencer.pcp.events.tests.subroutine
all_suites.addTest(subroutine.all_suites)

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
