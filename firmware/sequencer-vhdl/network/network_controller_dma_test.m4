dnl-*-VHDL-*-
-- DMA test for network controller.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([network_controller_dma_test], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.ptp.all;
library pcplib;
use pcplib.instructions.all;
],[dnl -- Generics ------------------------------------------------------------
data_generic_
  PHYSICAL_ADDRESS_WIDTH : positive := 17;
  PHYSICAL_DATA_WIDTH : positive := 32;
],[dnl -- Ports ---------------------------------------------------------------
   common_test_ports_
   network_common_test_ports_
   ptp_top_sram_test_ports_([slave])
   tcp_dma_control_test_ports_   
   ethernet_test_ports_
],[dnl -- Declarations --------------------------------------------------------
  constant NETWORK_ICMP_ENABLE : boolean := false;
  constant PTP_I2C_ENABLE      : boolean := false;
  constant PTP_TRIGGER_ENABLE  : boolean := false;
  constant AVR_ENABLE          : boolean := true;
   
avr_signals_
   
pcp_signals_
ptp_dma_memory_signals_

network_debug_led_signals_
network_udp_signals_
network_tcp_signals_
tcp_dma_memory_signals_
network_controller_component_
dhcp_signals_
boot_led_signals_
signal nswitch             : byte;

network_common_signals_

sram_arbiter_signals_
sram_sizer_signals_(8, 8)
sram_sizer_signals_(16, 16)
sram_sizer8_arbiter_signals_
sram_controller_signals_
],[dnl -- Body ----------------------------------------------------------------

sram_sizer8_arbiter_instance_
sram_sizer_instance_(8, 8, 2)
sram_sizer_instance_(16, 16, 1)
sram_arbiter_instance_

network_instance_
tcp_dma_instance_

  udp_recv_wb_cyc <= '0';
  ptp_dma_sram_wb_cyc <= '0';
  dhcp_status_load <= '1';

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
