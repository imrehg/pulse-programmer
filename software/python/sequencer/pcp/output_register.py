# Module : output_registers
# Package: sequencer.pcp
# Pulse Control Processor output registers for remembering pulse outputs
# between instructions.

from sequencer.util import *

#==============================================================================
class OutputRegister:
  #----------------------------------------------------------------------------
  def __init__(self, reg_width, init_value=0x00, start_index=0):
    """
    OutputRegister(reg_width, init_value=0x00)
      reg_width = width of the register in bits.
      init_value = intial value, defaults to 0x00
    """
    self.reg_width   = reg_width
    self.init_value  = init_value
    self.value       = init_value
#    self.start_index = start_index
#    self.end_index   = start_index + reg_width
  #----------------------------------------------------------------------------
  def generate(self, output_mask):
    """
    generate(output_mask)
      output_mask = provides a clear and set mask for modifying this register.
    Returns the register value, only updating the set mask bits and
    retaining all other previous bits.
    """
    if (self.reg_width != output_mask.get_mask_width()):
      raise WidthError("Mask width does not match register width",
                       width = self.reg_width,
                       value = output_mask.get_mask_width())
#    if (self.start_index != output_mask.get_start_index()):
#      raise MismatchError("Mask start index does not match register's.",
#                          self.start_index, output_mask.get_start_index())
#    if (self.end_index != output_mask.get_end_index()):
#      raise MismatchError("Mask end index does not match register's.",
#                          self.end_index, output_mask.get_end_index())
    self.value &= output_mask.get_clear_mask()
    self.value |= output_mask.get_set_mask()
    return self.value
  #----------------------------------------------------------------------------
  def get_value(self):
    return self.value
  #----------------------------------------------------------------------------
  def get_reg_width(self):
    return self.reg_width
  #----------------------------------------------------------------------------
  def reset(self):
    """
    Resets the register's value to the initial one provided in the constructor,
    returns nothing.
    """
    self.value = self.init_value
  #----------------------------------------------------------------------------
  def __str__(self):
    return "OutputRegister:" \
           " reg_width=" + str(self.reg_width) + \
           " value=" + hex(self.get_value())
#==============================================================================
