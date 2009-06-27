# Module : bdec
# Package: pcp.instructions.tests
# Unit test for branch-decrement instruction class.

import unittest
from sequencer.pcp.instructions.bdec import *

#==============================================================================
class Test_BranchDecrement_Instr(unittest.TestCase):
  #----------------------------------------------------------------------------
  def setUp(self):
    Word.set_masks(word_width = 32, address_width = 19)
    InstructionWord.set_opcode_mask(opcode_width = 4)
    TargetInstruction.set_address_mask()
    BranchDecrement_Instr.set_opcode(opcode = 0xD)
    BranchDecrement_Instr.set_masks(register_width = 5,
                                    register_shift = 22)
    self.n = InstructionWord()
    self.n.set_address(0x1A000)
    # Create an empty instance to test methods
    self.p  = BranchDecrement_Instr(target = self.n, loop_register = 0x5)
  #----------------------------------------------------------------------------
  def test_static(self):
    BranchDecrement_Instr.set_opcode(0xF)
    # Tests that set_opcode sets values correctly
    self.assertEquals(BranchDecrement_Instr.OPCODE, 0xF)
    self.assertRaises(MaskError, BranchDecrement_Instr.set_opcode, 0x1F)
    # Tests that set_trigger_mask sets static values correctly
    self.assertEquals(5     , BranchDecrement_Instr.REGISTER_MASK.width)
    self.assertEquals(0x1F  , BranchDecrement_Instr.REGISTER_MASK.mask)
    self.assertEquals(22    , BranchDecrement_Instr.REGISTER_MASK.shift)
  #----------------------------------------------------------------------------
  def test_static_masks(self):
    # Tests for negative register width
    self.assertRaises(RangeError, BranchDecrement_Instr.set_masks,
                      register_width = -1,
                      register_shift = 22)
    # Tests for too-large register shift
    self.assertRaises(OverlapError, BranchDecrement_Instr.set_masks,
                      register_width = 4,
                      register_shift = 25)
  #----------------------------------------------------------------------------
  def test_init(self):
    # Test for non-instruction target
    self.assertRaises(AttributeError, BranchDecrement_Instr,
                      target = None, loop_register = 0x1)
    # Tests for register bits outside of mask
    self.assertRaises(MaskError, BranchDecrement_Instr,
                      target = self.n, loop_register = 0xFF)
    # Tests that accessors set values correctly
    self.assertEquals(self.n, self.p.target)
    self.assertEquals(0x5   , self.p.loop_register)
  #----------------------------------------------------------------------------
  def test_get_target_address(self):
    self.assertEquals(0x1A000, self.p.target.get_address())
  #----------------------------------------------------------------------------
  def test_get_loop_register(self):
    self.assertEquals(0x5 << 22, self.p.get_loop_register())
  #----------------------------------------------------------------------------
  def test_get_binary_charlist(self):
    self.assertEquals(
      ['\xD1', '\x41', '\xA0', '\x00'],
      self.p.get_binary_charlist())
  #----------------------------------------------------------------------------
  def tearDown(self):
    del self.p
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_BranchDecrement_Instr),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
