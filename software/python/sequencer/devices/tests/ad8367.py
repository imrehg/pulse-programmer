# Module : ad8367
# Package: sequencer.devices.tests
# Unit test for AD8367_Factory.

import unittest
from sequencer.pcp.bitmask            import *
from sequencer.devices.ad8367_factory import *
from sequencer.devices.ad9744_factory import *

class Test_AD8367_Factory(unittest.TestCase):

  def setUp(self):
    self.c = Bitmask(label = "Chain Address Mask",
                     width = 5,
                     shift = 14)
    self.dm = Bitmask(label = "Data Mask",
                      width = 12,
                      shift = 2)
    self.u = Bitmask(label = "Update Mask",
                      width = 1,
                      shift = 1)
    self.f = AD9744_Factory(
      chain_address_mask = self.c,
      update_mask        = self.u,
      data_mask          = self.dm)
    self.f2 = AD8367_Factory(dac_slave = self.f)
    self.d = self.f2.create_device(chain_address = 7)

  def test_create_gain_events(self):
    gain_events = self.d.create_gain_events(1)
    # Setup chain address and data, update, and not update events.
    self.assertEquals(3, len(gain_events))
    # Setup chain_address and data
    self.assertEquals(2, gain_events[0].duration)
    self.assertEquals((0x7 << 14) | (self.f2.UNITY_STEP << 2),
                      gain_events[0].output_mask.value)
    # Update
    self.assertEquals(True, gain_events[1].is_min_duration)
    self.assertEquals((0x1 << 1), gain_events[1].output_mask.value)
    # Not update
    self.assertEquals(True, gain_events[2].is_min_duration)
    self.assertEquals(0x00, gain_events[2].output_mask.value)
                      
  def test_create_gain_events_same(self):
    level_events = self.d.create_gain_events(0x456)
    level_events = self.d.create_gain_events(0x123)
    # Setup data, update, and not update events.
    self.assertEquals(3, len(level_events))
    # Setup data
    self.assertEquals(True, level_events[0].is_min_duration)
    self.assertEquals((0x97C << 2),
                      level_events[0].output_mask.value)
    # Update
    self.assertEquals(True, level_events[1].is_min_duration)
    self.assertEquals((0x1 << 1), level_events[1].output_mask.value)
    # Not update
    self.assertEquals(True, level_events[2].is_min_duration)
    self.assertEquals(0x00, level_events[2].output_mask.value)

  def test_chain_address(self):
    device = self.f2.create_device(1)
    # Cannot create another device with the same chain address
    self.assertRaises(RuntimeError, self.f2.create_device, 1)
    device2 = self.f2.create_device(2)
    self.assertNotEquals(device, device2)

  def tearDown(self):
    del self.f
    del self.f2
    del self.dm
    del self.d
    del self.c
    del self.u

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_AD8367_Factory),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
