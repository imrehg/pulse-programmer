# Module : subroutine
# Package: pcp.events.tests
# Unit test for subroutine definition event.

import unittest
from sequencer.pcp.events            import *
from sequencer.pcp.events.halt       import *
from sequencer.pcp.events.subroutine import *

#------------------------------------------------------------------------------
class Test_Subroutine_Event(unittest.TestCase):

  def setUp(self):
    self.s1 = Subroutine_Event(sequence = [Halt_Event()], label = "A")
    self.s2 = Subroutine_Event(sequence = [Halt_Event()], label = "B")
    self.s3 = Subroutine_Event(sequence = [Halt_Event()], label = "A")

  def test_init(self):
    self.assertEquals("A", self.s1.get_label())

  def test_cmp(self):
    self.assertEquals(True, self.s1 < self.s2)
    self.assertEquals(True, self.s1 == self.s3)
    self.assertEquals(True, self.s2 > self.s3)
    self.assertEquals(False, self.s3 < self.s1)
    self.assertEquals(False, self.s1 == self.s2)
    self.assertEquals(False, self.s1 != self.s3)
    self.assertEquals(False, self.s2 <= self.s3)
    self.assertEquals(False, self.s3 > self.s1)

  def tearDown(self):
    del self.s1
    del self.s2
    del self.s3
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_Subroutine_Event)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)

