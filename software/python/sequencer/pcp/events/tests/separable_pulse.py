# Module : separable_pulse.py
# Package: pcp.events.tests
# Unit test for separable pulse event.

import unittest
from sequencer.pcp.output_mask            import *
from sequencer.pcp.events                 import *
from sequencer.pcp.events.atomic_pulse    import *
from sequencer.pcp.events.separable_pulse import *
from sequencer.pcp.instructions.nop       import *

#------------------------------------------------------------------------------
class Test_SeparablePulse_Event(unittest.TestCase):

  def setUp(self):
    self.o1 = OutputMask(mask_width = 64,
                         bit_indices = (1, 2, 3, 4),
                         value = 0xF)
    self.a1 = AtomicPulse_Event(self.o1, 0x3)
    self.o2 = OutputMask(mask_width = 64,
                         bit_indices = (33, 34, 35, 36),
                         value = 0xF)
    self.a2 = AtomicPulse_Event(self.o2, 0x3)
    self.s  = SeparablePulse_Event([self.a1, self.a2])
    # Create an empty instance to test methods

  def test_event_generator(self):
    event_list = []
    for event in self.s.event_generator():
      event_list.append(event)
    self.assertEquals(self.a1, event_list[0])
    self.assertEquals(self.a2, event_list[1])

  def test_get_duration(self):
    self.assertEquals(0x3, self.s.get_duration())

  def tearDown(self):
    del self.s
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_SeparablePulse_Event)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
