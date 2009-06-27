# Module : ad9854
# Package: sequencer.devices.tests
# Unit test for AD9854 DDS device.

import unittest
from sequencer.devices.ad9854 import *

class Test_AD9854(unittest.TestCase):

  def setUp(self):
    self.d = AD9854(
      ref_freq      = 300,
      reset_bit     = 37,
      sp_mode_bit   = 38,
      update_bit    = 41,
      osk_bit       = 34,
      wrb_bit       = 30,
      rdb_bit       = 31,
      address_bits  = (29, 28, 27, 26, 25, 24),
      data_bits     = (23, 22, 21, 20, 19, 18, 17, 16),
      min_duration  = 0x02)

  def test_create_register_masks(self):
    reg_array = self.d.mask_freq_tune_one
    self.assertEquals(6, len(reg_array))
    self.assertEquals(0x24000000, reg_array[0].get_set_mask())
    self.assertEquals(0x04000000, reg_array[1].get_set_mask())

  def test_create_reset_events(self):
    pass

  def test_create_level_events(self):
    event_list = self.d.create_level_events(0x00)
    # Should be four events b/c first level is always uninitialized
    # (writing two registers, plus their setups)
    self.assertEquals(4, len(event_list))
    event_list = self.d.create_level_events(0x03)
    # Should be one event b/c level changes in lower byte only
    self.assertEquals(1, len(event_list))
    self.assertEquals(0x02, event_list[0].get_duration())
    self.assertEquals(0x0000000079C00000,
                      event_list[0].get_output_mask().get_set_mask())
    event_list = self.d.create_level_events(0x103)
    # Should be one event b/c level changes in upper byte only
    self.assertEquals(1, len(event_list))
    self.assertEquals(0x02, event_list[0].get_duration())
    self.assertEquals(0x0000000059800000,
                      event_list[0].get_output_mask().get_set_mask())

  def test_create_update_events(self):
    event_list = self.d.create_update_events()
    self.assertEquals(1, len(event_list))
    self.assertEquals(0x02, event_list[0].get_duration())
    self.assertEquals(self.d.not_write_mask, event_list[0].get_output_mask())

  def tearDown(self):
    del self.d

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_AD9854),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
