# Module : bitmask
# Package: sequencer.pcp
# Pulse Control Processor output registers for remembering pulse outputs
# between instructions.

from sequencer.util import *
#==============================================================================
class Bitmask:
  """
  A tuple of a bitmask width, shift, value, and text label.
  This is similar to an OutputMask but has a shift and does not contain a
  built-in value; it does not support
  merging operations, modifying subcontainment, etc., since it is only meant
  to support operands in an instruction word.
  """

  def __init__(self, label, width, shift):
    self.label        = label
    self.width        = width
    self.shift        = shift
    self.end          = shift+width
    self.mask         = generate_mask(self.width)
    self.hash_value   = self.label.__hash__() * self.width * self.shift
    if (shift < 0):
      raise RangeError(label + " shift cannot be negative.",
                       0, 0, shift)
    self.shifted_mask = self.mask << shift

  def get_label(self):
    return self.label

  def get_width(self):
    return self.width

  def get_shift(self):
    return self.shift

  def get_end(self):
    return self.end

  def get_mask(self):
    return self.mask

  def check_value(self, value):
    if (self.width == 0):
      # Bitmasks are allowed to be zero width to ignore any values and
      # allow chain daughterboard signals to be optional (power, sp_mode, etc.)
      return
    if (value == None):
      raise RuntimeError(self.label+ " value is None.")
    if ((~self.mask) & value):
      raise MaskError(self.label+" bits outside mask.", self.mask, value)

  def get_shifted_value(self, value):
    self.check_value(value)
    return (value & self.mask) << self.shift

  def get_index_set(self):
    return tuple([self.shift+i for i in range(self.width)])

  def is_overlapping(self, other):
    return ((self.shifted_mask & other.shifted_mask) != 0)

  def is_superset(self, other):
    return ((~self.shifted_mask & other.shifted_mask) == 0x00)

  def __eq__(self, other):
    if (other == None):
      return False
    return ((self.label == other.label) and (self.width == other.width) and
            (self.shift == other.shift))

  def __hash__(self):
    return self.hash_value
  
  def __str__(self):
    return "bm " + \
           " lab=" + str(self.label) + \
           " wid=" + str(self.width) + \
           " shf=" + str(self.shift)
