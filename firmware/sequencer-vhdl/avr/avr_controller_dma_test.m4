dnl-*-VHDL-*-
-- DMA test for AVR controller.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([avr_controller_dma_test], dnl
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
   ptp_router_daisy_test_ports_
   ptp_debug_led_test_ports_
   ptp_top_status_test_ports_
   avr_controller_test_ports_
   network_common_test_ports_
   ptp_router_test_ports_
   tcp_test_ports_
   instruction_out : out std_logic_vector(15 downto 0);
],[dnl -- Declarations --------------------------------------------------------
  constant NETWORK_ICMP_ENABLE : boolean := false;
  constant PTP_I2C_ENABLE      : boolean := false;
  constant PTP_TRIGGER_ENABLE  : boolean := false;
   
avr_sram_signals_
avr_port_signals_
avr_controller_component_

tcp_dma_control_signals_
tcp_dma_memory_signals_
pcp_memory_signals_
  signal pcp_fifo_busy    : std_logic;

ptp_top_signals_
ptp_top_sram_signals_
ptp_top_start_signals_
ptp_top_debug_signals_
ptp_top_router_signals_
ptp_dma_router_signals_
ptp_dma_memory_signals_
ptp_dma_control_signals_

ptp_avr_interface_component_
ptp_top_component_
ptp_router_component_

tcp_avr_interface_component_

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

ptp_top_instance_
ptp_router_instance_
ptp_dma_instance_
ptp_avr_interface_instance_

  ptp_triggers <= (others => '0');
  ptp_sram_wb_read_data <= pre_sizer8_wb_read_data;
  ptp_sram_addr         <= pre_sizer8_burst_addr;

tcp_avr_interface_instance_
tcp_dma_instance_

--   instruction_out(15 downto 13) <= pre_sizer8_addr_prefix;
--   instruction_out(12 downto 0) <= post_sizer8_wb_adr(15 downto 3);
--  instruction_out(7 downto 0) <= avr_port_d_out;
--  instruction_out(15 downto 8) <= avr_port_d_in;
   
  storage : memory_controller
    generic map (
      ADDRESS_WIDTH => PHYSICAL_ADDRESS_WIDTH,
      DATA_WIDTH    => PHYSICAL_DATA_WIDTH
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
])
