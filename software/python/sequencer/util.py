# Module : util
# Package: sequencer
# Utility definitions and constants for the pulse sequencer python interface.

import math
import sequencer

# Module constants
BITS_IN_BYTE       = 8 # Well, it's true

###############################################################################
# Utility classes

# Wrapper class for static (class) methods:
class Callable:
    def __init__(self, anycallable):
        self.__call__ = anycallable

###############################################################################
# Error classes
# Classes
#==============================================================================
class FlagError(StandardError):
  "Errors involving bitmask flags in an instruction."

  def __init__(self, message, flag_mask, flag_value):
    self.message    = message
    self.flag_mask  = flag_mask
    self.flag_value = flag_value

  def __str__(self):
    return repr(self.message) + \
           '\nFlag Mask : ' + str(self.flag_mask) + \
           '\nFlag Value: ' + hex(self.flag_value)
#==============================================================================
class OverlapError(StandardError):
  "Errors involving two bitmasks overlapping."

  def __init__(self, message, start1, end1, start2, end2):
    self.message       = message
    self.start1 = start1
    self.end1   = end1
    self.start2 = start2
    self.end2   = end2

  def __str__(self):
    return repr(self.message) + \
           '\nStart 1: ' + repr(self.start1) + \
           '\nEnd 1:   ' + repr(self.end1)   + \
           '\nStart 2: ' + repr(self.start2)  + \
           '\nEnd 2:   ' + repr(self.end2)
#==============================================================================
class MismatchError(StandardError):
  "Errors involving a mismatch between an expected and actual value."

  def __init__(self, message, expected, actual):
    self.message  = message
    self.expected = expected
    self.actual   = actual

  def __str__(self):
    return repr(self.message) + \
           '\nExpected: ' + repr(self.expected) + \
           '\nActual: '   + repr(self.actual)
#==============================================================================
class WidthError(StandardError):
  "Errors involving bitmasks outside of an allowable bit range."

  def __init__(self, message, width, value):
    self.message = message
    self.width   = width
    self.value   = value

  def __str__(self):
    return repr(self.message) + \
           '\nWidth: ' + repr(self.width) + \
           '\nValue: ' + repr(self.value)
#==============================================================================
class MaskError(StandardError):
  "Errors involving input values with bits outside an allowed mask."

  def __init__(self, message, mask, value):
    self.message = message
    self.mask    = mask
    self.value   = value

  def __str__(self):
    return repr(self.message) + '\nMask: ' + repr(hex(self.mask)) + \
           ' Value: ' + repr(hex(self.value))
#==============================================================================
class EventError(StandardError):
  "Errors involving pulse sequencer events."

  def __init__(self, message, event_class):
    self.message     = message
    self.event_class = event_class

  def __str__(self):
    return repr(self.message) + '\nEvent Class: ' + repr(self.event_class)
#==============================================================================
class DurationError(StandardError):
  "Errors involving pulse durations."

  def __init__(self, message, duration):
    self.message  = message
    self.duration = duration

  def __str__(self):
    return repr(self.message) + '\nDuration: ' + repr(self.duration)
#==============================================================================
class SelectError(StandardError):
  """
  Errors dealing with subcontainment, or selecting a smaller value whose
  difference is contained within a power-of-two subdivision of a larger value.
  """

  def __init__(self,
               message,
               old_value,
               new_value,
               diff,
               total_width,
               sub_width
               ):
    self.message     = message
    self.old_value   = old_value
    self.new_value   = new_value
    self.diff        = diff
    self.total_width = total_width
    self.sub_width   = sub_width

  def __str__(self):
    return repr(self.message) + \
           '\nOld Value: '   + hex(self.old_value)   + \
           '\nNew Value: '   + hex(self.new_value)   + \
           '\nDifference: '  + hex(self.diff)        + \
           '\nTotal Width: ' + hex(self.total_width) + \
           '\nSub Width: '   + hex(self.sub_width)
#==============================================================================
class RangeError(StandardError):
  "Errors associated with values outside of the allowed range."
  #----------------------------------------------------------------------------
  def __init__(self,
               message,
               min_value,
               max_value,
               value
               ):
    self.message   = message
    self.min_value = min_value
    self.max_value = max_value
    self.value     = value
  #----------------------------------------------------------------------------
  def __str__(self):
    return repr(self.message) + \
           '\nMin Value: '    + repr(self.min_value) + \
           '\nMax Value: '    + repr(self.max_value) + \
           '\nValue: '        + repr(self.value)
#==============================================================================
class DeviceError(StandardError):
  "Errors associated with hardware devices."
  #----------------------------------------------------------------------------
  def __init__(self,
               message):
    self.message = message
  #----------------------------------------------------------------------------
  def __str__(self):
      return repr(self.message)
#==============================================================================
class MergeError(StandardError):
  "Errors associated with merging."

  def __init__(self, message, overlap):
      self.message = message
      self.overlap = overlap

  def __str__(self):
      return self.message + "\n" \
             " Overlap: " + str(self.overlap)
#==============================================================================
class ContainmentError(StandardError):
  "Errors associated with subcontainment."

  def __init__(self, message, total_width, sub_width, value):
      self.message     = message
      self.total_width = total_width
      self.sub_width   = sub_width
      self.value       = value

  def __str__(self):
      return self.message + "\n" \
             " Total Width: " + str(self.total_width) + \
             " Sub Width: " + str(self.sub_width) + \
             " Value: " + hex(self.value)
#==============================================================================
class TotalContainmentException(Exception):
  "An exception meaning the subcontainment is total."
  #----------------------------------------------------------------------------
  def __init__(self, total_width, sub_width, value):
      self.total_width = total_width
      self.sub_width   = sub_width
      self.value       = value
  #----------------------------------------------------------------------------
  def __str__(self):
      return "Total Width: " + str(self.total_width) + \
             " Sub Width: " + str(self.sub_width) + \
             " Value: " + str(self.value)
#==============================================================================
class AbortException(Exception):
  """
  An exception meaning to abort/discard the current instruction during
  resolution.
  """
  #----------------------------------------------------------------------------
  def __init__(self, message):
      self.message = message
  #----------------------------------------------------------------------------
  def __str__(self):
      return self.message

###############################################################################
## Module global functions

def hex_char_list(hex_num, byte_width):
  """
  hex_char_list(hex_num, byte_width)
    hex_num    = number to convert into a list of bytes
    byte_width = number of bytes to divide hex_num into
  Returns a string representing the lower bytes of hex_num
  """
  i = 0
  datastring = ''
  while i < byte_width:
    datastring = chr(hex_num & 0xff) + datastring # Prepend b/c we return in MSB
    hex_num >>= 8
    i += 1
  return datastring
#------------------------------------------------------------------------------
def generate_mask(width):
  "Generates an AND bit mask of the given width starting at the LSB."
  mask = 0x00
  for i in range(width):
    mask |= (0x01 << i)
  return mask
#------------------------------------------------------------------------------
def is_subcontained(total_width, sub_width, value):
  """
  is_subcontained(total_width, sub_width, value):
    total_width = total number of bits in a word
    sub_width   = number of bits in a power-of-two subdivision of a word
    value       = value whose bit subcontainment is to be determined.
                  A value is subcontained for a given total_width and
                  sub_width if its set ('1') bits are completed contained
                  within a power-of-two subdivision.
  Returns:
    if the value is subcontained ->
      a number in [0, total_width/sub_width] indicating in which subdivision
    if the value is zero (totally contained, or nothing to subcontain) ->
      raises TotalContainmentException
    otherwise (contained in more than one subdivision)
      raises ContainmentError

  e.g. is_subcontained(8, 4, 0xF0) = 1
       is_subcontained(8, 4, 0x0F) = 0
       is_subcontained(8, 4, 0x3C) => throws ContainmentError
       is_subcontained(8, 2, 0x30) = 2
  Note that total_width and sub_width need not be powers-of-two, just the
  multiple of total_width / sub_width.
  """

  if (value == 0):
      raise TotalContainmentException(total_width, sub_width, 0)

  multiple = int(math.ceil(total_width / sub_width))
  contained = False
  subdivision = -1
  sub_mask = generate_mask(sub_width)
  if (sub_width > total_width):
      raise ContainmentError("Sub width is greater than total width.",
                             total_width, sub_width, value)
  for i in range(multiple):
    if (value & (sub_mask << (sub_width * i))):
      if (contained):
        raise ContainmentError("Value is not subcontained.",
                               total_width, sub_width, value)
        subdivision = -1
      else:
        subdivision = i
      contained = True
  if (contained):
      return subdivision
#------------------------------------------------------------------------------
def round(value):
    return int(value + 0.5)

#------------------------------------------------------------------------------
def debug_print(message, level):
  # Handle the None case for unit tests.
  if ((sequencer.params != None) and (sequencer.params.debug >= level)):
    print(message)
#------------------------------------------------------------------------------
