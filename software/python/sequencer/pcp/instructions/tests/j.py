# Module : j.py
# Package: pcp.instructions.tests
# Unit test for jump instruction class.

import unittest
from sequencer.pcp.instructions import *
from sequencer.pcp.instructions.j import *

#------------------------------------------------------------------------------
class Test_Jump_Instr(unittest.TestCase):

  def setUp(self):
    Word.set_masks(word_width = 64, address_width = 11)
    InstructionWord.set_opcode_mask(opcode_width = 6)
    self.i = InstructionWord()
    self.j = Jump_Instr(self.i)  # Create an empty instance to test methods
    Jump_Instr.set_opcode(0x1A)

  def test_static(self):
    # Tests that set_opcode sets values correctly
    self.assertEqual(Jump_Instr.OPCODE, 0x1A)

  def test_get_binary_charlist(self):
    # Set address so target can be resolved
    self.i.set_address(0x711)
    self.assertEquals(
      ['\x68', '\x00', '\x00', '\x00', '\x00', '\x00', '\x07', '\x11'],
      self.j.get_binary_charlist())

  def tearDown(self):
    del self.i
    del self.j
    Jump_Instr.set_opcode(0x17)
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_Jump_Instr)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)


