# Module : pcp0
# Package: pcp.machines
# Class for the pcp0 machine in the PCP64 processor family.

from sequencer.util import *
from sequencer.pcp.instructions import *
from sequencer.pcp.machines import *
from sequencer.pcp.machines.pcp64 import *

###############################################################################
# Import supported instruction types
from sequencer.pcp.instructions.halt  import * # Halt instruction
from sequencer.pcp.instructions.j     import * # Jump instruction
from sequencer.pcp.instructions.btr   import * # Branch on trigger instruction
from sequencer.pcp.instructions.p     import * # Pulse immediate instruction
from sequencer.pcp.instructions.pr    import * # Pulse register instruction
from sequencer.pcp.instructions.ld64i import * # Load 64-bit immediate instruction

# Import supported event types
from sequencer.pcp.events.atomic_pulse import *
from sequencer.pcp.events.simul_pulse  import *
from sequencer.pcp.events.finite_loop  import *
from sequencer.pcp.events.load_immed   import *
from sequencer.pcp.events.data         import *

#==============================================================================
class pcp0_Machine(PCP64_Family):
  "Class for the original pcp0 machine."

  def __init__(self, chain_position):
    PCP64_Family.__init__(self,
                          name               = 'pcp0',
                          chain_position     = 0,
                          min_immed_duration = 2,
                          min_reg_duration   = 3)

