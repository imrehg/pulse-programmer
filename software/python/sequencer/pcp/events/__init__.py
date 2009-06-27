# Module : __init__
# Package: pcp.events
# Global definitions and abstract base classes
# for Pulse Control Processor high-level events.

from sequencer.pcp.instructions.nop   import * # Nop instruction

#==============================================================================
class Event:
  """
  Base class for an abstract PCP event. Events are the basic units of
  PulseSequences and can be composed into a hierarchy, with composite
  events composed of other composite events and atomic events. At each
  hierarchical level, each event completes before the next event, in a
  timeline. Within each event, the composing sub-events may or may not
  coincide.
  """

  def __init__(self):
    # First word should be collapsable
    self.first_word = Nop_Instr(True)
    self.added = False

  def get_first_word(self):
    return self.first_word

  def get_size(self):
    # All events are atomic by default; override if composite.
    return 1

  def is_event(self):
    return True

  def set_added(self):
    if (self.added):
      raise EventError("This event cannot be added twice.", self.__class__)
    self.added = True

#==============================================================================
class Target_Event(Event):
  """
  Base class for an abstract event that takes a target.
  """

  def __init__(self, target, branch_delay_slot = None):
    """
    Target_Event(target):
      target = the event to jump to.
    """
    Event.__init__(self)
    first_word = target.get_first_word()
    if ((not first_word.is_instruction()) or
        (not first_word.is_collapsable())):
      raise RuntimeError("Target should be a collapsable nop instruction.")
    self.target = target
    #    self.branch_delay_slot = branch_delay_slot
  
  def get_target(self):
    return self.target

#  def get_branch_delay_slot(self):
#    if (self.branch_delay_slot == None):
      # If no branch_delay_slot provided, do naive instruction scheduling
      # and insert a non-collapsable nop.
#      return Nop_Instr(False)
#    else:
#      return self.branch_delay_slot

#==============================================================================
class Sequence_Event(Event):
  """
  Base class for an abstract event which contains a sequence of other events,
  like a loop.
  """

  def __init__(self, sequence):
    """
    Sequence_Event(sequence):
      sequence = list of non-duplicate events which make up the loop body.
    """
    if (len(sequence) <= 0):
      raise RuntimeError("Sequence must be non-empty.")

    self.event_count = 0
    for x in sequence:
      if (not x.is_event()):
        raise RuntimeError("An item in the sequence is not an event.")
      self.event_count += x.get_size()
    Event.__init__(self)
    self.event_list = list(sequence)

  def event_generator(self):
    for event in self.event_list:
      yield event

  def get_size(self):
    # Overridden from Event, b/c we are composite
    return self.event_count

  def set_added(self):
    for x in self.event_list:
      x.set_added()
    
#==============================================================================
class AbstractRegister:
  """
  Base class for an abstract register for transferring values from data words
  to instructions which take a register argument.
  """

  def __init__(self, label):
    """
    AbstractRegister(label):
      label = descriptive text for debugging purposes.
    """
    self.label = label

  def __str__(self):
    return self.label

  def is_abstract_register(self):
    return True

#==============================================================================
class FeedbackSource:
  """
  Base class for a feedback source used for conditional branching.
  """

  def __init__(self, label, bit_index):
    """
    FeedbackSource(label):
      label = descriptive text for debugging purposes.
    """
    self.label = label
    self.bit_index = bit_index

  def __str__(self):
    return self.label

  def get_bit_index(self):
    return self.bit_index

  def is_feedback_source(self):
    return True

#==============================================================================
class Frequency:
  "Class for an abstract, immutable frequency object."

  def __init__(self, frequency, relative_phase):
    """
    Frequency(frequency, relative_phase)
      frequency      = in hertz
      relative_phase = currently unused. in the future it may allow
                       two different instances of the same frequency with a
                       specified relative phase between them.
                       in radians.
    """
    if (frequency < 0):
      raise RuntimeError("Frequency cannot be negative ("+str(frequency)+")")
    if (relative_phase < 0):
      raise RuntimeError("Relative phase cannot be negative ("+\
                         str(relative_phase)+")")
    self.frequency      = frequency
    self.relative_phase = relative_phase

  def is_abstract_frequency(self):
    return True

  def get_frequency(self):
    return self.frequency

  def get_relative_phase(self):
    return self.relative_phase

  def __str__(self):
    return "Frequency="+str(self.frequency)+" Hz phase="+ \
           str(self.relative_phase)


