# Module : pcp64
# Package: pcp.machines.tests
# Unit test for PCP64_Family module

import unittest
from sequencer.util               import *
from sequencer.pcp.machines       import *
from sequencer.pcp.machines.pcp64 import *
from sequencer.pcp.events         import *

#==============================================================================
class Test_PCP64_Family(unittest.TestCase):

  #----------------------------------------------------------------------------
  def setUp(self):
    self.f = PCP64_Family(min_immed_duration = 2, min_reg_duration = 3)
  #----------------------------------------------------------------------------
  def test_init(self):
    self.assertEquals(2, self.f.min_duration)
    self.assertEquals(3, self.f.min_reg_duration)
  #----------------------------------------------------------------------------
  # Tests atomic pulses that generate immediate pulses
  def test_translate_sequence(self):
    o  = OutputMask(64, (0, 1, 2, 3), 0xA)
    o2 = OutputMask(64, (4, 5, 6, 7), 0xA)
    p  = AtomicPulse_Event(o, 0x2)
    p2 = AtomicPulse_Event(o2, 0x3)
    i  = InfiniteLoop_Event([p, p2])
    s  = PulseSequence()
    s.add_event(i)
    bp = self.f.translate_sequence(s)
    charlist = []
    for byte in bp.binary_generator():
      charlist.append(byte)
    expected = ['\x72', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x0A',
                '\x70', '\x00', '\x00', '\x06', '\x00', '\x00', '\x00', '\xAA',
                '\x5c', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
                '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
                '\x64', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x04',
                '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
                ]
    # This will be the binary produced by the default PCP64 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def tearDown(self):
    del self.f

#==============================================================================
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_PCP64_Family)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
