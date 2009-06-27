# Module : wait
# Package: pcp.instructions
# Wait instruction class definition
# for Pulse Control Processor binary instruction words.

from sequencer.pcp                   import *
from sequencer.pcp.bitmask           import *
from sequencer.pcp.instructions.insn import *

#==============================================================================
class Wait_Instr(InstructionWord):
  "Instruction word for a wait."

  #----------------------------------------------------------------------------
  # Class constants
  OPCODE         = 0x9 # Default 4-bit opcode for PCP32

  DURATION_MASK = Bitmask(label="Duration", width = 28, shift = 0)

  MASK_LIST      = []

  #----------------------------------------------------------------------------
  def set_opcode(opcode):
    InstructionWord.check_opcode(opcode)
    Wait_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
  set_opcode = Callable(set_opcode)
  #----------------------------------------------------------------------------
  def set_masks(duration_width, duration_shift):

    # Create bitmasks for testing
    duration_mask = Bitmask(label = "Duration",
                            width = duration_width,
                            shift = duration_shift)

    Wait_Instr.MASK_LIST = list(InstructionWord.MASK_LIST)
    Wait_Instr.MASK_LIST.extend([duration_mask])

    # Check widths and shifts for all fields
    InstructionWord.check_masks(Wait_Instr.MASK_LIST)

    Wait_Instr.DURATION_MASK  = duration_mask
  set_masks = Callable(set_masks)
  #----------------------------------------------------------------------------
  def __init__(self, duration):
    """
    Wait_Instr(duration)
      duration = duration value to be masked and shifted.
    """
    InstructionWord.__init__(self)

    check_inputs([(duration, self.DURATION_MASK)])

    self.duration = duration
  #----------------------------------------------------------------------------
  def get_duration(self):
    return self.DURATION_MASK.get_shifted_value(self.duration-5)
  #----------------------------------------------------------------------------
  def resolve_value(self):
    self.value = self.get_opcode() | self.get_duration()
  #----------------------------------------------------------------------------
  def __str__(self):
    return "Wait_Instr: " \
           "dur=" + hex(self.duration)

