# Module : pp
# Package: pcp.instructions

from sequencer.constants          import *
from sequencer.pcp                import *
from sequencer.pcp.instructions.p import *

#==============================================================================
class PulsePhase_Instr(PulseImmed_Instr):
  """
  Instruction word for a phase pulse; this is a special-purpose pulse to
  write information from the phase accumulator register file directly to a
  DDS device, and only support minimum duration pulses merged with each
  subdivision of the phase adjustment word.
  """

  #----------------------------------------------------------------------------
  # Class constants
  OPCODE             = 0xD # Default 4-bit opcode for PCP32

  PHASE_DATA_MASK    = Bitmask(label = "Phase Data"  , width = 8, shift = 8)
  OUTPUT_MASK        = Bitmask(label = "Output"      , width = 8, shift = 0)
  REGISTER_MASK      = Bitmask(label = "Register"    , width = 5, shift = 23)
  PHASE_SELECT_MASK  = Bitmask(label = "Phase Select", width = 1, shift = 16)
  MULTIPLE           = 2

  MASK_LIST          = []

  #----------------------------------------------------------------------------
  def set_opcode(opcode):
    InstructionWord.check_opcode(opcode)
    PulsePhase_Instr.OPCODE = opcode & InstructionWord.OPCODE_MASK
  set_opcode = Callable(set_opcode)
  #----------------------------------------------------------------------------
  def set_masks(phase_data_width, phase_data_shift, output_width, output_shift,
                register_width, register_shift, phase_select_shift,
                hw_phase_adjust_width):

    multiple = int(math.ceil(hw_phase_adjust_width /
                             math.fabs(phase_data_width)))
    phase_select_width = int(math.ceil(math.log(multiple, 2)))

    # Create bitmasks for testing
    phase_data_mask = Bitmask(label = "Phase Data"      ,
                              width = phase_data_width  ,
                              shift = phase_data_shift  )
    output_mask     = Bitmask(label = "Output"          ,
                              width = output_width      ,
                              shift = output_shift      )
    register_mask   = Bitmask(label = "Register"        ,
                              width = register_width    ,
                              shift = register_shift    )
    phase_sel_mask  = Bitmask(label = "Phase Select"    ,
                              width = phase_select_width,
                              shift = phase_select_shift)

    # Check mask widths and shifts
    PulsePhase_Instr.MASK_LIST = list(InstructionWord.MASK_LIST);
    # Don't check phase data mask, it is meant to overlap with output_mask
    PulsePhase_Instr.MASK_LIST.extend(
      [output_mask, register_mask, phase_sel_mask])
    InstructionWord.check_masks(PulsePhase_Instr.MASK_LIST)

    PulsePhase_Instr.PHASE_DATA_MASK   = phase_data_mask
    PulsePhase_Instr.OUTPUT_MASK       = output_mask
    PulsePhase_Instr.REGISTER_MASK     = register_mask
    PulsePhase_Instr.PHASE_SELECT_MASK = phase_sel_mask
    PulsePhase_Instr.MULTIPLE          = multiple
  set_masks = Callable(set_masks)
  #----------------------------------------------------------------------------
  def __init__(self, output_mask, output_reg, register, phase_select):
    """
    PulsePhase_Instr(output, register, select, bit_indices)
      output_mask = an output value that needs to be tested for subcontainment,
                    shifted, and merged with output_reg
      output_reg  = register for remembering output (may be None if
                    output is an integer)
      register   = source register for phase adjust value.
      phase_select = index of subdivision of phase width.
    """
    InstructionWord.__init__(self)
    # This has to be done otherwise the collapsable attribute is not set

    PulseImmed_Instr.__init__(self,
                              output_mask = output_mask,
                              output_reg  = output_reg,
                              duration    = 0)

    input_tuples = [(register    , self.REGISTER_MASK    ),
                    (phase_select, self.PHASE_SELECT_MASK)]
    check_inputs(input_tuples)

    self.register     = register
    self.phase_select = phase_select
  #----------------------------------------------------------------------------
  def get_register(self):
    return self.REGISTER_MASK.get_shifted_value(self.register)
  #----------------------------------------------------------------------------
  def get_phase_select(self):
    return self.PHASE_SELECT_MASK.get_shifted_value(self.phase_select)
  #----------------------------------------------------------------------------
  def get_select(self):
    # Return zero b/c phase pulse only ever selects a fixed subdivision,
    # hardcoded in the machine itself.
    return 0
  #----------------------------------------------------------------------------
  def resolve_value(self):
    PulseImmed_Instr.resolve_value(self)
    # We don't include phase data b/c this is taken directly by machine
    self.value |= self.get_register() | self.get_phase_select()
  #----------------------------------------------------------------------------
  def __str__(self):
    return "pp_insn: "                     + \
           " o_m=" + str(self.output_mask) + \
           " reg=" + str(self.register)    + \
           " psl=" + str(self.phase_select)
#          " o_r=" + str(self.output_reg)  + \
 
#==============================================================================
