# Module : ld64i.py
# Package: pcp.instructions.tests
# Unit test for load-64bit-immediate instruction class.

import unittest
from sequencer.pcp.instructions       import *
from sequencer.pcp.instructions.ld64i import *

#------------------------------------------------------------------------------
class Test_Load64Immed_Instr(unittest.TestCase):

  #----------------------------------------------------------------------------
  def setUp(self):
    Word.set_masks(word_width = 64, address_width = 11)
    InstructionWord.set_opcode_mask(opcode_width = 6)
    TargetInstruction.set_address_mask()
    self.d = DataWord(0x1234567890ABCDEF)
    self.d.set_address(0x345)
    # Create an empty instance to test methods
    self.l = Load64Immed_Instr(self.d, 0x1F)
  #----------------------------------------------------------------------------
  def test_static(self):
    Load64Immed_Instr.set_opcode(0x1A)
    # Tests that set_opcode sets values correctly
    self.assertEquals(Load64Immed_Instr.OPCODE, 0x1A)
    Load64Immed_Instr.set_reg_mask(8, 31)
    # Tests that set_trigger_mask sets static values correctly
    self.assertEquals(8   , Load64Immed_Instr.REGISTER_MASK.width)
    self.assertEquals(0xFF, Load64Immed_Instr.REGISTER_MASK.mask)
    self.assertEquals(31  , Load64Immed_Instr.REGISTER_MASK.shift)
    # Tests that incorrect trigger mask settings causes errors
    self.assertRaises(RangeError, Load64Immed_Instr.set_reg_mask, -1, 31)
    self.assertRaises(RangeError, Load64Immed_Instr.set_reg_mask, 64, 31)
    self.assertRaises(OverlapError, Load64Immed_Instr.set_reg_mask, 4, 60)
    self.assertRaises(OverlapError, Load64Immed_Instr.set_reg_mask, 9, 1)
  #----------------------------------------------------------------------------
  def test_init(self):
    # Tests validation of trigger against previously set mask
    self.assertRaises(MaskError, Load64Immed_Instr, self.d, 0x2F)
    self.assertRaises(RuntimeError, Load64Immed_Instr, self.l, 0x1F)
    self.assertEquals(0x1F, self.l.register)
  #----------------------------------------------------------------------------
  def test_get_register(self):
    self.assertEquals(0x00F8000000000000, self.l.get_register())
  #----------------------------------------------------------------------------
  def test_get_binary_charlist(self):
    self.assertEquals(
      ['\x10', '\xF8', '\x00', '\x00', '\x00', '\x00', '\x03', '\x45'],
      self.l.get_binary_charlist())
  #----------------------------------------------------------------------------
  def tearDown(self):
    del self.d
    del self.l
    Load64Immed_Instr.set_opcode(0x04)
    Load64Immed_Instr.set_reg_mask(5, 51)
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_Load64Immed_Instr)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
