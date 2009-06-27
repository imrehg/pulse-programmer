# Module : pcp1
# Package: pcp.machines.tests
# Unit test for pcp1 machine.

import unittest
from sequencer.util              import *
from sequencer.pcp.machines.pcp1 import *

#==============================================================================
class Test_pcp1_Machine(unittest.TestCase):

  #----------------------------------------------------------------------------
  def setUp(self):
    self.m = pcp1_Machine()
  #----------------------------------------------------------------------------
  def test_init(self):
    self.assertEquals(8, self.m.get_sub_stack_depth())
    self.assertEquals(3, self.m.get_loop_address_width())
    self.assertEquals(8, self.m.get_loop_data_width())
    self.assertEquals(4, self.m.get_phase_address_width())
    self.assertEquals(AD9858_PHASE_DATA_WIDTH, self.m.get_phase_data_width())
    self.assertEquals(AD9858_PHASE_ADJUST_WIDTH, self.m.get_phase_adjust_width())
    self.assertEquals(8 , self.m.get_phase_pulse_width())
    self.assertEquals(16, self.m.get_phase_load_width())
    self.assertEquals(4 , self.m.get_min_wait_duration())
  #----------------------------------------------------------------------------
  # Tests atomic pulses that generate immediate pulses
  def test_translate_sequence(self):
    s  = PulseSequence()
    bp = self.m.translate_sequence(s)
    charlist = []
    for byte in bp.binary_generator():
      charlist.append(byte)
    expected = [
      '\x00', '\x00', '\x00', '\x00', # Initial nop to prevent multiple booting
      '\x80', '\x00', '\x00', '\x01', # Halt
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      ]
    # This will be the binary produced by the default PCP64 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def tearDown(self):
    del self.m

#==============================================================================
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_pcp1_Machine)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
