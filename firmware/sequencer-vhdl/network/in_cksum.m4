dnl--*-VHDL-*-
-- IP one's complement running checksum generator.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Reads in a byte and incorporates it into its running checksum
-- since the last clear.

-- no WB_WE_I, WB_ADR_I b/c this is a checksum slave, supporting
-- a block write of words to sum and a single read of the checksum value.
-- WB_ACK_I goes high only after WB_STB_I has gone low and a valid
-- checksum appears on WB_DAT_O.
-- This deviates from Wishbone standard.

unit_([in_cksum], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use ieee.numeric_std.all;
],[dnl -- Generics
],[dnl -- Ports
wb_common_port_
    wb_cyc_i            : in     std_logic;
    wb_stb_i            : in     std_logic;
    wb_dat_i            : in     std_logic_vector(0 to (CKSUM_WIDTH-1));
    wb_dat_o            : out    ip_checksum;
    wb_ack_o            : buffer std_logic;
],[dnl -- Declarations
  signal sum                : unsigned(0 to 31);
  signal padded_high_sum    : unsigned(0 to 31);
  signal padded_low_sum     : unsigned(0 to 31);
  signal folded_back        : unsigned(0 to 31);
  signal padded_high_folded : unsigned(0 to 31);
  signal padded_low_folded  : unsigned(0 to 31);
  signal folded_back_again  : unsigned(0 to 31);
  signal truncated          : ip_checksum;
],[dnl -- Body
  process(wb_rst_i, wb_clk_i, wb_cyc_i, wb_stb_i, truncated)

  begin

    if (wb_rst_i = '1') then
      sum <= (others => '0');
    elsif (rising_edge(wb_clk_i) and (wb_cyc_i = '1')) then

      if (wb_stb_i = '1') then
        sum <= sum + unsigned(wb_dat_i);
      end if;

    end if;

    -- registered output to improve throughput
    wb_dat_o <= not truncated;
      
  end process;

  padded_high_sum <= X"0000" & sum( 0 to 15);
  padded_low_sum  <= X"0000" & sum(16 to 31);

  folded_back        <= padded_high_sum + padded_low_sum;

  padded_high_folded <= X"0000" & folded_back( 0 to 15);
  padded_low_folded  <= X"0000" & folded_back(16 to 31);

  folded_back_again  <= padded_high_folded + padded_low_folded;
  truncated <= std_logic_vector(folded_back_again(16 to 31));
])
