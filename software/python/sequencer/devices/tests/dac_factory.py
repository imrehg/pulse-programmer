# Module : dac_factory
# Package: sequencer.devices.tests
# Unit test for abstract DAC factory.

import unittest
from sequencer.pcp.bitmask         import *
from sequencer.devices.dac_factory import *

class Test_DAC_Factory(unittest.TestCase):

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
      min_level_mv       = 50,
      max_level_mv       = 1000,
      chain_address_mask = self.c,
      update_mask        = self.u,
      data_mask          = self.dm
      )

  def test_init(self):
    self.assertEquals(self.c, self.d.CHAIN_ADDRESS_MASK)
    self.assertEquals([self.dm, self.u], self.d.OUTPUT_MASKS)
    self.assertEquals([self.dm, self.u, self.c], self.d.MASK_LIST)
    self.assertEquals(self.dm, self.d.DATA_MASK)
    self.assertEquals(self.u, self.d.UPDATE_MASK)
    self.assertEquals(50, self.d.MIN_LEVEL_MV)
    self.assertEquals(1000, self.d.MAX_LEVEL_MV)
    self.assertEquals(950, self.d.LEVEL_RANGE_MV)
    self.assertEquals(2**12, self.d.STEP_RANGE)
    self.assertAlmostEqual(950.0 / 2**12, self.d.MV_PER_STEP, 2)

  def test_init_bad(self):
    # Max should not be less than min
    self.assertRaises(RuntimeError, DAC_Factory,
                      chain_address_mask = self.c,
                      min_level_mv       = 950,
                      max_level_mv       = 50,
                      update_mask        = self.u,
                      data_mask          = self.dm)
    # Data mask overlaps with chain address mask
    self.assertRaises(OverlapError, DAC_Factory,
                      chain_address_mask = self.c,
                      min_level_mv       = 50,
                      max_level_mv       = 950,
                      update_mask        = self.u,
                      data_mask          = self.b2)

  def tearDown(self):
    del self.d
    del self.c
    del self.b1
    del self.b2
    del self.dm
    del self.u

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_DAC_Factory),
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
