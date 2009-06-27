# Module : output_mask
# Package: pcp.tests
# Unit tests for OutputMask module

import unittest
from sequencer.pcp             import *
from sequencer.pcp.bitmask     import *
from sequencer.pcp.output_mask import *

#------------------------------------------------------------------------------
class Test_OutputMask(unittest.TestCase):

  def setUp(self):
    self.o = OutputMask(mask_width  = 32,
                        bit_indices = (1, 3, 5, 7, 9, 11, 13, 15),
                        value       = 0x55)
    b1 = Bitmask(label = "b1", width = 1, shift = 2)
    b2 = Bitmask(label = "b2", width = 1, shift = 4)
    b3 = Bitmask(label = "b3", width = 1, shift = 6)
    self.o2 = OutputMask(mask_width = 32,
                         bit_tuples = [(b1, 1), (b2, 0), (b3, 1)])

  def test_init(self):
    self.assertEquals(8, self.o.get_size())
    self.assertEquals(32, self.o.get_mask_width())
    self.assertEquals(0xFFFF5555, self.o.get_clear_mask())
    self.assertEquals(0x00002222, self.o.get_set_mask())
    self.assertRaises(MaskError, OutputMask,
                      mask_width  = 32,
                      bit_indices = (1, 3, 5, 7, 9, 11, 13, 15),
                      value       = 0xFFF)

  def test_tuples(self):
    self.assertEquals(3, self.o2.get_size())
    self.assertEquals(0xFFFFFFAB, self.o2.get_clear_mask())
    self.assertEquals(0x00000044, self.o2.get_set_mask())

  def test_overlapping(self):
    b4 = Bitmask(label = "b4", width = 2, shift = 2)
    b5 = Bitmask(label = "b5", width = 3, shift = 4)
    b6 = Bitmask(label = "b6", width = 4, shift = 6)
    self.assertRaises(OverlapError, OutputMask,
                      mask_width = 32,
                      bit_tuples = [(b4, 0x2), (b5, 0x7), (b6, 0xF)])

  def test_mask(self):
    b4 = Bitmask(label = "b4", width = 2, shift = 2)
    b5 = Bitmask(label = "b5", width = 3, shift = 4)
    b6 = Bitmask(label = "b6", width = 4, shift = 7)
    self.assertRaises(MaskError, OutputMask,
                      mask_width = 32,
                      bit_tuples = [(b4, 0x7), (b5, 0x7), (b6, 0xF)])
    self.assertRaises(MaskError, OutputMask,
                      mask_width = 32,
                      bit_tuples = [(b4, 0x2), (b5, 0x10), (b6, 0xF)])
    self.assertRaises(MaskError, OutputMask,
                      mask_width = 32,
                      bit_tuples = [(b4, 0x2), (b5, 0x7), (b6, 0xFF)])

  def test_merge(self):
    o2 = OutputMask(mask_width  = 32,
                    bit_indices = (0, 2, 4, 6, 8, 10, 12, 14),
                    value       = 0xAA)
    o3 = self.o.merge(o2)
    self.assertEquals(0xFFFF0000, o3.get_clear_mask())
    self.assertEquals(0x00006666, o3.get_set_mask())

  def test_merge_error(self):
    o2 = OutputMask(mask_width  = 31,
                    bit_indices = (0, 2, 4, 6, 8, 10, 12, 14),
                    value       = 0xAA)
    self.assertRaises(WidthError, self.o.merge, o2)
    o3 = OutputMask(mask_width  = 32,
                    bit_indices = (1, 2, 4, 6, 8, 10, 12, 14),
                    value       = 0xAA)
    self.assertRaises(MergeError, self.o.merge, o3)

  def test_eq(self):
    self.assertEquals(False, self.o == self.o2)
    self.assertEquals(True, self.o == self.o)
    o3 = OutputMask(mask_width  = 32,
                    bit_indices = (1, 3, 5, 7, 9, 11, 13, 15),
                    value       = 0x55)
    self.assertEquals(True, self.o == o3)

  def test_split(self):
    o1 = OutputMask(mask_width  = 32,
                    bit_indices = (1, 3, 5, 7, 8, 10, 12, 14),
                    value       = 0x95)
    o2 = o1.split(sub_width = 8, index = 0)
    o3 = o1.split(sub_width = 8, index = 1)
    o4 = OutputMask(mask_width = 8, bit_indices = (1, 3, 5, 7),
                    value = 0x05)
    self.assertEquals(o2, o4)
    print("o3 " + hex(o3.value))
    self.assertEquals(o3, OutputMask(mask_width  = 8,
                                     bit_indices = (0, 2, 4, 6),
                                     value       = 0x09))

  def tearDown(self):
    del self.o

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_OutputMask)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
