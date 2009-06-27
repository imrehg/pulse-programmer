# Module : __init__
# Package: pcp.instructions
# Global definitions and abstract base classes
# for Pulse Control Processor binary instruction words.

import math
from sequencer.util import *

# Module global functions
#==============================================================================
class Word:
  """
  Base class for configurable program location. By default it has a
  64-bit width and an 11-bit address.
  """
  #----------------------------------------------------------------------------
  WIDTH         = 64
  WORD_MASK     = generate_mask(WIDTH)
  # The address only appears in control flow instructions, but the constants
  # are declared here because all words need to return correctly masked
  # instructions.
  # All addresses are flush to the least-significant bit (shift of zero).
  ADDRESS_WIDTH = 11
  ADDRESS_MASK  = generate_mask(ADDRESS_WIDTH)
  #----------------------------------------------------------------------------
  def set_masks(word_width, address_width):
    if (word_width < 0):
      raise WidthError("Word width cannot be negative.", 0, Word.WIDTH)
    Word.WIDTH = word_width
    Word.WORD_MASK = generate_mask(word_width)
    if (address_width > Word.WIDTH):
      raise WidthError("Address cannot be wider than a word.",
                       Word.WIDTH, address_width)
    Word.ADDRESS_WIDTH = address_width
    Word.ADDRESS_MASK = generate_mask(address_width)
  set_masks = Callable(set_masks)

  def set_address(self, address):
    if ((~Word.ADDRESS_MASK) & address):
      raise MaskError('Trying to set address bigger than allowed width.',
                      Word.ADDRESS_MASK, address)
    self.address = address & Word.ADDRESS_MASK

  def get_address(self):
    "Returns the address of this word ANDed with the internal mask."
    return self.address

  def get_binary_charlist(self):
    self.resolve_value() # Subclass-dependent resolution of binary word value
    return hex_char_list(self.value, Word.WIDTH / BITS_IN_BYTE)

  def get_address_inc(self):
    return 1

  def __init__(self):
    self.collapsable = False

#  def is_collapsable(self):
#    return False

  def is_word(self):
    return True

#==============================================================================
class DataWord(Word):
  "A (non-instruction) 64-bit data word."

  def __init__(self, value):
    Word.__init__(self)
    self.value = value

  def resolve_value(self):
    pass # No resolution necessary

  def is_instruction(self):
    return False

