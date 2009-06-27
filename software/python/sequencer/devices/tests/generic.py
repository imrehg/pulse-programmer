# Module : generic
# Package: sequencer.devices.tests
# Unit test for generic device.

import unittest
from sequencer.pcp.bitmask     import *
from sequencer.devices.generic import *

class Test_Generic_Device(unittest.TestCase):

  def setUp(self):
    self.b = Bitmask(label = "b",
                      width = 14,
                      shift = 10)
    self.d = Generic_Device(output_mask = self.b)

  def test_init(self):
    self.assertEquals(None, self.d.CHAIN_ADDRESS_MASK)
    self.assertEquals(None, self.d.POWER_MASK)
    self.assertEquals([self.b], self.d.OUTPUT_MASKS)

  def test_create(self):
    self.assertRaises(RuntimeError, self.d.create_device, 31)

  def test_create_output_events(self):
    setup_events = self.d.create_output_events(0x1234)
    self.assertEquals(1, len(setup_events))
    p = setup_events[0]
    self.assertEquals(True, p.is_min_duration)
    self.assertEquals(0x1234 << 10, p.output_mask.value)

  def tearDown(self):
    del self.d
    del self.b

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_Generic_Device),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
