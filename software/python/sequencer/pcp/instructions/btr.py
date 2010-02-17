# btr.py module for pcp.instructions package
# Branch on trigger instruction class definition
# for Pulse Control Processor binary instruction words.

from sequencer.pcp                   import *
from sequencer.pcp.bitmask           import *
from sequencer.pcp.instructions.insn import *

#==============================================================================
class BranchTrigger_Instr(InstructionWord):
  "Instruction word for conditional branching in a pulse program."
  #----------------------------------------------------------------------------
  OPCODE       =    0x14 # Default 6-bit opcode for PCP64
  TRIGGER_MASK =    Bitmask(label = "Trigger", width = 9, shift = 32)
  LEVEL_MASK =      Bitmask(label = "Level", width = 1, shift = 18)
  ADDRESS_MASK =    Bitmask(label = "Address", width = 18, shift = 0)
#  TRIGGER_MASK =   Bitmask(label = "Trigger", width = 9, shift = 19)
  MASK_LIST    = []
  #----------------------------------------------------------------------------
  def set_opcode(opcode):
    InstructionWord.check_opcode(opcode)
    BranchTrigger_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
  set_opcode = Callable(set_opcode)
  #----------------------------------------------------------------------------
  def set_masks(trigger_width, trigger_shift, level_width, level_shift):

    trigger_mask = Bitmask(label = "Trigger",
                           width = trigger_width,
                           shift = trigger_shift)
    level_mask = Bitmask(label = "Level",
                         width = level_width,
                         shift = level_shift)
    # manually add our address_mask instead of inheriting from TargetInstruction
    target_mask = Bitmask(label = "Target",
                           width = 18,
                           shift = 0)

    # Check mask widths and shifts
    #BranchTrigger_Instr.MASK_LIST = list(TargetInstruction.MASK_LIST);
    BranchTrigger_Instr.MASK_LIST.extend([trigger_mask, level_mask, target_mask])

    InstructionWord.check_masks(BranchTrigger_Instr.MASK_LIST)

    BranchTrigger_Instr.TRIGGER_MASK    = trigger_mask
    BranchTrigger_Instr.LEVEL_MASK      = level_mask
    BranchTrigger_Instr.TARGET_MASK     = target_mask
  set_masks = Callable(set_masks)
  #----------------------------------------------------------------------------
  def __init__(self, target, trigger, level=1):
    """
    BranchTrigger_Instr(target, trigger, level)
      target         = destination instruction of branch.
      trigger        = trigger mask corresponding to the conditional branch trigger.
      level          = trigger on high or low level (1 or 0)
    """
    InstructionWord.__init__(self)

    self.trigger = trigger
    self.level = level
    self.target = target

    check_inputs([(trigger, BranchTrigger_Instr.TRIGGER_MASK),
                  (level,   BranchTrigger_Instr.LEVEL_MASK)])

    #----------------------------------------------------------------------------
  def get_trigger(self):
    return self.TRIGGER_MASK.get_shifted_value(self.trigger)
  #----------------------------------------------------------------------------
  def get_level(self):
    return self.LEVEL_MASK.get_shifted_value(self.level)
  #----------------------------------------------------------------------------
  def resolve_value(self):
    self.value = self.get_opcode() | self.target.get_address() | \
                 self.get_trigger() | self.get_level()
  #----------------------------------------------------------------------------
  def __str__(self):
    return "[btr]:" \
           " tgt=" + hex(self.target.get_address()) + \
	         " lvl=" + hex(self.level) + \
           " msk=" + hex(self.get_trigger()) + \
           " val=" + hex(self.value)
  
#==============================================================================
