divert(-1)dnl
# Macros containing testing ports
# -----------------------------------------------------------------------------
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
# -----------------------------------------------------------------------------

###############################################################################
# Test generics to override the ones in seqlib.m4
define([ptp_top_test_generics_], [dnl
  AVR_ENABLE                    : boolean                  := true;
  FIRMWARE_MAJOR_VERSION_NUMBER : std_logic_vector(0 to 7) := X"00";
  FIRMWARE_MINOR_VERSION_NUMBER : std_logic_vector(0 to 7) := X"01";
])
                            
###############################################################################
define([ptp_top_test_ports_], [dnl
      ptp_self_id            : buffer ptp_id_type;
ptp_top_i2c_test_ports_
ptp_top_status_test_ports_
ptp_top_debug_test_ports_
ptp_top_start_test_ports_
ptp_top_trigger_test_ports_
])

# $1 = [connected] if read_data and ack should be read-only outputs
define([ptp_top_i2c_test_ports_], [dnl
ifelse([$1], [connected], [define([direction_], [buffer])], [define([direction_], [in])])
      -- I2C ports
      ptp_i2c_wb_cyc         : buffer std_logic;
      ptp_i2c_wb_stb         : buffer std_logic;
      ptp_i2c_wb_we          : buffer std_logic;
      ptp_i2c_wb_adr         : buffer i2c_slave_address_type;
      ptp_i2c_wb_write_data  : buffer byte;
      ptp_i2c_wb_read_data   : direction_ byte;
      ptp_i2c_wb_ack         : direction_ std_logic;
])

define([ptp_top_status_test_ports_], [dnl
      -- Status ports
      clock_scale_quantum    : in     clock_scale_quantum_type;
      network_detected       : in     std_logic;
      ptp_chain_initiator    : buffer boolean;
      ptp_chain_terminator   : in     boolean;
      pcp_halted             : in     std_logic;
])

# $1 = ack connected (read-only out) or unconnected (input)
define([ptp_top_debug_test_ports_], [dnl
ifelse([$1], [connected], [define([direction_], [buffer])], [define([direction_], [in])])
      -- Debug ports
      debug_led_wb_cyc       : buffer    std_logic;
      debug_led_wb_stb       : buffer    std_logic;
      debug_led_wb_dat       : buffer    byte;
      debug_led_wb_ack       : direction_     std_logic;
])

define([ptp_top_start_test_ports_], [dnl
      -- Start ports
      avr_reset              : buffer std_logic;
      pcp_reset              : buffer std_logic;
      pcp_start_addr         : buffer sram_address_type;
])

define([ptp_top_trigger_test_ports_], [dnl
      -- Trigger ports
      ptp_triggers             : in     trigger_source_type;
      pcp_fifo_busy            : in     std_logic;
])

###############################################################################
# $1 = master or slave
define([ptp_top_sram_test_ports_], [dnl
ifelse([$1], [slave], [define([direction1_], [in])], [define([direction1_], [out])])
ifelse([$1], [slave], [define([direction2_], [out])], [define([direction2_], [in])])
  -- Memory ports
  ptp_sram_wb_cyc        : direction1_ std_logic;
  ptp_sram_wb_stb        : direction1_ std_logic;
  ptp_sram_wb_we         : direction1_ std_logic;
  ptp_sram_wb_adr        : direction1_ virtual8_address_type;
  ptp_sram_wb_write_data : direction1_ byte;
  ptp_sram_wb_read_data  : direction2_ byte;
  ptp_sram_wb_ack        : direction2_ std_logic;
  ptp_sram_burst         : direction1_ std_logic;
])

###############################################################################
define([common_test_ports_], [dnl
      network_clock          : in  std_logic;
      wb_rst_i               : in  std_logic;
])

###############################################################################
define([avr_controller_test_ports_], [dnl
      avr_reset_in           : in  std_logic;
      ether_rx_clk           : in  std_logic;
])

###############################################################################
define([avr_ports_test_ports_], [dnl
  avr_port_a_in  : in  byte;
  avr_port_b_in  : in  byte;
  avr_port_c_in  : in  byte;
  avr_port_d_in  : in  byte;
  avr_port_e_in  : in  byte;
  avr_port_f_in  : in  byte;
  avr_port_a_out : out byte;
  avr_port_b_out : out byte;
  avr_port_c_out : out byte;
  avr_port_d_out : out byte;
  avr_port_e_out : out byte;
  avr_port_f_out : out byte;
])

###############################################################################
define([avr_dmem_test_ports_], [dnl
  -- Data memory interface to SRAM sizer arbiter
  avr_dmem_wb_cyc            : in  std_logic;
  avr_dmem_wb_stb            : in  std_logic;
  avr_dmem_wb_we             : in  std_logic;
  avr_dmem_wb_adr            : in  virtual_address_type;
  avr_dmem_wb_write_data     : in  virtual_data_type;
  avr_dmem_wb_read_data      : out virtual_data_type;
  avr_dmem_wb_ack            : out std_logic;
])

###############################################################################
define([ptp_dma_control_test_ports_], [dnl
  ptp_dma_xmit_sram_wb_stb       : in     std_logic;
  ptp_dma_xmit_sram_wb_ack       : out    std_logic;
  ptp_dma_xmit_sram_length       : in     ptp_length_type;
  ptp_dma_xmit_length            : out    ptp_length_type;
  ptp_dma_recv_sram_wb_stb       : out    std_logic;
  ptp_dma_recv_sram_wb_ack       : in     std_logic;
  ptp_dma_recv_sram_length       : buffer ptp_length_type;
  ptp_dma_recv_length            : buffer ptp_length_type;
  ptp_dma_xmit_sram_buffer_start : in     virtual_address_type;
  ptp_dma_recv_sram_buffer_start : in     virtual_address_type;
])

###############################################################################
define([ptp_router_test_ports_], [dnl
  -- UDP interface
  ptp_udp_xmit_wb_cyc            : out    std_logic;
  ptp_udp_xmit_wb_stb            : out    std_logic;
  ptp_udp_xmit_wb_dat            : out    std_logic_vector(0 to 7);
  ptp_udp_xmit_wb_ack            : in     std_logic;
  ptp_udp_xmit_dest_ip_addr      : out    ip_address;
  ptp_udp_xmit_src_port          : out    udp_port_type;
  ptp_udp_xmit_dest_port         : out    udp_port_type;
  ptp_udp_xmit_length            : buffer udp_length_type;
  ptp_udp_xmit_dont_fragment     : out    std_logic;
  -- Receive Wishbone slave interface from UDP
  ptp_udp_recv_wb_cyc            : in     std_logic;
  udp_recv_wb_stb                : in     std_logic;
  udp_recv_wb_dat                : in     std_logic_vector(0 to 7);
  ptp_udp_recv_wb_ack            : out    std_logic;
  ptp_server_port                : in     udp_port_type;
  udp_recv_src_ip_addr           : in     ip_address;
  udp_recv_src_port              : in     udp_port_type;
  udp_recv_dest_port             : in     udp_port_type;
  udp_recv_length                : in     udp_length_type;
])

###############################################################################
define([ptp_debug_led_test_ports_], [dnl
  -- Debugging LED outputs
  ptp_link_master_xmit_debug_led  : buffer byte;
  ptp_link_master_recv_debug_led  : buffer byte;
  ptp_link_slave_xmit_debug_led   : buffer byte;
  ptp_link_slave_recv_debug_led   : buffer byte;
  ptp_link_state_debug_led        : buffer byte;
  ptp_link_recv_arbiter_debug_led : buffer byte;
  ptp_link_debug_led              : buffer byte;
  ptp_route_recv_debug_led        : buffer byte;
  ptp_route_xmit_debug_led        : buffer byte;
  ptp_route_debug_led             : buffer byte;
  ptp_route_buffer_debug_led      : buffer byte;
  ptp_debug_led                   : buffer byte;
  ptp_top_debug_led               : buffer byte;
])

###############################################################################
define([ptp_router_daisy_test_ports_], [dnl
      -- Physical daisy chain pins to master
      daisy_transmit                  : out nibble;
      daisy_receive                   : in  nibble;
])

###############################################################################
define([ptp_router_dma_test_ports_], [dnl
      -- Receive slave interface from AVR
      ptp_dma_xmit_wb_cyc             : in  std_logic;
      ptp_dma_xmit_wb_stb             : in  std_logic;
      ptp_dma_xmit_wb_dat             : in  std_logic_vector(DATA_WIDTH-1
                                                              downto 0);
      ptp_dma_xmit_wb_ack             : out std_logic;
      -- Transmit master inteface from AVR
      ptp_dma_recv_wb_cyc             : out std_logic;
      ptp_dma_recv_wb_stb             : out std_logic;
      ptp_dma_recv_wb_dat             : out std_logic_vector(DATA_WIDTH-1
                                                             downto 0);
      ptp_dma_recv_wb_ack             : in  std_logic;
])

###############################################################################
define([network_common_test_ports_], [dnl
  self_ip_addr           : in  ip_address;
])

###############################################################################
define([tcp_test_ports_], [dnl
  -- TCP receive signals
  tcp_recv_wb_cyc        : in  std_logic;
  tcp_recv_wb_stb        : in  std_logic;
  tcp_recv_wb_dat        : in  std_logic_vector(0 to NETWORK_DATA_WIDTH-1);
  tcp_recv_wb_ack        : out std_logic;
  tcp_recv_src_ip_addr   : in  ip_address;
  tcp_recv_length        : in  ip_total_length;

  -- TCP transmit signals
  tcp_xmit_wb_cyc        : out std_logic;
  tcp_xmit_wb_stb        : out std_logic;
  tcp_xmit_wb_dat        : out std_logic_vector(0 to NETWORK_DATA_WIDTH-1);
  tcp_xmit_wb_ack        : in  std_logic;
  tcp_xmit_dont_fragment : out std_logic;
  tcp_xmit_length        : buffer ip_total_length;
  tcp_xmit_dest_ip_addr  : out ip_address;
])

###############################################################################
define([tcp_dma_control_test_ports_], [dnl
  tcp_xmit_sram_wb_stb       : in  std_logic;
  tcp_xmit_sram_wb_ack       : buffer std_logic;
  tcp_recv_sram_wb_stb       : buffer std_logic;
  tcp_recv_sram_wb_ack       : in  std_logic;
  tcp_xmit_sram_length       : in  ip_total_length;
  tcp_recv_sram_length       : buffer ip_total_length;
  tcp_xmit_sram_buffer_start : in virtual_address_type;
  tcp_recv_sram_buffer_start : in virtual_address_type;
])

###############################################################################
define([sram_test_ports_], [dnl
  sram_wb_cyc        : out std_logic;
  sram_wb_stb        : out std_logic;
  sram_wb_we         : out std_logic;
  sram_wb_adr        : out std_logic_vector(SRAM_ADDRESS_WIDTH-1 downto 0);
  sram_wb_write_data : out std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
  sram_wb_read_data  : in std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
  sram_wb_ack        : in std_logic;
  sram_burst         : out std_logic;
  sram_addr_out      : in std_logic_vector(SRAM_ADDRESS_WIDTH-1 downto 0);
])

###############################################################################
define([ethernet_test_ports_], [dnl
    ether_rx_clk   : in    std_logic;
    ether_tx_clk   : in    std_logic;
    ether_rxd      : in    nibble;
    ether_txd      : out   nibble;
    ether_rx_dv    : in    std_logic;
    ether_tx_en    : out   std_logic;
])

###############################################################################
# $1 = name
# $2 = virtual width of sizer
define([sram_sizer_test_ports_], [dnl
  -- Mux signals from arbiter to the SRAM sizer
  -- Before the sizer from client of virtual address space
  pre_sizer$1_wb_cyc         : buffer std_logic;
  pre_sizer$1_wb_stb         : buffer std_logic;
  pre_sizer$1_wb_we          : buffer std_logic;
  pre_sizer$1_wb_adr         : buffer virtual$1_address_type;
  pre_sizer$1_wb_write_data  : buffer std_logic_vector(($2-1) downto 0);
  pre_sizer$1_wb_read_data   : buffer std_logic_vector(($2-1) downto 0);
  pre_sizer$1_wb_ack         : buffer std_logic;
  pre_sizer$1_burst          : buffer std_logic;
  pre_sizer$1_burst_addr     : buffer virtual$1_address_type;
  -- After the sizer itself a client of the physical address space
  post_sizer$1_wb_cyc        : buffer std_logic;
  post_sizer$1_wb_gnt        : buffer std_logic;
  post_sizer$1_wb_stb        : buffer std_logic;
  post_sizer$1_wb_we         : buffer std_logic;
  post_sizer$1_wb_adr        : buffer std_logic_vector(SRAM_ADDRESS_WIDTH-1
                                                       downto 0);
  post_sizer$1_wb_write_data : buffer std_logic_vector(SRAM_DATA_WIDTH-1
                                                       downto 0);
  post_sizer$1_wb_ack        : buffer std_logic;
  post_sizer$1_burst         : buffer std_logic;
])

# Renable output for processed file
divert(0)dnl