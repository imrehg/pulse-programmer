# Module : __init__
# Package: sequencer.devices.tests
# Base module for unit tests in the sequencer.devices package

import unittest
from sequencer.devices import *

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite()

# Run all sub-test modules in this package by importing them
import sequencer.devices.tests.device_factory
all_suites.addTest(device_factory.all_suites)
import sequencer.devices.tests.generic
all_suites.addTest(generic.all_suites)
import sequencer.devices.tests.dac_factory
all_suites.addTest(dac_factory.all_suites)
import sequencer.devices.tests.ad9744
all_suites.addTest(ad9744.all_suites)
import sequencer.devices.tests.vga_factory
all_suites.addTest(vga_factory.all_suites)
import sequencer.devices.tests.ad8367
all_suites.addTest(ad8367.all_suites)
import sequencer.devices.tests.dds_factory
all_suites.addTest(dds_factory.all_suites)
#import sequencer.devices.tests.ad9854
#all_suites.addTest(ad9854.all_suites)
#import sequencer.devices.tests.ad9858
#all_suites.addTest(ad9858.all_suites)

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
