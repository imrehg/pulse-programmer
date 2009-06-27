# Module : output_mask
# Package: sequencer.pcp
# Pulse Control Processor output registers for remembering pulse outputs
# between instructions.

import copy
from sequencer.util import *
from sequencer.pcp  import *
from sets import Set as set

#==============================================================================
class OutputMask:
  """
  A fixed-width mask that generates clear and set values for a subset of bits.
  """
  #----------------------------------------------------------------------------
  def __init__(self,
               mask_width,
               bit_indices = (),
               value       = 0x00,
               bit_tuples  = None
               ):
    """
    OutputMask(mask_width, bit_indices, value, bit_tuples)
      mask_width  = the width of this mask in bits.
      bit_indices = tuple of bit index numbers in this mask in *LSB* order.
                    This is how values will be shifted into this mask.
                    Duplicates will be removed.
      value = number to output using bit_indices and mask_width
      bit_tuples = tuples of (Bitmask, value) to set in this this mask.
    Returns a new Output_Mask instance object.
    """

    self.is_resolved    = False
    self.bit_indices    = set() # Ordering is provided below
    # Save the value before bit shifting
    self.original_value = value
    self.value          = 0x00

    if (bit_tuples == None):
      # Only process bit_indices and value if client is not using bit_tuples
      for bit_index in bit_indices:
        if ((bit_index < 0) or (bit_index >= mask_width)):
          raise RangeError("Bit index is out of range.",
                           0, mask_width, bit_index)
        if (bit_index not in self.bit_indices):
          self.bit_indices.add(bit_index)
        self.value |= (value & 0x01) << bit_index
        value >>= 1
                        
    else:
      # Build a list to maintain ordering but check for duplicates
      check_overlap([bit_mask for (bit_mask, bit_value) in bit_tuples])
      for (bit_mask, bit_value) in bit_tuples:
        if ((bit_mask.shift < 0) or (bit_mask.end > mask_width)):
          raise WidthError("Bit mask does not fit within output mask.",
                           0, mask_width, bit_mask.shift, bit_mask.end)
        self.bit_indices = self.bit_indices.union(bit_mask.get_index_set())
        self.value |= bit_mask.get_shifted_value(bit_value)

    self.clear_mask    = 0x00 # Initially clear all bits.
    self.positive_mask = 0x00 # Initially clear all bits.
    self.mask_width    = mask_width

    for i in range(mask_width):
      if (i not in self.bit_indices):
        self.clear_mask |= 0x01 << i
      else:
        self.positive_mask |= 0x01 << i

    if (value != 0x00):
      raise MaskError("Value contains bits outside given mask.",
                      self.positive_mask, value)
  #----------------------------------------------------------------------------
  def get_clear_mask(self):
    """
    Returns a negative mask for ANDing to clear the right bits in an
    Output_Register.
    """
    return self.clear_mask
  #----------------------------------------------------------------------------
  def get_size(self):
    """
    Returns the number of bits in this mask.
    """
    return len(self.bit_indices)
  #----------------------------------------------------------------------------
  def get_mask_width(self):
    return self.mask_width
  #----------------------------------------------------------------------------
  def get_set_mask(self):
    """
    Returns the positive mask with the value bits filled in for ORing with
    an Output_Register after clearing it with the get_clear_mask() value.
    """
    return self.value
  #----------------------------------------------------------------------------
  def split(self, sub_width, index):
    """
    Returns a split of this mask by only taking the given subdivision index.
    """
    sub_mask    = generate_mask(sub_width)
    start_shift = sub_width * index
    end_shift   = (sub_width * (index+1)) - 1
#    shifted_sub_mask = sub_mask << shift
#    split_value = old_value & shifted_sub_mask
#    split_value = split_value | (self.value & ~shifted_sub_mask)
    copied_mask = copy.copy(self)
#    copied_mask.modify_subcontainment(sub_width, split_value)
    # Prune bit indices to new subdivision
    copied_list = list(self.bit_indices)
    for i in self.bit_indices:
      if ((i < start_shift) or (i > end_shift)):
        copied_list.remove(i)
    copied_mask.bit_indices = set([(x - start_shift) for x in copied_list])
    copied_mask.mask_width  = sub_width
    copied_mask.value       = (copied_mask.value >> start_shift) & sub_mask
    return copied_mask
  #----------------------------------------------------------------------------
  def merge(self, other_mask):
    """
    If the bit_indices of self and other_mask do not overlap,
    returns a new OutputMask whose bit_indices are a union of the two,
    whose clear_mask is an AND of the two, and whose set_mask is an OR of
    the two.
    """
    if (self.mask_width != other_mask.mask_width):
      raise WidthError("Cannot merge masks with different widths.",
                       self.mask_width, other_mask.mask_width)
    this_bit_indices = set(self.bit_indices)
    other_bit_indices = set(other_mask.bit_indices)
    overlap = this_bit_indices.intersection(other_bit_indices)
    if (len(overlap) != 0):
      raise MergeError("Cannot merge overlapping output masks.", overlap)
    union_bit_indices = this_bit_indices.union(other_bit_indices)
    new_mask = OutputMask(self.mask_width, union_bit_indices, 0x00)
    new_mask.value = self.get_set_mask() | other_mask.get_set_mask()
    return new_mask
  #----------------------------------------------------------------------------
  def modify_subcontainment(self, sub_width, old_value):
    """
    If this mask's set bits are subcontained, modify this mask by shifting
    down the output value to the right subdivision, shrinking its mask width,
    and returning the index of the subdivision. Otherwise, throw SelectError.
    """
    # We only care if changed (not just set '1') bits for this particular
    # value are subcontained not the whole mask in general,
    # and subcontained only in this mask's bits.

    if (self.is_resolved): 
      raise RuntimeError("Output mask is already resolved.")
    self.is_resolved = True
    diff = (old_value ^ self.value) & self.positive_mask
    try:
      select = is_subcontained(self.mask_width, sub_width, diff)
      if (select >= 0):
        self.mask_width = sub_width
        self.value >>= select * sub_width
        self.positive_mask >>= select * sub_width
        self.clear_mask >>= select * sub_width
        return select
    except ContainmentError:
      raise SelectError("Diff is not subcontained.", old_value, self.value,
                        diff, self.mask_width, sub_width)
  #----------------------------------------------------------------------------
  def get_subcontainment(self, sub_width):
    """
    Returns the select index if this mask is subcontained for the given sub
    width, but does not modify this mask, otherwise raises ContainmentError.
    """
    return is_subcontained(self.mask_width, sub_width, self.positive_mask)
  #----------------------------------------------------------------------------
  def is_output_mask(self):
    return True
  #----------------------------------------------------------------------------
  def __eq__(self, other):
    if (other == None):
      return False
    return ((self.mask_width == other.mask_width) and
            (self.bit_indices == other.bit_indices) and
            (self.value == other.value))
  #----------------------------------------------------------------------------
  def __str__(self):
    return "OutputMask:" \
           " wid=" + hex(self.mask_width) + \
           " val=" + hex(self.original_value) + \
           " bit=" + str([str(x) for x in self.bit_indices]) + \
           " set=" + hex(self.get_set_mask())
