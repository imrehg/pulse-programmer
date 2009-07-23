dnl-*-VHDL-*-
-- Test connecting application-layer PTP with router.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([ptp_top_test], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.ptp.all;
],[dnl -- Generics ------------------------------------------------------------
data_generic_
  ADDRESS_WIDTH : positive := 10;
  STABLE_COUNT  : positive := 1;
  ABORT_TIMEOUT : positive := 10;
ptp_top_test_generics_
],[dnl -- Ports ---------------------------------------------------------------
   common_test_ports_
   ptp_top_test_ports_
   ptp_top_sram_test_ports_
   ptp_router_test_ports_
   ptp_router_dma_test_ports_
   ptp_router_daisy_test_ports_
   ptp_debug_led_test_ports_
],[dnl -- Declarations --------------------------------------------------------
ptp_top_router_signals_
dnl pcp_memory_signals_
  constant self_mac_addr : mac_address := SELF_MAC_ADDRESS;

ptp_top_component_
ptp_router_component_
],[dnl -- Body ----------------------------------------------------------------
ptp_top_instance_
ptp_router_instance_

])
