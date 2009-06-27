# Module : sub
# Package: pcp.instructions.tests
# Unit test for subroutine call instruction class.

import unittest
from sequencer.pcp.instructions      import *
from sequencer.pcp.instructions.insn import *
from sequencer.pcp.instructions.sub  import *

#==============================================================================
class Test_SubroutineCall_Instr(unittest.TestCase):
  #----------------------------------------------------------------------------
  def setUp(self):
    Word.set_masks(word_width = 32, address_width = 19)
    InstructionWord.set_opcode_mask(opcode_width = 4)
    SubroutineCall_Instr.set_opcode(opcode = 0xD)
    # Create an empty instance to test methods
    self.i = InstructionWord()
    self.i.set_address(0x34567)
    self.p = SubroutineCall_Instr(target = self.i)
  #----------------------------------------------------------------------------
  def test_static(self):
    SubroutineCall_Instr.set_opcode(0xF)
    # Tests that set_opcode sets values correctly
    self.assertEquals(SubroutineCall_Instr.OPCODE, 0xF)
    self.assertRaises(MaskError, SubroutineCall_Instr.set_opcode, 0x1F)
  #----------------------------------------------------------------------------
  def test_init(self):
    # Tests for address bits outside of mask
    pass
  #----------------------------------------------------------------------------
  def test_get_binary_charlist(self):
    self.assertEquals(
      ['\xD0', '\x03', '\x45', '\x67'],
      self.p.get_binary_charlist())
  #----------------------------------------------------------------------------
  def tearDown(self):
    del self.p
    del self.i
    
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_SubroutineCall_Instr),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
