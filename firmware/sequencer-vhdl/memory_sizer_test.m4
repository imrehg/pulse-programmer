dnl--*-VHDL-*-
-- Test connecting a memory_sizer up to a memory_controller.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([memory_sizer_test],
  [dnl -- Libraries
sequencer_libraries_
],[dnl -- Generics
  ADDRESS_WIDTH : positive := 8;
  DATA_WIDTH : positive := 8;
],[dnl -- Ports
wb_common_port_
   -- Master ports
    wb_cyc_i            : in     std_logic;
    wb_stb_i            : in     std_logic;
    wb_we_i             : in     std_logic;
    wb_adr_i            : in     std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    wb_dat_i            : in     std_logic_vector(DATA_WIDTH-1 downto 0);
    wb_dat_o            : out    std_logic_vector(DATA_WIDTH-1 downto 0);
    wb_ack_o            : out    std_logic;
    burst_in            : in     std_logic;
    sram_addr_out       : buffer std_logic_vector(15 downto 0);
    sram_wb_cyc         : buffer std_logic;
    sram_wb_gnt         : in     std_logic;
    sram_wb_stb         : buffer std_logic;
    sram_wb_we          : buffer std_logic;
    sram_wb_adr         : buffer std_logic_vector(15 downto 0);
    sram_wb_write_data  : buffer std_logic_vector(15 downto 0);
    sram_wb_read_data   : buffer std_logic_vector(15 downto 0);
    sram_wb_ack         : buffer std_logic;
    sram_burst          : buffer std_logic;
    sram_burst_addr_out : out    std_logic_vector(7 downto 0);
],[dnl -- Declarations

memory_sizer_component_
],[dnl -- Body

  storage : memory_controller
    generic map (
      ADDRESS_WIDTH => 16,
      DATA_WIDTH    => 16
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
      addr_out      => sram_addr_out
      );

  sizer : memory_sizer
    generic map (
      VIRTUAL_ADDRESS_WIDTH  => ADDRESS_WIDTH,
      VIRTUAL_DATA_WIDTH     => DATA_WIDTH,
      PHYSICAL_ADDRESS_WIDTH => 16,
      DATA_SCALE_TWO_POWER   => 1, -- 16 >= 8*2^1
      PHYSICAL_DATA_WIDTH    => 16 
      )
    port map (
      -- Wishbone common signals
      wb_clk_i            => wb_clk_i,
      wb_rst_i            => wb_rst_i,
      -- Slave interface to client of virtual memory
      wbs_cyc_i           => wb_cyc_i,
      wbs_stb_i           => wb_stb_i,
      wbs_we_i            => wb_we_i,
      wbs_adr_i           => wb_adr_i,
      wbs_dat_i           => wb_dat_i,
      wbs_dat_o           => wb_dat_o,
      wbs_ack_o           => wb_ack_o,
      burst_in            => burst_in,
      -- Master interface to physical memory
      wbm_cyc_o           => sram_wb_cyc,
      wbm_gnt_i           => sram_wb_gnt,
      wbm_stb_o           => sram_wb_stb,
      wbm_we_o            => sram_wb_we,
      wbm_adr_o           => sram_wb_adr,
      wbm_dat_o           => sram_wb_write_data,
      wbm_dat_i           => sram_wb_read_data,
      wbm_ack_i           => sram_wb_ack,
      burst_out           => sram_burst,
      burst_addr_in       => sram_addr_out,
      burst_addr_out      => sram_burst_addr_out,
      phy_start_addr      => B"111111111"
    );
])
