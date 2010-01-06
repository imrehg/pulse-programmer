# Module : nop
# Package: pcp.instructions
# Nop (null opcode) instruction class definition
# for Pulse Control Processor binary instruction words.

from sequencer.pcp.instructions.insn import *

#==============================================================================
class Nop_Instr(TargetInstruction):
  "Instruction word for doing nothing."
  #----------------------------------------------------------------------------
  OPCODE = 0x00 # Default 6-bit opcode for PCP64
  #----------------------------------------------------------------------------
  def set_opcode(opcode):
    InstructionWord.check_opcode(opcode)
    Nop_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
  set_opcode = Callable(set_opcode)
  #----------------------------------------------------------------------------
  def __init__(self, collapsable=False,address_inc=1):
    """
    Nop_Instr(collapsable):
      collapsable = Boolean indicating whether this nop should be collapsed
                    when resolving instructions. A collapsed instruction is
                    removed from the final generated word sequence and takes
                    on the address of the next word. Effectively, these nops
                    are placeholder instructions so that addresses get resolved
                    correctly even though event resolution happens earlier.
    """
    self.collapsable = collapsable
    self.address_inc=address_inc
  #----------------------------------------------------------------------------
  def get_address_inc(self):
    return self.address_inc

  #----------------------------------------------------------------------------
  def resolve_value(self):
    self.value = self.get_opcode()
  #----------------------------------------------------------------------------
  def is_collapsable(self):
    return self.collapsable
  #----------------------------------------------------------------------------
  def __str__(self):
    return "Nop_Instr: " + \
           "collapsable=" + repr(self.collapsable) +\
           " addr:" + hex(self.address_inc)
# address_inc vs. address
#==============================================================================
