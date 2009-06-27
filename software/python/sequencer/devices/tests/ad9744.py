# Module : ad9744
# Package: sequencer.devices.tests
# Unit test for abstract device factory.

import unittest
from sequencer.pcp.bitmask            import *
from sequencer.devices.ad9744_factory import *
from sequencer.devices.ad9744         import *

class Test_AD9744_Device(unittest.TestCase):

  def setUp(self):
    self.c = Bitmask(label = "Chain Address Mask",
                     width = 5,
                     shift = 14)
    self.c2 = Bitmask(label = "Bad Chain Address Mask",
                     width = 5,
                     shift = 2)
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
    self.d = self.f.create_device(chain_address = 7)

  def test_init(self):
    self.assertEquals(self.u, self.f.UPDATE_MASK)
    self.assertEquals(self.dm, self.f.DATA_MASK)
    self.assertEquals([self.dm, self.u, self.c], self.f.MASK_LIST)
    self.assertEquals(self.f, self.d.parent)
    self.assertEquals(7, self.d.chain_address)

  def test_init_bad(self):
    # Overlapping chain address mask
    self.assertRaises(OverlapError, AD9744_Factory,
                      chain_address_mask    = self.c2,
                      update_mask           = self.u,
                      data_mask             = self.dm)

  def test_create_level_events(self):
    level_events = self.d.create_level_events(0x123)
    # Setup chain address and data, update, and not update events.
    self.assertEquals(3, len(level_events))
    # Setup chain_address and data
    self.assertEquals(2, level_events[0].duration)
    self.assertEquals((0x7 << 14) | (0x123 << 2),
                      level_events[0].output_mask.value)
    # Update
    self.assertEquals(True, level_events[1].is_min_duration)
    self.assertEquals((0x1 << 1), level_events[1].output_mask.value)
    # Not update
    self.assertEquals(True, level_events[2].is_min_duration)
    self.assertEquals(0x00, level_events[2].output_mask.value)
                      
  def test_create_level_events_same(self):
    level_events = self.d.create_level_events(0x123)
    level_events = self.d.create_level_events(0x456)
    # Setup data, update, and not update events.
    self.assertEquals(3, len(level_events))
    # Setup data
    self.assertEquals(True, level_events[0].is_min_duration)
    self.assertEquals((0x456 << 2),
                      level_events[0].output_mask.value)
    # Update
    self.assertEquals(True, level_events[1].is_min_duration)
    self.assertEquals((0x1 << 1), level_events[1].output_mask.value)
    # Not update
    self.assertEquals(True, level_events[2].is_min_duration)
    self.assertEquals(0x00, level_events[2].output_mask.value)

  def test_chain_address(self):
    device = self.f.create_device(1)
    # Cannot create another device with the same chain address
    self.assertRaises(RuntimeError, self.f.create_device, 1)
    device2 = self.f.create_device(2)
    self.assertNotEquals(device, device2)

  def tearDown(self):
    del self.f
    del self.d
    del self.c
    del self.c2
    del self.u

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_AD9744_Device),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
