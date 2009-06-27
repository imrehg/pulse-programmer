# Module : ramp
# Package: pcp.instructions
# Pulse ramp instruction class definition
# adds an arbitary binary charlist

import sequencer.constants
from sequencer.pcp                   import *
from sequencer.pcp.bitmask           import *
from sequencer.pcp.instructions.insn import *
from sequencer.pcp.output_mask       import *
from sequencer.pcp.output_register   import *
import math

#==============================================================================
class Pulse_Ramp_Instr(InstructionWord):
  "Instruction word for an immediate pulse."

  #----------------------------------------------------------------------------
  # Class constants
  DURATION_MASK  = Bitmask(label = "Duration",
                           width = 23,
                           shift = 33)

  #----------------------------------------------------------------------------
  def set_opcode(opcode):
    InstructionWord.check_opcode(opcode)
    PulseImmed_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
  set_opcode = Callable(set_opcode)
  #----------------------------------------------------------------------------
  def set_masks(output_width, output_shift, duration_width, duration_shift,
                select_shift, flag_masks = []):

    # Check select width and shift
    multiple = int(sequencer.constants.HARDWARE_OUTPUT_WIDTH /
                   math.fabs(output_width))
    select_width = int(math.ceil(math.log(multiple, 2)))

    output_mask   = Bitmask(label = "Output"      ,
                            width = output_width  ,
                            shift = output_shift  )
    duration_mask = Bitmask(label = "Duration"    ,
                            width = duration_width,
                            shift = duration_shift)
    select_mask   = Bitmask(label = "Select"      ,
                            width = select_width  ,
                            shift = select_shift  )
    
    PulseImmed_Instr.MASK_LIST = list(InstructionWord.MASK_LIST)
    PulseImmed_Instr.MASK_LIST.extend(
      [output_mask, duration_mask, select_mask])
    PulseImmed_Instr.MASK_LIST.extend(flag_masks)

    # Check mask widths and shifts
    InstructionWord.check_masks(PulseImmed_Instr.MASK_LIST)
    
    PulseImmed_Instr.OUTPUT_MASK    = output_mask
    PulseImmed_Instr.DURATION_MASK  = duration_mask
    PulseImmed_Instr.SELECT_MASK    = select_mask
    PulseImmed_Instr.FLAG_MASKS     = flag_masks
  set_masks = Callable(set_masks)
  #----------------------------------------------------------------------------
  def __init__(self,charlist):
    """
    Pulse_Ramp instruction will just write the precompiled bytecode to the charlist"""
    self.charlist=charlist

  #----------------------------------------------------------------------------
  def get_output(self):
    # We don't need to get_shifted_value here b/c resolve_value does this
    return self.output_value
  #----------------------------------------------------------------------------
  def get_duration(self):
    return self.DURATION_MASK.get_shifted_value(self.duration)
  #----------------------------------------------------------------------------
  def get_select(self):
    return self.SELECT_MASK.get_shifted_value(self.select)
  #---------------------------------------------------------------------------
  def get_flags(self):
    return get_bit_tuple_value(self.flags)
  #----------------------------------------------------------------------------
  def resolve_value(self):
    self.value=10
  #----------------------------------------------------------------------------
  def __str__(self):
    return "pulse ramp:"

  #---------------------------------------------------------------------------
  # return the number of words
  def get_length(self):
    l1=len(self.charlist)
    return int(l1 - 36)/4

  # just return an arbitrary charlist right now --PS
  def get_binary_charlist(self):
    charlist=self.charlist
    l1=len(charlist)
    #charlist=sequencer.charlist2[4:l1-32]

    return charlist[4:l1-32]
  # I think we have to leave out the last 32 chars but don't know why
  # It works this way

#==============================================================================
