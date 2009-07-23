dnl--*-VHDL-*-
-- Generic burst controller front end with ports to connect to external memory.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

memory_unit_([memory_burst_controller],
  [dnl -- Libraries
use ieee.numeric_std.all;
],[dnl -- Ports ---------------------------------------------------------------
  ext_wb_we_o  : out std_logic;
  ext_wb_dat_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
  ext_wb_dat_i : in std_logic_vector(DATA_WIDTH-1 downto 0);
  ext_wb_adr_o : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);  
],[dnl -- Declarations --------------------------------------------------------
],[dnl -- Component Instantiation ---------------------------------------------
  ext_wb_we_o <= wb_we_i;
  ext_wb_dat_o <= wb_dat_i;
  wb_dat_o <= ext_wb_dat_i;
  ext_wb_adr_o <= memory_addr;
])

