# Module : infinite_loop.py
# Package: pcp.events.tests
# Unit test for infinite loop event.

import unittest
from sequencer.pcp.events                import *
from sequencer.pcp.events.init_frequency import *

#------------------------------------------------------------------------------
class Test_InitFrequency_Event(unittest.TestCase):

  def setUp(self):
    self.f = Frequency(frequency = 222, relative_phase = math.pi/7)
    self.i = InitFrequency_Event(frequency = self.f, ref_freq = 1000,
                                 phase_width = 32)

  def test_init(self):
    self.assertEquals(0x038D4FDF4, self.i.tuning_word)
    self.assertEquals(0x012492492, self.i.phase_offset)

  def test_get_tuning_word(self):
    self.assertEquals(0xDF4, self.i.get_tuning_word(0, 12))
    self.assertEquals(0xD4F, self.i.get_tuning_word(1, 12))
    self.assertEquals(0x038, self.i.get_tuning_word(2, 12))

  def test_get_relative_offset(self):
    self.assertEquals(0x92, self.i.get_phase_offset(index = 0, sub_width = 8))
    self.assertEquals(0x24, self.i.get_phase_offset(index = 1, sub_width = 8))
    self.assertEquals(0x49, self.i.get_phase_offset(index = 2, sub_width = 8))
    self.assertEquals(0x12, self.i.get_phase_offset(index = 3, sub_width = 8))

  def tearDown(self):
    del self.i
    del self.f
      
#------------------------------------------------------------------------------
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_InitFrequency_Event)
  ))

def run():
  unittest.TextTestRunner(verbosity=2).run(all_suites)

