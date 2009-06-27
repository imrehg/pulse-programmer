# Module : p
# Package: pcp.instructions.tests
# Unit test for pulse-immediate instruction class.

import unittest
from sequencer.pcp.output_mask    import *
from sequencer.pcp.instructions   import *
from sequencer.pcp.instructions.p import *

#==============================================================================
class Test_PulseImmed_Instr(unittest.TestCase):

  #----------------------------------------------------------------------------
  def setUp(self):
    Word.set_masks(word_width = 64, address_width = 11)
    InstructionWord.set_opcode_mask(opcode_width = 6)
    PulseImmed_Instr.set_opcode(0x1C)
    self.b2 = Bitmask(label = "b2",
                     width = 1,
                     shift = 57)
    PulseImmed_Instr.set_masks(output_width   = 32,
                               output_shift   = 0,
                               duration_width = 23,
                               duration_shift = 33,
                               select_shift   = 32,
                               flag_masks     = [self.b2])
    # Create an empty instance to test methods
    self.o  = OutputRegister(reg_width = 32)
    self.m  = OutputMask(mask_width  = 32,
                         bit_indices = (8, 7, 6, 5, 4, 3, 2, 1),
                         value       = 0x7D)
    self.m2 = OutputMask(mask_width  = 31,
                         bit_indices = (1, 2, 3, 4),
                         value       = 0x7)
    self.m5 = OutputMask(mask_width  = 32,
                         bit_indices = (8, 7, 6, 5, 4, 3, 2, 1),
                         value       = 0x7D)
    self.p  = PulseImmed_Instr(output_mask = self.m5,
                               output_reg  = [self.o, self.o],
                               duration    = 0x12345)
    self.b = Bitmask(label = "b",
                     width = 29,
                     shift = 32)
    self.m6 = OutputMask(mask_width  = 64,
                         bit_tuples = [(self.b, 0x12345678)])
    self.p2  = PulseImmed_Instr(output_mask = self.m6,
                                output_reg  = [self.o, self.o],
                                duration    = 0x12345)
    self.p3  = PulseImmed_Instr(output_mask = self.m6,
                                output_reg  = [self.o, self.o],
                                duration    = 0x12345,
                                flags       = [(self.b2, 0x1)])
  #----------------------------------------------------------------------------
  # Tests that valid mask settings are set correctly.
  def test_static(self):
    PulseImmed_Instr.set_opcode(0x1A)
    # Tests that set_opcode sets values correctly
    self.assertEquals(PulseImmed_Instr.OPCODE, 0x1A)
    PulseImmed_Instr.set_masks(output_width   = 29,
                               output_shift   = 1,
                               duration_width = 20,
                               duration_shift = 34,
                               select_shift   = 32,
                               flag_masks     = [self.b2])
    # Tests that set_trigger_mask sets static values correctly
    self.assertEquals(29,         PulseImmed_Instr.OUTPUT_MASK.width)
    self.assertEquals(0x1FFFFFFF, PulseImmed_Instr.OUTPUT_MASK.mask)
    self.assertEquals(1,          PulseImmed_Instr.OUTPUT_MASK.shift)
    self.assertEquals(20,         PulseImmed_Instr.DURATION_MASK.width)
    self.assertEquals(0xFFFFF,    PulseImmed_Instr.DURATION_MASK.mask)
    self.assertEquals(34,         PulseImmed_Instr.DURATION_MASK.shift)
    self.assertEquals(1,          PulseImmed_Instr.SELECT_MASK.width)
    self.assertEquals(0x01,       PulseImmed_Instr.SELECT_MASK.mask)
    self.assertEquals(32,         PulseImmed_Instr.SELECT_MASK.shift)
    self.assertEquals([self.b2],  PulseImmed_Instr.FLAG_MASKS)
  #----------------------------------------------------------------------------
  # Tests that invalid mask settings are caught.
  def test_static_invalid(self):
    # Tests negative output width
    self.assertRaises(RangeError, PulseImmed_Instr.set_masks,
                      output_width   = -1,
                      output_shift   = 1,
                      duration_width = 20,
                      duration_shift = 34,
                      select_shift   = 32)
    # Tests too-large output width
    self.assertRaises(RangeError, PulseImmed_Instr.set_masks,
                      output_width   = 29,
                      output_shift   = 40,
                      duration_width = 20,
                      duration_shift = 34,
                      select_shift   = 32)
    # Test negative duration width
    self.assertRaises(RangeError, PulseImmed_Instr.set_masks,
                      output_width   = 29,
                      output_shift   = 1,
                      duration_width = -1,
                      duration_shift = 34,
                      select_shift   = 32)
    # Tests too-large duration width
    self.assertRaises(OverlapError, PulseImmed_Instr.set_masks,
                      output_width   = 29,
                      output_shift   = 1,
                      duration_width = 20,
                      duration_shift = 40,
                      select_shift   = 32)
    # Tests too-large select shift
    self.assertRaises(OverlapError, PulseImmed_Instr.set_masks,
                      output_width   = 29,
                      output_shift   = 1,
                      duration_width = 20,
                      duration_shift = 34,
                      select_shift   = 60)
    self.assertRaises(OverlapError, PulseImmed_Instr.set_masks,
                      output_width   = 34,
                      output_shift   = 0,
                      duration_width = 20,
                      duration_shift = 33,
                      select_shift   = 32)
    self.assertRaises(OverlapError, PulseImmed_Instr.set_masks,
                      output_width   = 29,
                      output_shift   = 1,
                      duration_width = 20,
                      duration_shift = 34,
                      select_shift   = 34)
  #----------------------------------------------------------------------------
  def test_init(self):
#    self.assertRaises(
#    PulseImmed_Instr(self.m, 0x03, 0x1, self.o)
    p3 = PulseImmed_Instr(output_mask = self.m2,
                          duration    = 0x03,
                          output_reg  = [self.o])
    self.assertRaises(SelectError, p3.resolve_value)
    o2 = OutputRegister(31)
    self.assertRaises(WidthError, PulseImmed_Instr,
                      output_mask = self.m2,
                      duration    = 0x03,
                      output_reg  = [o2])
    self.assertEquals([(self.b2, 0x1)], self.p3.flags)
  #----------------------------------------------------------------------------
  def test_init_reg(self):
    PulseImmed_Instr.set_masks(output_width   = 32,
                               output_shift   = 1,
                               duration_width = 22,
                               duration_shift = 34,
                               select_shift   = 33)
    
    p2 = PulseImmed_Instr(output_mask = self.m,
                          duration    = 0x03,
                          output_reg  = [self.o]
                          )
    # p2 should not have output_value attribute yet before resolving value
    self.assertRaises(AttributeError, p2.get_output)
    p2.resolve_value()
    self.assertEquals(0x000000000000017C, p2.get_output())
  #----------------------------------------------------------------------------
  def test_zero_output(self):
    # Tests that a "set" value of 0 will be generated if it is different than
    # the previous (1) value
    p2 = PulseImmed_Instr(output_mask = self.m,
                          duration    = 0x03,
                          output_reg  = [self.o]
                          )
    p2.resolve_value()
    self.assertEquals(0x000000000000017C, self.o.get_value())
    # Check that resolving only generates (mutates) the output register once.
    p2.resolve_value()
    self.assertEquals(0x000000000000017C, self.o.get_value())
    m2  = OutputMask(32, (8, 7, 6, 5, 4, 3, 2, 1), 0x7C)
    p3 = PulseImmed_Instr(output_mask = m2,
                          duration    = 0x03,
                          output_reg  = [self.o]
                          )
    p3.resolve_value()
    self.assertEquals(0x000000000000007C, self.o.get_value())
  #----------------------------------------------------------------------------
  def test_get_output(self):
    self.p2.resolve_value()
    self.assertEquals(0x0000000012345678, self.p2.get_output())
  #----------------------------------------------------------------------------
  def test_get_duration(self):
    self.assertEquals(0x0002468A00000000, self.p.get_duration())
  #----------------------------------------------------------------------------
  def test_get_select(self):
    self.p2.resolve_value()
    self.assertEquals(0x000000100000000, self.p2.get_select())
  #----------------------------------------------------------------------------
  def test_get_flags(self):
    self.p3.resolve_value()
    self.assertEquals(0x1 << 57, self.p3.get_flags())
  #----------------------------------------------------------------------------
  def test_get_binary_charlist(self):
    self.p2.resolve_value()
    self.assertEquals(
      ['\x70', '\x02', '\x46', '\x8B', '\x12', '\x34', '\x56', '\x78'],
      self.p2.get_binary_charlist())
  #----------------------------------------------------------------------------
  def tearDown(self):
    del self.b
    del self.b2
    del self.p
    del self.p2
    del self.p3
    del self.o
    del self.m
    del self.m5
    del self.m2
    del self.m6
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_PulseImmed_Instr)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
