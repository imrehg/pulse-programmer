# Module : nop
# Package: pcp.instructions.tests
# Unit test for nop instruction class.

import unittest
from sequencer.pcp.instructions import *
from sequencer.pcp.instructions.nop import *

#------------------------------------------------------------------------------
class Test_Nop_Instr(unittest.TestCase):

  def setUp(self):
    self.n = Nop_Instr(False)  # Create an empty instance to test methods
    Nop_Instr.set_opcode(0x1A)

  def test_static(self):
    # Tests that set_opcode sets values correctly
    self.assertEqual(Nop_Instr.OPCODE, 0x1A)

  def test_collapsable(self):
    self.assertEquals(False, self.n.is_collapsable())

  def test_get_binary_charlist(self):
    # Set address so target can be resolved
    self.n.set_address(0x711)
    self.assertEquals(
      ['\x68', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00', '\x00'],
      self.n.get_binary_charlist())

  def tearDown(self):
    del self.n
    Nop_Instr.set_opcode(0x00)
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_Nop_Instr)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)

