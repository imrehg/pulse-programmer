# Module : simul_pulse.py
# Package: pcp.events.tests
# Unit test for simultaneous pulses event.

import unittest
from sequencer.pcp.output_mask        import *
from sequencer.pcp.events             import *
from sequencer.pcp.events.simul_pulse import *
from sequencer.pcp.instructions.nop   import *

#------------------------------------------------------------------------------
class Test_SimulPulse_Event(unittest.TestCase):

  def setUp(self):
    self.o1 = OutputMask(32, (1, 2, 3, 4), 0xF)
    self.a1 = AtomicPulse_Event(self.o1, 0x3)
    self.o2 = OutputMask(32, (5, 6, 7, 8), 0xF)
    self.a2 = AtomicPulse_Event(self.o2, 0x3)
    self.s = SimulPulse_Event([self.a1, self.a2])

  def test_init(self):
    o3 = OutputMask(31, (9, 10, 11, 12), 0x3)
    a3 = AtomicPulse_Event(o3, 0x3)
    # a3's output mask has a different width
    self.assertRaises(WidthError, SimulPulse_Event, [self.a1, a3])
    o3 = OutputMask(32, (9, 10, 11, 12), 0x3)
    a3 = AtomicPulse_Event(o3, 0x4)
    # a3's duration is different
    self.assertRaises(RuntimeError, SimulPulse_Event, [self.a1, a3])
    o3 = OutputMask(32, (1, 2, 3, 4), 0x3)
    a3 = AtomicPulse_Event(o3, 0x3)
    # a3's output mask cannot be merged
    self.assertRaises(MergeError, SimulPulse_Event, [self.a1, a3])

  def test_get_merged_mask(self):
    self.assertEquals(0x1FE, self.s.get_merged_mask().get_set_mask())

  def test_get_duration(self):
    self.assertEquals(0x3, self.s.get_duration())

  def tearDown(self):
    del self.s
    del self.o1
    del self.a1
    del self.o2
    del self.a2
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_SimulPulse_Event)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)

