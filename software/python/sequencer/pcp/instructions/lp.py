# Module : lp
# Package: pcp.instructions
# Load phase instruction class definition
# for Pulse Control Processor binary instruction words.

from sequencer.constants             import *
from sequencer.pcp                   import *
from sequencer.pcp.bitmask           import *
from sequencer.pcp.instructions      import *
from sequencer.pcp.instructions.insn import *

#==============================================================================
class LoadPhase_Instr(InstructionWord):
  "Instruction word for loading phase accumulator."

  #----------------------------------------------------------------------------
  # Class constants
  OPCODE                 = 0xE # Default 4-bit opcode for PCP32

  CONSTANT_MASK          = Bitmask(label="Constant"        , width=16, shift=0)
  REGISTER_MASK          = Bitmask(label="Register"        , width=5, shift=23)
  SELECT_MASK            = Bitmask(label="Select"          , width=1, shift=16)

  WREN_FLAG_MASK         = Bitmask(label="Wren Flag"       , width=1, shift=22)
  ADDEND_FLAG_MASK       = Bitmask(label="Addend Flag"     , width=1, shift=21)
  SET_CURRENT_FLAG_SHIFT = Bitmask(label="Set Current Flag", width=1, shift=20)

  MASK_LIST              = []

  #----------------------------------------------------------------------------
  def set_opcode(opcode):
    InstructionWord.check_opcode(opcode)
    LoadPhase_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
  set_opcode = Callable(set_opcode)
  #----------------------------------------------------------------------------
  def set_masks(constant_width, constant_shift, register_width, register_shift,
                select_shift, wren_flag_shift, addend_flag_shift,
                set_current_flag_shift, hw_phase_data_width):

    multiple = int(math.ceil(hw_phase_data_width /
                             math.fabs(constant_width)))
    select_width = int(math.ceil(math.log(multiple, 2)))

    # Create bitmasks for testing
    constant_mask         = Bitmask(label = "Constant",
                                    width = constant_width,
                                    shift = constant_shift)
    register_mask         = Bitmask(label = "Register",
                                    width = register_width,
                                    shift = register_shift)
    select_mask           = Bitmask(label = "Select",
                                    width = select_width,
                                    shift = select_shift)
    wren_flag_mask        = Bitmask(label = "Wren Flag",
                                    width = 1,
                                    shift = wren_flag_shift)
    addend_flag_mask      = Bitmask(label = "Addend Flag",
                                    width = 1,
                                    shift = addend_flag_shift)
    set_current_flag_mask = Bitmask(label = "Set Current Flag",
                                    width = 1,
                                    shift = set_current_flag_shift)

    # Check mask widths and shifts.
    LoadPhase_Instr.MASK_LIST = list(InstructionWord.MASK_LIST)
    LoadPhase_Instr.MASK_LIST.extend([
      constant_mask, register_mask, select_mask, wren_flag_mask,
      addend_flag_mask, set_current_flag_mask])
    InstructionWord.check_masks(LoadPhase_Instr.MASK_LIST)

    LoadPhase_Instr.CONSTANT_MASK         = constant_mask
    LoadPhase_Instr.REGISTER_MASK         = register_mask
    LoadPhase_Instr.SELECT_MASK           = select_mask
    LoadPhase_Instr.WREN_FLAG_MASK        = wren_flag_mask
    LoadPhase_Instr.ADDEND_FLAG_MASK      = addend_flag_mask
    LoadPhase_Instr.SET_CURRENT_FLAG_MASK = set_current_flag_mask
  set_masks = Callable(set_masks)
  #----------------------------------------------------------------------------
  def __init__(self, constant, register, select, wren_flag, addend_flag,
               set_current_flag):
    """
    LoadPhase_Instr(constant, register, select, wren_flag, addend_flag,
                    set_current_flag)
      constant         = constant to load into a phase or addend word.
      register         = destination register for phase/addend values.
      select           = index of subdivision within total phase/addend word.
      wren_flag        = 1 if this insn should write out currently loaded
                         files to phase register file.
      addend_flag      = 1 if this insn should load into the addend word,
                         otherwise loads into the phase word.
      set_current_flag = 1 if this insn should make the current register
                         the current one for future phase pulses.
    """
    InstructionWord.__init__(self)
    # This has to be done otherwise the collapsable attribute is not set
    check_inputs([(constant        , self.CONSTANT_MASK        ),
                  (register        , self.REGISTER_MASK        ),
                  (select          , self.SELECT_MASK          ),
                  (wren_flag       , self.WREN_FLAG_MASK       ),
                  (addend_flag     , self.ADDEND_FLAG_MASK     ),
                  (set_current_flag, self.SET_CURRENT_FLAG_MASK)])

    #self.check_select(select)
    self.constant         = constant
    self.register         = register
    self.select           = select
    self.wren_flag        = wren_flag
    self.addend_flag      = addend_flag
    self.set_current_flag = set_current_flag
  #----------------------------------------------------------------------------
  def get_constant(self):
    return self.CONSTANT_MASK.get_shifted_value(self.constant)
  #----------------------------------------------------------------------------
  def get_register(self):
    return self.REGISTER_MASK.get_shifted_value(self.register)
  #----------------------------------------------------------------------------
  def get_select(self):
    return self.SELECT_MASK.get_shifted_value(self.select)
  #----------------------------------------------------------------------------
  def get_wren_flag(self):
    return self.WREN_FLAG_MASK.get_shifted_value(self.wren_flag)
  #----------------------------------------------------------------------------
  def get_addend_flag(self):
    return self.ADDEND_FLAG_MASK.get_shifted_value(self.addend_flag)
  #----------------------------------------------------------------------------
  def get_set_current_flag(self):
    return self.SET_CURRENT_FLAG_MASK.get_shifted_value(self.set_current_flag)
  #----------------------------------------------------------------------------
  def resolve_value(self):
    self.value = self.get_opcode()    | self.get_register()    | \
                 self.get_constant()  | self.get_select()      | \
                 self.get_wren_flag() | self.get_addend_flag() | \
                 self.get_set_current_flag()
  #----------------------------------------------------------------------------
  def __str__(self):
    return "LoadPhase_Instr: " +\
           " reg=" + str(self.register)         + \
           " sel=" + str(self.select)           + \
           " wef=" + str(self.wren_flag)        + \
           " adf=" + str(self.addend_flag)      + \
           " scf=" + str(self.set_current_flag) +\
           " con=" + str(self.constant)         +\
           " \n value: "+str(self.value)
