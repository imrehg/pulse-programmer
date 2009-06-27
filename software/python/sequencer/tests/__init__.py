# Module : __init__.py
# Package: sequencer.tests
# Base module for all tests in the main sequencer package

import unittest
from sequencer.util import *

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite()

# Run all sub-test modules in this package by importing them
import sequencer.tests.util
all_suites.addTest(util.all_suites)
import sequencer.pcp.tests
all_suites.addTest(sequencer.pcp.tests.all_suites)
import sequencer.devices.tests
all_suites.addTest(sequencer.devices.tests.all_suites)

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
