# Module : atomic_pulse.py
# Package: pcp.events.tests
# Unit test for atomic pulse event.

import unittest
from sequencer.pcp.output_mask         import *
from sequencer.pcp.events              import *
from sequencer.pcp.events.atomic_pulse import *
from sequencer.pcp.instructions.nop    import *

#------------------------------------------------------------------------------
class Test_AtomicPulse_Event(unittest.TestCase):

  def setUp(self):
    self.o = OutputMask(mask_width  = 32,
                        bit_indices = (1, 2, 3, 4),
                        value       = 0xF)
    self.a = AtomicPulse_Event(output_mask = self.o,
                               duration    = 0x3)
    # Create an empty instance to test methods

  def test_init(self):
    self.assertRaises(AttributeError, AtomicPulse_Event, Nop_Instr(True), 0x3)

  def test_init_bad(self):
    self.assertRaises(RuntimeError, AtomicPulse_Event,
                      output_mask     = self.o,
                      duration        = 0x3,
                      is_min_duration = True)

  def test_is_min_duration(self):
    a2 = AtomicPulse_Event(output_mask     = self.o,
                           is_min_duration = True)
    self.assertEquals(True, a2.get_is_min_duration())

  def test_get_output_mask(self):
    self.assertEquals(self.o, self.a.get_output_mask())

  def test_get_duration(self):
    self.assertEquals(0x3, self.a.get_duration())

  def test_merge_mask(self):
    o2 = OutputMask(mask_width = 32, bit_indices = (5, 6, 7, 8), value = 0x00)
    self.a.merge_mask(o2)
    o3 = OutputMask(mask_width = 32,
                    bit_indices = (1, 2, 3, 4, 5, 6, 7, 8),
                    value = 0xF)
    self.assertEquals(o3, self.a.output_mask)

  def tearDown(self):
    del self.a
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_AtomicPulse_Event)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
