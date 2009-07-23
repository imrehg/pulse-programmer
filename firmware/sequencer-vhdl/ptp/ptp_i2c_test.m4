dnl-*-VHDL-*-
-- Test for ptp_i2c module connected to i2c_controller.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([ptp_i2c_test], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.ptp.all;
],[dnl -- Generics ------------------------------------------------------------
data_generic_
ptp_top_test_generics_
],[dnl -- Ports ---------------------------------------------------------------
   common_test_ports_
      ptp_self_id            : buffer ptp_id_type;
ptp_top_i2c_test_ports_([connected])
ptp_top_status_test_ports_
ptp_top_debug_test_ports_([connected])
ptp_top_start_test_ports_
ptp_top_trigger_test_ports_
   ptp_router_test_ports_
   ptp_router_daisy_test_ports_
   ptp_debug_led_test_ports_
   sequencer_i2c_ports_
],[dnl -- Declarations --------------------------------------------------------
ptp_top_sram_signals_
ptp_top_router_signals_
ptp_dma_router_signals_
ptp_dma_memory_signals_
ptp_dma_control_signals_
tcp_dma_control_signals_
tcp_dma_memory_signals_
pcp_dma_memory_signals_
dnl pcp_common_signals_
   
network_debug_led_signals_
dnl sram_arbiter_signals_
dnl sram_sizer_signals_(8, 8)
dnl sram_sizer8_arbiter_signals_
dnl sram_controller_signals_
dnl avr_sram_signals_
i2c_signals_
boot_led_signals_
signal sequencer_debug_led : byte;
signal debug_led_select    : byte;

ptp_top_component_
ptp_router_component_
],[dnl -- Body ----------------------------------------------------------------
ptp_top_instance_
ptp_router_instance_
dnl ptp_dma_instance_
i2c_instances_
  boot_led_wb_cyc <= '0';
  ptp_dma_recv_sram_wb_stb <= '0';
])
