# Module : halt.py
# Package: pcp.events.tests
# Unit test for halt event.

import unittest
from sequencer.pcp.events import *
from sequencer.pcp.events.halt import *

#------------------------------------------------------------------------------
class Test_Halt_Event(unittest.TestCase):

  def setUp(self):
    self.h = Halt_Event()  # Create an empty instance to test methods

  def tearDown(self):
    del self.h
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_Halt_Event)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)

