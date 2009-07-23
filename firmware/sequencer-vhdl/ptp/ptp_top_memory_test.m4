dnl-*-VHDL-*-
-- Test of PTP application layer connected to memory.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([ptp_top_memory_test], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.ptp.all;
],[dnl -- Generics ------------------------------------------------------------
data_generic_
   SRAM_ADDRESS_WIDTH : positive := 17;
   SRAM_DATA_WIDTH : positive := 16;
ptp_top_test_generics_
],[dnl -- Ports ---------------------------------------------------------------
   common_test_ports_
   ptp_top_test_ports_
   ptp_router_daisy_test_ports_
   ptp_debug_led_test_ports_
   ptp_dma_control_test_ports_
   avr_dmem_test_ports_
   sram_sizer_test_ports_(8, 8)
],[dnl -- Declarations --------------------------------------------------------
ptp_top_sram_signals_
ptp_top_router_signals_
ptp_router_signals_
ptp_dma_router_signals_
ptp_dma_memory_signals_
pcp_dma_memory_signals_
tcp_dma_memory_signals_
tcp_dma_control_signals_
network_udp_signals_
dnl pcp_common_signals_
   
sram_arbiter_signals_
sram_sizer8_arbiter_signals_
sram_controller_signals_

ptp_top_component_
ptp_router_component_

],[dnl -- Body ----------------------------------------------------------------

ptp_top_instance_
ptp_router_instance_
ptp_dma_instance_
sram_sizer8_arbiter_instance_
sram_sizer_instance_(8, 8, 1)
   
  storage : memory_controller
    generic map (
      ADDRESS_WIDTH       => SRAM_ADDRESS_WIDTH,
      DATA_WIDTH          => SRAM_DATA_WIDTH,
      READ_PIPELINE_DELAY => 1
      )
    port map (
      wb_clk_i      => network_clock,
      wb_cyc_i      => post_sizer8_wb_cyc,
      wb_stb_i      => post_sizer8_wb_stb,
      wb_we_i       => post_sizer8_wb_we,
      wb_adr_i      => post_sizer8_wb_adr(SRAM_ADDRESS_WIDTH-1 downto 0),
      wb_dat_i      => post_sizer8_wb_write_data(SRAM_DATA_WIDTH-1 downto 0),
      wb_dat_o      => sram_wb_read_data(SRAM_DATA_WIDTH-1 downto 0),
      wb_ack_o      => post_sizer8_wb_ack,
      burst_in      => post_sizer8_burst,
      addr_out      => sram_addr_out(SRAM_ADDRESS_WIDTH-1 downto 0)
      );

   ptp_udp_recv_wb_cyc <= '0';
   post_sizer8_wb_gnt <= '1';
   tcp_sram_wb_cyc <= '0';
   pcp_dma_sram_wb_cyc <= '0';
   avr_dmem_wb_read_data <= pre_sizer8_wb_read_data;

])
