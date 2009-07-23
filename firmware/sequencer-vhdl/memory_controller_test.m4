dnl--*-VHDL-*-
-- Test connecting a memory controller with read pipeline delay of 2.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([memory_controller_test],
  [dnl -- Libraries
sequencer_libraries_
],[dnl -- Generics
  ADDRESS_WIDTH         : positive := 8;
  DATA_WIDTH            : positive := 8;
],[dnl -- Ports
    wb_clk_i            : in  std_logic;
    sram_addr_out       : out std_logic_vector(15 downto 0);
    sram_wb_cyc         : in  std_logic;
    sram_wb_stb         : in  std_logic;
    sram_wb_we          : in  std_logic;
    sram_wb_adr         : in  std_logic_vector(15 downto 0);
    sram_wb_write_data  : in  std_logic_vector(15 downto 0);
    sram_wb_read_data   : out std_logic_vector(15 downto 0);
    sram_wb_ack         : out std_logic;
    sram_burst          : in  std_logic;
    sram_one_shot       : in  std_logic;
    sram_burst_addr_out : out std_logic_vector(7 downto 0);
],[dnl -- Declarations
],[dnl -- Body

  storage : memory_controller
    generic map (
      ADDRESS_WIDTH => 16,
      DATA_WIDTH    => 16,
      READ_PIPELINE_DELAY => 2
      )
    port map (
      wb_clk_i      => wb_clk_i,
      wb_cyc_i      => sram_wb_cyc,
      wb_stb_i      => sram_wb_stb,
      wb_we_i       => sram_wb_we,
      wb_adr_i      => sram_wb_adr,
      wb_dat_i      => sram_wb_write_data,
      wb_dat_o      => sram_wb_read_data,
      wb_ack_o      => sram_wb_ack,
      burst_in      => sram_burst,
      one_shot_in   => sram_one_shot,
      addr_out      => sram_addr_out
      );
])
