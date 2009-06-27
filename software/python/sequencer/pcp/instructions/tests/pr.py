# Module : pr.py
# Package: pcp.instructions.tests
# Unit test for pulse-register instruction class.

import unittest
from sequencer.pcp.instructions    import *
from sequencer.pcp.instructions.pr import *

#------------------------------------------------------------------------------
class Test_PulseReg_Instr(unittest.TestCase):

  #----------------------------------------------------------------------------
  def setUp(self):
    Word.set_masks(word_width = 64, address_width = 11)
    InstructionWord.set_opcode_mask(opcode_width = 6)
    # Create an empty instance to test methods
    self.p = PulseReg_Instr(0x1F, 0x0E)
  #----------------------------------------------------------------------------
  def test_static(self):
    PulseReg_Instr.set_opcode(0x1A)
    # Tests that set_opcode sets values correctly
    self.assertEquals(PulseReg_Instr.OPCODE, 0x1A)
    PulseReg_Instr.set_masks(4, 46, 6, 40)
    # Tests that set_trigger_mask sets static values correctly
    self.assertEquals(4   , PulseReg_Instr.OUTPUT_REGISTER_MASK.width)
    self.assertEquals(0xF , PulseReg_Instr.OUTPUT_REGISTER_MASK.mask)
    self.assertEquals(46  , PulseReg_Instr.OUTPUT_REGISTER_MASK.shift)
    self.assertEquals(6   , PulseReg_Instr.DURATION_REGISTER_MASK.width)
    self.assertEquals(0x3F, PulseReg_Instr.DURATION_REGISTER_MASK.mask)
    self.assertEquals(40  , PulseReg_Instr.DURATION_REGISTER_MASK.shift)

    # Tests that incorrect mask settings causes errors
    self.assertRaises(RangeError, PulseReg_Instr.set_masks,
                      output_reg_width   = -1,
                      output_reg_shift   = 46,
                      duration_reg_width = 4,
                      duration_reg_shift = 40)
    self.assertRaises(OverlapError, PulseReg_Instr.set_masks,
                      output_reg_width   = 4,
                      output_reg_shift   = 60,
                      duration_reg_width = 4,
                      duration_reg_shift = 40)
    self.assertRaises(RangeError, PulseReg_Instr.set_masks,
                      output_reg_width = 4,
                      output_reg_shift = 46,
                      duration_reg_width = -1,
                      duration_reg_shift = 40)
    self.assertRaises(OverlapError, PulseReg_Instr.set_masks,
                      output_reg_width = 4,
                      output_reg_shift = 46,
                      duration_reg_width = 4,
                      duration_reg_shift = 60)
    self.assertRaises(OverlapError, PulseReg_Instr.set_masks,
                      output_reg_width = 4,
                      output_reg_shift = 46,
                      duration_reg_width = 6,
                      duration_reg_shift = 41)
  #----------------------------------------------------------------------------
  def test_init(self):
    # Tests validation of output, duration, select against previously set masks
    self.assertRaises(MaskError, PulseReg_Instr, 0x7F, 0x01)
    self.assertRaises(MaskError, PulseReg_Instr, 0x1F, 0xFF)
    self.assertEquals(0x1F, self.p.output_reg)
    self.assertEquals(0x0E, self.p.duration_reg)
  #----------------------------------------------------------------------------
  def test_get_output_reg(self):
    self.assertEquals(0x00003E0000000000, self.p.get_output_reg())
  #----------------------------------------------------------------------------
  def test_get_duration_reg(self):
    self.assertEquals(0x0003800000000000, self.p.get_duration_reg())
  #----------------------------------------------------------------------------
  def test_get_binary_charlist(self):
    self.assertEquals(
      ['\x74', '\x03', '\xBE', '\x00', '\x00', '\x00', '\x00', '\x00'],
      self.p.get_binary_charlist())
  #----------------------------------------------------------------------------
  def tearDown(self):
    del self.p
    PulseReg_Instr.set_opcode(0x1D)
    PulseReg_Instr.set_masks(5, 41, 5, 46)
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_PulseReg_Instr)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
