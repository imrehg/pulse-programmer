dnl-*-VHDL-*-
-- Test of PCP controller connected to memory, PTP, and DMA
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([pcp_controller_test], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.ptp.all;
library pcplib;
use pcplib.instructions.all;
],[dnl -- Generics ------------------------------------------------------------
data_generic_
   SRAM_ADDRESS_WIDTH : positive := PCP0_ADDRESS_WIDTH;
   SRAM_DATA_WIDTH : positive := PCP0_DATA_WIDTH;
ptp_top_test_generics_
],[dnl -- Ports ---------------------------------------------------------------
   common_test_ports_
   ptp_router_test_ports_
   sequencer_clock_ports_
   sequencer_switch_ports_
   sequencer_lvds_ports_
   ptp_router_daisy_test_ports_
   ptp_debug_led_test_ports_
   sram_sizer_test_ports_(8, 8)
   sram_sizer_test_ports_(64, 8)
],[dnl -- Declarations --------------------------------------------------------
ptp_top_signals_
ptp_top_status_signals_
ptp_top_debug_signals_
ptp_top_sram_signals_
ptp_top_router_signals_
dnl ptp_router_signals_
ptp_dma_router_signals_
ptp_dma_memory_signals_
ptp_dma_control_signals_
tcp_dma_memory_signals_
tcp_dma_control_signals_
dnl network_udp_signals_
avr_common_signals_
avr_sram_signals_
clock_scaler_signals_
network_common_signals_
pcp_common_signals_
pcp_dma_memory_signals_
pcp_dma_control_signals_
signal nswitch             : byte;

dnl pcp_memory_signals_

sram_arbiter_signals_
sram_sizer8_arbiter_signals_
sram_controller_signals_

ptp_top_component_
ptp_router_component_
pcp_controller_component_
],[dnl -- Body ----------------------------------------------------------------

pcp_instances_
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

   ptp_chain_terminator <= true;
   network_detected <= '1';
   post_sizer8_wb_gnt  <= '1';
   post_sizer8_wb_gnt <= '1';
   tcp_sram_wb_cyc <= '0';
   ptp_dma_xmit_sram_wb_stb <= '0';
   ptp_dma_recv_sram_wb_stb <= '0';
--   avr_dmem_wb_read_data <= pre_sizer8_wb_read_data;

])
