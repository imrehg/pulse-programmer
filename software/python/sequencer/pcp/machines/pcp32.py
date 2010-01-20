# Module : pcp32
# Package: pcp.machines
# Abstract base class for the PCP32 processor family.

import sequencer.constants
from sequencer.util                import *
from sequencer.pcp.output_register import *
from sequencer.pcp.instructions    import *
from sequencer.pcp.machines        import *

###############################################################################
# Import supported instruction types
from sequencer.pcp.instructions.halt  import * # Halt instruction
from sequencer.pcp.instructions.j     import * # Jump instruction
from sequencer.pcp.instructions.btr   import * # Branch on trigger instruction
from sequencer.pcp.instructions.p     import * # Pulse immediate instruction
from sequencer.pcp.instructions.pp    import * # Pulse phase instruction
from sequencer.pcp.instructions.lp    import * # Load phase instruction
from sequencer.pcp.instructions.ldc   import * # Load constant instruction
from sequencer.pcp.instructions.bdec  import * # Branch-decrement instruction
from sequencer.pcp.instructions.sub   import * # Subroutine instruction
from sequencer.pcp.instructions.ret   import * # Return instruction
from sequencer.pcp.instructions.wait  import * # Wait instruction
from sequencer.pcp.instructions.icnt  import * # Input Counting instruction

# Import supported event types
from sequencer.pcp.events.atomic_pulse     import *
from sequencer.pcp.events.simul_pulse      import *
from sequencer.pcp.events.separable_pulse  import *
from sequencer.pcp.events.finite_loop      import *
from sequencer.pcp.events.wait             import *
from sequencer.pcp.events.init_frequency   import *
from sequencer.pcp.events.switch_frequency import *
from sequencer.pcp.events.subroutine_call  import *
from sequencer.pcp.events.subroutine       import *
from sequencer.pcp.events.ins_nop          import *
from sequencer.pcp.events.input_counter    import *

import copy

#==============================================================================
class PCP32_Family(Family):
  "Base class for the original PCP32 architecture."

  PHASE_PULSE_MASK = OutputMask(mask_width  = 64,
                                bit_indices = (24, 25, 26, 27, 28, 29, 30, 31),
                                value       = 0xFF)

  #----------------------------------------------------------------------------
  def handle_separable_pulse(self, separable_event):
    word_list = [separable_event.get_first_word()]
    merged_mask = None;
    for event in separable_event.event_generator():
      current_mask = event.get_output_mask()
      if (merged_mask == None):
        merged_mask = current_mask
      else:
        try:
          new_mask = merged_mask.merge(current_mask)
          new_mask.get_subcontainment(16)
          merged_mask = new_mask
        except ContainmentError, ce:
          p = PulseImmed_Instr(output_mask = merged_mask,
                               duration    = 0, # always minimum duration
                               output_reg  = self.reg16)
          word_list.append(p)
          merged_mask = current_mask
    # Add last word
    p = PulseImmed_Instr(output_mask = merged_mask,
                         duration    = 0, # always minimum duration
                         output_reg  = self.reg16)
    word_list.append(p)
    return word_list
  handle_separable_pulse = Callable(handle_separable_pulse)
  #----------------------------------------------------------------------------
  def handle_subroutine_return(self):
    word_list = [SubroutineReturn_Instr()]
    # Naively fill branch delay slots with non-collapsable nops
    for i in range(self.branch_delay_slots):
      word_list.append(Nop_Instr())
    return word_list
  #----------------------------------------------------------------------------
  def handle_subroutine_call(self, event):
    word_list = [event.get_first_word()]
    subroutine = event.get_target()
    target = subroutine.get_first_word()
    word_list.append(SubroutineCall_Instr(target = target))
    # Naively fill branch delay slots with non-collapsable nops
    for i in range(self.branch_delay_slots):
      word_list.append(Nop_Instr())

    return word_list
  handle_subroutine_call = Callable(handle_subroutine_call)
  #----------------------------------------------------------------------------
  def handle_init_frequency(self, event):
    word_list = [event.get_first_word()]
    if (self.phase_registers.has_key(event.get_frequency())):
      raise RuntimeError("Cannot initialize the same frequency twice.")
    if (self.current_phase_reg >= self.phase_register_max):
      raise RuntimeError("There are no more free phase registers to use.")
    lower_addend_word = event.get_tuning_word(0, self.phase_load_width)
    upper_addend_word = event.get_tuning_word(1, self.phase_load_width)
    lower_offset_word = event.get_phase_offset(0, self.phase_load_width)
    upper_offset_word = event.get_phase_offset(1, self.phase_load_width)
    debug_print("lower addend word: "+ str(lower_addend_word),3)
    debug_print("upper addend word: "+ str(upper_addend_word),3)
    debug_print("tuning word: "+ str(event.tuning_word),3)
    debug_print("offset word: " +str(event.phase_offset),3)
    l1 = LoadPhase_Instr(constant         = lower_addend_word,
                         register         = self.current_phase_reg,
                         select           = 0,
                         wren_flag        = 0,
                         addend_flag      = 1,
                         set_current_flag = 0)
    l2 = LoadPhase_Instr(constant         = upper_addend_word,
                         register         = self.current_phase_reg,
                         select           = 1,
                         wren_flag        = 0,
                         addend_flag      = 1,
                         set_current_flag = 0)
    l3 = LoadPhase_Instr(constant         = lower_offset_word,
                         register         = self.current_phase_reg,
                         select           = 0,
                         wren_flag        = 0,
                         addend_flag      = 0,
                         set_current_flag = 0)
    l4 = LoadPhase_Instr(constant         = upper_offset_word,
                         register         = self.current_phase_reg,
                         select           = 1,
                         wren_flag        = 1,
                         addend_flag      = 0,
                         set_current_flag = 0)
    l5 = LoadPhase_Instr(constant         = 0,
                         register         = self.current_phase_reg,
                         select           = 0,
                         wren_flag        = 0,
                         addend_flag      = 0,
                         set_current_flag = 0)
    word_list.append(l1)
    word_list.append(l2)
    word_list.append(l3)
    word_list.append(l4)
    word_list.append(l5)
    # Add the abstract frequency to our dictionary
    self.phase_registers[event.get_frequency()] = self.current_phase_reg
    self.current_phase_reg += 1
    return word_list
  handle_init_frequency = Callable(handle_init_frequency)
  #----------------------------------------------------------------------------
  def handle_switch_frequency(self, phase_event):
    word_list = [phase_event.get_first_word()]
    frequency = phase_event.frequency

    phase_offset = phase_event.phase_offset
    print "pcp phase: "+str(phase_offset)
    # define the lonely usesless phase offset
    # What to do with this cute offset?
    # should we add it to the register?

    if (not self.phase_registers.has_key(frequency)):
      raise RuntimeError("Phase register not previously initialized. " + \
                         str(frequency))

    phase_reg = self.phase_registers[frequency]

    #get the phase offset words --PS

    lower_offset_word = phase_event.get_phase_offset(0, self.phase_load_width)
    upper_offset_word = phase_event.get_phase_offset(1, self.phase_load_width)

     #write upper half of phase offset register
    lp1 = LoadPhase_Instr(constant         = upper_offset_word,
                          register         = phase_reg,
                          select           = 1,
                          wren_flag        = 0,
                          addend_flag      = 1,
                          set_current_flag = 0)
    #Write lower half of phase offset and set as current
    lp2 = LoadPhase_Instr(constant         = lower_offset_word,
                          register         = phase_reg,
                          select           = 0,
                          wren_flag        = 0,
                          addend_flag      = 1,
                          set_current_flag = 1)
    # Clear current
    lp3 = LoadPhase_Instr(constant         = 0x00,
                          register         = phase_reg,
                          select           = 0,
                          wren_flag        = 0,
                          addend_flag      = 0,
                          set_current_flag = 0)
#    print "upper phase reg: "+str(lp1)
    word_list.append(lp1)
    # Insert four branch delay slots (clearing set_current_flag counts as one)
    word_list.append(lp2)
    word_list.append(lp3)
    for i in range(0,3):
      word_list.append(Nop_Instr())

    # Pulse all parts of word b/c we don't know what has changed or not


    # pulse the address and the data with the pp pulse
    # then add an atomic pulse for the WRB pin
    for i in range(PulsePhase_Instr.MULTIPLE):
      #for mask in phase_event.mask_list:
#      print "phase select"+str(i)
      debug_print("phase_select: " +str(i),0)
      debug_print("addr mask: " +str(phase_event.addr_mask_list[i]),3)
      pp = PulsePhase_Instr(output_mask  = copy.copy(phase_event.addr_mask_list[i]),
                              output_reg   = self.reg16,
                              register     = phase_reg,
                              phase_select = i)
      word_list.append(pp)

      addr_mask=copy.copy(phase_event.addr_mask_list[i])
      write_mask=addr_mask.merge(phase_event.mask_list[0])

      wpp = PulsePhase_Instr(output_mask  = copy.copy(write_mask),
                              output_reg   = self.reg16,
                              register     = phase_reg,
                              phase_select = i)
      word_list.append(wpp)

#      write_pulse=PulseImmed_Instr(output_mask = write_mask,
#                                  duration    = 0, # always minimum duration
#                                  output_reg  = self.reg16)
#      word_list.append(write_pulse)

      not_write_mask=addr_mask.merge(phase_event.mask_list[1])
      debug_print("write: " +str(write_mask), 3)

      not_write_pulse = PulsePhase_Instr(output_mask  = not_write_mask,
                                         output_reg   = self.reg16,
                              register     = phase_reg,
                              phase_select = i)

#      not_write_pulse=PulseImmed_Instr(output_mask = not_write_mask,
#                                  duration    = 0, # always minimum duration
#                                  output_reg  = self.reg16)

      word_list.append(not_write_pulse)
      debug_print("not write: " + str(not_write_mask), 3)

    return word_list
  handle_switch_frequency = Callable(handle_switch_frequency)
  #----------------------------------------------------------------------------
  def handle_ins_nop(self, event):
    word_list = [event.get_first_word()]
    for i in range(event.number):
      word_list.append(Nop_Instr())
    return word_list
  handle_ins_nop = Callable(handle_ins_nop)
  #----------------------------------------------------------------------------
  def handle_wait(self, event):
    word_list = [event.get_first_word()]
    duration = event.get_duration()
    if (duration >= self.min_wait_duration+4):
      word_list.append(Wait_Instr(duration = duration))
      # Naively fill branch delay slots with non-collapsable nops
      for i in range(self.branch_delay_slots):
        word_list.append(Nop_Instr())
    else:
      for i in range(duration):
        word_list.append(Nop_Instr())
    return word_list
  handle_wait = Callable(handle_wait)
  #----------------------------------------------------------------------------
  def handle_atomic_pulse(self, event):
    word_list = [event.get_first_word()]
    output_mask = event.get_output_mask()
    output_mask = output_mask.split(
      sub_width = sequencer.constants.HARDWARE_OUTPUT_WIDTH,
      index     = self.chain_position)
    p = PulseImmed_Instr(output_mask = output_mask,
                         duration    = 0, # always minimum duration
                         output_reg  = self.reg16)
    word_list.append(p)
    if (not event.get_is_min_duration()):
      # Create a fake wait word event so we don't add the same first word twice
      fake_wait = Wait_Event(duration = event.get_duration()-1)
      wait_word_list = self.handle_wait(self, fake_wait)
      word_list.extend(wait_word_list)
    return word_list
  handle_atomic_pulse = Callable(handle_atomic_pulse)
  #----------------------------------------------------------------------------
  # PCP32 can handle true loops (and nested ones too)
  def handle_finite_loop(self, loop_event):
    if (self.loop_register_index >= self.loop_register_max):
      raise RuntimeError("Nested loop depth exceeded: " + \
                         str(self.loop_register_index))
    # Loop beginning is just a collapsable nop
    loop_begin = Nop_Instr(collapsable = True)
    # Save the value of this nesting level before incrementing for body.
    this_loop_index = self.loop_register_index
    self.loop_register_index += 1
    word_list = [loop_event.get_first_word()]
    word_list.append(LoadConstant_Instr(this_loop_index,
                                        loop_event.get_loop_count()))
    word_list.append(loop_begin)
    for event in loop_event.event_generator():
      word_list.extend(self.translate_event(event))
    word_list.append(BranchDecrement_Instr(loop_begin, this_loop_index))
    # Naively fill branch delay slots with non-collapsable nops
    for i in range(self.branch_delay_slots):
      word_list.append(Nop_Instr())

    # Decrement back to this nesting level
    self.loop_register_index -= 1
    if (self.loop_register_index != this_loop_index):
      raise MismatchError("Nested loop mistmatched.",
                          this_loop_index, self.loop_register_index)
    return word_list
  handle_finite_loop = Callable(handle_finite_loop)
  #----------------------------------------------------------------------------
  def handle_simul_pulse(self, event):
    raise RuntimeError("not yet implemented.")
    word_list = [event.get_first_word()]
  handle_simul_pulse = Callable(handle_simul_pulse)
  #----------------------------------------------------------------------------
### TODO: ###
  def handle_input_counter_reset(self, event):
	word_list = [event.get_first_word()]
	word_list.append(InputCounter_Instr(
						register = event.get_input_channel().get_bit_index(),
						subopcode = event.get_subopcode(),
						mem_address = 0)) # address unused
	return word_list
  handle_input_counter_reset = Callable(handle_input_counter_reset)
  #----------------------------------------------------------------------------
  def handle_input_counter_latch(self, event):
	word_list = [event.get_first_word()]
	word_list.append(InputCounter_Instr(
						register = event.get_input_channel().get_bit_index(),
						subopcode = event.get_subopcode(),
						mem_address = 0)) # address unused
	return word_list
  handle_input_counter_latch = Callable(handle_input_counter_latch)
  #----------------------------------------------------------------------------
  def handle_input_counter_write(self, event):
	word_list = [event.get_first_word()]
	word_list.append(InputCounter_Instr(
						register = event.get_input_channel().get_bit_index(),
						subopcode = event.get_subopcode(),
						mem_address = event.get_memory_address()))
	return word_list
  handle_input_counter_write = Callable(handle_input_counter_write)
  #----------------------------------------------------------------------------
  def handle_input_counter_compare(self, event):
	word_list = [event.get_first_word()]
	word_list.append(InputCounter_Instr(
						register = event.get_input_channel().get_bit_index(),
						subopcode = event.get_subopcode(),
						mem_address = 0)) # address unused
	return word_list
  handle_input_counter_compare = Callable(handle_input_counter_compare)
  #----------------------------------------------------------------------------
  def handle_input_counter_branch(self, event):
	word_list = [event.get_first_word()]
	word_list.append(InputCounter_Instr(
						register = event.get_input_channel().get_bit_index(),
						subopcode = event.get_subopcode(),
						mem_address = event.get_target())) #### TODO: this should not be get_target? ###
	return word_list
  handle_input_counter_branch = Callable(handle_input_counter_branch)
  #----------------------------------------------------------------------------
  def __init__(self               ,
               name               ,
               sub_stack_depth    ,
               loop_address_width ,
               loop_data_width    ,
               phase_address_width,
               phase_data_width   ,
               phase_adjust_width ,
               phase_load_width   ,
               phase_pulse_width  ,
               min_wait_duration  ,
               chain_position     = 0,
               ):
    Family.__init__(self,
                    name               = name          ,
                    chain_position     = chain_position,
                    word_width         = 32            ,
                    address_width      = 19            ,
                    program_size       = 524288        ,
                    reg_width          = 5             ,
                    reg_count          = 32            ,
                    min_duration       = 1             ,
                    branch_delay_slots = 5
                    )
    self.event_dict[AtomicPulse_Event    ] = self.handle_atomic_pulse
    self.event_dict[SimulPulse_Event     ] = self.handle_simul_pulse
    self.event_dict[FiniteLoop_Event     ] = self.handle_finite_loop
    self.event_dict[SeparablePulse_Event ] = self.handle_separable_pulse
    self.event_dict[SubroutineCall_Event ] = self.handle_subroutine_call
    self.event_dict[InitFrequency_Event  ] = self.handle_init_frequency
    self.event_dict[SwitchFrequency_Event] = self.handle_switch_frequency
    self.event_dict[Wait_Event           ] = self.handle_wait
    self.event_dict[ins_nop_Event        ] = self.handle_ins_nop
	### TODO: ###
    self.event_dict[InputCounterReset_Event] = self.handle_input_counter_reset
    self.event_dict[InputCounterLatch_Event] = self.handle_input_counter_latch
    self.event_dict[InputCounterWrite_Event] = self.handle_input_counter_write
    self.event_dict[InputCounterCompare_Event] = self.handle_input_counter_compare
    self.event_dict[InputCounterBranch_Event] = self.handle_input_counter_branch
    # Create family-specific output registers for remembering output values
    self.reg16 = (OutputRegister(16), OutputRegister(16),
                  OutputRegister(16), OutputRegister(16))

    if (sub_stack_depth < 0):
      raise RuntimeError("Address stack depth cannot be negative.")
    if ((loop_address_width < 0) or (loop_address_width > 5)):
      raise RangeError("Loop reg address width must be within 0-5 bits.",
                       0, 5, loop_address_width);
    if ((loop_data_width < 0) or (loop_data_width > 22)):
      raise RangeError("Loop data width must be within 0-22 bits.",
                       0, 22, loop_data_width);
    if ((phase_address_width < 0) or (phase_address_width > 5)):
      raise RangeError("Phase reg address width must be within 0-5 bits.",
                       0, 5, phase_address_width);
    if (phase_data_width < 0):
      raise RuntimeError("Phase data width cannot be negative.")
    if (phase_adjust_width < 0):
      raise RuntimeError("Phase adjust width cannot be negative.")
    if (phase_pulse_width < 0):
      raise RuntimeError("Phase pulse width cannot be negative.")
    if (phase_load_width < 0):
      raise RuntimeError("Phase load width cannot be negative.")
    if (min_wait_duration < 0):
      raise RuntimeError("Minimum wait duration cannot be negative.")

    self.sub_stack_depth     = sub_stack_depth
    self.loop_address_width  = loop_address_width
    self.loop_data_width     = loop_data_width
    self.phase_address_width = phase_address_width
    self.phase_data_width    = phase_data_width
    self.phase_adjust_width  = phase_adjust_width
    self.phase_pulse_width   = phase_pulse_width
    self.phase_load_width    = phase_load_width
    self.min_wait_duration   = min_wait_duration

    self.loop_register_max   = 2**loop_address_width
    self.phase_register_max  = 2**phase_address_width

    self.subroutine_dict     = {}
    self.loop_register_index = 0
    self.phase_registers     = {} # Dict of abstract frequencies for switching
    self.current_phase_reg   = 0
  #----------------------------------------------------------------------------
  def get_sub_stack_depth(self):
    return self.sub_stack_depth
  #----------------------------------------------------------------------------
  def get_loop_address_width(self):
    return self.loop_address_width
  #----------------------------------------------------------------------------
  def get_loop_data_width(self):
    return self.loop_data_width
  #----------------------------------------------------------------------------
  def get_phase_address_width(self):
    return self.phase_address_width
  #----------------------------------------------------------------------------
  def get_phase_data_width(self):
    return self.phase_data_width
  #----------------------------------------------------------------------------
  def get_phase_adjust_width(self):
    return self.phase_adjust_width
  #----------------------------------------------------------------------------
  def get_phase_load_width(self):
    return self.phase_load_width
  #----------------------------------------------------------------------------
  def get_phase_pulse_width(self):
    return self.phase_pulse_width
  #----------------------------------------------------------------------------
  def get_min_wait_duration(self):
    return self.min_wait_duration
  #----------------------------------------------------------------------------
  def machine_dependent_epilogue(self, program, sequence):
    # Add a final halt before subroutine definitions
    program.extend_words(self.handle_halt(self, Halt_Event()))

    # Resolve subroutine definitions
    for sub_event in sequence.get_sub_events():
      sub_word_list = [sub_event.get_first_word()]
      for event in sub_event.event_generator():
        sub_word_list.extend(self.translate_event(event))
      # Return from subroutine after body
      sub_word_list.extend(self.handle_subroutine_return())
      program.extend_words(sub_word_list)
  #----------------------------------------------------------------------------
  def setup_instructions(self):
    Word                  .set_masks(word_width    = 32,
                                     address_width = 19)
    InstructionWord       .set_opcode_mask(opcode_width = 4) # 4 bits for PCP32
    TargetInstruction     .set_address_mask()
    Halt_Instr            .set_opcode(opcode = 0x8)
    Jump_Instr            .set_opcode(opcode = 0x4)

    BranchTrigger_Instr   .set_opcode(opcode = 0x3)
    BranchTrigger_Instr   .set_trigger_mask(trigger_width = 9,
                                            trigger_shift = 19)
    PulseImmed_Instr      .set_opcode(opcode = 0xC)
    PulseImmed_Instr      .set_masks(output_width   = 16,
                                     output_shift   = 0 ,
                                     duration_width = 0 ,
                                     duration_shift = 0 ,
                                     select_shift   = 16)
    SubroutineCall_Instr  .set_opcode(opcode = 0x5)
    SubroutineReturn_Instr.set_opcode(opcode = 0x6)
    Wait_Instr            .set_opcode(opcode = 0x9)
    Wait_Instr            .set_masks(duration_width = 28,
                                     duration_shift = 0)
    BranchDecrement_Instr .set_opcode(opcode = 0xA)
    BranchDecrement_Instr .set_masks(register_width = self.loop_address_width,
                                     register_shift = 23)
    LoadConstant_Instr    .set_opcode(opcode = 0xB)
    LoadConstant_Instr    .set_masks(constant_width = self.loop_data_width,
                                     constant_shift = 0,
                                     register_width = self.loop_address_width,
                                     register_shift = 23)
    PulsePhase_Instr      .set_opcode(opcode = 0xD)
    PulsePhase_Instr.set_masks(
      phase_data_width      = self.phase_pulse_width,
      phase_data_shift      = 16 - self.phase_pulse_width,
      output_width          = 16, # Meant to overlap with phase_data
      output_shift          = 0,
      register_width        = self.phase_address_width,
      register_shift        = 23,
      phase_select_shift    = 16,
      hw_phase_adjust_width = self.phase_adjust_width)
    LoadPhase_Instr       .set_opcode(opcode = 0xE)
    LoadPhase_Instr.set_masks(
      constant_width         = self.phase_load_width,
      constant_shift         = 0,
      register_width         = self.phase_address_width,
      register_shift         = 23,
      select_shift           = 16,
      wren_flag_shift        = 22,
      addend_flag_shift      = 21,
      set_current_flag_shift = 20,
      hw_phase_data_width    = self.phase_data_width)
	### TODO: ###
    InputCounter_Instr.set_opcode(opcode = 0x2)
    InputCounter_Instr.set_masks(
	  register_width = 5,
	  register_shift = 23,
	  subopcode_width = 3,
	  subopcode_shift = 20,
	  address_width = 18,
	  address_shift = 0)

#==============================================================================
