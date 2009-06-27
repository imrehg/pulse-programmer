# Module : p
# Package: pcp.instructions
# Pulse immediate instruction class definition
# for Pulse Control Processor binary instruction words.

import sequencer.constants
from sequencer.pcp                   import *
from sequencer.pcp.bitmask           import *
from sequencer.pcp.instructions.insn import *
from sequencer.pcp.output_mask       import *
from sequencer.pcp.output_register   import *
import math

#==============================================================================
class PulseImmed_Instr(InstructionWord):
  "Instruction word for an immediate pulse."

  #----------------------------------------------------------------------------
  # Class constants
  OPCODE         = 0x1C # Default 6-bit opcode for PCP64

  OUTPUT_MASK    = Bitmask(label = "Output",
                           width = 32,
                           shift = 0)
  DURATION_MASK  = Bitmask(label = "Duration",
                           width = 23,
                           shift = 33)
  SELECT_MASK    = Bitmask(label = "Select",
                           width = 1,
                           shift = 32)
  FLAG_MASKS     = []
  MASK_LIST      = []

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
  def __init__(self, output_mask, output_reg, duration, flags = []):
    """
    PulseImmed_Instr(output, duration, select)
      output_mask = an output value that needs to be tested for subcontainment,
                    shifted, and merged with output_reg
      output_reg  = register for remembering output (may be None if
                    output is an integer)
      duration   = duration value to be masked and shifted.
      flags      = list of tuples (Bitmask, value)
    """
    InstructionWord.__init__(self)
    # Check for bit tuple masks are inside word.
    #input_mask_list = [mask for (input, mask) in bit_tuples]
    #self.check_masks(input_mask_list)
    # Check all inputs
    input_tuples = [(duration, self.DURATION_MASK)]
    #input_tuples.extend(bit_tuples)
    check_inputs(input_tuples)

    if (output_reg == None):
      raise RuntimeError("Output register cannot be None.")
    if (output_mask == None):
      raise RuntimeError("Output mask cannot be None.")

    for reg in output_reg:
      if (reg.get_reg_width() != self.OUTPUT_MASK.width):
        raise WidthError("Some output reg has different width than instr.",
                         self.OUTPUT_MASK.width, reg.get_reg_width())
    for (flag_mask, flag_value) in flags:
      if (flag_mask not in self.FLAG_MASKS):
        raise FlagError("A given flag is not valid for this instruction.",
                        flag_mask, flag_value)

    self.output_mask = output_mask
    self.output_reg  = output_reg
    self.duration    = duration
    self.flags       = flags
    self.is_resolved = False
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
    if (not self.is_resolved):
      # Only resolve once, since we don't want to stomp on the register
      # that is shared with all other pulse immediate instructions.
      self.is_resolved = True
      old_value = 0x00
      for i in range(len(self.output_reg)):
        old_value |= (self.output_reg[i].get_value()) \
                     << (self.OUTPUT_MASK.width * i)
#      try:
      self.select = self.output_mask.modify_subcontainment(
        self.OUTPUT_MASK.width, old_value)
      check_inputs([(self.select, self.SELECT_MASK)])
      if (self.output_mask.get_mask_width() != self.OUTPUT_MASK.width):
        raise WidthError("Output mask has different width than instr.",
                         self.OUTPUT_MASK.width,
                         self.output_mask.get_mask_width())
      selected_reg = self.output_reg[self.select]
      self.output_value = selected_reg.generate(self.output_mask)
#      except TotalContainmentException:
#        self.select = 0
#        self.output_value = 0x00
        # If diff is totally contained (zero), then throw an AbortException
        # so that the pulse program knows to discard us.
#        raise AbortException("p: totally contained \n" +
#                             "omask = " + str(self.output_mask) + \
#                             ("old_val   = %x\n" % old_value))

    self.value = self.get_opcode() | self.get_duration() | \
                 self.get_output() | self.get_select()   | \
                 self.get_flags()
  #----------------------------------------------------------------------------
  def __str__(self):
    return "p_insn:"                       + \
           " addr:"  + hex(self.address)    + \
           " output: " + hex(self.get_output())  +\
           " select: " + hex(self.get_select())
#           " value:" + hex(self.value)      +\
  #           " dur=" + hex(self.duration)    + \
#           " sel=" + hex(self.select)
#           " o_m=" + hex(self.output_mask) + \


#==============================================================================
