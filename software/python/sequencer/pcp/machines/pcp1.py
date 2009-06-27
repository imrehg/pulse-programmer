# Module : pcp1
# Package: pcp.machines
# Class for the pcp1 machine in the PCP32 processor family.

from sequencer.util               import *
from sequencer.pcp.instructions   import *
from sequencer.pcp.machines       import *
from sequencer.pcp.machines.pcp32 import *

#==============================================================================
class pcp1_Machine(PCP32_Family):
  "Class for the pcp1 machine."

  #----------------------------------------------------------------------------
  def __init__(self, chain_position = 0):
    """
    pcp1_Machine(chain_position):
      chain_position - an integer indicating this machine's position in the
                       daisy-chain (0 indicates chain initiator).
    """
    PCP32_Family.__init__(self,
                          name                = 'pcp1',
                          chain_position      = chain_position,
                          sub_stack_depth     = 8,
                          loop_address_width  = 3,
                          loop_data_width     = 8,
                          phase_address_width = 4,
                          phase_data_width    = AD9858_PHASE_DATA_WIDTH,
                          phase_adjust_width  = AD9858_PHASE_ADJUST_WIDTH,
                          phase_pulse_width   = 8,
                          phase_load_width    = 16,
                          min_wait_duration   = 4)

  #----------------------------------------------------------------------------
  def machine_dependent_prologue(self, program):
    """
    First instruction word must be a nop to prevent multiple bootstrapping
    problem. I guess normal processors never have this problem.
    """
    program.add_word(Nop_Instr())
