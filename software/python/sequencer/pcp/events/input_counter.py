# Module : input_counter
# Package: pcp.events
# Class definitions for input counting events

from sequencer.pcp.events import *

#==============================================================================
class InputCounterReset_Event(Event):
	"""
	Base class for abstract input counter reset event
	"""
	def __init__(self, input_channel):
		"""
		InputCounterReset_Event(input_channel):
			input_channel = address of counter to reset
		"""
		Event.__init__(self)
		self.input_channel = input_channel
		self.subopcode = 0x0
	
	def get_subopcode(self):
		return self.subopcode
	
	def get_input_channel(self):
		return self.input_channel
	
	def __str__(self):
		return "InputCounterReset_Event: " + \
			   " subopcode: " + repr(self.subopcode) + \
			   " input_channel: " + repr(self.input_channel)
#==============================================================================
class InputCounterLatch_Event(Event):
	"""
	Base class for abstract input counter latch to register event
	"""
	def __init__(self, input_channel):
		"""
		InputCounterLatch_Event(input_channel):
			input_channel = address of counter to latch to register
		"""
		Event.__init__(self)
		self.input_channel = input_channel
		self.subopcode = 0x1
	
	def get_subopcode(self):
		return self.subopcode
	
	def get_input_channel(self):
		return self.input_channel
	
	def __str__(self):
		return "InputCounterLatch_Event: " + \
			   " subopcode: " + repr(self.subopcode) + \
			   " input_channel: " + repr(self.input_channel)
#==============================================================================
class InputCounterWrite_Event(Event):
	"""
	Base class for abstract input counter write to memory event
	"""
	def __init__(self, input_channel, memory_address):
		"""
		InputCounterWrite_Event(input_channel, memory_address):
			input_channel = address of counter to write to memory
		"""
		Event.__init__(self)
		self.input_channel = input_channel
		self.memory_address = memory_address
		self.subopcode = 0x2 
	
	def get_subopcode(self):
		return self.subopcode
	
	def get_input_channel(self):
		return self.input_channel
	
	def get_memory_address(self):
		return self.memory_address
	
	def __str__(self):
		return "InputCounterWrite_Event: " + \
			   " subopcode: " + repr(self.subopcode) + \
			   " input_channel: " + repr(self.input_channel) + \
			   " memory_address: " + repr(self.memory_address)
#==============================================================================
class InputCounterCompare_Event(Event):
	"""
	Base class for abstract input counter compare to threshold event
	"""
	def __init__(self, input_channel):
		"""
		InputCounterCompare_Event(input_channel):
			input_channel = address of counter to compare to its threshold register
		"""
		Event.__init__(self)
		self.input_channel = input_channel
		self.subopcode = 0x4
	
	def get_subopcode(self):
		return self.subopcode
	
	def get_input_channel(self):
		return self.input_channel
	
	def __str__(self):
		return "InputCounterCompare_Event: " + \
			   " subopcode: " + repr(self.subopcode) + \
			   " input_channel: " + repr(self.input_channel)
#==============================================================================
class InputCounterBranch_Event(Target_Event):
	"""
	Base class for abstract input counter branch on threshold event
	"""
	def __init__(self, target, branch_delay_slot = None):
		"""
		InputCounterBranch_Event(target):
			target = instruction to branch to
		"""
		Target_Event.__init__(self, target, branch_delay_slot)
		self.subopcode = 0x5
	
	def get_subopcode(self):
		return self.subopcode
	
	def __str__(self):
		return "InputCounterBranch_Event: " + \
			   " subopcode: " + repr(self.subopcode) + \
			   " target: " + repr(target)
#==============================================================================