dnl-*-VHDL-*-
-- Pulse Control Processor register file.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([pcp_reg_file], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
library pcplib;
use pcplib.instructions.all;
],[dnl -- Generics ------------------------------------------------------------
  DATA_WIDTH    : positive := 64;
  ADDRESS_WIDTH : positive := 8;
  REGISTER_COUNT : positive := 5;
],[dnl -- Ports ---------------------------------------------------------------
   wb_clk_i                 : in  std_logic;
   wb1_adr_i                : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
   wb1_dat_o                : out std_logic_vector(DATA_WIDTH-1 downto 0);
   wb1_dat_i                : in  std_logic_vector(DATA_WIDTH-1 downto 0);
   wb1_we_i                 : in  std_logic;
   wb2_adr_i                : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
   wb2_dat_o                : out std_logic_vector(DATA_WIDTH-1 downto 0);
],[dnl -- Declarations --------------------------------------------------------
],[dnl -- Body ----------------------------------------------------------------

  reg_file : memory_dual_controller
    generic map (
      DATA_WIDTH        => DATA_WIDTH,
      ADDRESS_WIDTH     => ADDRESS_WIDTH,
      WORD_COUNT        => REGISTER_COUNT
      )
    port map (
      wb_clk_i          => wb_clk_i,
      -- First port
      wb1_cyc_i         => '1',
      wb1_stb_i         => '1',
      wb1_we_i          => wb1_we_i,
      wb1_adr_i         => wb1_adr_i(ADDRESS_WIDTH-1 downto 0),
      wb1_dat_i         => wb1_dat_i,
      wb1_dat_o         => wb1_dat_o,
      burst1_in         => '0',
      -- Second port
      wb2_cyc_i         => '1',
      wb2_stb_i         => '1',
      wb2_adr_i         => wb2_adr_i(ADDRESS_WIDTH-1 downto 0),
      wb2_dat_o         => wb2_dat_o,
      burst2_in         => '0'
      );

-------------------------------------------------------------------------------
])
