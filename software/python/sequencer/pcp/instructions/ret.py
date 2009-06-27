# Module : ret
# Package: pcp.instructions
# Subroutine return instruction class definition
# for Pulse Control Processor binary instruction words.

from sequencer.pcp.instructions.insn import *

#==============================================================================
class SubroutineReturn_Instr(InstructionWord):
  "Instruction word for calling a subroutine in a pulse program."
  #----------------------------------------------------------------------------
  OPCODE = 0x6 # Default 4-bit opcode for PCP32
  #----------------------------------------------------------------------------
  def set_opcode(opcode):
    InstructionWord.check_opcode(opcode)
    SubroutineReturn_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
  set_opcode = Callable(set_opcode)
  #----------------------------------------------------------------------------
  def __str__(self):
    return "SubroutineReturn_Instr: "
#==============================================================================
