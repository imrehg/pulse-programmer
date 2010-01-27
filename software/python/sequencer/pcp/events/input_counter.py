# Module : input_counter
# Package: pcp.events
# Class definitions for input counting events

from sequencer.pcp.events import *
from sequencer.pcp.instructions.icnt import icnt_subopcodes as subop

#==============================================================================
class InputCounter_Event(Event):
	"""
	Base class for abstract input counter event
	"""
	def __init__(self, input_channel):
		"""
		InputCounterReset_Event(input_channel):
			input_channel = address of counter to reset
		"""
		Event.__init__(self)
		self.input_channel = input_channel
		self.subopcode = None
	
	def get_subopcode(self):
		return self.subopcode
	
	def get_input_channel(self):
		return self.input_channel
	
	def __str__(self):
		return "InputCounterReset_Event: " + \
			   " subopcode: " + repr(self.subopcode) + \
			   " input_channel: " + repr(self.input_channel)
#==============================================================================
class InputCounterReset_Event(InputCounter_Event):
	"""
	Base class for abstract input counter reset event
	"""
	def __init__(self, input_channel):
		InputCounter_Event.__init__(self, input_channel)
		self.subopcode = subop.ICNT_RESET
	
#==============================================================================
class InputCounterLatch_Event(InputCounter_Event):
	"""
	Base class for abstract input counter latch to register event
	"""
	def __init__(self, input_channel):
		InputCounter_Event.__init__(self, input_channel)
		self.subopcode = subop.ICNT_LATCH
#==============================================================================
class InputCounterWrite_Event(InputCounter_Event):
	"""
	Base class for abstract input counter write to memory event
	"""
	def __init__(self, input_channel):
		InputCounter_Event.__init__(self, input_channel)
		self.subopcode = subop.ICNT_WRITE
#==============================================================================
class InputCounterCompare_Event(InputCounter_Event):
	"""
	Base class for abstract input counter compare to threshold event
	"""
	def __init__(self, input_channel):
		InputCounter_Event.__init__(self, input_channel)
		self.subopcode = subop.ICNT_COMPARE
#==============================================================================
class InputCounterBranch_Event(Target_Event):
	"""
	Base class for abstract input counter branch on threshold event
	"""
	def __init__(self, target, branch_delay_slot = None):
		"""
		InputCounterBranch_Event(target):
			target = event to branch to
		"""
		Target_Event.__init__(self, target, branch_delay_slot)
		self.subopcode = subop.ICNT_BRANCH
		self.target = target
	
	def get_subopcode(self):
		return self.subopcode
	
	def __str__(self):
		return "InputCounterBranch_Event: " + \
			   " subopcode: " + repr(self.subopcode) + \
			   " target: " + repr(target)
#==============================================================================