# __init__ module for pcp package
# Global package definitions for Pulse Control Processor family for
# executing pulse programs.

from sequencer.util        import *
from sequencer.pcp.bitmask import *

#------------------------------------------------------------------------------
def check_masks(mask_list, width):
  # Remove Nones
  while (None in mask_list):
    mask_list.remove(None)
  for bitmask in mask_list:
    if (bitmask.__class__ != Bitmask):
      raise RuntimeError("An item in the mask list is not a Bitmask.")
    if ((bitmask.width < 0) or (bitmask.width > width)):
      raise RangeError(bitmask.label+" does not fit within word.",
                       0, width, bitmask.width)
    if ((bitmask.shift < 0) or
        (bitmask.shift > width - bitmask.width)):
      raise RangeError(bitmask.label+" shift is out of range for width.",
                       0, width - bitmask.width,
                       bitmask.shift)
#----------------------------------------------------------------------------
def check_overlap(mask_list):
  """
  check_overlap(mask_list):
    mask_list = list of Bitmask objects to check for overlapping with each
                other.
  This function does not check if the given bitmasks are within a valid
  global range, b/c Bitmasks don't know anything about global ranges.
  A specific class method should be defined for specific global ranges,
  e.g. InstructionWord.check_masks
  """
  # Create a copy for running removals
  copied_list = list(mask_list)
  for bitmask in mask_list:
    copied_list.remove(bitmask)
    for other_mask in copied_list:
      if (bitmask.is_overlapping(other_mask)):
        raise OverlapError("Mask overlap btw "+bitmask.label + \
                           " and "+other_mask.label+".",
                           bitmask.shift, bitmask.end,
                           other_mask.shift, other_mask.end)
#----------------------------------------------------------------------------
def check_inputs(input_list):
  for (input, mask) in input_list:
    mask.check_value(input)
#----------------------------------------------------------------------------
def get_bit_tuple_value(bit_tuples):
  returned_value = 0x00
  for (bitmask, value) in bit_tuples:
    returned_value |= bitmask.get_shifted_value(value)
  return returned_value
#def get_bit_tuples_shifted_value(bit_tuples):
#  returned_value = 0x00
#  for (value, bitmask) in bit_tuples:
#    returned_value |= bitmask.get_shifted_value(value);
#  return returned_value
#  get_bit_tuples_shifted_value = Callable(get_bit_tuples_shifted_value)





