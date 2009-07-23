dnl--*-VHDL-*-
-- CRC32 running checksum VHDL source
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Reads in a nibble and incorporates it into its running CRC32 checksum
-- since the last reset.
-- Output is properly reflected and negated.

-- This module uses the CRC32_WIDTH constant for readability and
-- maintainability, but obviously it won't work for anything but 32 bits.

unit_([crc32],
  [dnl -- Libraries
library seqlib;
use seqlib.util.all;
use seqlib.network.all;
],[dnl -- Generics
],[dnl -- Ports
wb_common_port_
    wb_stb_i : in  std_logic;
    wb_dat_i : in  nibble;
    wb_dat_o : out crc32_checksum;
],[dnl -- Declarations
  -- inputs to CRC register
  signal crc_ff_in         : std_logic_vector(31 downto 0);
  -- outputs of CRC register
  signal crc_ff_out        : std_logic_vector(31 downto 0);
  -- xor of top bit and next message bit
  signal xorbit            : std_logic_vector(31 downto 28);  
  -- reflected outputs
  signal crc_reflected_out : std_logic_vector(31 downto 0);
],[dnl -- Body
  process(wb_clk_i, wb_rst_i, wb_stb_i)

  begin

    if (wb_rst_i = '1') then
      crc_ff_out <= (others => '1');
    elsif (rising_edge(wb_clk_i) and (wb_stb_i = '1')) then
      crc_ff_out <= crc_ff_in;
    end if;

  end process;

  xorbit(31) <= crc_ff_out(31) xor wb_dat_i(0);
  xorbit(30) <= crc_ff_out(30) xor wb_dat_i(1);
  xorbit(29) <= crc_ff_out(29) xor wb_dat_i(2);
  xorbit(28) <= crc_ff_out(28) xor wb_dat_i(3);

  crc_ff_in(31) <= wb_rst_i or (crc_ff_out(27));
  crc_ff_in(30) <= wb_rst_i or (crc_ff_out(26));
  crc_ff_in(29) <= wb_rst_i or (crc_ff_out(25)
                                 xor xorbit(31));
  crc_ff_in(28) <= wb_rst_i or (crc_ff_out(24)
                                 xor xorbit(30));
  crc_ff_in(27) <= wb_rst_i or (crc_ff_out(23)
                                 xor xorbit(29));
  crc_ff_in(26) <= wb_rst_i or (crc_ff_out(22)
                                 xor xorbit(31) xor xorbit(28));
  crc_ff_in(25) <= wb_rst_i or (crc_ff_out(21)
                                 xor xorbit(31) xor xorbit(30));
  crc_ff_in(24) <= wb_rst_i or (crc_ff_out(20)
                                 xor xorbit(30) xor xorbit(29));
  crc_ff_in(23) <= wb_rst_i or (crc_ff_out(19)
                                 xor xorbit(29) xor xorbit(28));
  crc_ff_in(22) <= wb_rst_i or (crc_ff_out(18)
                                 xor xorbit(28));
  crc_ff_in(21) <= wb_rst_i or (crc_ff_out(17));
  crc_ff_in(20) <= wb_rst_i or (crc_ff_out(16));
  crc_ff_in(19) <= wb_rst_i or (crc_ff_out(15)
                                 xor xorbit(31));
  crc_ff_in(18) <= wb_rst_i or (crc_ff_out(14)
                                 xor xorbit(30));
  crc_ff_in(17) <= wb_rst_i or (crc_ff_out(13)
                                 xor xorbit(29));
  crc_ff_in(16) <= wb_rst_i or (crc_ff_out(12)
                                 xor xorbit(28));
  crc_ff_in(15) <= wb_rst_i or (crc_ff_out(11)
                                 xor xorbit(31));
  crc_ff_in(14) <= wb_rst_i or (crc_ff_out(10)
                                 xor xorbit(31) xor xorbit(30));
  crc_ff_in(13) <= wb_rst_i or (crc_ff_out( 9)
                                 xor xorbit(31) xor xorbit(30) xor xorbit(29));
  crc_ff_in(12) <= wb_rst_i or (crc_ff_out( 8)
                                 xor xorbit(30) xor xorbit(29) xor xorbit(28));
  crc_ff_in(11) <= wb_rst_i or (crc_ff_out( 7)
                                 xor xorbit(31) xor xorbit(29) xor xorbit(28));
  crc_ff_in(10) <= wb_rst_i or (crc_ff_out( 6)
                                 xor xorbit(31) xor xorbit(30) xor xorbit(28));
  crc_ff_in( 9) <= wb_rst_i or (crc_ff_out( 5)
                                 xor xorbit(30) xor xorbit(29));
  crc_ff_in( 8) <= wb_rst_i or (crc_ff_out( 4)
                                 xor xorbit(31) xor xorbit(29) xor xorbit(28));
  crc_ff_in( 7) <= wb_rst_i or (crc_ff_out( 3)
                                 xor xorbit(31) xor xorbit(30) xor xorbit(28));
  crc_ff_in( 6) <= wb_rst_i or (crc_ff_out( 2)
                                 xor xorbit(30) xor xorbit(29));
  crc_ff_in( 5) <= wb_rst_i or (crc_ff_out( 1)
                                 xor xorbit(31) xor xorbit(29) xor xorbit(28));
  crc_ff_in( 4) <= wb_rst_i or (crc_ff_out( 0)
                                 xor xorbit(31) xor xorbit(30) xor xorbit(28));
  crc_ff_in( 3) <= wb_rst_i or (xorbit(31) xor xorbit(30) xor xorbit(29));
  crc_ff_in( 2) <= wb_rst_i or (xorbit(30) xor xorbit(29) xor xorbit(28));
  crc_ff_in( 1) <= wb_rst_i or (xorbit(29) xor xorbit(28));
  crc_ff_in( 0) <= wb_rst_i or (xorbit(28));

  -- Ethernet CRC32 reflects output
  reflect_gen: for i in 31 downto 0 generate
    crc_reflected_out(i) <= crc_ff_out(31-i);
  end generate reflect_gen;
  
  -- then negates it (XOR with 0xFFFFFFFF)
  negate_gen: for i in 31 downto 0 generate
    wb_dat_o(i) <= not crc_reflected_out(i);
  end generate negate_gen;
])

