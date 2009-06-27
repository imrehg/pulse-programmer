# Module : ldc
# Package: pcp.instructions.tests
# Unit test for load constant instruction class.

import unittest
from sequencer.pcp.instructions.ldc import *

#==============================================================================
class Test_LoadConstant_Instr(unittest.TestCase):
  #----------------------------------------------------------------------------
  def setUp(self):
    Word.set_masks(word_width = 32, address_width = 19)
    InstructionWord.set_opcode_mask(opcode_width = 4)
    LoadConstant_Instr.set_opcode(opcode = 0xD)
    LoadConstant_Instr.set_masks(register_width = 6,
                                 register_shift = 22,
                                 constant_width = 6,
                                 constant_shift = 1)
    # Create an empty instance to test methods
    self.p  = LoadConstant_Instr(register = 0x25, constant = 0x11)
  #----------------------------------------------------------------------------
  def test_static(self):
    LoadConstant_Instr.set_opcode(0xF)
    # Tests that set_opcode sets values correctly
    self.assertEquals(LoadConstant_Instr.OPCODE, 0xF)
    self.assertRaises(MaskError, LoadConstant_Instr.set_opcode, 0x1F)
    # Tests that set_masks sets static values correctly
    self.assertEquals(6   , LoadConstant_Instr.REGISTER_MASK.width)
    self.assertEquals(0x3F, LoadConstant_Instr.REGISTER_MASK.mask)
    self.assertEquals(22  , LoadConstant_Instr.REGISTER_MASK.shift)
    self.assertEquals(6   , LoadConstant_Instr.CONSTANT_MASK.width)
    self.assertEquals(0x3F, LoadConstant_Instr.CONSTANT_MASK.mask)
    self.assertEquals(1   , LoadConstant_Instr.CONSTANT_MASK.shift)
  #----------------------------------------------------------------------------
  def test_static_masks(self):
    # Tests for negative register width
    self.assertRaises(RangeError, LoadConstant_Instr.set_masks,
                      register_width = -1,
                      register_shift = 22,
                      constant_width = 6,
                      constant_shift = 1)
    # Tests for too-large register shift
    self.assertRaises(OverlapError, LoadConstant_Instr.set_masks,
                      register_width = 6,
                      register_shift = 23,
                      constant_width = 6,
                      constant_shift = 1)
    # Tests for negative constant width
    self.assertRaises(RangeError, LoadConstant_Instr.set_masks,
                      register_width = 6,
                      register_shift = 22,
                      constant_width = -1,
                      constant_shift = 1)
    # Tests for too-large constant shift
    self.assertRaises(OverlapError, LoadConstant_Instr.set_masks,
                      register_width = 6,
                      register_shift = 22,
                      constant_width = 6,
                      constant_shift = 20)
  #----------------------------------------------------------------------------
  def test_init(self):
    # Tests for register bits outside of mask
    self.assertRaises(MaskError, LoadConstant_Instr,
                      register = 0xFF, constant = 0x11)
    # Tests for constant bits outside of mask
    self.assertRaises(MaskError, LoadConstant_Instr,
                      register = 0x1F, constant = 0xFF)
    # Tests that constructor sets data members correctly
    self.assertEquals(0x25, self.p.register)
    self.assertEquals(0x11, self.p.constant)
  #----------------------------------------------------------------------------
  def test_get_register(self):
    self.assertEquals(0x25 << 22, self.p.get_register())
  #----------------------------------------------------------------------------
  def test_get_constant(self):
    self.assertEquals(0x11 << 1, self.p.get_constant())
  #----------------------------------------------------------------------------
  def test_get_binary_charlist(self):
    self.assertEquals(
      ['\xD9', '\x40', '\x00', '\x22'],
      self.p.get_binary_charlist())
  #----------------------------------------------------------------------------
  def tearDown(self):
    del self.p
    
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_LoadConstant_Instr),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
