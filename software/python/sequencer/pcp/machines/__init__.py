# Module : __init__
# Package: pcp.machines
# Global definitions and abstract base classes
# for Pulse Control Processor machines (specific processor implementations).

#from util import *
from sequencer.pcp.instructions         import *
from sequencer.pcp.instructions.program import *

###############################################################################
# Import universally supported instruction types
from sequencer.pcp.instructions.halt  import * # Halt instruction
from sequencer.pcp.instructions.j     import * # Jump instruction
from sequencer.pcp.instructions.btr   import * # Branch-on-trigger instruction

# Import universally supported event types
from sequencer.pcp.events.halt                 import *
from sequencer.pcp.events.jump                 import *
from sequencer.pcp.events.feedback_branch      import *
from sequencer.pcp.events.feedback_branch_wait import *
from sequencer.pcp.events.feedback_while_loop  import *
from sequencer.pcp.events.infinite_loop        import *
from sequencer.pcp.events.label                import *

# Classes

#==============================================================================
class Family:
  """
  Base class for an abstract PCP architecture (family), consisting of a
  program word width and an instruction set (including opcode width).
  """
  #----------------------------------------------------------------------------
  # Universally supported event handler functions
  def handle_label(self, event):
    return [event.get_first_word()]
  handle_label = Callable(handle_label)
  #----------------------------------------------------------------------------
  def handle_halt(self, event):
    h = Halt_Instr()
    word_list = [event.get_first_word(), h]
    # Naively fill branch delay slots with non-collapsable nops
    for i in range(self.branch_delay_slots):
      word_list.append(Nop_Instr())
    return word_list
  handle_halt = Callable(handle_halt)
  #----------------------------------------------------------------------------
  def handle_jump(self, event):
    j = Jump_Instr(event.get_target().get_first_word())
    word_list = [event.get_first_word(), j]
    # One branch delay slot, naively fill with non-collapsable nop
    for i in range(self.branch_delay_slots):
      word_list.append(Nop_Instr())
    return word_list
  handle_jump = Callable(handle_jump)
  #----------------------------------------------------------------------------
  def handle_feedback_branch(self, event):
    trigger_mask = 0x00
    for x in event.feedback_source_generator():
      trigger_mask |= (0x01 << x.get_bit_index())
    b = BranchTrigger_Instr(target=event.get_target().get_first_word(),
                            trigger=trigger_mask)
    # One branch delay slot, naively fill with non-collapsable nop
    word_list = [event.get_first_word(), b]
    for i in range(self.branch_delay_slots):
      word_list.append(Nop_Instr())
    return word_list
  handle_feedback_branch = Callable(handle_feedback_branch)
  #----------------------------------------------------------------------------
  def handle_feedback_branch_wait(self, event):
    trigger_mask = 0x00
    word_list = [event.get_first_word()]
    # Execute Halt first
    word_list.append(Halt_Instr())
    # Fill all but last branch delay slot with nops
    for i in range(self.branch_delay_slots-1):
      word_list.append(Nop_Instr())
    
    for x in event.feedback_source_generator():
      trigger_mask |= (0x01 << x.get_bit_index())
    # Add BranchTrigger to last branch delay slot
    b = BranchTrigger_Instr(target=event.get_target().get_first_word(),
                            trigger=trigger_mask)
    word_list.append(b)
    return word_list
  handle_feedback_branch_wait = Callable(handle_feedback_branch_wait)
  #----------------------------------------------------------------------------
  def handle_loop(self, loop_event):
    word_list = [loop_event.get_first_word()]
    for event in loop_event.event_generator():
      word_list.extend(self.translate_event(event))
    return word_list
  handle_loop = Callable(handle_loop)
  #----------------------------------------------------------------------------
  def __init__(self                  ,
               name                  ,
               word_width            ,
               address_width         ,
               program_size          ,
               reg_width             ,
               reg_count             ,
               min_duration          ,
               chain_position     = 0,
               branch_delay_slots = 1,
               event_dict         = {}):
    """
    Family(name, word_width, address_width, program_size, reg_width,
           reg_count, event_dict):
      width = width of a program word in bits for this family
      event_dict = dictionary of events and handler functions for this family
    """
    if (word_width < 0):
      raise WidthError("Word width cannot be negative.", 0, word_width)
    if (address_width < 0):
      raise WidthError("Address width cannot be negative.", 0, word_width)
    if (program_size < 0):
      raise WidthError("Program size cannot be negative.", 0, word_width)
    if (program_size > 2**address_width):
      raise WidthError("Program size cannot be greater than 2**(addr width).",
                       0, word_width)
    if (reg_width < 0):
      raise WidthError("Register address width cannot be negative.",
                       0, word_width)
    if (reg_count < 0):
      raise WidthError("Register count cannot be negative.", 0, word_width)
    if (reg_count > 2**reg_width):
      raise WidthError("Reg count cannot be greater than 2**(reg width).",
                       0, word_width)
    if (min_duration < 0):
      raise WidthError("Minimum duration cannot be negative.", 0, min_duration)
    if (branch_delay_slots < 0):
      raise WidthError("Branch delay slots cannot be negative.", 0,
                       branch_delay_slots)
    if (event_dict == None):
      raise RuntimeError("Supported event dictionary cannot be None.")
    if (chain_position < 0):
      raise RuntimeError("Chain position cannot be negative.")

    self.name                = name
    self.chain_position      = chain_position
    self.word_width          = word_width
    self.address_width       = address_width
    self.program_size        = program_size
    self.reg_width           = reg_width
    self.reg_count           = reg_count
    self.min_duration        = min_duration
    self.branch_delay_slots  = branch_delay_slots
#    self.load_words          = []
#    self.data_words          = []
    # Initialize family-specific register hash-table; we only allocate
    # a new register and generate a load/data word for a value once.
    self.reg_table     = {} # Table mapping values to reg numbers
    self.current_reg   = 0
    # Start out with base dictionary
    self.event_dict    = {
      Label_Event             : self.handle_label,
      Halt_Event              : self.handle_halt,
      Jump_Event              : self.handle_jump,
      FeedbackBranch_Event    : self.handle_feedback_branch,
      FeedbackBranchWait_Event: self.handle_feedback_branch_wait,
      FeedbackWhileLoop_Event : self.handle_loop,
      InfiniteLoop_Event      : self.handle_loop
      }
    self.event_dict.update(event_dict) # Then augment w/ family-specific
  #----------------------------------------------------------------------------
  def __str__(self):
    return self.name
  #----------------------------------------------------------------------------
  def setup_instructions(self):
    # Dummy method for testing
    pass
  #----------------------------------------------------------------------------
  def get_min_duration(self):
    return self.min_duration
  #----------------------------------------------------------------------------
  def get_reg(self, value):
    if (self.reg_table.has_key(value)):
      return self.reg_table[value]
    elif (current_reg >= self.reg_count):
      raise RuntimeError("This sequence uses more register values than "\
                         "our naive scheme allows.")
    else:
      current_reg += 1
      self.reg_table[value] = current_reg
      return current_reg
  #----------------------------------------------------------------------------
#  def generate_load_data(self, value):
#    data_word = DataWord(value)
#    self.data_words.append(data_word)
#    return data_word
  #----------------------------------------------------------------------------
  def get_name(self):
    return self.name
  #----------------------------------------------------------------------------
  def get_word_width(self):
    return self.word_width
  #----------------------------------------------------------------------------
  def get_address_width(self):
    return self.address_width
  #----------------------------------------------------------------------------
  def get_program_size(self):
    return self.program_size
  #----------------------------------------------------------------------------
  def get_reg_width(self):
    return self.reg_width
  #----------------------------------------------------------------------------
  def get_reg_count(self):
    return self.reg_count
  #----------------------------------------------------------------------------
  def translate_sequence(self, sequence):
    """
    translate_sequence(sequence):
      sequence = Sequence instance object of events to be translated into
                 a pulse program binary.
    Returns: the translated pulse program in binary form (PulseProgram)
    Throws: RuntimeError if PulseProgram exceed maximum size for this
            architecture
    """
    self.setup_instructions()
    program = PulseProgram(self.word_width, self.program_size)

    self.machine_dependent_prologue(program = program)

    for event in sequence.event_list: # Get iterator
      for word in self.translate_event(event):
        program.add_word(word)

    self.machine_dependent_epilogue(program = program, sequence = sequence)

    return program
  #----------------------------------------------------------------------------
  def machine_dependent_prologue(self, program, sequence):
    """
    Machine-specific instructions preceding all user-defined events.
    Override in each machine is necessary.
    """
    return
  #----------------------------------------------------------------------------
  def machine_dependent_epilogue(self, program, sequence):
    """
    Machine-specific instructions preceding all user-defined events.
    Override in each machine is necessary.
    """
    return
  #----------------------------------------------------------------------------
  def translate_event(self, event):
    """
    translate_event(event):
      event = event object to translate into one or more binary program words.
    Returns: list of words to add to a PulseProgram
    Throws: KeyError if the given event's class is not supported by this
            architecture.
    """
    try:
      handler_method = self.event_dict[event.__class__]
      word_list = handler_method(self, event)
#      debug_print(word_list, 2)
      return word_list
    except KeyError:
      raise EventError("Event type unsupported by machine "+self.name,
                       event.__class__)

