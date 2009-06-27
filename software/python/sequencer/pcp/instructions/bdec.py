# Module : bdec
# Package: pcp.instructions
# Decrement and branch instruction class definition
# for Pulse Control Processor binary instruction words.

from sequencer.pcp                   import *
from sequencer.pcp.bitmask           import *
from sequencer.pcp.instructions.insn import *

#==============================================================================
class BranchDecrement_Instr(TargetInstruction):
  """
  Instruction word for decrement branching (loop counters) in a pulse program.
  """
  #----------------------------------------------------------------------------
  OPCODE        = 0xA # Default 4-bit opcode for PCP32
  REGISTER_MASK = Bitmask(label = "Register", width = 5, shift = 23)
  MASK_LIST     = []
  #----------------------------------------------------------------------------
  def set_opcode(opcode):
    InstructionWord.check_opcode(opcode)
    BranchDecrement_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
  set_opcode = Callable(set_opcode)
  #----------------------------------------------------------------------------
  def set_masks(register_width, register_shift):

    # Create masks for testing
    register_mask = Bitmask(label = "Register",
                            width = register_width,
                            shift = register_shift)

    BranchDecrement_Instr.MASK_LIST = list(TargetInstruction.MASK_LIST)
    BranchDecrement_Instr.MASK_LIST.extend([register_mask])

    # Check mask widths and shifts.
    InstructionWord.check_masks(BranchDecrement_Instr.MASK_LIST)

    BranchDecrement_Instr.REGISTER_MASK  = register_mask
  set_masks = Callable(set_masks)
  #----------------------------------------------------------------------------
  def __init__(self, target, loop_register):
    """
    BranchDecrement_Instr(target, loop_reg)
      target   = destination instruction of branch.
      loop_reg = address of loop register to use for decrementing/branching.
    """
    TargetInstruction.__init__(self, target, True)
    check_inputs([(loop_register, BranchDecrement_Instr.REGISTER_MASK)])

    self.loop_register = loop_register
  #----------------------------------------------------------------------------
  def get_loop_register(self):
    return self.REGISTER_MASK.get_shifted_value(self.loop_register)
  #----------------------------------------------------------------------------
  def resolve_value(self):
    self.value = self.get_opcode() | self.target.get_address() | \
                 self.get_loop_register()
  #----------------------------------------------------------------------------
  def __str__(self):
    return "BranchDecrement_Instr: " \
           "tgt=" + hex(self.target.get_address()) + \
           "reg=" + hex(self.loop_register)
#==============================================================================
