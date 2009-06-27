# Module : __init__
# Package: pcp.tests
# Base module for unit tests in the main pcp package

import unittest
from sequencer.pcp         import *
from sequencer.pcp.bitmask import *

#------------------------------------------------------------------------------
class Test_BaseFunctions(unittest.TestCase):

  def test_get_bit_tuple_value(self):
    b1 = Bitmask(label = 'b1', width = 1, shift = 3)
    b2 = Bitmask(label = 'b2', width = 1, shift = 4)
    b3 = Bitmask(label = 'b3', width = 1, shift = 5)
    mask_list = [b1, b2, b3]
    tuples = [(mask, 0x1) for mask in mask_list]
    self.assertEquals(0x7 << 3, get_bit_tuple_value(tuples))

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_BaseFunctions)
  ))

# Run all sub-test modules in this package by importing them
import sequencer.pcp.tests.bitmask
all_suites.addTest(bitmask.all_suites)
import sequencer.pcp.tests.output_mask
all_suites.addTest(output_mask.all_suites)
import sequencer.pcp.tests.output_register
all_suites.addTest(output_register.all_suites)
import sequencer.pcp.instructions.tests
all_suites.addTest(sequencer.pcp.instructions.tests.all_suites)
import sequencer.pcp.events.tests
all_suites.addTest(sequencer.pcp.events.tests.all_suites)
import sequencer.pcp.machines.tests
all_suites.addTest(sequencer.pcp.machines.tests.all_suites)

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
