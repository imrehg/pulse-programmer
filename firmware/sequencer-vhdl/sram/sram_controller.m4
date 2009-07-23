dnl--*-VHDL-*-
-- SRAM wishbone slave interface.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

memory_unit_([sram_controller], dnl
  [dnl -- Libraries -----------------------------------------------------------
use ieee.numeric_std.all;
],[dnl -- Ports ---------------------------------------------------------------
    -- Physical SRAM device pins
    sram_data      : inout std_logic_vector(DATA_WIDTH-1 downto 0);
    sram_addr      : out   std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    sram_nOE       : out   std_logic;
    sram_nGW       : out   std_logic;
    sram_clk       : out   std_logic;
    sram_nCE1      : out   std_logic;
],[dnl -- Declarations --------------------------------------------------------
  signal write_phase            : std_logic;
  signal read_phase             : std_logic;
],[dnl -- Body ----------------------------------------------------------------
  sram_clk <= wb_clk_i;

  sram_nCE1 <= not wb_cyc_i;

  write_phase <= wb_stb_i and wb_we_i;
  read_phase <= wb_stb_i and (not wb_we_i);

  -- these are active low, so they assigned the reverse of what is expected
  sram_nGW <= not write_phase;
  sram_nOE <= not read_phase;

--   ack_process : process(wb_clk_i)

--   begin
--     if (rising_edge(wb_clk_i)) then
--       wb_ack_o <= write_phase or intermediate_write_ack;
--       -- if we are writing, ack after one cycle b/c of SRAM's write pipeline
--       -- (builtin input register)
--       intermediate_write_ack <= intermediate_read_ack;
--       -- if we are reading, ack after two cycles b/c of SRAM's read pipeline
--       -- (built-in address reg and output reg)
--       intermediate_read_ack <= read_phase and wb_cyc_i;

--     end if;
--   end process;

  sram_addr <= memory_addr;

  input_tristate_gen : for i in DATA_WIDTH-1 downto 0 generate
    sram_data(i) <= wb_dat_i(i) when (write_phase = '1') else 'Z';
    wb_dat_o(i) <= sram_data(i) when (write_phase = '0') else 'Z';
  end generate input_tristate_gen;
])
