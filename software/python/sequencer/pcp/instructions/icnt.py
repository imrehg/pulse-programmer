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
						# TODO: extend TargetInstruction instead?
class InputCounter_Instr(InstructionWord):
	"""
	Instruction word for input counter
	"""
	
	# Class constants
	OPCODE 					= 0x2
	### bit 18,19 unused?
	REGISTER_MASK			= Bitmask(label="Register", width=5, shift=24)
	SUBOPCODE_MASK			= Bitmask(label="Subopcode", width=3, shift=21)
	ADDRESS_MASK			= Bitmask(label="Address", width=18, shift=0)
	
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
		address_mask 	= Bitmask(label="Address", 
								  width=address_width, 
								  shift=address_shift)
		
		InputCounter_Instr.MASK_LIST = list(InstructionWord.MASK_LIST)
		InputCounter_Instr.MASK_LIST.extend([register_mask, subopcode_mask, address_mask])
		InstructionWord.check_masks(InputCounter_Instr.MASK_LIST)
		
		InputCounter_Instr.REGISTER_MASK = register_mask
		InputCounter_Instr.SUBOPCODE_MASK = subopcode_mask
		InputCounter_Instr.ADDRESS_MASK = address_mask
		
	set_masks = Callable(set_masks)
	#----------------------------------------------------------------------------
	def __init__(self, register, subopcode, mem_address):
		"""
		InputCounter_Intsr(subopcode)
			register	= address of counter register
			subopcode	= subopcode of the instruction
			mem_address		= memory address for writing/branching
		"""
		InstructionWord.__init__(self)
		# This has to be done otherwise the collapsable attribute is not set
		check_inputs([(register, InputCounter_Instr.REGISTER_MASK),
					  (subopcode, InputCounter_Instr.SUBOPCODE_MASK),
					  (mem_address, InputCounter_Instr.ADDRESS_MASK)])

		self.register = register
		self.subopcode = subopcode
		self.mem_address = mem_address
	#----------------------------------------------------------------------------
	def get_register(self):
		return self.REGISTER_MASK.get_shifted_value(self.register)
	#----------------------------------------------------------------------------
	def get_subopcode(self):
		return self.SUBOPCODE_MASK.get_shifted_value(self.subopcode)
	#----------------------------------------------------------------------------
	def get_mem_address(self):
		return self.ADDRESS_MASK.get_shifted_value(self.mem_address)
	#----------------------------------------------------------------------------
	def resolve_value(self):
		self.value = self.get_opcode() | self.get_subopcode() | \
		             self.get_register() | self.get_mem_address()
	#----------------------------------------------------------------------------
	def __str__(self):
		return "InputCounter_Instr: " + \
			   " register: " + hex(self.register) + \
			   " subopcode: " + hex(self.subopcode) + \
			   " address: " + hex(self.address)
#==============================================================================