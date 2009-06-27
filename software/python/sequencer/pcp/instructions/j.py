# Module : j
# Package: pcp.instructions
# Jump instruction class definition
# for Pulse Control Processor binary instruction words.

from sequencer.pcp.instructions.insn import *

#==============================================================================
class Jump_Instr(TargetInstruction):
  "Instruction word for unconditional jumping in a pulse program."
  #----------------------------------------------------------------------------
  OPCODE = 0x17 # Default 6-bit opcode for PCP64
  #----------------------------------------------------------------------------
  def set_opcode(opcode):
    InstructionWord.check_opcode(opcode)
    Jump_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
  set_opcode = Callable(set_opcode)
  #----------------------------------------------------------------------------
  def __init__(self, target):
    TargetInstruction.__init__(self, target, True)
  #----------------------------------------------------------------------------
  def __str__(self):
    return "Jump_Instr: "+ \
           "target=" + hex(self.target.get_address())+ \
           " value" + hex(self.value) +\
           " opcode:" + hex(self.get_opcode())
  
#==============================================================================
