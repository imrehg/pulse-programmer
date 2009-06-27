# Module : btr.py
# Package: pcp.instructions.tests
# Unit test for branch-on-trigger instruction class.

import unittest
from sequencer.pcp.instructions     import *
from sequencer.pcp.instructions.btr import *

#------------------------------------------------------------------------------
class Test_BranchTrigger_Instr(unittest.TestCase):
  #----------------------------------------------------------------------------
  def setUp(self):
    Word.set_masks(word_width = 64, address_width = 11)
    InstructionWord.set_opcode_mask(opcode_width = 6)
    TargetInstruction.set_address_mask()
    self.i = InstructionWord()
    self.i.set_address(0x345)
    # Create an empty instance to test methods
    self.b = BranchTrigger_Instr(self.i, 0x1FF)
  #----------------------------------------------------------------------------
  def test_static(self):
    BranchTrigger_Instr.set_opcode(0x1A)
    # Tests that set_opcode sets values correctly
    self.assertEquals(BranchTrigger_Instr.OPCODE, 0x1A)
    BranchTrigger_Instr.set_trigger_mask(8, 31)
    # Tests that set_trigger_mask sets static values correctly
    self.assertEquals(8   , BranchTrigger_Instr.TRIGGER_MASK.width)
    self.assertEquals(0xFF, BranchTrigger_Instr.TRIGGER_MASK.mask)
    self.assertEquals(31  , BranchTrigger_Instr.TRIGGER_MASK.shift)
    # Tests that incorrect trigger mask settings causes errors
    self.assertRaises(RangeError, BranchTrigger_Instr.set_trigger_mask, -1, 31)
    self.assertRaises(RangeError, BranchTrigger_Instr.set_trigger_mask, 64, 31)
    self.assertRaises(RangeError, BranchTrigger_Instr.set_trigger_mask, 9, 60)
    self.assertRaises(OverlapError, BranchTrigger_Instr.set_trigger_mask, 9, 1)
  #----------------------------------------------------------------------------
  def test_init(self):
    # Tests validation of trigger against previously set mask
    self.assertRaises(MaskError, BranchTrigger_Instr, self.i, 0xFF)
    self.assertEquals(0x1FF, self.b.trigger)
  #----------------------------------------------------------------------------
  def test_init(self):
    self.assertEquals(0x000001FF00000000, self.b.get_trigger())
  #----------------------------------------------------------------------------
  def test_get_binary_charlist(self):
    self.assertEquals(
      ['\x50', '\x00', '\x01', '\xFF', '\x00', '\x00', '\x03', '\x45'],
      self.b.get_binary_charlist())
  #----------------------------------------------------------------------------
  def tearDown(self):
    del self.i
    del self.b
    BranchTrigger_Instr.set_opcode(0x14)
    BranchTrigger_Instr.set_trigger_mask(9, 32)
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_BranchTrigger_Instr)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)

