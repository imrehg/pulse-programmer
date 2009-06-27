# Module : pcp64
# Package: pcp.machines
# Abstract base class for the PCP64 processor family.

import sequencer.constants
from sequencer.util                import *
from sequencer.pcp.output_register import *
from sequencer.pcp.output_mask     import *
from sequencer.pcp.instructions    import *
from sequencer.pcp.machines        import *

###############################################################################
# Import supported instruction types
from sequencer.pcp.instructions.halt  import * # Halt instruction
from sequencer.pcp.instructions.j     import * # Jump instruction
from sequencer.pcp.instructions.btr   import * # Branch on trigger instruction
from sequencer.pcp.instructions.p     import * # Pulse immediate instruction
from sequencer.pcp.instructions.pr    import * # Pulse register instruction
from sequencer.pcp.instructions.ld64i import * # Load 64-bit immed instruction

# Import supported event types
from sequencer.pcp.events.atomic_pulse import *
from sequencer.pcp.events.simul_pulse  import *
from sequencer.pcp.events.finite_loop  import *
from sequencer.pcp.events.load_immed   import *
from sequencer.pcp.events.data         import *

#==============================================================================
class PCP64_Family(Family):
  "Base class for the original PCP64 architecture."

  DURATION_2_BIT = 57
  DURATION_2_MASK = Bitmask(label = "Duration 2",
                            width = 1,
                            shift = DURATION_2_BIT)
  #----------------------------------------------------------------------------
  def create_reg_pulse(self, output_mask, duration):
    output_reg      = self.get_reg(output_mask.get_set_mask())
    duration_reg    = self.get_reg(duration)
    p               = PulseReg_Instr(output_reg, duration_reg)
    self.last_pulse = p
    return p
  #----------------------------------------------------------------------------
  def handle_load(self, event):
    raise RuntimeError("not yet implemented")
  handle_load = Callable(handle_load)
  #----------------------------------------------------------------------------
  def handle_data(self, event):
    raise RuntimeError("not yet implemented")
  handle_data = Callable(handle_data)
  #----------------------------------------------------------------------------
  def handle_wait(self, event):
    if (self.last_pulse.__class__ == PulseImmed_Instr):
      new_duration = self.last_pulse.get_duration() + event.get_duration()
      self.last_pulse.duration = new_duration
    else:
      raise RuntimeError("only waits after immediate pulses are supported.")
  handle_wait = Callable(handle_wait)
  #----------------------------------------------------------------------------
  def handle_atomic_pulse(self, event):
    output_mask = event.get_output_mask()
    duration    = event.get_duration()
    word_list   = [event.get_first_word()]
    flags       = []

    # Perform splitting here for this device chain position.
    output_mask = output_mask.split(
      sub_width = sequencer.constants.HARDWARE_OUTPUT_WIDTH,
      index     = self.chain_position)

    if (duration >= self.min_duration):
      # We have to handle the special case of minimum width pulse here (0x02)
      
      if ((duration <= self.min_duration) or (event.get_is_min_duration())):
        flags.append((self.DURATION_2_MASK, 0x1))
        duration = 0
      p = PulseImmed_Instr(output_mask = output_mask,
                           duration    = duration,
                           output_reg  = self.reg32,
                           flags       = flags)
      self.last_pulse = p
      word_list.append(p)
    # Otherwise it must use a 64-bit register, and we check to see if has
    # greater than the register pulse duration.
    elif (duration >= self.min_reg_duration):
      word_list.append(self.create_reg_pulse(output_mask, duration))
    return word_list
  handle_atomic_pulse = Callable(handle_atomic_pulse)
  #----------------------------------------------------------------------------
  # PCP64 doesn't have a looping instruction, so just repeat a finite loop
  # (kludge)
  def handle_finite_loop(self, loop_event):
    word_list = loop_event.get_first_word()
    for i in range(loop_event.get_loop_count()):
      for event in loop_event.event_generator():
        word_list.extend(self.translate_event(event))
    return word_list
  handle_finite_loop = Callable(handle_finite_loop)
  #----------------------------------------------------------------------------
  def handle_simul_pulse(self, event):
    word_list = [event.get_first_word()]
    word_list.append(self.create_reg_pulse(event.get_output_mask(),
                                           event.get_duration()))
    return word_list
  handle_simul_pulse = Callable(handle_simul_pulse)
  #----------------------------------------------------------------------------
  def __init__(self,
               name               ='PCP64',
               chain_position     = 0,
               min_immed_duration = 2,
               min_reg_duration   = 3,
               ):
    Family.__init__(self,
                    name               = name,
                    chain_position     = chain_position,
                    word_width         = 64,
                    address_width      = 11,
                    program_size       = 2048,
                    reg_width          = 5,
                    reg_count          = 32,
                    min_duration       = min_immed_duration,
                    branch_delay_slots = 1
                    )
    if (min_reg_duration <= 0):
      raise DurationError("Minimum register duration must be positive.",
                          min_reg_duration)
    self.min_reg_duration              = min_reg_duration
    self.event_dict[AtomicPulse_Event] = self.handle_atomic_pulse
    self.event_dict[SimulPulse_Event]  = self.handle_simul_pulse
    self.event_dict[FiniteLoop_Event]  = self.handle_finite_loop
    self.event_dict[LoadImmed_Event]   = self.handle_load
    self.event_dict[Data_Event]        = self.handle_data
    # Create family-specific output registers for remembering output values
    self.reg32 = (OutputRegister(32), OutputRegister(32))
    self.reg64 = OutputRegister(64)
    zero_mask = OutputMask(mask_width = 32)
    # Initial pulse is virtual; all zeros, to handle initial waits correctly.
    self.last_pulse = PulseImmed_Instr(output_mask = zero_mask,
                                       output_reg  = self.reg32,
                                       duration    = 0)
  #----------------------------------------------------------------------------
  def machine_dependent_epilogue(self, program, sequence):
    # Add a final halt to safely end program.
    program.extend_words(self.handle_halt(self, Halt_Event()))
  #----------------------------------------------------------------------------
#  def generate_load_data(self, reg, value):
#    data_word = Family.generate_load_data(value)
#    self.load_words.append(Load64Immed_Instr(data_word, reg))
  #----------------------------------------------------------------------------
  def setup_instructions(self):
    Word               .set_masks(word_width    = 64,
                                  address_width = 11)
    InstructionWord    .set_opcode_mask(opcode_width = 6) # 6 bits for PCP64
    TargetInstruction  .set_address_mask()
    Halt_Instr         .set_opcode(opcode = 0x19)
    Jump_Instr         .set_opcode(opcode = 0x17)
    BranchTrigger_Instr.set_opcode(opcode = 0x14)
    BranchTrigger_Instr.set_trigger_mask(trigger_width = 9,
                                         trigger_shift = 32)
    PulseImmed_Instr   .set_opcode(opcode = 0x1C)
    PulseImmed_Instr   .set_masks(output_width   = 32,
                                  output_shift   = 0,
                                  duration_width = 23,
                                  duration_shift = 33,
                                  select_shift   = 32,
                                  flag_masks     = [self.DURATION_2_MASK])
    PulseReg_Instr     .set_opcode(opcode = 0x1D)
    PulseReg_Instr     .set_masks(output_reg_width = 5,
                                  output_reg_shift = 41,
                                  duration_reg_width = 5,
                                  duration_reg_shift = 46)
    Load64Immed_Instr  .set_opcode(opcode = 0x04)
    Load64Immed_Instr  .set_reg_mask(register_width = 5,
                                     register_shift = 51)
#==============================================================================

