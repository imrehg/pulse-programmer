import sequencer.constants
import os

#------------------------------------------------------------------------------
from datetime import datetime
import struct

def save_program(binary_charlist):
  datetext = datetime.today().strftime("%Y-%m-%d-%H%M%S")
  filename = "pulse-"+datetext+".bin"
  if (os.access(filename, os.F_OK)):
    filename = "pulse-"+datetext+"2.bin"
  filehandle = open(filename, "wb")
  for char in binary_charlist:
    filehandle.write(char)
  filehandle.close()  
#------------------------------------------------------------------------------
from sequencer.pcp.events.infinite_loop import InfiniteLoop_Event
def begin_infinite_loop():
    #we've to remove the current devices so we create the setup events for them !!
  unset_current_devices()
  sequencer.current_sequence.push_loop_stack()
#------------------------------------------------------------------------------
def end_infinite_loop():
  sequencer.current_sequence.pop_loop_stack(
    loop_event_class = InfiniteLoop_Event)
#------------------------------------------------------------------------------
from sequencer.pcp.events.finite_loop import FiniteLoop_Event
def begin_finite_loop():
  #we've to remove the current devices so we create the setup events for them !!
  unset_current_devices()
  sequencer.current_sequence.push_loop_stack()
#------------------------------------------------------------------------------
def end_finite_loop(loop_count):
  sequencer.current_sequence.pop_loop_stack(
    loop_event_class = FiniteLoop_Event,
    loop_count       = loop_count)
#------------------------------------------------------------------------------
from sequencer.pcp.events.feedback_branch import FeedbackBranch_Event

def branch(label, triggers):
  #we've to remove the current devices so we create the setup events for them !!
  unset_current_devices()
  sequencer.current_sequence.add_event(FeedbackBranch_Event(label, triggers))
#------------------------------------------------------------------------------
#from sequencer.pcp.events.feedback_branch_wait import FeedbackBranchWait_Event

def branch_wait(label, triggers):
  unset_current_devices()
  sequencer.current_sequence.add_event(FeedbackBranchWait_Event(label, triggers))
#------------------------------------------------------------------------------
from sequencer.pcp.events.jump import Jump_Event

def jump_label(label):
  #we've to remove the current devices so we create the setup events for them !!
  unset_current_devices()
  sequencer.current_sequence.add_event(Jump_Event(label))
#------------------------------------------------------------------------------
from sequencer.pcp.events.wait import Wait_Event

def wait(duration):
  max_wait=2**14-1
  # There is an error in the firmware that doesn't handle big waits correct:
  while (duration > max_wait):
    duration -= max_wait
    sequencer.current_sequence.add_event(Wait_Event(max_wait))
  sequencer.current_sequence.add_event(Wait_Event(duration))
#------------------------------------------------------------------------------
from sequencer.pcp.events.ins_nop import ins_nop_Event

def ins_nop(number):
  sequencer.current_sequence.add_event(ins_nop_Event(number))
#-----------------------------------------------------------------------------
def begin_subroutine(label):
  #we've to remove the current devices so we create the setup events for them !!
  unset_current_devices()
  sequencer.current_sequence.push_sub_stack(label)
#-----------------------------------------------------------------------------
def end_subroutine():
  sequencer.current_sequence.pop_sub_stack()
#-----------------------------------------------------------------------------
def call_subroutine(label):
  #we've to remove the current devices so we create the setup events for them !!
  unset_current_devices()
  sequencer.current_sequence.add_subroutine_call(label)
#------------------------------------------------------------------------------
def parse_params(*option_list):
  option_list = list(option_list)
  option_list.extend(sequencer.standard_params)
#  parse_params(*standard_params) # unpack list into tuples
  for (option,type) in option_list:
    if (type == "boolean"):
      sequencer.parser.add_option("--"+option, action="store_true",
                                  dest=option)
    else:
      sequencer.parser.add_option("--"+option, type=type, dest=option)
  (sequencer.params, sequencer.args) = sequencer.parser.parse_args()
  if ('debug' in dir(sequencer.params)):
    sequencer.debug_level = sequencer.params.debug
  if ('nonet' not in dir(sequencer.params)):
    sequencer.params.nonet = False
#------------------------------------------------------------------------------
from sequencer.pcp.events.label import Label_Event

def create_and_insert_label(label_name=""):
  label_event = Label_Event(label_name)
  sequencer.current_sequence.add_event(label_event)
  return label_event

def create_label(label_name=""):
  label_event = Label_Event(label_name)
  return label_event

def insert_label(label_event):
  sequencer.current_sequence.add_event(label_event)

#--------------------------------------------------------------------------
# unset the current devices - we need this for loops and subroutines
def unset_current_devices():
  sequencer.current_sequence.unset_current_devices()

### TODO: ###
from sequencer.pcp.events.input_counter import InputCounterReset_Event
from sequencer.pcp.events.input_counter import InputCounterLatch_Event
from sequencer.pcp.events.input_counter import InputCounterWrite_Event
from sequencer.pcp.events.input_counter import InputCounterCompare_Event
from sequencer.pcp.events.input_counter import InputCounterBranch_Event

def reset_input_counter(input_channel):
  reset_icnt = InputCounterReset_Event(input_channel)
  sequencer.current_sequence.add_event(reset_icnt)

def latch_input_counter(input_channel):
  latch_icnt = InputCounterLatch_Event(input_channel)
  sequencer.current_sequence.add_event(latch_icnt)

def write_input_counter(input_channel, memory_address):
  write_icnt = InputCounterWrite_Event(input_channel, memory_address)
  sequencer.current_sequence.add_event(write_icnt)

def compare_input_counter(input_channel):
  compare_icnt = InputCounterCompare_Event(input_channel)
  sequencer.current_sequence.add_event(compare_icnt)

def branch_input(input_channel, triggers):
  pass
  