# Module : sub
# Package: pcp.instructions
# Subroutine call instruction class definition
# for Pulse Control Processor binary instruction words.

from sequencer.pcp.instructions.insn import *

#==============================================================================
class SubroutineCall_Instr(TargetInstruction):
  "Instruction word for calling a subroutine in a pulse program."
  #----------------------------------------------------------------------------
  OPCODE = 0x5 # Default 4-bit opcode for PCP32
  #----------------------------------------------------------------------------
  def set_opcode(opcode):
    InstructionWord.check_opcode(opcode)
    SubroutineCall_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
  set_opcode = Callable(set_opcode)
  #----------------------------------------------------------------------------
  def __init__(self, target):
    TargetInstruction.__init__(self, target, True)
  #----------------------------------------------------------------------------
  def __str__(self):
    return "SubroutineCall_Instr: " \
           "target=" + hex(self.target.get_address())
#==============================================================================
