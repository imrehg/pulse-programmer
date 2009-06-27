# Module : vga_factory
# Package: sequencer.devices.tests
# Unit test for abstract VGA factory.

import unittest
from sequencer.util                import *
from sequencer.pcp.bitmask         import *
from sequencer.devices.dac_factory import *
from sequencer.devices.vga_factory import *

class Test_VGA_Factory(unittest.TestCase):

  def setUp(self):
    self.c = Bitmask(label = "Chain Address Mask",
                     width = 5,
                     shift = 14)
    self.b1 = Bitmask(label = "b1",
                      width = 14,
                      shift = 10)
    self.b2 = Bitmask(label = "b2",
                      width = 4,
                      shift = 18)
    self.dm = Bitmask(label = "Data Mask",
                      width = 12,
                      shift = 2)
    self.u = Bitmask(label = "Update Mask",
                      width = 1,
                      shift = 1)
    self.d = DAC_Factory(
      min_level_mv       = 0,
      max_level_mv       = 1000,
      chain_address_mask = self.c,
      update_mask        = self.u,
      data_mask          = self.dm
      )
    self.v = VGA_Factory(
      min_level_mv       = 50,
      max_level_mv       = 950,
      min_gain_db        = -2.5,
      max_gain_db        = 42.5,
      dac_slave          = self.d
      )

  def test_init(self):
    self.assertEquals(self.d, self.v.DAC_FACTORY)
    self.assertEquals(self.c, self.v.CHAIN_ADDRESS_MASK)
    self.assertEquals([], self.v.OUTPUT_MASKS)
    self.assertEquals([self.c], self.v.MASK_LIST)
    self.assertEquals(50, self.v.MIN_LEVEL_MV)
    self.assertEquals(950, self.v.MAX_LEVEL_MV)
    self.assertAlmostEqual(-2.5, self.v.MIN_GAIN_DB, 2)
    self.assertAlmostEqual(42.5, self.v.MAX_GAIN_DB, 2)
    self.assertEquals(900, self.v.LEVEL_RANGE_MV)
    self.assertAlmostEqual(45.0, self.v.GAIN_RANGE_DB, 2)
    db_per_step = ((1000.0 / 2**12) / (900.0 / 45))
    self.assertAlmostEqual(db_per_step, self.v.DB_PER_STEP, 4)
    self.assertEquals(205, self.v.MIN_STEP)
    self.assertEquals(3891, self.v.MAX_STEP)
    self.assertAlmostEqual(round((2.5 / db_per_step) + 205),
                           self.v.UNITY_STEP, 2)

  def test_init_bad(self):
    # Max level should not be less than min
    self.assertRaises(RuntimeError, VGA_Factory,
                      min_level_mv          = 950,
                      max_level_mv          = 50,
                      min_gain_db           = -2.5,
                      max_gain_db           = 42.5,
                      dac_slave             = self.d)
    # Max gain should not be less than min
    self.assertRaises(RuntimeError, VGA_Factory,
                      min_level_mv          = 50,
                      max_level_mv          = 950,
                      min_gain_db           = 42.5,
                      max_gain_db           = -2.5,
                      dac_slave             = self.d)
    # Min gain is too high to achieve unity gain
    self.assertRaises(RuntimeError, VGA_Factory,
                      min_level_mv          = 50,
                      max_level_mv          = 950,
                      min_gain_db           = 0,
                      max_gain_db           = 42.5,
                      dac_slave             = self.d)
    # Max gain is too low to achieve unity gain
    self.assertRaises(RuntimeError, VGA_Factory,
                      min_level_mv          = 50,
                      max_level_mv          = 950,
                      min_gain_db           = -2.5,
                      max_gain_db           = 0,
                      dac_slave             = self.d)

  def tearDown(self):
    del self.v
    del self.d
    del self.c
    del self.b1
    del self.b2
    del self.dm

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_VGA_Factory),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
