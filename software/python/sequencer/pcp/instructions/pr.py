# Module : pr
# Package: pcp.instructions
# Pulse register instruction class definition
# for Pulse Control Processor binary instruction words.

from sequencer.pcp                   import *
from sequencer.pcp.bitmask           import *
from sequencer.pcp.instructions.insn import *

#------------------------------------------------------------------------------
class PulseReg_Instr(InstructionWord):
  "Instruction word for register pulse."
  #----------------------------------------------------------------------------
  OPCODE                 = 0x1D # Default 6-bit opcode for PCP64

  OUTPUT_REGISTER_MASK   = Bitmask(label = "Output Register",
                                   width = 5,
                                   shift = 41)
  DURATION_REGISTER_MASK = Bitmask(label = "Duration Register",
                                   width = 5,
                                   shift = 46)
  #----------------------------------------------------------------------------
  def set_opcode(opcode):
    InstructionWord.check_opcode(opcode)
    PulseReg_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
  set_opcode = Callable(set_opcode)
  #----------------------------------------------------------------------------
  def set_masks(output_reg_width, output_reg_shift,
                duration_reg_width, duration_reg_shift):

    output_reg_mask   = Bitmask(label = "Output Register",
                                width = output_reg_width,
                                shift = output_reg_shift)
    duration_reg_mask = Bitmask(label = "Duration Register",
                                width = duration_reg_width,
                                shift = duration_reg_shift)

    PulseReg_Instr.MASK_LIST = list(InstructionWord.MASK_LIST)
    PulseReg_Instr.MASK_LIST.extend([output_reg_mask, duration_reg_mask])

    InstructionWord.check_masks(PulseReg_Instr.MASK_LIST)

    PulseReg_Instr.OUTPUT_REGISTER_MASK   = output_reg_mask
    PulseReg_Instr.DURATION_REGISTER_MASK = duration_reg_mask
  set_masks = Callable(set_masks)
  #----------------------------------------------------------------------------
  def __init__(self, output_reg, duration_reg):
    """
    PulseReg_Instr(output_reg, duration_reg)
      output_reg   = tuple of (reg value, reg width in bits, reg end bit index)
      duration_reg = tuple of (reg value, reg width in bits, reg end bit index)
    """

    check_inputs([(output_reg  , PulseReg_Instr.OUTPUT_REGISTER_MASK),
                  (duration_reg, PulseReg_Instr.DURATION_REGISTER_MASK)])

    self.output_reg   = output_reg
    self.duration_reg = duration_reg
  #----------------------------------------------------------------------------
  def get_output_reg(self):
    return self.OUTPUT_REGISTER_MASK.get_shifted_value(self.output_reg)
  #----------------------------------------------------------------------------
  def get_duration_reg(self):
    return self.DURATION_REGISTER_MASK.get_shifted_value(self.duration_reg)
  #----------------------------------------------------------------------------
  def resolve_value(self):
    self.value = self.get_opcode() | self.get_output_reg() | \
                 self.get_duration_reg()

  
