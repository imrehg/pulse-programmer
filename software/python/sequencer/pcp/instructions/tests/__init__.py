# Module : __init__.py
# Package: pcp.instructions.tests
# Base module for unit tests in this package

import unittest
from sequencer.pcp.instructions         import *
from sequencer.pcp.instructions.insn    import *
from sequencer.pcp.instructions.program import *

#------------------------------------------------------------------------------
class Test_Word(unittest.TestCase):

  def setUp(self):
    self.w = Word() # Create an empty instance to test methods
    # Tests that static methods are callable.
    Word.set_masks(word_width = 64, address_width = 12)

  def test_static(self):
    # Tests that set_address_mask sets values correctly
    self.assertEqual(Word.WIDTH, 64) # Should still be 64
    self.assertEqual(Word.ADDRESS_WIDTH, 12)
    self.assertEqual(Word.ADDRESS_MASK, 0xFFF)

  def test_init(self):
    # Should not have address yet
    self.assertRaises(AttributeError, self.w.get_address)
    # Check that AttributeError is thrown because resolve_value is undefined
    self.assertRaises(AttributeError, self.w.get_binary_charlist)

  def test_address(self):
    # Set a valid address now
    self.w.set_address(0x345)
    # Verify address is set
    self.assertEquals(self.w.get_address(), 0x345)
    # Set an invalid address and make sure RuntimeError is raised
    self.assertRaises(MaskError, self.w.set_address, 0x1234)
    # Verify old address is still set
    self.assertEquals(self.w.get_address(), 0x345)

  def tearDown(self):
    # Restore class defaults
    Word.set_masks(word_width = 64, address_width = 11)
    del self.w

#------------------------------------------------------------------------------
class Test_InstructionWord(unittest.TestCase):

  def setUp(self):
    self.i = InstructionWord() # Empty instance to test methods
    InstructionWord.set_opcode_mask(7)

  def test_static(self):
    self.assertEquals(InstructionWord.OPCODE_WIDTH, 7)
    self.assertEquals(InstructionWord.OPCODE_MASK, 0x7F)

  def test_set_opcode_mask(self):
    self.assertRaises(RangeError, InstructionWord.set_opcode_mask, 65)

  def test_check_opcode(self):
    self.assertEquals(None, InstructionWord.check_opcode(0x60))
    self.assertRaises(MaskError, InstructionWord.check_opcode, 0xFF)

  def test_get_opcode(self):
    # There should be no opcode yet in this abstract InstructionWord
    self.assertRaises(AttributeError, self.i.get_opcode)
    # Assign an opcode just to test correct bitshifting
    self.i.OPCODE = 0x65
    self.assertEquals(0xCA00000000000000, self.i.get_opcode())

  def test_is_instruction(self):
    self.assertEquals(True, self.i.is_instruction())

  def test_get_binary_charlist(self):
    # Check that AttributeError is thrown because resolve_value is undefined
    self.assertRaises(AttributeError, self.i.get_binary_charlist)

  def tearDown(self):
    del self.i
    # Restore defaults
    InstructionWord.set_opcode_mask(6)
  
#------------------------------------------------------------------------------
class Test_DataWord(unittest.TestCase):

  def setUp(self):
    self.d = DataWord(0x12345678ABCDEF00) # Empty instance to test methods

  def test_init(self):
    self.assertEquals(0x12345678ABCDEF00, self.d.value)

  def test_is_instruction(self):
    self.assertEquals(False, self.d.is_instruction())

  def test_get_binary_charlist(self):
    self.assertEquals(
      ['\x12', '\x34', '\x56', '\x78', '\xAB', '\xCD', '\xEF', '\x00'],
      self.d.get_binary_charlist())
    
#------------------------------------------------------------------------------
class Test_TargetInstruction(unittest.TestCase):

  def setUp(self):
    self.i = InstructionWord()
    self.t = TargetInstruction(self.i, True) # Instance to test methods

  def test_init(self):
    # Passing a target of None should cause an error
    self.assertRaises(AttributeError, TargetInstruction, None, True)
    d = DataWord(0x00)
    # Passing in a non-instruction target should cause a RuntimeError
    self.assertRaises(RuntimeError, TargetInstruction, d, True)

  def test_resolve_value(self):
    # Set address so target can be resolved
    self.i.set_address(0x711)
    # Set opcode so TargetInstruction can be resolved
    self.t.OPCODE = 0x34
    self.t.resolve_value()
    self.assertEquals(0xD000000000000711, self.t.value)

  def tearDown(self):
    del self.i
    del self.t

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_Word),
  unittest.makeSuite(Test_InstructionWord),
  unittest.makeSuite(Test_DataWord),
  unittest.makeSuite(Test_TargetInstruction)
  ))

# Run all sub-test modules in this package by importing them
import sequencer.pcp.instructions.tests.nop
all_suites.addTest(nop.all_suites)
import sequencer.pcp.instructions.tests.halt
all_suites.addTest(halt.all_suites)
import sequencer.pcp.instructions.tests.j
all_suites.addTest(j.all_suites)
import sequencer.pcp.instructions.tests.btr
all_suites.addTest(btr.all_suites)
import sequencer.pcp.instructions.tests.ld64i
all_suites.addTest(ld64i.all_suites)
import sequencer.pcp.instructions.tests.p
all_suites.addTest(p.all_suites)
import sequencer.pcp.instructions.tests.pr
all_suites.addTest(pr.all_suites)
import sequencer.pcp.instructions.tests.bdec
all_suites.addTest(bdec.all_suites)
import sequencer.pcp.instructions.tests.wait
all_suites.addTest(wait.all_suites)
import sequencer.pcp.instructions.tests.pp
all_suites.addTest(pp.all_suites)
import sequencer.pcp.instructions.tests.lp
all_suites.addTest(lp.all_suites)
import sequencer.pcp.instructions.tests.ldc
all_suites.addTest(ldc.all_suites)
import sequencer.pcp.instructions.tests.sub
all_suites.addTest(sub.all_suites)
import sequencer.pcp.instructions.tests.ret
all_suites.addTest(ret.all_suites)
import sequencer.pcp.instructions.tests.program
all_suites.addTest(program.all_suites)

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
