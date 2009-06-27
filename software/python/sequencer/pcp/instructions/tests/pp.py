# Module : pp
# Package: pcp.instructions.tests
# Unit test for pulse-phase instruction class.

import unittest
from sequencer.pcp.output_mask     import *
from sequencer.pcp.output_register import *
from sequencer.pcp.instructions    import *
from sequencer.pcp.instructions.pp import *

#==============================================================================
class Test_PulsePhase_Instr(unittest.TestCase):
  #----------------------------------------------------------------------------
  def setUp(self):
    Word.set_masks(word_width = 32, address_width = 19)
    InstructionWord.set_opcode_mask(opcode_width = 4)
    PulsePhase_Instr.set_opcode(opcode = 0xD)
    PulsePhase_Instr.set_masks(phase_data_width      = 1,
                               phase_data_shift      = 16,
                               output_width          = 15,
                               output_shift          = 1,
                               register_width        = 4,
                               register_shift        = 22,
                               phase_select_shift    = 17,
                               hw_phase_adjust_width = 29)
    self.bitmask = Bitmask(label = "Non-phase Data",
                           width = 13,
                           shift = 1)
    self.output_reg = [OutputRegister(reg_width = 15),
                       OutputRegister(reg_width = 15)]
    self.output_mask = OutputMask(mask_width = 32,
                                  bit_tuples = [(self.bitmask, 0x1234)])
    # Create an empty instance to test methods
    self.p  = PulsePhase_Instr(output_mask  = self.output_mask,
                               output_reg   = self.output_reg ,
                               register     = 0x4             ,
                               phase_select = 0x1             )
  #----------------------------------------------------------------------------
  def test_static(self):
    PulsePhase_Instr.set_opcode(0xF)
    # Tests that set_opcode sets values correctly
    self.assertEquals(PulsePhase_Instr.OPCODE, 0xF)
    self.assertRaises(MaskError, PulsePhase_Instr.set_opcode, 0x1F)
    # Tests that set_trigger_mask sets static values correctly
    self.assertEquals(1     , PulsePhase_Instr.PHASE_DATA_MASK.width)
    self.assertEquals(0x1   , PulsePhase_Instr.PHASE_DATA_MASK.mask)
    self.assertEquals(16    , PulsePhase_Instr.PHASE_DATA_MASK.shift)
    self.assertEquals(15    , PulsePhase_Instr.OUTPUT_MASK.width)
    self.assertEquals(0x7FFF, PulsePhase_Instr.OUTPUT_MASK.mask)
    self.assertEquals(1     , PulsePhase_Instr.OUTPUT_MASK.shift)
    self.assertEquals(4     , PulsePhase_Instr.REGISTER_MASK.width)
    self.assertEquals(0xF   , PulsePhase_Instr.REGISTER_MASK.mask)
    self.assertEquals(22    , PulsePhase_Instr.REGISTER_MASK.shift)
    self.assertEquals(5     , PulsePhase_Instr.PHASE_SELECT_MASK.width)
    self.assertEquals(0x1F  , PulsePhase_Instr.PHASE_SELECT_MASK.mask)
    self.assertEquals(17    , PulsePhase_Instr.PHASE_SELECT_MASK.shift)
  #----------------------------------------------------------------------------
  def test_static_masks(self):
    # Tests for negative output width
    self.assertRaises(RangeError, PulsePhase_Instr.set_masks,
                      phase_data_width      = 1 ,
                      phase_data_shift      = 16,
                      output_width          = -1,
                      output_shift          = 1 ,
                      register_width        = 4 ,
                      register_shift        = 22,
                      phase_select_shift    = 17,
                      hw_phase_adjust_width = 29)
    # Tests for too-large output shift
    self.assertRaises(OverlapError, PulsePhase_Instr.set_masks,
                      phase_data_width      = 1 ,
                      phase_data_shift      = 16,
                      output_width          = 15,
                      output_shift          = 3 ,
                      register_width        = 4,
                      register_shift        = 22,
                      phase_select_shift    = 17,
                      hw_phase_adjust_width = 29)
    # Tests for negative register width
    self.assertRaises(RangeError, PulsePhase_Instr.set_masks,
                      phase_data_width      = 1 ,
                      phase_data_shift      = 16,
                      output_width          = 15,
                      output_shift          = 1 ,
                      register_width        = -1,
                      register_shift        = 22,
                      phase_select_shift    = 17,
                      hw_phase_adjust_width = 29)
    # Tests for too-large register shift
    self.assertRaises(OverlapError, PulsePhase_Instr.set_masks,
                      phase_data_width      = 1 ,
                      phase_data_shift      = 16,
                      output_width          = 15,
                      output_shift          = 1 ,
                      register_width        = 4,
                      register_shift        = 25,
                      phase_select_shift    = 17,
                      hw_phase_adjust_width = 29)
  #----------------------------------------------------------------------------
  def test_init(self):
    # Tests for non-matching output register width
    reg = [OutputRegister(reg_width = 16), OutputRegister(reg_width = 16)]
    self.assertRaises(WidthError, PulsePhase_Instr,
                      output_mask  = self.output_mask,
                      output_reg   = reg,
                      register     = 0x03,
                      phase_select = 0x1)
    # Tests for register bits outside of mask
    self.assertRaises(MaskError, PulsePhase_Instr,
                      output_mask  = self.output_mask,
                      output_reg   = self.output_reg,
                      register     = 0xFF,
                      phase_select = 0x1)
    # Tests for select bits outside of mask
    self.assertRaises(MaskError, PulsePhase_Instr,
                      output_mask  = self.output_mask,
                      output_reg   = self.output_reg,
                      register     = 0x03,
                      phase_select = 0x3F)
    # Tests that accessors set values correctly
    self.assertEquals(self.output_mask, self.p.output_mask )
    self.assertEquals(self.output_reg , self.p.output_reg  )
    self.assertEquals(0x4             , self.p.register    )
    self.assertEquals(0x1             , self.p.phase_select)
  #----------------------------------------------------------------------------
  def test_get_register(self):
    self.assertEquals(0x4 << 22, self.p.get_register())
  #----------------------------------------------------------------------------
  def test_get_phase_select(self):
    self.assertEquals(0x1 << 17, self.p.get_phase_select())
  #----------------------------------------------------------------------------
  def test_get_binary_charlist(self):
    self.assertEquals(
      ['\xD1', '\x02', '\x24', '\x68'],
      self.p.get_binary_charlist())
  #----------------------------------------------------------------------------
  def tearDown(self):
    del self.p
    del self.output_reg
    del self.output_mask
    del self.bitmask
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_PulsePhase_Instr),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
