# Module : icnt
# Package: pcp.instructions
# Input Counter instruction class definition
# for Pulse Control Processor binary instruction words.

from sequencer.constants             import *
from sequencer.pcp                   import *
from sequencer.pcp.bitmask           import *
from sequencer.pcp.instructions      import *
from sequencer.pcp.instructions.insn import *

#==============================================================================

# subopcodes
class icnt_subopcodes:
	ICNT_RESET 		= 0x0
	ICNT_LATCH 		= 0x1
	ICNT_WRITE		= 0x2
	ICNT_COMPARE 	= 0x4
	ICNT_BRANCH 	= 0x5
					
class InputCounter_Instr(InstructionWord, TargetInstruction):
	"""
	Instruction word for input counter
	"""
	
	# Class constants
	OPCODE 					= 0x2
	# bits 18,19 are unused
	REGISTER_MASK			= Bitmask(label="Register", width=5, shift=24)
	SUBOPCODE_MASK			= Bitmask(label="Subopcode", width=3, shift=21)
	TARGET_MASK				= Bitmask(label="Target", width=18, shift=0)
	
	MASK_LIST				= []
	
	#----------------------------------------------------------------------------
	def set_opcode(opcode):
		InstructionWord.check_opcode(opcode)
		InputCounter_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
	set_opcode = Callable(set_opcode)
	#----------------------------------------------------------------------------
	def set_masks(register_width, register_shift, subopcode_width, subopcode_shift,
				  address_width, address_shift):
				  
		register_mask 	= Bitmask(label="Register", 
								  width=register_width, 
								  shift=register_shift)
		subopcode_mask 	= Bitmask(label="Subopcode", 
								  width=subopcode_width, 
								  shift=subopcode_shift)
		target_mask 	= Bitmask(label="Target", 
								  width=address_width, 
								  shift=address_shift)
		
		InputCounter_Instr.MASK_LIST = list(InstructionWord.MASK_LIST)
		InputCounter_Instr.MASK_LIST.extend([register_mask, subopcode_mask, target_mask])
		InstructionWord.check_masks(InputCounter_Instr.MASK_LIST)
		
		InputCounter_Instr.REGISTER_MASK = register_mask
		InputCounter_Instr.SUBOPCODE_MASK = subopcode_mask
		InputCounter_Instr.TARGET_MASK = target_mask
		
	set_masks = Callable(set_masks)
	#----------------------------------------------------------------------------
	def __init__(self, register, subopcode, target):
		"""
		InputCounter_Intsr(register, subopcode, target)
			register		= address of counter register
			subopcode		= subopcode of the instruction
			target			= memory address for writing/branching
		"""
		InstructionWord.__init__(self)
		# This has to be done otherwise the collapsable attribute is not set
		check_inputs([(register, InputCounter_Instr.REGISTER_MASK),
					  (subopcode, InputCounter_Instr.SUBOPCODE_MASK)])

		self.register = register | 0x10 # all input counter registers are prefixed with 0x10xxx
		self.subopcode = subopcode
		self.target = target
	#----------------------------------------------------------------------------
	def get_register(self):
		return self.REGISTER_MASK.get_shifted_value(self.register)
	#----------------------------------------------------------------------------
	def get_subopcode(self):
		return self.SUBOPCODE_MASK.get_shifted_value(self.subopcode)
	#----------------------------------------------------------------------------
	def get_target_address(self):
		if (self.subopcode == icnt_subopcodes.ICNT_BRANCH):
			return self.TARGET_MASK.get_shifted_value(self.target.get_address())
		else:
			return self.TARGET_MASK.get_shifted_value(self.target)
	#----------------------------------------------------------------------------
	def resolve_value(self):
		self.value = self.get_opcode() | self.get_subopcode() | \
		             self.get_register() | self.get_target_address()
	#----------------------------------------------------------------------------
	def __str__(self):
		return "InputCounter_Instr: " + \
			   " register: " + hex(self.register) + \
			   " subopcode: " + hex(self.subopcode) + \
			   " target_address: " + hex(self.get_target_address())
#==============================================================================