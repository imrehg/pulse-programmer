# Module : __init__
# Package: pcp.instructions
# Global definitions and abstract base classes
# for Pulse Control Processor binary instruction words.

import math
from sequencer.util             import *
from sequencer.pcp              import *
from sequencer.pcp.bitmask      import *
from sequencer.pcp.instructions import *

#==============================================================================
class InstructionWord(Word):
  "Base class for a 64-bit instruction word."
  #----------------------------------------------------------------------------
  OPCODE_WIDTH = 6
  OPCODE_MASK  = generate_mask(OPCODE_WIDTH)
  OPCODE_SHIFT = Word.WIDTH - OPCODE_WIDTH # Opcodes are always at the front.
  MASK_LIST    = []
  #----------------------------------------------------------------------------
  def set_opcode_mask(opcode_width):
    if ((opcode_width < 0) or (opcode_width > Word.WIDTH)):
      raise RangeError("Opcode width out of range.", 0, Word.WIDTH,
                       opcode_width)
    InstructionWord.OPCODE_WIDTH = opcode_width
    InstructionWord.OPCODE_MASK  = generate_mask(opcode_width)
    InstructionWord.OPCODE_SHIFT = Word.WIDTH - opcode_width
    InstructionWord.MASK_LIST = [
      Bitmask(label = "Opcode",
              width = opcode_width,
              shift = InstructionWord.OPCODE_SHIFT)
      ]
  set_opcode_mask = Callable(set_opcode_mask)
  #----------------------------------------------------------------------------
  def check_opcode(opcode):
    if ((~InstructionWord.OPCODE_MASK) & opcode):
      raise MaskError("Opcode has bits outside the allowable mask.",
                      InstructionWord.OPCODE_MASK, opcode)
  check_opcode = Callable(check_opcode)
  #----------------------------------------------------------------------------
  def check_masks(mask_list):
    check_masks(mask_list, Word.WIDTH)
    check_overlap(mask_list)
  check_masks = Callable(check_masks)
  #----------------------------------------------------------------------------
  def get_opcode(self):
    # Shift opcode to beginning
    return (self.OPCODE << self.OPCODE_SHIFT)
  #----------------------------------------------------------------------------
  def resolve_value(self):
    self.value = self.get_opcode()
  #----------------------------------------------------------------------------
  def is_instruction(self):
    return True

  def __init__(self):
    Word.__init__(self)

#==============================================================================
class TargetInstruction(InstructionWord):
  """
  Base class for instruction types that take a target address.

  Target_Instruction(target)
    target = instruction target instruction.
    is_instruction = should the target be an instruction or not?
  """

  MASK_LIST = []
  ADDRESS_MASK = None
  #----------------------------------------------------------------------------
  def set_address_mask():
    TargetInstruction.MASK_LIST = list(InstructionWord.MASK_LIST)
    address_mask = Bitmask(label = "Address",
                           width = InstructionWord.ADDRESS_WIDTH,
                           shift = 0)
    TargetInstruction.MASK_LIST.append(address_mask)
  set_address_mask = Callable(set_address_mask)
  #----------------------------------------------------------------------------
  def __init__(self, target, is_instruction):
    InstructionWord.__init__(self)
    if (target.is_instruction() != is_instruction):
      raise(RuntimeError, "Target for jump must be an instruction.")
    self.target = target
  #----------------------------------------------------------------------------
  def resolve_value(self):
    self.value = self.get_opcode() | self.target.get_address()
  #----------------------------------------------------------------------------
  def get_target_address(self):
    return (self.target.get_address() & self.ADDRESS_MASK)
#==============================================================================
