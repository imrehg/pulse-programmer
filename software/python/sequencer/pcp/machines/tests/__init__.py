# Module : __init__.py
# Package: pcp.machines.tests
# Base module for unit tests in this package

import unittest
from sequencer.constants    import *
from sequencer.util         import *
from sequencer.pcp.machines import *
from sequencer.pcp.events   import *

#------------------------------------------------------------------------------
class Test_Family(unittest.TestCase):

  def setUp(self):
    self.f = Family(name               = 'pcp0',
                    word_width         = 64,
                    address_width      = 11,
                    program_size       = 2048,
                    reg_width          = 5,
                    reg_count          = 32,
                    min_duration       = 2)

  def test_init(self):
    self.assertRaises(WidthError, Family, 'pcp0', -1, 11, 2048, 5, 32, {})
    self.assertRaises(WidthError, Family, 'pcp0', 64, -1, 2048, 5, 32, {})
    self.assertRaises(WidthError, Family, 'pcp0', 64, 11, -1, 5, 32, {})
    self.assertRaises(WidthError, Family, 'pcp0', 64, 11, 4095, 5, 32, {})
    self.assertRaises(WidthError, Family, 'pcp0', 64, 11, 2048, -1, 32, {})
    self.assertRaises(WidthError, Family, 'pcp0', 64, 11, 2048, 5, -1, {})
    self.assertRaises(WidthError, Family, 'pcp0', 64, 11, 2048, 5, 64, {})
    self.assertEquals('pcp0', self.f.get_name())
    self.assertEquals(64, self.f.get_word_width())
    self.assertEquals(5, self.f.get_reg_width())
    self.assertEquals(32, self.f.get_reg_count())
    self.assertEquals(11, self.f.get_address_width())
    self.assertEquals(2048, self.f.get_program_size())
    self.assertEquals(6, len(self.f.event_dict))

  def test_translate_sequence(self):
    h = Halt_Event()
    h3 = Halt_Event()
    j = Jump_Event(h3)
    i = InfiniteLoop_Event([h, h3, j])
    h2 = Halt_Event()
    f2 = FeedbackBranch_Event(h2, [Input_0_Trigger])
    fwl = FeedbackWhileLoop_Event([h2, f2], [Input_2_Trigger])
    s = PulseSequence()
    s.add_event(i)
    s.add_event(fwl)
    bp = self.f.translate_sequence(s)
    charlist = []
    for byte in bp.binary_generator():
      charlist.append(byte)
    expected = [
      '\x64', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
      '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
      '\x64', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x02',
      '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
      '\x5c', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x02',
      '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
      '\x5c', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
      '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
      '\x64', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x08',
      '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
      '\x50', '\x00', '\x00', '\x01', '\x00', '\x00', '\x00', '\x08',
      '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
      '\x50', '\x00', '\x00', '\x04', '\x00', '\x00', '\x00', '\x08',
      '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00',
      ]
    # This will be the binary produced by the default PCP64 opcodes
    self.assertEquals(expected, charlist)
    
  def tearDown(self):
    del self.f

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_Family)
  ))

# Run all sub-test modules in this package by importing them
import sequencer.pcp.machines.tests.pcp64
all_suites.addTest(pcp64.all_suites)
import sequencer.pcp.machines.tests.pcp32
all_suites.addTest(pcp32.all_suites)
import sequencer.pcp.machines.tests.pcp1
all_suites.addTest(pcp1.all_suites)

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
