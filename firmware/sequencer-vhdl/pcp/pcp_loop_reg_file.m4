dnl-*-VHDL-*-
-- Pulse Control Processor register file for loop counters.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://pulse-sequencer.sf.net
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([pcp_loop_reg_file], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
library pcplib;
use pcplib.instructions.all;
],[dnl -- Generics ------------------------------------------------------------
  DATA_WIDTH     : positive := 6;
  ADDRESS_WIDTH  : positive := 5;
  REGISTER_COUNT : positive := 32;
],[dnl -- Ports ---------------------------------------------------------------
   wb_clk_i      : in  std_logic;
   wb_adr_i      : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
   wb_dat_i      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
   wb_we_i       : in  std_logic;
   decrement_in  : in  std_logic;
   is_zero_out   : out std_logic;
   debug_out     : out std_logic_vector(DATA_WIDTH-1 downto 0);
],[dnl -- Declarations --------------------------------------------------------
memory_signals_
   signal dec_addr : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
],[dnl -- Body ----------------------------------------------------------------
memory_instance_

  process(wb_clk_i)

  begin
    if (rising_edge(wb_clk_i)) then
      dec_addr <= wb_adr_i;
    end if;
  end process;

  mem_cyc     <= '1';
  mem_stb     <= '1';
  mem_we      <= decrement_in or wb_we_i;
  mem_addr_in <= dec_addr when (decrement_in = '1') else wb_adr_i;
  mem_dat_i   <= wb_dat_i when (wb_we_i = '1') else
                 std_logic_vector(unsigned(mem_dat_o) - 1);
  mem_burst   <= '0';

  is_zero_out <= '1' when (to_integer(unsigned(mem_dat_o)) = 0) else '0';

  debug_out(DATA_WIDTH-1 downto 0) <= mem_dat_o;

-------------------------------------------------------------------------------
])
