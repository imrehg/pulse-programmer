# Module : lp
# Package: pcp.instructions.tests
# Unit test for branch-decrement instruction class.

import unittest
from sequencer.pcp.instructions      import *
from sequencer.pcp.instructions.lp   import *

#==============================================================================
class Test_LoadPhase_Instr(unittest.TestCase):
  #----------------------------------------------------------------------------
  def setUp(self):
    Word.set_masks(word_width = 32, address_width = 19)
    InstructionWord.set_opcode_mask(opcode_width = 4)
    LoadPhase_Instr.set_opcode(opcode = 0xD)
    LoadPhase_Instr.set_masks(constant_width            = 8,
                              constant_shift            = 1,
                              register_width            = 3,
                              register_shift            = 25,
                              select_shift              = 15,
                              wren_flag_shift           = 21,
                              addend_flag_shift         = 22,
                              set_current_flag_shift    = 23,
                              hw_phase_data_width = 31)
    # Create an empty instance to test methods
    self.p  = LoadPhase_Instr(constant = 0x34,
                              register = 0x7,
                              select   = 0x3,
                              wren_flag = 1,
                              addend_flag = 1,
                              set_current_flag = 1)
  #----------------------------------------------------------------------------
  def test_static(self):
    LoadPhase_Instr.set_opcode(0xF)
    # Tests that set_opcode sets values correctly
    self.assertEquals(LoadPhase_Instr.OPCODE, 0xF)
    self.assertRaises(MaskError, LoadPhase_Instr.set_opcode, 0x1F)
    # Tests that set_masks sets static values correctly
    self.assertEquals(8   , LoadPhase_Instr.CONSTANT_MASK.width)
    self.assertEquals(0xFF, LoadPhase_Instr.CONSTANT_MASK.mask)
    self.assertEquals(1   , LoadPhase_Instr.CONSTANT_MASK.shift)
    self.assertEquals(3   , LoadPhase_Instr.REGISTER_MASK.width)
    self.assertEquals(0x7 , LoadPhase_Instr.REGISTER_MASK.mask)
    self.assertEquals(25  , LoadPhase_Instr.REGISTER_MASK.shift)
    self.assertEquals(2   , LoadPhase_Instr.SELECT_MASK.width)
    self.assertEquals(0x3 , LoadPhase_Instr.SELECT_MASK.mask)
    self.assertEquals(15  , LoadPhase_Instr.SELECT_MASK.shift)
    self.assertEquals(21  , LoadPhase_Instr.WREN_FLAG_MASK.shift)
    self.assertEquals(22  , LoadPhase_Instr.ADDEND_FLAG_MASK.shift)
    self.assertEquals(23  , LoadPhase_Instr.SET_CURRENT_FLAG_MASK.shift)
  #----------------------------------------------------------------------------
  def test_static_masks(self):
    # Tests for negative constant width
    self.assertRaises(RangeError, LoadPhase_Instr.set_masks,
                      constant_width         = -1,
                      constant_shift         = 1,
                      register_width         = 3,
                      register_shift         = 25,
                      select_shift           = 15,
                      wren_flag_shift        = 21,
                      addend_flag_shift      = 22,
                      set_current_flag_shift = 23,
                      hw_phase_data_width    = 31)
    # Tests for too-large constant shift
    self.assertRaises(OverlapError, LoadPhase_Instr.set_masks,
                      constant_width         = 14,
                      constant_shift         = 3,
                      register_width         = 3,
                      register_shift         = 25,
                      select_shift           = 15,
                      wren_flag_shift        = 21,
                      addend_flag_shift      = 22,
                      set_current_flag_shift = 23,
                      hw_phase_data_width    = 31)
    # Tests for negative register width.
    self.assertRaises(RangeError, LoadPhase_Instr.set_masks,
                      constant_width         = 14,
                      constant_shift         = 1,
                      register_width         = -1,
                      register_shift         = 25,
                      select_shift           = 15,
                      wren_flag_shift        = 21,
                      addend_flag_shift      = 22,
                      set_current_flag_shift = 23,
                      hw_phase_data_width    = 31)
    # Tests for too-large register shift.
    self.assertRaises(OverlapError, LoadPhase_Instr.set_masks,
                      constant_width         = 14,
                      constant_shift         = 1,
                      register_width         = 3,
                      register_shift         = 27,
                      select_shift           = 15,
                      wren_flag_shift        = 21,
                      addend_flag_shift      = 22,
                      set_current_flag_shift = 23,
                      hw_phase_data_width    = 31)
    # Tests for too-large select shift.
    self.assertRaises(OverlapError, LoadPhase_Instr.set_masks,
                      constant_width         = 8,
                      constant_shift         = 1,
                      register_width         = 3,
                      register_shift         = 25,
                      select_shift           = 20,
                      wren_flag_shift        = 21,
                      addend_flag_shift      = 22,
                      set_current_flag_shift = 23,
                      hw_phase_data_width    = 31)
    # Tests for negative wren flag shift.
    self.assertRaises(RangeError, LoadPhase_Instr.set_masks,
                      constant_width         = 14,
                      constant_shift         = 1,
                      register_width         = 3,
                      register_shift         = 25,
                      select_shift           = 15,
                      wren_flag_shift        = -1,
                      addend_flag_shift      = 22,
                      set_current_flag_shift = 23,
                      hw_phase_data_width    = 31)
    # Tests for too-large addend flag shift
    self.assertRaises(OverlapError, LoadPhase_Instr.set_masks,
                      constant_width         = 14,
                      constant_shift         = 1,
                      register_width         = 3,
                      register_shift         = 25,
                      select_shift           = 15,
                      wren_flag_shift        = 21,
                      addend_flag_shift      = 23,
                      set_current_flag_shift = 23,
                      hw_phase_data_width    = 31)
    # Tests for too-large set current flag shift
    self.assertRaises(OverlapError, LoadPhase_Instr.set_masks,
                      constant_width         = 14,
                      constant_shift         = 1,
                      register_width         = 3,
                      register_shift         = 25,
                      select_shift           = 15,
                      wren_flag_shift        = 21,
                      addend_flag_shift      = 22,
                      set_current_flag_shift = 25,
                      hw_phase_data_width    = 31)
  #----------------------------------------------------------------------------
  def test_init(self):
    # Tests for constant bits outside of mask
    self.assertRaises(MaskError, LoadPhase_Instr,
                      constant         = 0xA234,
                      register         = 0x7,
                      select           = 0x7,
                      wren_flag        = 1,
                      addend_flag      = 1,
                      set_current_flag = 1)
    # Tests for register bits outside of mask
    self.assertRaises(MaskError, LoadPhase_Instr,
                      constant         = 0x1234,
                      register         = 0xF,
                      select           = 0x7,
                      wren_flag        = 1,
                      addend_flag      = 1,
                      set_current_flag = 1)
    # Tests for select bits outside of mask
    self.assertRaises(MaskError, LoadPhase_Instr,
                      constant         = 0x1234,
                      register         = 0x7,
                      select           = 0x8,
                      wren_flag        = 0x1,
                      addend_flag      = 0x1,
                      set_current_flag = 0x1)
    # Tests for wren flag bits outside of mask
    self.assertRaises(MaskError, LoadPhase_Instr,
                      constant         = 0x1234,
                      register         = 0x7,
                      select           = 0x7,
                      wren_flag        = 0x3,
                      addend_flag      = 0x1,
                      set_current_flag = 0x1)
    # Tests for addend flag bits outside of mask
    self.assertRaises(MaskError, LoadPhase_Instr,
                      constant         = 0x1234,
                      register         = 0x7,
                      select           = 0x7,
                      wren_flag        = 0x1,
                      addend_flag      = 0x3,
                      set_current_flag = 0x1)
    # Tests for set current flag bits outside of mask
    self.assertRaises(MaskError, LoadPhase_Instr,
                      constant         = 0x1234,
                      register         = 0x7,
                      select           = 0x7,
                      wren_flag        = 0x1,
                      addend_flag      = 0x1,
                      set_current_flag = 0x3)
  #----------------------------------------------------------------------------
  def test_get_constant(self):
    self.assertEquals(0x34 << 1, self.p.get_constant())
  #----------------------------------------------------------------------------
  def test_get_register(self):
    self.assertEquals(0x7 << 25, self.p.get_register())
  #----------------------------------------------------------------------------
  def test_get_select(self):
    self.assertEquals(0x3 << 15, self.p.get_select())
  #----------------------------------------------------------------------------
  def test_get_wren_flag(self):
    self.assertEquals(0x1 << 21, self.p.get_wren_flag())
  #----------------------------------------------------------------------------
  def test_get_addend_flag(self):
    self.assertEquals(0x1 << 22, self.p.get_addend_flag())
  #----------------------------------------------------------------------------
  def test_get_set_current(self):
    self.assertEquals(0x1 << 23, self.p.get_set_current_flag())
  #----------------------------------------------------------------------------
  def test_get_binary_charlist(self):
    self.assertEquals(
      ['\xDE', '\xE1', '\x80', '\x68'],
      self.p.get_binary_charlist())
  #----------------------------------------------------------------------------
  def tearDown(self):
    del self.p
    
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_LoadPhase_Instr),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
