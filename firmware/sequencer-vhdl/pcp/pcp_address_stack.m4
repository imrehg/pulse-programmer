dnl-*-VHDL-*-
-- Pulse Control Processor address stack for subroutine calls.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://pulse-sequencer.sf.net
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([pcp_address_stack], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
library pcplib;
use pcplib.instructions.all;
],[dnl -- Generics ------------------------------------------------------------
  DATA_WIDTH     : positive := 19;
  ADDRESS_WIDTH  : positive := 5;
  STACK_DEPTH    : positive := 32;
],[dnl -- Ports ---------------------------------------------------------------
   wb_clk_i                 : in  std_logic;
   sclr                     : in  std_logic;
   wb_dat_i                 : in  std_logic_vector(DATA_WIDTH-1 downto 0);
   push_in                  : in  std_logic;
   pop_in                   : in  std_logic;
   wb_dat_o                 : out std_logic_vector(DATA_WIDTH-1 downto 0);
],[dnl -- Declarations --------------------------------------------------------
memory_signals_
   signal stack_pointer : unsigned(ADDRESS_WIDTH-1 downto 0);

],[dnl -- Body ----------------------------------------------------------------
memory_instance_

  mem_cyc      <= '1';
  mem_stb      <= '1';
  mem_we       <= push_in;
  mem_addr_in  <= std_logic_vector(stack_pointer+1) when (push_in='1') else
                  std_logic_vector(stack_pointer);
  mem_dat_i    <= wb_dat_i;
  wb_dat_o     <= mem_dat_o;
  mem_burst    <= '0';

  process(wb_clk_i, sclr)

  begin
    if (rising_edge(wb_clk_i)) then
      if (sclr = '1') then
        stack_pointer <= (others => '0');
      else
        if (push_in = '1') then
          stack_pointer <= stack_pointer + 1;
        elsif (pop_in = '1') then
          stack_pointer <= stack_pointer - 1;
        end if;
      end if;
    end if;

  end process;

-------------------------------------------------------------------------------
])
