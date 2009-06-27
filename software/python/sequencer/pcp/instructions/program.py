from sequencer.util import *
from sequencer.pcp.instructions import Word
from sequencer.pcp.instructions.nop import Nop_Instr

#==============================================================================
class PulseProgram:
  """
  Container class for a pulse program binary for a particular PCP machine.
  """
  #----------------------------------------------------------------------------
  def __init__(self, width, size_limit):
    """
    PulseProgram(width):
      width = width of a program word in bits for this pulse program
      size_limit = maximum number of words in this program
    """
    if (width <= 0):
      raise WidthError("Width must be positive.", 1, width)
    if (size_limit <= 0):
      raise WidthError("Size limit must be positive.", 1, size_limit)
    self.width = width
    # This must be a list to support ordering; we add set-like behaviour
    # manually.
    self.words = []
    self.word_count = 0;
    self.size_limit = size_limit
    self.datastring = ''
    self.validated = False
  #----------------------------------------------------------------------------
#  def __add_binary_charlist(self, charlist):
#    # Check that word is a list of chars of the right length.
#    if (len(charlist) != (self.width / BITS_IN_BYTE)):
#      raise RuntimeError("Program word is the wrong length.")
#    for x in charlist:
#      if ((type(x) != str) or (len(x) != 1)):
#        raise RuntimeError("An item in the charlist is not a one-character string.")
#    self.charlist.extend(charlist)
  #----------------------------------------------------------------------------
  def add_word(self, word):
    if (self.word_count >= self.size_limit):
      raise RuntimeError("Program size limit exceeded.")
    # Don't check for duplicate words at all
    # live fast and dangerous -- P.S.
    #    if (word in self.words):
    #      raise RuntimeError("Cannot add the same instruction twice.")
    if (not word.is_word()):
      raise RuntimeError("Cannot add a non-word")
    self.words.append(word)
    # Only increment the count for non-collapsable words
    if (not word.collapsable):
      self.word_count += 1
    self.validated = False
  #----------------------------------------------------------------------------
  def extend_words(self, word_list):
    for word in word_list:
      self.add_word(word)
  #----------------------------------------------------------------------------
  def __validate(self):
    "Resolves addresses and generates final binary words."
    address = 0x00 # Address counter
    collapsable_words = []
    # Addresses must be set in a separate loop for forward references.
    for x in self.words:
      x.set_address(address)
      if (not x.collapsable):
        address += x.get_address_inc()

    # Reset binary charlist before validating and regenerating
    self.datastring = ''
    for x in self.words:
      try:
        x.resolve_value()
      except TotalContainmentException, e:
        debug_print("Total Containment: "+str(e),3)
        nop_insn = Nop_Instr()
        nop_insn.set_address(x.get_address())
        nop_insn.resolve_value()
        x = nop_insn

      if (not x.collapsable):
        debug_print(str(x), 3)
        self.datastring += x.get_binary_charlist()

    # Divide by the number of bytes in each word
    datalen = len(self.datastring) / (Word.WIDTH / BITS_IN_BYTE)

    if (datalen != address):
      raise RuntimeError("Program length "+hex(datalen)+" does not match "+\
                         "last address "+hex(address)+".")

    self.validated = True
  #----------------------------------------------------------------------------
#  def binary_generator(self):
#    if (self.validated == False):
#      self.__validate()
#    for byte in self.charlist:
#      yield byte
  #----------------------------------------------------------------------------
  def get_binary_charlist(self):
    if (self.validated == False):
      self.__validate()
    return self.datastring
  #----------------------------------------------------------------------------
  def get_size(self):
    return self.word_count
#==============================================================================

