# halt.py module for pcp.instructions package
# Halt instruction class definition
# for Pulse Control Processor binary instruction words.

from sequencer.pcp.instructions.insn import *

#==============================================================================
class Halt_Instr(TargetInstruction):
  "Instruction word for halting a pulse program safely at the end."
  #----------------------------------------------------------------------------
  OPCODE = 0x19 # Default 6-bit opcode for PCP64
  #----------------------------------------------------------------------------
  def set_opcode(opcode):
    InstructionWord.check_opcode(opcode)
    Halt_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
  set_opcode = Callable(set_opcode)
  #----------------------------------------------------------------------------
  def __init__(self):
    TargetInstruction.__init__(self, self, True) # Self-target
  #----------------------------------------------------------------------------
  def __str__(self):
    return "Halt_Instr:"
#==============================================================================
