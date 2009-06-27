# Module : wait
# Package: pcp.instructions.tests
# Unit test for wait instruction class.

import unittest
from sequencer.pcp.instructions      import *
from sequencer.pcp.instructions.wait import *

#==============================================================================
class Test_Wait_Instr(unittest.TestCase):
  #----------------------------------------------------------------------------
  def setUp(self):
    Word.set_masks(word_width = 32, address_width = 19)
    InstructionWord.set_opcode_mask(opcode_width = 4)
    Wait_Instr.set_opcode(opcode = 0xD)
    Wait_Instr.set_masks(duration_width = 27,
                         duration_shift = 1)
    # Create an empty instance to test methods
    self.p  = Wait_Instr(duration = 0x1234567)
  #----------------------------------------------------------------------------
  def test_static(self):
    Wait_Instr.set_opcode(0xF)
    # Tests that set_opcode sets values correctly
    self.assertEquals(Wait_Instr.OPCODE, 0xF)
    self.assertRaises(MaskError, Wait_Instr.set_opcode, 0x1F)
    # Tests that set_masks sets static values correctly
    self.assertEquals(27       , Wait_Instr.DURATION_MASK.width)
    self.assertEquals(0x7FFFFFF, Wait_Instr.DURATION_MASK.mask)
    self.assertEquals(1        , Wait_Instr.DURATION_MASK.shift)
  #----------------------------------------------------------------------------
  def test_static_masks(self):
    # Tests for negative duration width
    self.assertRaises(RangeError, Wait_Instr.set_masks,
                      duration_width = -1,
                      duration_shift = 1)
    # Tests for too-large duration shift
    self.assertRaises(OverlapError, Wait_Instr.set_masks,
                      duration_width = 28,
                      duration_shift = 1)
  #----------------------------------------------------------------------------
  def test_init(self):
    # Tests for duration bits outside of mask
    self.assertRaises(MaskError, Wait_Instr,
                      duration = 0x10000001)
  #----------------------------------------------------------------------------
  def test_get_duration(self):
    self.assertEquals(0x1234567 << 1, self.p.get_duration())
  #----------------------------------------------------------------------------
  def test_get_binary_charlist(self):
    self.assertEquals(
      ['\xD2', '\x46', '\x8A', '\xCE'],
      self.p.get_binary_charlist())
  #----------------------------------------------------------------------------
  def tearDown(self):
    del self.p
    
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_Wait_Instr),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
