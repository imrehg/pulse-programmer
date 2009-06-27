# Module  ld64i
# Package pcp.instructions
# Load 64-bit immediate instruction class definition
# for Pulse Control Processor binary instruction words.

from sequencer.pcp                   import *
from sequencer.pcp.bitmask           import *
from sequencer.pcp.instructions.insn import *

#==============================================================================
class Load64Immed_Instr(TargetInstruction):
  "Instruction word for loading a 64-bit constant at an immediate address."
  #----------------------------------------------------------------------------
  OPCODE         = 0x04 # Default 6-bit opcode for PCP64
  
  REGISTER_MASK = Bitmask(label = "Register", width = 5, shift = 51)
  #----------------------------------------------------------------------------
  def set_opcode(opcode):
    InstructionWord.check_opcode(opcode)
    Load64Immed_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
  set_opcode = Callable(set_opcode)
  #----------------------------------------------------------------------------
  def set_reg_mask(register_width, register_shift):

    register_mask = Bitmask(label = "Register",
                            width = register_width,
                            shift = register_shift)

    # Check mask widths and shifts
    Load64Immed_Instr.MASK_LIST = list(TargetInstruction.MASK_LIST);
    Load64Immed_Instr.MASK_LIST.extend([register_mask])
    InstructionWord.check_masks(Load64Immed_Instr.MASK_LIST)

    Load64Immed_Instr.REGISTER_MASK  = register_mask
  set_reg_mask = Callable(set_reg_mask)
  #----------------------------------------------------------------------------
  def __init__(self, target, register):
    """
    Load64Immed_Instr(target, trigger)
      target   = immediate instruction (source for load)
      register = destination register for load.
    """
    TargetInstruction.__init__(self, target, False)
    check_inputs([(register, Load64Immed_Instr.REGISTER_MASK)])
    self.register = register
  #----------------------------------------------------------------------------
  def get_register(self):
    return self.REGISTER_MASK.get_shifted_value(self.register)
  #----------------------------------------------------------------------------
  def resolve_value(self):
    self.value = self.get_opcode() | self.target.get_address() | \
                 self.get_register()

