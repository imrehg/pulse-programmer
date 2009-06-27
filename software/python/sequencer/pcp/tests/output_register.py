# Module : output_register
# Package: pcp.tests
# Unit tests for OutputRegister class.

import unittest
from sequencer.pcp                 import *
from sequencer.pcp.output_mask     import *
from sequencer.pcp.output_register import *

#------------------------------------------------------------------------------
class Test_OutputRegister(unittest.TestCase):

  def setUp(self):
    self.o = OutputRegister(32, 0x12340000)
    self.m = OutputMask(32, (1, 3, 5, 7, 9, 11, 13, 15), 0x22)
#    self.m.set_value(0x22)

  def test_init(self):
    self.assertEquals(0x12340000, self.o.get_value())
    self.assertEquals(32, self.o.get_reg_width())
    self.assertEquals(0x12340808, self.o.generate(self.m))
    self.assertEquals(0x12340808, self.o.get_value())

  def test_reset(self):
    self.o.generate(self.m)
    self.o.reset()
    self.assertEquals(0x12340000, self.o.get_value())

  def tearDown(self):
    del self.o

#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_OutputRegister)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
