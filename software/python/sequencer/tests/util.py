# Module : util.py
# Package: sequencer.tests
# Test for base functions in util.

import unittest
from sequencer.util import *

#------------------------------------------------------------------------------
class Test_BaseFunctions(unittest.TestCase):

  def test_generate_mask(self):
    self.assertEqual(generate_mask(7), 0x7F)
    self.assertEqual(generate_mask(32), 0xFFFFFFFF)

  # Tests total and sub widths which are not powers-of-two.
  def test_is_subcontained_strange(self):
    self.assertEquals(0, is_subcontained(total_width = 30,
                                         sub_width   = 15,
                                         value       = 0x7FFF))
    self.assertEquals(2, is_subcontained(total_width = 60,
                                         sub_width   = 15,
                                         value       = 0xC0000000))

  # Tests for TotalContainmentException
  def test_is_subcontained_total(self):
    self.assertRaises(TotalContainmentException, is_subcontained,
                      total_width = 10,
                      sub_width   =  5,
                      value       =  0)

  def test_is_subcontained(self):
    self.assertEquals(1, is_subcontained(total_width = 64,
                                         sub_width   = 32,
                                         value       = 0xFFFFFFFF00000000))
    self.assertEquals(0, is_subcontained(total_width = 64,
                                         sub_width   = 32,
                                         value       = 0x00000000FFFFFFFF))
    self.assertEquals(2, is_subcontained(total_width = 64,
                                         sub_width   = 16,
                                         value       = 0x000000FF00000000))
    self.assertEquals(4, is_subcontained(total_width = 64,
                                         sub_width   = 8,
                                         value       = 0x000000FF00000000))

  # Tests ContainmentError
  def test_is_subcontained_error(self):
    self.assertRaises(ContainmentError, is_subcontained,
                      total_width = 64,
                      sub_width   = 32,
                      value       = 0x000AA00000444440)
    self.assertRaises(ContainmentError, is_subcontained,
                      total_width = 64,
                      sub_width   = 16,
                      value       = 0x00000000FFFFFFFF)
    self.assertRaises(ContainmentError, is_subcontained,
                      total_width = 64,
                      sub_width   = 16,
                      value       = 0x00000000FFFFFFFF)

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_BaseFunctions)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
