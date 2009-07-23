dnl-*-VHDL-*-
-- Memory test of AVR controller.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([avr_controller_memory_test], dnl
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
   ptp_top_sram_test_ports_([slave])
   avr_controller_test_ports_
   avr_ports_test_ports_
   instruction_out : out std_logic_vector(15 downto 0);
],[dnl -- Declarations --------------------------------------------------------
avr_common_signals_
avr_controller_component_
avr_sram_signals_
   
tcp_dma_memory_signals_
tcp_dma_control_signals_
network_udp_signals_
ptp_dma_memory_signals_
pcp_dma_memory_signals_
pcp_dma_control_signals_
   
sram_arbiter_signals_
sram_sizer_signals_(8, 8)
sram_sizer_signals_(16, 16)
sram_sizer8_arbiter_signals_
sram_controller_signals_
],[dnl -- Body ----------------------------------------------------------------

avr_controller_instance_
sram_sizer8_arbiter_instance_
sram_sizer_instance_(8, 8, 2)
sram_sizer_instance_(16, 16, 1)
sram_arbiter_instance_

   instruction_out <= pre_sizer16_wb_read_data;
   
  storage : memory_controller
    generic map (
      ADDRESS_WIDTH       => PHYSICAL_ADDRESS_WIDTH,
      DATA_WIDTH          => PHYSICAL_DATA_WIDTH,
      READ_PIPELINE_DELAY => 2
      )
    port map (
      wb_clk_i      => network_clock,
      wb_cyc_i      => sram_wb_cyc,
      wb_stb_i      => sram_wb_stb,
      wb_we_i       => sram_wb_we,
      wb_adr_i      => sram_wb_adr(PHYSICAL_ADDRESS_WIDTH-1 downto 0),
      wb_dat_i      => sram_wb_write_data(PHYSICAL_DATA_WIDTH-1 downto 0),
      wb_dat_o      => sram_wb_read_data(PHYSICAL_DATA_WIDTH-1 downto 0),
      wb_ack_o      => sram_wb_ack,
      burst_in      => sram_burst,
      addr_out      => sram_addr_out(PHYSICAL_ADDRESS_WIDTH-1 downto 0)
      );

   ptp_dma_sram_wb_cyc <= '0';
   tcp_sram_wb_cyc <= '0';
   avr_reset <= avr_reset_in;
    ptp_sram_wb_read_data <= pre_sizer8_wb_read_data;
    ptp_sram_addr      <= pre_sizer8_burst_addr;
--   avr_dmem_wb_read_data <= pre_sizer8_wb_read_data;
])
