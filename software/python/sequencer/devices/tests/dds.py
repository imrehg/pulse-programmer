# Module : dds
# Package: sequencer.devices.tests
# Unit test for abstract dds device.

from sequencer.pcp.bitmask import Bitmask
from sequencer.devices.dds_factory import DDS_Factory
from sequencer.devices.dds import DDS_Device

class Test_DDS(unittest.TestCase):

  def setUp(self):

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
    self.assertEquals(0x0000000000020000, self.f.init_mask.get_set_mask())
    self.assertEquals(0x0100000000000000, self.f.update_mask.get_set_mask())
    self.assertEquals(0x0000000000020000, self.f.not_update_mask.get_set_mask())
    self.assertEquals(0xFEFFFFFFFFFDFFFF, self.f.not_update_mask.get_clear_mask())
    self.assertEquals(0x0100000000000000, self.f.write_mask.get_set_mask())
    self.assertEquals(0x0000000000020000, self.f.not_write_mask.get_set_mask())
    self.assertEquals(0xFEFFFFFFFFFDFFFF, self.f.not_write_mask.get_clear_mask())

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
    del self.dds

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_DDS),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
