# Module : jump.py
# Package: pcp.events.tests
# Unit test for jump event.

import unittest
from sequencer.pcp.events import *
from sequencer.pcp.events.jump import *
from sequencer.pcp.instructions.nop import *

#------------------------------------------------------------------------------
class Test_Jump_Event(unittest.TestCase):

  def setUp(self):
    self.i = Nop_Instr(True)
    self.j = Jump_Event(self.i)  # Create an empty instance to test methods

  def tearDown(self):
    del self.j
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_Jump_Event)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)

