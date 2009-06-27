# Module : load_immediate
# Package: pcp.events
# Class definition for a load data word (into a register) event.

from sequencer.pcp.events import *
from sequencer.pcp.events.data import *

#==============================================================================
class LoadImmed_Event(Target_Event):
  """
  Base class for an abstract load event, which generates both load
  instruction words and target data words.
  """

  def __init__(self, value, reg):
    """
    LoadImmed_Event(value):
      value = value of data word to load into an abstract register.
      reg = destination register of load event.
    """
    if (not reg.is_abstract_register()):
      raise RuntimeError("Given destination is not an abstract register.")
    self.reg = reg
    self.data_event = Data_Event(value)
    Target_Event.__init__(self, self.data_event.get_first_word())

  def get_register(self):
    return self.reg

  def get_data_event(self):
    return self.data_event

  def get_size(self):
    # Overridden from Event, b/c we are composite
    return 2

