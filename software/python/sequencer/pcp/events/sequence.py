# Module : sequence
# Package: pcp.events
# Class definition for pulse sequence.

from sequencer.pcp.events.halt            import *
from sequencer.pcp.events.infinite_loop   import InfiniteLoop_Event
from sequencer.pcp.events.subroutine      import Subroutine_Event
from sequencer.pcp.events.subroutine_call import SubroutineCall_Event

class PulseSequence:
  """
  Container class for an abstract pulse sequence.
  """

  def __init__(self, sub_names_dict = {}):
    """
    PulseSequencer():
    """
    self.event_list     = []
    self.loop_stack     = []
    self.sub_stack      = []
    self.sub_names_dict = sub_names_dict
    if (len(sub_names_dict) > 0):
      self.reused = True
    else:
      self.reused = False
 #   self.event_count    = 0

  def push_loop_stack(self):
    self.loop_stack.append(self.event_list)
    self.event_list = []

  def pop_loop_stack(self, loop_event_class, **key_args):
    prev_event_list = self.loop_stack.pop()
    prev_event_list.append(loop_event_class(sequence = self.event_list,
                                            **key_args))
    self.event_list = prev_event_list

  def push_sub_stack(self, label):
    # Tuple of string label and event list
    self.sub_stack.append((label, self.event_list))
    self.event_list = []

  def pop_sub_stack(self, **key_args):
    (prev_label, prev_event_list) = self.sub_stack.pop()
    sub_event = Subroutine_Event(sequence = self.event_list,
                                 label    = prev_label,
                                 **key_args)
    self.event_list = prev_event_list
    self.sub_names_dict[prev_label] = sub_event

  def add_subroutine_call(self, label):
    if (label not in self.sub_names_dict.keys()):
      raise RuntimeError("Label " + label + " not a subroutine.")
    sub_event = self.sub_names_dict[label]
    self.event_list.append(SubroutineCall_Event(sub_event))

  def add_event_list(self, event_list):
    for event in event_list:
      self.add_event(event)

  def add_event(self, event):
    # If any event has been added before, the recursive set_added called
    # will find them out.
    event.set_added()
    self.event_list.append(event)
#    self.event_count += event.get_size()

#  def get_size(self):
#    return self.event_count

#  def event_generator(self):
#    for event in self.event_list:
#      yield event

  def get_sub_events(self):
    if (self.reused):
      return []
    else:
      return self.sub_names_dict.values()
  
