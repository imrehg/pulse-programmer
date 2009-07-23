dnl-*-VHDL-*-
-- Timing test of AVR controller.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([avr_controller_timing_test], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.ptp.all;
],[dnl -- Generics ------------------------------------------------------------
data_generic_
  PHYSICAL_ADDRESS_WIDTH : positive := 17;
  PHYSICAL_DATA_WIDTH : positive := 32;
ptp_top_test_generics_
],[dnl -- Ports ---------------------------------------------------------------
   common_test_ports_
dnl   ptp_top_sram_test_ports_([slave])
   avr_controller_test_ports_
dnl   avr_ports_test_ports_
   sram_test_ports_
dnl   instruction_out : out std_logic_vector(15 downto 0);
],[dnl -- Declarations --------------------------------------------------------
avr_common_signals_
avr_controller_component_
avr_sram_signals_
avr_port_signals_
   
tcp_dma_signals_
udp_signals_
ptp_dma_memory_signals_
ptp_top_sram_signals_
 
sram_arbiter_signals_
sram_sizer_signals_(8, 8)
sram_sizer_signals_(16, 16)
sram_sizer8_arbiter_signals_
dnl sram_controller_signals_
],[dnl -- Body ----------------------------------------------------------------

avr_controller_instance_
sram_sizer8_arbiter_instance_
sram_sizer_instance_(8, 8, 2)
sram_sizer_instance_(16, 16, 1)
sram_arbiter_instance_

   ptp_dma_sram_wb_cyc <= '0';
   tcp_sram_wb_cyc <= '0';
   avr_reset <= avr_reset_in;
    ptp_sram_wb_read_data <= pre_sizer8_wb_read_data;
    ptp_sram_addr      <= pre_sizer8_burst_addr;
--   avr_dmem_wb_read_data <= pre_sizer8_wb_read_data;
])
