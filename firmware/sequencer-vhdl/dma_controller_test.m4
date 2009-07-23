dnl-*-VHDL-*-
-- Test for DMA controller module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([dma_controller_test], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
  VIRTUAL_ADDRESS_WIDTH  : positive := 8;
  VIRTUAL_DATA_WIDTH     : positive := 8;
  PHYSICAL_ADDRESS_WIDTH : positive := 9;
  PHYSICAL_DATA_WIDTH    : positive := 16;
  DATA_SCALE_TWO_POWER   : positive := 1;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   -- Wishbone master interface to ip_transmit
wb_xmit_master_port_
   -- Wishbone slave interface from ip_receive
wb_recv_slave_port_
  -- b/c the memory isn't a master by itself
  xmit_wbs_stb_i         : in  std_logic;
  xmit_wbs_ack_o         : out std_logic;
  xmit_length_in         : in  ip_total_length;
  xmit_length_out        : out ip_total_length;
  recv_wbm_stb_o         : out std_logic;
  recv_wbm_ack_i         : in  std_logic;
  recv_length_in         : in  ip_total_length;
  recv_length_out        : out ip_total_length;
  xmit_buffer_start_addr : in  std_logic_vector(VIRTUAL_ADDRESS_WIDTH-1
                                                downto 0);
  recv_buffer_start_addr : in  std_logic_vector(VIRTUAL_ADDRESS_WIDTH-1
                                                downto 0);
  -- Pins directly to SRAM (for debugging)
  sram_wb_cyc            : buffer std_logic;
  sram_wb_stb            : buffer std_logic;
  sram_wb_we             : buffer std_logic;
  sram_wb_adr            : buffer std_logic_vector(PHYSICAL_ADDRESS_WIDTH-1
                                                   downto 0);
  sram_wb_dat_i          : buffer std_logic_vector(PHYSICAL_DATA_WIDTH-1
                                                   downto 0);
  sram_wb_dat_o          : buffer std_logic_vector(PHYSICAL_DATA_WIDTH-1
                                                   downto 0);
  sram_wb_ack            : buffer std_logic;
  sram_burst             : buffer std_logic;
  sram_addr_out          : buffer std_logic_vector(PHYSICAL_ADDRESS_WIDTH-1
                                                   downto 0);
  -- Memory outputs to SRAM or sizer
  mem_wbm_cyc_o          : buffer std_logic;
  mem_wbm_stb_o          : buffer std_logic;
  mem_wbm_we_o           : buffer std_logic;
  mem_wbm_adr_o          : buffer std_logic_vector(VIRTUAL_ADDRESS_WIDTH-1
                                                   downto 0);
  mem_wbm_dat_i          : buffer std_logic_vector(DATA_WIDTH-1
                                                   downto 0);
  mem_wbm_dat_o          : buffer std_logic_vector(DATA_WIDTH-1
                                                   downto 0);
  mem_wbm_ack_i          : buffer std_logic;
  mem_burst              : buffer std_logic;
  mem_addr_in            : buffer std_logic_vector(VIRTUAL_ADDRESS_WIDTH-1
                                                   downto 0);
  phy_start_prefix       : in     std_logic_vector(PHYSICAL_ADDRESS_WIDTH-1
                                                   downto
                                                   (VIRTUAL_ADDRESS_WIDTH - DATA_SCALE_TWO_POWER));
],[dnl -- Declarations --------------------------------------------------------
dma_controller_component_
],[dnl -- Body ----------------------------------------------------------------

  sizer : memory_sizer
    generic map (
      VIRTUAL_ADDRESS_WIDTH  => VIRTUAL_ADDRESS_WIDTH,
      VIRTUAL_DATA_WIDTH     => VIRTUAL_ADDRESS_WIDTH,
      PHYSICAL_ADDRESS_WIDTH => PHYSICAL_ADDRESS_WIDTH,
      DATA_SCALE_TWO_POWER   => 1,
      PHYSICAL_DATA_WIDTH    => PHYSICAL_DATA_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i            => wb_clk_i,
      wb_rst_i            => wb_rst_i,
      -- Slave interface to client of virtual memory
      wbs_cyc_i           => mem_wbm_cyc_o,
      wbs_stb_i           => mem_wbm_stb_o,
      wbs_we_i            => mem_wbm_we_o,
      wbs_adr_i           => mem_wbm_adr_o,
      wbs_dat_i           => mem_wbm_dat_o,
      wbs_dat_o           => mem_wbm_dat_i,
      wbs_ack_o           => mem_wbm_ack_i,
      burst_in            => mem_burst,
      burst_addr_out      => mem_addr_in,
      -- Master interface to physical memory
      wbm_cyc_o           => sram_wb_cyc,
      wbm_gnt_i           => sram_wb_cyc,
      wbm_stb_o           => sram_wb_stb,
      wbm_we_o            => sram_wb_we,
      wbm_adr_o           => sram_wb_adr,
      wbm_dat_o           => sram_wb_dat_o,
      wbm_dat_i           => sram_wb_dat_i,
      wbm_ack_i           => sram_wb_ack,
      burst_out           => sram_burst,
      burst_addr_in       => sram_addr_out,
      phy_start_addr      => phy_start_prefix
    );

  storage : memory_controller
    generic map (
      ADDRESS_WIDTH       => PHYSICAL_ADDRESS_WIDTH,
      DATA_WIDTH          => PHYSICAL_DATA_WIDTH,
      READ_PIPELINE_DELAY => 1
      )
    port map (
      wb_clk_i      => wb_clk_i,
      wb_cyc_i      => sram_wb_cyc,
      wb_stb_i      => sram_wb_stb,
      wb_we_i       => sram_wb_we,
      wb_adr_i      => sram_wb_adr,
      wb_dat_i      => sram_wb_dat_o,
      wb_dat_o      => sram_wb_dat_i,
      wb_ack_o      => sram_wb_ack,
      burst_in      => sram_burst,
      addr_out      => sram_addr_out
      );

  dma : dma_controller
    generic map (
      DATA_WIDTH          => DATA_WIDTH,
      ADDRESS_WIDTH       => VIRTUAL_ADDRESS_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i            => wb_clk_i,
      wb_rst_i            => wb_rst_i,
      -- Wishbone master interface to ip_transmit
      xmit_wbm_cyc_o      => xmit_wbm_cyc_o,
      xmit_wbm_stb_o      => xmit_wbm_stb_o,
      xmit_wbm_dat_o      => xmit_wbm_dat_o,
      xmit_wbm_ack_i      => xmit_wbm_ack_i,
      -- Wishbone slave interface from ip_receive
      recv_wbs_cyc_i      => recv_wbs_cyc_i,
      recv_wbs_stb_i      => recv_wbs_stb_i,
      recv_wbs_dat_i      => recv_wbs_dat_i,
      recv_wbs_ack_o      => recv_wbs_ack_o,
      -- Memory outputs to SRAM or sizer
      mem_wbm_cyc_o       => mem_wbm_cyc_o,
      mem_wbm_stb_o       => mem_wbm_stb_o,
      mem_wbm_we_o        => mem_wbm_we_o,
      mem_wbm_adr_o       => mem_wbm_adr_o,
      mem_wbm_dat_i       => mem_wbm_dat_i,
      mem_wbm_dat_o       => mem_wbm_dat_o,
      mem_wbm_ack_i       => mem_wbm_ack_i,
      mem_burst           => mem_burst,
      mem_addr_in         => mem_addr_in,
      -- b/c the memory isn't a master by itself
      xmit_wbs_stb_i      => xmit_wbs_stb_i,
      xmit_wbs_ack_o      => xmit_wbs_ack_o,
      xmit_length_in      => xmit_length_in,
      xmit_length_out     => xmit_length_out,
      recv_wbm_stb_o      => recv_wbm_stb_o,
      recv_wbm_ack_i      => recv_wbm_ack_i,
      recv_length_in      => recv_length_in,
      recv_length_out     => recv_length_out,
      xmit_buffer_start_addr => xmit_buffer_start_addr,
      recv_buffer_start_addr => recv_buffer_start_addr
      );

])
