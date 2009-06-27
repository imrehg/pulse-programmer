# Module : ad9858
# Package: sequencer.devices.tests
# Unit test for AD9858 DDS device.

import unittest
from sequencer.devices.ad9858 import *

#==============================================================================
class Test_AD9858(unittest.TestCase):
  #----------------------------------------------------------------------------
  def setUp(self):
    self.d = AD9858(
      ref_freq      = 1000,
      reset_bit     = 37,
      sp_mode_bit   = 36,
      update_bit    = 41,
      profile_bits  = (38, 39),
      wrb_bit       = 30,
      rdb_bit       = 31,
      address_bits  = (29, 28, 27, 26, 25, 24),
      data_bits     = (23, 22, 21, 20, 19, 18, 17, 16),
      min_duration  = 0x02)
  #----------------------------------------------------------------------------
  def test_create_register_masks(self):
    reg_array_array = self.d.mask_freq_tune
    # Four profiles
    self.assertEquals(4, len(reg_array_array))
    reg_array = reg_array_array[0]
    # Four 8-bit words in a FTW
    self.assertEquals(4, len(reg_array))
    # 0x0A
    self.assertEquals(0x14000000, reg_array[0].get_set_mask())
    # 0x0B
    self.assertEquals(0x34000000, reg_array[1].get_set_mask())
  #----------------------------------------------------------------------------
  def test_create_reset_events(self):
    event_list = self.d.create_reset_events()
    # 2 events
    self.assertEquals(2, len(event_list))
    # Check WRB, RDB, and SPMODE bits high
    self.assertEquals(0x00000010C0000000,
                      event_list[0].get_output_mask().get_set_mask())
    self.assertEquals(0x02, event_list[0].get_duration())
    # Check for correct word for clock/power settings
    # Second in a series of writes (non-first), so write should be active
    # (negative-true)
    self.assertEquals(0x00000000001A0000,
                      event_list[1].get_output_mask().get_set_mask())
    self.assertEquals(0x02, event_list[1].get_duration())
  #----------------------------------------------------------------------------
  def test_create_freq_events(self):
    event_list = self.d.create_freq_events(0x00, 00)
    # Should be zero events b/c level doesn't change
    self.assertEquals(0, len(event_list))
    event_list = self.d.create_freq_events(0x03, 00)
    # Should be two event b/c level changes in lower byte only (plus setup)
    self.assertEquals(2, len(event_list))
    self.assertEquals(0x02, event_list[0].get_duration())
    self.assertEquals(0x0000000054C00000,
                      event_list[0].get_output_mask().get_set_mask())
    event_list = self.d.create_freq_events(0x104, 00)
    # Should be four events b/c freq changes in lower two bytes only
    # plus their setups
    self.assertEquals(4, len(event_list))
    self.assertEquals(0x02, event_list[0].get_duration())
    self.assertEquals(0x0000000054200000,
                      event_list[0].get_output_mask().get_set_mask())
    # This is the second (non-first) in a series of writes, should contain
    # a lowered (negative-true) write signal
    self.assertEquals(0x0000000034800000,
                      event_list[1].get_output_mask().get_set_mask())

    event_list = self.d.create_freq_events(0x00, 01)
    # Should be zero events b/c level doesn't change
    self.assertEquals(0, len(event_list))

    event_list = self.d.create_freq_events(0x104, 0x00)
    # Should be zero events b/c level doesn't change
    self.assertEquals(0, len(event_list))
  #----------------------------------------------------------------------------
  def test_create_profile_events(self):
    event_list = self.d.create_profile_events(0x00)
    # Should be zero because profile doesn't change
    self.assertEquals(0, len(event_list))

    event_list = self.d.create_profile_events(0x03)
    # Should be one because we change profiles
    self.assertEquals(1, len(event_list))
    self.assertEquals(0x02, event_list[0].get_duration())
    self.assertEquals(0x00000C000000000,
                      event_list[0].get_output_mask().get_set_mask())
    event_list = self.d.create_profile_events(0x03)
    self.assertEquals(0, len(event_list))
  #----------------------------------------------------------------------------
  def tearDown(self):
    del self.d

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_AD9858),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
