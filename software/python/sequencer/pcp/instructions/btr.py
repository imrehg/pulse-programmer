# btr.py module for pcp.instructions package
# Branch on trigger instruction class definition
# for Pulse Control Processor binary instruction words.

from sequencer.pcp                   import *
from sequencer.pcp.bitmask           import *
from sequencer.pcp.instructions.insn import *

#==============================================================================
class BranchTrigger_Instr(TargetInstruction):
  "Instruction word for conditional branching in a pulse program."
  #----------------------------------------------------------------------------
  OPCODE       = 0x14 # Default 6-bit opcode for PCP64
  TRIGGER_MASK = Bitmask(label = "Trigger", width = 9, shift = 32)
#  TRIGGER_MASK = Bitmask(label = "Trigger", width = 9, shift = 19)
  MASK_LIST    = []
  #----------------------------------------------------------------------------
  def set_opcode(opcode):
    InstructionWord.check_opcode(opcode)
    BranchTrigger_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
  set_opcode = Callable(set_opcode)
  #----------------------------------------------------------------------------
  def set_trigger_mask(trigger_width, trigger_shift):

    trigger_mask = Bitmask(label = "Trigger",
                           width = trigger_width,
                           shift = trigger_shift)

    # Check mask widths and shifts
    BranchTrigger_Instr.MASK_LIST = list(TargetInstruction.MASK_LIST);
    BranchTrigger_Instr.MASK_LIST.extend([trigger_mask])
    InstructionWord.check_masks(BranchTrigger_Instr.MASK_LIST)
    
    BranchTrigger_Instr.TRIGGER_MASK  = trigger_mask
  set_trigger_mask = Callable(set_trigger_mask)
  #----------------------------------------------------------------------------
  def __init__(self, target, trigger):
    """
    BranchTrigger_Instr(target, trigger)
      target         = destination instruction of branch.
      trigger = trigger mask corresponding to the conditional branch trigger.
    """
    TargetInstruction.__init__(self, target, True)
    check_inputs([(trigger, BranchTrigger_Instr.TRIGGER_MASK)])
    self.trigger = trigger
  #----------------------------------------------------------------------------
  def get_trigger(self):
    return self.TRIGGER_MASK.get_shifted_value(self.trigger)
  #----------------------------------------------------------------------------
  def resolve_value(self):
    self.value = self.get_opcode() | self.target.get_address() | \
                 self.get_trigger()
  #----------------------------------------------------------------------------
  def __str__(self):
    return "[btr]:" \
           " tgt=" + hex(self.target.get_address()) + \
           " trg=" + hex(self.get_trigger()) + \
           " val=" + hex(self.value)
  
#==============================================================================
