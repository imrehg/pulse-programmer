# Module : pcp32
# Package: pcp.machines.tests
# Unit test for PCP32_Family module

import unittest
import math
from sequencer.util               import *
from sequencer.pcp.machines       import *
from sequencer.pcp.machines.pcp32 import *
from sequencer.pcp.events         import *

#==============================================================================
class Test_PCP32_Family(unittest.TestCase):

  #----------------------------------------------------------------------------
  def setUp(self):
    self.f = PCP32_Family(name                = "pcp0.5",
                          sub_stack_depth     = 8,
                          loop_address_width  = 3,
                          loop_data_width     = 8,
                          phase_address_width = 4,
                          phase_data_width    = AD9858_PHASE_DATA_WIDTH,
                          phase_adjust_width  = AD9858_PHASE_ADJUST_WIDTH,
                          phase_pulse_width   = 8,
                          phase_load_width    = 16,
                          min_wait_duration   = 3)
    self.o1 = OutputMask(mask_width  = 64,
                         bit_indices = (0, 1, 2, 3),
                         value       = 0xA)
    self.o2 = OutputMask(mask_width  = 64,
                         bit_indices = (8, 9, 10, 11),
                         value       = 0xA)
    self.o3 = OutputMask(mask_width  = 64,
                         bit_indices = (32, 33, 34, 35),
                         value       = 0xA)
    self.o4 = OutputMask(mask_width  = 64,
                         bit_indices = (60, 61, 62, 63),
                         value       = 0xA)
    self.p1 = AtomicPulse_Event(output_mask = self.o1)
    self.p2 = AtomicPulse_Event(output_mask = self.o2)
    self.p3 = AtomicPulse_Event(output_mask = self.o3)
    self.p4 = AtomicPulse_Event(output_mask = self.o4)
    self.f01 = Frequency(frequency = 121, relative_phase = math.pi/3)
    self.f02 = Frequency(frequency = 232, relative_phase = math.pi/3)
    self.f03 = Frequency(frequency = 252, relative_phase = math.pi/3)
    self.f04 = Frequency(frequency = 272, relative_phase = math.pi/3)
    self.f05 = Frequency(frequency = 292, relative_phase = math.pi/3)
    self.f06 = Frequency(frequency = 312, relative_phase = math.pi/3)
    self.f07 = Frequency(frequency = 332, relative_phase = math.pi/3)
    self.f08 = Frequency(frequency = 352, relative_phase = math.pi/3)
    self.f09 = Frequency(frequency = 372, relative_phase = math.pi/3)
    self.f10 = Frequency(frequency = 392, relative_phase = math.pi/3)
    self.f11 = Frequency(frequency = 412, relative_phase = math.pi/3)
    self.f12 = Frequency(frequency = 432, relative_phase = math.pi/3)
    self.f13 = Frequency(frequency = 452, relative_phase = math.pi/3)
    self.f14 = Frequency(frequency = 472, relative_phase = math.pi/3)
    self.f15 = Frequency(frequency = 492, relative_phase = math.pi/3)
    self.f16 = Frequency(frequency = 212, relative_phase = math.pi/3)
    self.f17 = Frequency(frequency = 192, relative_phase = math.pi/3)
    # Tuning word = 0x3DF3B646, Phase word = 0x2AAAAAAB
    self.i01 = InitFrequency_Event(frequency   = self.f01,
                                   ref_freq    = 500,
                                   phase_width = 32)
    # Tuning word = 0x76C8B439
    self.i02 = InitFrequency_Event(frequency   = self.f02,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i03 = InitFrequency_Event(frequency   = self.f03,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i04 = InitFrequency_Event(frequency   = self.f04,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i05 = InitFrequency_Event(frequency   = self.f05,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i06 = InitFrequency_Event(frequency   = self.f06,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i07 = InitFrequency_Event(frequency   = self.f07,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i08 = InitFrequency_Event(frequency   = self.f08,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i09 = InitFrequency_Event(frequency   = self.f09,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i10 = InitFrequency_Event(frequency   = self.f10,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i11 = InitFrequency_Event(frequency   = self.f11,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i12 = InitFrequency_Event(frequency   = self.f12,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i13 = InitFrequency_Event(frequency   = self.f13,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i14 = InitFrequency_Event(frequency   = self.f14,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i15 = InitFrequency_Event(frequency   = self.f15,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i16 = InitFrequency_Event(frequency   = self.f16,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i17 = InitFrequency_Event(frequency   = self.f17,
                                   ref_freq    = 500,
                                   phase_width = 32)
    self.i18 = InitFrequency_Event(frequency   = self.f01,
                                   ref_freq    = 500,
                                   phase_width = 32)
  #----------------------------------------------------------------------------
  def test_init(self):
    self.assertEquals("pcp0.5", self.f.name)
    self.assertEquals(8                        , self.f.sub_stack_depth    )
    self.assertEquals(3                        , self.f.loop_address_width )
    self.assertEquals(8                        , self.f.loop_data_width    )
    self.assertEquals(4                        , self.f.phase_address_width)
    self.assertEquals(AD9858_PHASE_DATA_WIDTH  , self.f.phase_data_width   )
    self.assertEquals(AD9858_PHASE_ADJUST_WIDTH, self.f.phase_adjust_width )
    self.assertEquals(8                        , self.f.phase_pulse_width  )
    self.assertEquals(16                       , self.f.phase_load_width   )
    self.assertEquals(3                        , self.f.min_wait_duration  )
    self.assertEquals(1                        , self.f.min_duration       )
  #----------------------------------------------------------------------------
  def test_handle_atomic_pulse(self):
    o2 = OutputMask(mask_width  = 64,
                    bit_indices = (28, 29, 30, 31),
                    value       = 0xA)
    p2 = AtomicPulse_Event(output_mask = o2)
    s = PulseSequence()
    s.add_event(self.p1)
    s.add_event(p2)
    s.add_event(self.p3)
    s.add_event(self.p4)
    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\xC0', '\x00', '\x00', '\x0A',
      '\xC0', '\x01', '\xA0', '\x00',
      '\xC0', '\x02', '\x00', '\x0A',
      '\xC0', '\x03', '\xA0', '\x00',
      '\x80', '\x00', '\x00', '\x04',
      '\x00', '\x00', '\x00', '\x00',
      '\x00', '\x00', '\x00', '\x00',
      '\x00', '\x00', '\x00', '\x00',
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def test_handle_atomic_pulse_wait(self):
    o2 = OutputMask(mask_width  = 64,
                    bit_indices = (28, 29, 30, 31),
                    value       = 0xA)
    p2 = AtomicPulse_Event(output_mask = o2, duration = 4)
    s = PulseSequence()
    s.add_event(p2)
    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\xC0', '\x01', '\xA0', '\x00',
      '\x90', '\x00', '\x00', '\x04', # wait for duration of 3
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\x80', '\x00', '\x00', '\x05',
      '\x00', '\x00', '\x00', '\x00',
      '\x00', '\x00', '\x00', '\x00',
      '\x00', '\x00', '\x00', '\x00',
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def test_handle_atomic_pulse_min(self):
    o2 = OutputMask(mask_width  = 64,
                    bit_indices = (28, 29, 30, 31),
                    value       = 0xA)
    p2 = AtomicPulse_Event(output_mask = o2, duration = 2)
    s = PulseSequence()
    s.add_event(p2)
    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\xC0', '\x01', '\xA0', '\x00',
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\x80', '\x00', '\x00', '\x03',
      '\x00', '\x00', '\x00', '\x00',
      '\x00', '\x00', '\x00', '\x00',
      '\x00', '\x00', '\x00', '\x00',
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def test_handle_separable_pulse(self):
    o2 = OutputMask(mask_width  = 64,
                    bit_indices = (28, 29, 30, 31),
                    value       = 0xA)
    p2 = AtomicPulse_Event(output_mask = o2)
    sp = SeparablePulse_Event([self.p4, self.p3, p2, self.p1])
    s = PulseSequence()
    s.add_event(sp)
    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\xC0', '\x03', '\xA0', '\x00',
      '\xC0', '\x02', '\x00', '\x0A',
      '\xC0', '\x01', '\xA0', '\x00',
      '\xC0', '\x00', '\x00', '\x0A',
      '\x80', '\x00', '\x00', '\x04',
      '\x00', '\x00', '\x00', '\x00',
      '\x00', '\x00', '\x00', '\x00',
      '\x00', '\x00', '\x00', '\x00',
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def test_handle_separable_pulse_merge(self):
    sp = SeparablePulse_Event([self.p4, self.p3, self.p2, self.p1])
    s = PulseSequence()
    s.add_event(sp)
    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\xC0', '\x03', '\xA0', '\x00',
      '\xC0', '\x02', '\x00', '\x0A',
      '\xC0', '\x00', '\x0A', '\x0A',
      '\x80', '\x00', '\x00', '\x03',
      '\x00', '\x00', '\x00', '\x00',
      '\x00', '\x00', '\x00', '\x00',
      '\x00', '\x00', '\x00', '\x00',
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def test_handle_subroutine(self):
    sp = SeparablePulse_Event([self.p1, self.p2, self.p3, self.p4])
    sub = Subroutine_Event(label = "Sub A", sequence = [sp])
    subcall = SubroutineCall_Event(sub)
    s = PulseSequence()
    s.add_event(subcall)
    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\x50', '\x00', '\x00', '\x08', # Sub call
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\x80', '\x00', '\x00', '\x04', # Halt
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\xC0', '\x00', '\x0A', '\x0A', # Sub definition
      '\xC0', '\x02', '\x00', '\x0A',
      '\xC0', '\x03', '\xA0', '\x00',
      '\x60', '\x00', '\x00', '\x00', # Sub return
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  # Test that non-subroutine passed as target to SubroutineCall_Event is
  # caught.
  def test_handle_subroutine_call_error(self):
    self.assertRaises(AttributeError, SubroutineCall_Event,
                      target = Halt_Event())
  #----------------------------------------------------------------------------
  def test_handle_subroutine_multiple_defs(self):
    sp = SeparablePulse_Event([self.p1, self.p2])
    sub = Subroutine_Event(label = "B", sequence = [sp])
    subcall = SubroutineCall_Event(sub)
    s = PulseSequence()
    s.add_event(subcall)

    sub = Subroutine_Event(label = "C", sequence = [self.p3])
    subcall = SubroutineCall_Event(sub)
    s.add_event(subcall)

    sub = Subroutine_Event(label = "D", sequence = [self.p4])
    subcall = SubroutineCall_Event(sub)
    s.add_event(subcall)
    
    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\x50', '\x00', '\x00', '\x10', # Sub 1 call
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\x50', '\x00', '\x00', '\x15', # Sub 2 call
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\x50', '\x00', '\x00', '\x1A', # Sub 3 call
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\x80', '\x00', '\x00', '\x0C', # Halt
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\xC0', '\x00', '\x0A', '\x0A', # Sub 1 definition
      '\x60', '\x00', '\x00', '\x00', # Sub return
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\xC0', '\x02', '\x00', '\x0A', # Sub 2 definition
      '\x60', '\x00', '\x00', '\x00', # Sub return
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\xC0', '\x03', '\xA0', '\x00', # Sub 3 definition
      '\x60', '\x00', '\x00', '\x00', # Sub return
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def test_handle_subroutine_multiple_calls(self):
    sp = SeparablePulse_Event([self.p1, self.p2])
    sub = Subroutine_Event(label = "B", sequence = [sp])
    subcall = SubroutineCall_Event(sub)
    s = PulseSequence()
    s.add_event(subcall)

    sub2 = Subroutine_Event(label = "C", sequence = [self.p3])
    subcall = SubroutineCall_Event(sub2)
    s.add_event(subcall)

    subcall = SubroutineCall_Event(sub)
    s.add_event(subcall)
    
    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\x50', '\x00', '\x00', '\x10', # Sub 1 call
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\x50', '\x00', '\x00', '\x15', # Sub 2 call
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\x50', '\x00', '\x00', '\x10', # Sub 3 call
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\x80', '\x00', '\x00', '\x0C', # Halt
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\xC0', '\x00', '\x0A', '\x0A', # Sub 1 definition
      '\x60', '\x00', '\x00', '\x00', # Sub return
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\xC0', '\x02', '\x00', '\x0A', # Sub 2 definition
      '\x60', '\x00', '\x00', '\x00', # Sub return
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def test_handle_init_frequency_twice(self):
    s = PulseSequence()
    s.add_event(self.i01)
    s.add_event(self.i02)
    s.add_event(self.i03)
    s.add_event(self.i18)
    # Cannot init the same frequency twice
    self.assertRaises(RuntimeError, self.f.translate_sequence, s)
  #----------------------------------------------------------------------------
  def test_handle_init_frequency_max(self):
    s = PulseSequence()
    s.add_event(self.i01)
    s.add_event(self.i02)
    s.add_event(self.i03)
    s.add_event(self.i04)
    s.add_event(self.i05)
    s.add_event(self.i06)
    s.add_event(self.i07)
    s.add_event(self.i08)
    s.add_event(self.i09)
    s.add_event(self.i10)
    s.add_event(self.i11)
    s.add_event(self.i12)
    s.add_event(self.i13)
    s.add_event(self.i14)
    s.add_event(self.i15)
    s.add_event(self.i16)
    s.add_event(self.i17)
    # Cannot add more frequencies than max.
    self.assertRaises(RuntimeError, self.f.translate_sequence, s)
  #----------------------------------------------------------------------------
  def test_handle_init_frequency(self):
    s = PulseSequence()
    s.add_event(self.i01)
    
    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\xE0', '\x20', '\xB6', '\x46', # loading lower addend
      '\xE0', '\x21', '\x3D', '\xF3', # loading upper addend
      '\xE0', '\x00', '\xAA', '\xAB', # loading lower offset
      '\xE0', '\x41', '\x2A', '\xAA', # loading upper offset and writing
      '\x80', '\x00', '\x00', '\x04', # Halt
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def test_handle_init_frequency_multiple(self):
    s = PulseSequence()
    s.add_event(self.i01)
    s.add_event(self.i02)
    
    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\xE0', '\x20', '\xB6', '\x46', # loading lower addend
      '\xE0', '\x21', '\x3D', '\xF3', # loading upper addend
      '\xE0', '\x00', '\xAA', '\xAB', # loading lower offset
      '\xE0', '\x41', '\x2A', '\xAA', # loading upper offset and writing
      '\xE0', '\xA0', '\xB4', '\x39', # loading lower addend
      '\xE0', '\xA1', '\x76', '\xC8', # loading upper addend
      '\xE0', '\x80', '\xAA', '\xAB', # loading lower offset
      '\xE0', '\xC1', '\x2A', '\xAA', # loading upper offset and writing
      '\x80', '\x00', '\x00', '\x08', # Halt
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def test_handle_switch_frequency_invalid(self):
    s = PulseSequence()
    switch = SwitchFrequency_Event(frequency = self.f17, mask_list = [])
    s.add_event(switch)

    # Cannot switch to a frequency that has never been initialized
    self.assertRaises(RuntimeError, self.f.translate_sequence, s)
  #----------------------------------------------------------------------------
  def test_handle_switch_frequency(self):
    s = PulseSequence()
    s.add_event(self.i01)
    o1 = OutputMask(mask_width  = 32,
                    bit_indices = (0, 1),
                    value       = 0x3)
    o2 = OutputMask(mask_width  = 32,
                    bit_indices = (0, 1),
                    value       = 0x1)
    switch = SwitchFrequency_Event(frequency = self.f01,
                                   mask_list = [o1, o2])
    s.add_event(switch)
    
    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\xE0', '\x20', '\xB6', '\x46', # loading lower addend
      '\xE0', '\x21', '\x3D', '\xF3', # loading upper addend
      '\xE0', '\x00', '\xAA', '\xAB', # loading lower offset
      '\xE0', '\x41', '\x2A', '\xAA', # loading upper offset and writing
      '\xE0', '\x10', '\x00', '\x00', # set current
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\x00', '\x00', '\x00', '\x00', # BDS4
      '\xD0', '\x00', '\x00', '\x03', # First mask, lower half in pulse phase
      '\xD0', '\x00', '\x00', '\x01', # Second mask, upper half in pulse phase
      '\xD0', '\x01', '\x00', '\x03', # First mask, lower half in pulse phase
      '\xD0', '\x01', '\x00', '\x01', # Second mask, upper half in pulse phase
      '\x80', '\x00', '\x00', '\x0D', # Halt
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def test_handle_switch_frequency_multiple(self):
    s = PulseSequence()
    s.add_event(self.i01)
    o1 = OutputMask(mask_width  = 32,
                    bit_indices = (0, 1),
                    value       = 0x3)
    o2 = OutputMask(mask_width  = 32,
                    bit_indices = (0, 1),
                    value       = 0x1)
    switch = SwitchFrequency_Event(frequency = self.f01,
                                   mask_list = [o1, o2])
    s.add_event(switch)

    s.add_event(self.i02)
    switch = SwitchFrequency_Event(frequency = self.f02,
                                   mask_list = [o1, o2])
    s.add_event(switch)

    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\xE0', '\x20', '\xB6', '\x46', # loading lower addend
      '\xE0', '\x21', '\x3D', '\xF3', # loading upper addend
      '\xE0', '\x00', '\xAA', '\xAB', # loading lower offset
      '\xE0', '\x41', '\x2A', '\xAA', # loading upper offset and writing
      '\xE0', '\x10', '\x00', '\x00', # set current
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\x00', '\x00', '\x00', '\x00', # BDS4
      '\xD0', '\x00', '\x00', '\x03', # First mask, lower half in pulse phase
      '\xD0', '\x00', '\x00', '\x01', # Second mask, upper half in pulse phase
      '\xD0', '\x01', '\x00', '\x03', # First mask, lower half in pulse phase
      '\xD0', '\x01', '\x00', '\x01', # Second mask, upper half in pulse phase
      '\xE0', '\xA0', '\xB4', '\x39', # loading lower addend
      '\xE0', '\xA1', '\x76', '\xC8', # loading upper addend
      '\xE0', '\x80', '\xAA', '\xAB', # loading lower offset
      '\xE0', '\xC1', '\x2A', '\xAA', # loading upper offset and writing
      '\xE0', '\x90', '\x00', '\x00', # set current
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\x00', '\x00', '\x00', '\x00', # BDS4
      '\xD0', '\x80', '\x00', '\x03', # First mask, lower half in pulse phase
      '\xD0', '\x80', '\x00', '\x01', # Second mask, upper half in pulse phase
      '\xD0', '\x81', '\x00', '\x03', # First mask, lower half in pulse phase
      '\xD0', '\x81', '\x00', '\x01', # Second mask, upper half in pulse phase
      '\x80', '\x00', '\x00', '\x1A', # Halt
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def test_handle_wait(self):
    s = PulseSequence()
    w = Wait_Event(duration = 0x03)
    s.add_event(w)

    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\x90', '\x00', '\x00', '\x03', # wait for duration of 3
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\x80', '\x00', '\x00', '\x04', # Halt
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def test_handle_wait_minimum(self):
    s = PulseSequence()
    w = Wait_Event(duration = 0x02)
    s.add_event(w)

    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\x00', '\x00', '\x00', '\x00', # nop1
      '\x00', '\x00', '\x00', '\x00', # nop2
      '\x80', '\x00', '\x00', '\x02', # Halt
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def test_handle_finite_loop(self):
    s = PulseSequence()
    f = FiniteLoop_Event(sequence = [self.p1, self.p2], loop_count = 5)
    s.add_event(f)

    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\xB0', '\x00', '\x00', '\x05', # ldc
      '\xC0', '\x00', '\x00', '\x0A',
      '\xC0', '\x00', '\x0A', '\x0A',
      '\xA0', '\x00', '\x00', '\x01', # bdec
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\x80', '\x00', '\x00', '\x07', # Halt
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def test_handle_finite_loop_nested(self):
    s = PulseSequence()
    f = FiniteLoop_Event(sequence = [self.p1, self.p2], loop_count = 5)
    f2 = FiniteLoop_Event(sequence = [self.p3, self.p4, f], loop_count = 10)
    s.add_event(f2)

    bp = self.f.translate_sequence(s)
    charlist = bp.get_binary_charlist()
    expected = [
      '\xB0', '\x00', '\x00', '\x0A', # outer ldc
      '\xC0', '\x02', '\x00', '\x0A',
      '\xC0', '\x03', '\xA0', '\x00',
      '\xB0', '\x80', '\x00', '\x05', # inner ldc
      '\xC0', '\x00', '\x00', '\x0A',
      '\xC0', '\x00', '\x0A', '\x0A',
      '\xA0', '\x80', '\x00', '\x04', # inner bdec
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\xA0', '\x00', '\x00', '\x01', # outer bdec
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      '\x80', '\x00', '\x00', '\x0E', # Halt
      '\x00', '\x00', '\x00', '\x00', # BDS1
      '\x00', '\x00', '\x00', '\x00', # BDS2
      '\x00', '\x00', '\x00', '\x00', # BDS3
      ]
    # This will be the binary produced by the default PCP32 opcodes
    self.assertEquals(expected, charlist)
  #----------------------------------------------------------------------------
  def tearDown(self):
    del self.f

#==============================================================================
# Collect all test suites for running
all_suites = unittest.TestSuite((
  unittest.makeSuite(Test_PCP32_Family)
  ))

def run_tests():
  unittest.TextTestRunner(verbosity=2).run(all_suites)
