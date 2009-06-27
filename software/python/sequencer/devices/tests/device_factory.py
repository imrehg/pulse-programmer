# Module : device_factory
# Package: sequencer.devices.tests
# Unit test for abstract device factory.

import unittest
from sequencer.pcp.bitmask            import *
from sequencer.devices.device_factory import *

class Test_Device_Factory(unittest.TestCase):

  def setUp(self):
    self.c = Bitmask(label = "Chain Address Mask",
                     width = 5,
                     shift = 2)
    self.c2 = Bitmask(label = "Bad Chain Address Mask",
                     width = 5,
                     shift = 9)
    self.b1 = Bitmask(label = "b1",
                      width = 14,
                      shift = 10)
    self.b2 = Bitmask(label = "b2",
                      width = 4,
                      shift = 24)
    self.b3 = Bitmask(label = "b3",
                      width = 10,
                      shift = 3)
    self.p  = Bitmask(label = "Power",
                      width = 1,
                      shift = 1)
    self.d = Device_Factory(
      chain_address_mask = self.c,
      output_masks    = [self.b1, self.b2]
      )
    self.d2 = Device_Factory(
      chain_address_mask = None,
      output_masks    = [self.b1, self.b2],
      power_mask      = self.p
      )

  def test_init(self):
    self.assertEquals(self.c, self.d.CHAIN_ADDRESS_MASK)
    self.assertEquals(self.p, self.d2.POWER_MASK)
    self.assertEquals([self.b1, self.b2], self.d.OUTPUT_MASKS)
    self.assertEquals([self.b1, self.b2, self.c], self.d.MASK_LIST)

  def test_init_bad(self):
    self.assertRaises(OverlapError, Device_Factory,
                      chain_address_mask    = self.c,
                      output_masks       = [self.b1, self.b3])
    self.assertRaises(OverlapError, Device_Factory,
                      chain_address_mask = self.c,
                      output_masks    = [self.b2, self.b3])
    self.assertRaises(OverlapError, Device_Factory,
                      chain_address_mask = self.c2,
                      output_masks    = [self.b1, self.b2])

  def test_create(self):
    device = self.d.create_device(31)
    o = OutputMask(mask_width = 64,
                   bit_tuples = [(self.c, 31)])
    self.assertEquals(o, device.chain_address_mask)

  def test_chain_address(self):
    device = self.d.create_device(1)
    # Cannot create another device with the same chain address
    self.assertRaises(RuntimeError, self.d.create_device, 1)
    device2 = self.d.create_device(2)
    self.assertNotEquals(device, device2)

  def test_create_setup_events(self):
    device = self.d.create_device(0xD)
    device2 = self.d.create_device(2)
    setup_events = self.d.create_setup_events(device)
    self.assertEquals(1, len(setup_events))
    p = setup_events[0]
    self.assertEquals(2, p.duration)
    self.assertEquals(0xD << 2, p.output_mask.value)
    setup_events = self.d.create_setup_events(device)
    self.assertEquals(0, len(setup_events), "For current device, no setup.")
    setup_events = self.d.create_setup_events(device2)
    self.assertEquals(1, len(setup_events), "For different device, setup.")

  def test_create_reset_events(self):
    reset_events = self.d2.create_reset_events()
    self.assertEquals(1, len(reset_events))
    self.assertEquals(0x1 << 1, reset_events[0].output_mask.value)
    self.assertEquals(True, reset_events[0].is_min_duration)

  def test_singleton(self):
    device = self.d2.create_device()
    device2 = self.d2.create_device()
    self.assertEquals(device, device2)
    self.assertEquals(None, device.chain_address_mask)

  def tearDown(self):
    del self.d
    del self.d2
    del self.p
    del self.c
    del self.c2
    del self.b1
    del self.b2
    del self.b3

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_Device_Factory),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
