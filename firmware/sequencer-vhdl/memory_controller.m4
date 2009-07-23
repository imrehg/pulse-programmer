dnl--*-VHDL-*-
-- Generic burst controller to memory.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

memory_unit_([memory_controller],
  [dnl -- Libraries
library altera_mf;
use altera_mf.altera_mf_components.all;
use ieee.numeric_std.all;
],[dnl -- Ports ---------------------------------------------------------------
],[dnl -- Declarations --------------------------------------------------------
],[dnl -- Component Instantiation ---------------------------------------------
  memory : altsyncram
    generic map (
      OPERATION_MODE => "SINGLE_PORT",
      WIDTH_A        => DATA_WIDTH,
      WIDTHAD_A      => ADDRESS_WIDTH
      )
    port map (
      wren_a    => wb_we_i and wb_stb_i,
--       clocken0  => ,
      data_a    => wb_dat_i,
      address_a => memory_addr,
      clock0    => wb_clk_i,
      q_a       => wb_dat_o
      );
])
