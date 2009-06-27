# Module : ldc
# Package: pcp.instructions
# Load constant into loop register instruction class definition
# for Pulse Control Processor binary instruction words.

from sequencer.pcp                   import *
from sequencer.pcp.bitmask           import *
from sequencer.pcp.instructions.insn import *

#==============================================================================
class LoadConstant_Instr(TargetInstruction):
  """
  Instruction word for loading a constant into a loop register
  in a pulse program.
  """
  #----------------------------------------------------------------------------
  OPCODE         = 0xB # Default 4-bit opcode for PCP32

  REGISTER_MASK = Bitmask(label = "Register", width = 5, shift = 23)
  CONSTANT_MASK = Bitmask(label = "Constant", width = 4, shift = 0)

  MASK_LIST      = []
  #----------------------------------------------------------------------------
  def set_opcode(opcode):
    InstructionWord.check_opcode(opcode)
    LoadConstant_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
  set_opcode = Callable(set_opcode)
  #----------------------------------------------------------------------------
  def set_masks(register_width, register_shift,
                constant_width, constant_shift):

    # Create masks for testing
    register_mask = Bitmask(label = "Register",
                            width = register_width,
                            shift = register_shift)
    constant_mask = Bitmask(label = "Constant",
                            width = constant_width,
                            shift = constant_shift)

    LoadConstant_Instr.MASK_LIST = list(InstructionWord.MASK_LIST)
    LoadConstant_Instr.MASK_LIST.extend([register_mask, constant_mask])

    # Check widths and shifts for all fields
    InstructionWord.check_masks(LoadConstant_Instr.MASK_LIST)

    LoadConstant_Instr.REGISTER_MASK  = register_mask
    LoadConstant_Instr.CONSTANT_MASK  = constant_mask
  set_masks = Callable(set_masks)
  #----------------------------------------------------------------------------
  def __init__(self, register, constant):
    """
    LoadConstant_Instr(loop_reg, data_constant)
      register = address of loop register to use for decrementing/branching.
      constant = initial value of loop_reg
    """
    InstructionWord.__init__(self)
    # This has to be done otherwise the collapsable attribute is not set
    check_inputs([(register, LoadConstant_Instr.REGISTER_MASK),
                  (constant, LoadConstant_Instr.CONSTANT_MASK)])

    self.register = register
    self.constant = constant
  #----------------------------------------------------------------------------
  def get_register(self):
    return self.REGISTER_MASK.get_shifted_value(self.register)
  #----------------------------------------------------------------------------
  def get_constant(self):
    return self.CONSTANT_MASK.get_shifted_value(self.constant)
  #----------------------------------------------------------------------------
  def resolve_value(self):
    self.value = self.get_opcode() | self.get_constant() | \
                 self.get_register()
  #----------------------------------------------------------------------------
  def __str__(self):
    return "LoadConstant_Instr: "        \
           "reg=" + hex(self.register) + \
           "dat=" + hex(self.constant)
#==============================================================================
