# Module : dds_factory
# Package: sequencer.devices.tests
# Unit test for abstract dds device.

import unittest
from sequencer.util import *
from sequencer.pcp.bitmask import Bitmask
from sequencer.devices.dds_factory import DDS_Factory

class Test_DDS_Factory(unittest.TestCase):

  def setUp(self):
    self.z = Bitmask(label = "Zero Mask",
                       width = 0,
                       shift = 0)
    self.c = Bitmask(label = "Chain Address",
                     width = 4,
                     shift = 50)
    self.p = Bitmask(label = "Power",
                     width = 1,
                     shift = 48)
    self.u = Bitmask(label = "Update",
                     width = 1,
                     shift = 56)
    self.w = Bitmask(label = "Write Bar",
                     width = 1,
                     shift = 17)
    self.pr = Bitmask(label = "Profile Enable",
                      width = 1,
                      shift = 16)
    self.a = Bitmask(label = "Address",
                     width = 6,
                     shift = 18)
    self.d = Bitmask(label = "Data",
                     width = 8,
                     shift = 24)
                     
    self.f = DDS_Factory(
      chain_address_mask = self.c,
      power_mask         = self.p,
      min_ref_freq       = 0.0,
      max_ref_freq       = 1000.0,
      reset_mask         = self.z,
      sp_mode_mask       = self.z,
      update_mask        = self.u,
      profile_mask       = self.pr,
      wrb_mask           = self.w,
      rdb_mask           = self.z,
      address_mask       = self.a,
      data_mask          = self.d,
      register_width     = 8,
      profile_count      = 4)

  def test_factory_init(self):
    self.assertEquals(self.c, self.f.CHAIN_ADDRESS_MASK)
    self.assertEquals(self.p, self.f.POWER_MASK)
    self.assertAlmostEqual(0, self.f.MIN_REF_FREQ, 2)
    self.assertAlmostEqual(1000, self.f.MAX_REF_FREQ, 2)
    self.assertEquals(self.z, self.f.RESET_MASK)
    self.assertEquals(self.z, self.f.SP_MODE_MASK)
    self.assertEquals(self.u, self.f.UPDATE_MASK)
    self.assertEquals(self.pr, self.f.PROFILE_MASK)
    self.assertEquals(self.w, self.f.WRITE_MASK)
    self.assertEquals(self.z, self.f.READ_MASK)
    self.assertEquals(self.a, self.f.ADDRESS_MASK)
    self.assertEquals(self.d, self.f.DATA_MASK)
    self.assertEquals(8, self.f.REGISTER_WIDTH)
    self.assertEquals(4, self.f.PROFILE_COUNT)
    self.assertEquals((0x1 << 48) | (0x1 << 17),
                      self.f.init_mask.get_set_mask())
    self.assertEquals((0x1 << 56) | (0x1 << 17),
                      self.f.update_mask.get_set_mask())
    self.assertEquals(0x1 << 17, self.f.clear_mask.get_set_mask())
    self.assertEquals(~((0x1 << 56) | (0x1 << 17)) & generate_mask(sequencer.TOTAL_OUTPUT_WIDTH),
                      self.f.clear_mask.get_clear_mask())
    self.assertEquals((0x00), self.f.write_mask.get_set_mask())

  def tearDown(self):
    del self.z
    del self.c
    del self.p
    del self.u
    del self.w
    del self.pr
    del self.a
    del self.d
    del self.f

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_DDS_Factory),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
