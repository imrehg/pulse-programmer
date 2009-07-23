divert(-1)dnl
# Macros for network modules
# -----------------------------------------------------------------------------
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
# -----------------------------------------------------------------------------

###############################################################################
# Byte count signals
#    $1 = upper range of byte count, starting at 0

define([byte_count_signals_], [dnl
  subtype  byte_count_type is natural range 0 to $1;
  constant COUNT_START       : byte_count_type := 0;
  signal   byte_count        : byte_count_type;
])

###############################################################################
# CRC32 checksum signals
define([crc32_signals_], [dnl
  signal checksum_enable      : std_logic;
  signal checksum_out         : crc32_checksum;
  signal checksum_reset       : std_logic;
])

###############################################################################
# CRC32 checksum instance
define([crc32_instance_], [dnl
  checksum : crc32
    port map (
      wb_clk_i   => phy_clock,
      wb_rst_i   => wb_rst_i or (not checksum_enable), 
      wb_stb_i   => checksum_enable,
      wb_dat_i   => nibble_in,
      wb_dat_o   => checksum_out
      );])

###############################################################################
# IP checksum signals

define([cksum_signals_], [dnl
  -- checksum signals
  signal checksum_enable        : std_logic;
  signal checksum_reset         : std_logic;
  signal checksum               : ip_checksum;
  signal checksum_word_in       : ip_checksum;
  signal checksum_toggle_enable : std_logic;
  signal checksum_word_toggle   : std_logic;
  signal checksum_word_ready    : std_logic;
])

define([network_transceiver_signals_], [dnl
  signal header_ack             : std_logic;
  signal data_ack               : std_logic;
])

###############################################################################
# IP checksum instance

define([cksum_instance_], [dnl
  cksum_generator : in_cksum
    port map (
      wb_clk_i => wb_clk_i,
      wb_rst_i => checksum_reset,
      wb_cyc_i => checksum_enable,
      wb_stb_i => checksum_word_ready,
      wb_dat_i => checksum_word_in,
      wb_dat_o => checksum
      );])

###############################################################################
# IP checksum word toggle
# Synchronous; include inside clock edge

define([cksum_toggle_], [dnl
      -- toggle the checksum word clock; will only be heeded when enabled
      -- we never insert wait states, so we can just depend on master strobe
      if (checksum_toggle_enable = '1') then
        if (checksum_word_toggle = '0') then
          checksum_word_toggle <= '1';
          checksum_word_ready  <= '1';
        else
          checksum_word_toggle <= '0';
        end if;
      end if;

      if (checksum_word_ready = '1') then
        checksum_word_ready    <= '0';
      end if;
])

###############################################################################
# IP checksum word toggle enable
# Asynchronous; include outside clock edge.

define([cksum_toggle_enable_], [dnl
    -- we never insert wait states, but we pass in our slave's acks
    if (wbm_cyc_o = '1' and data_ack = '1') then
      checksum_toggle_enable <= wbs_ack_o;
      -- to mask acks from going to a new master after the old one has
      -- released us early (we hold it late to report checksum errors)
      wbs_ack_o <= wbm_ack_i and data_ack;
    else
      checksum_toggle_enable <= checksum_enable and
                                (wbs_ack_o or (not wbs_cyc_i));
      -- we cannot tie ack to stb directly b/c it takes one cycle to
      -- jump from idle state to receive_header state.
      wbs_ack_o <= header_ack and wbs_stb_i;
    end if;
])

###############################################################################
# Transform macro for network header bytes
#   $1 = argument to transform

define([network_header_transform_], [dnl
              when COUNT_START+i =>
                $1
])

###############################################################################
# Top-level Ethernet Wishbone signals

define([ethernet_wb_signals_], [dnl
  -- Ethernet transmit Wishbone interface
  signal eth_xmit_wb_cyc : std_logic;
  signal eth_xmit_wb_stb : std_logic;
  signal eth_xmit_wb_ack : std_logic;
  signal eth_xmit_wb_dat : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal eth_xmit_type_length : ethernet_type_length;
  signal eth_xmit_dest_addr : mac_address;
  signal eth_xmit_total_length : ip_total_length;

  -- Ethernet receive Wishbone interface
  signal eth_recv_wb_cyc : std_logic;
  signal eth_recv_wb_stb : std_logic;
  signal eth_recv_wb_dat : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal eth_recv_wb_ack : std_logic;

  signal eth_recv_type_length : ethernet_type_length;
  signal eth_recv_error : std_logic;
])

###############################################################################
# Top-level Ethernet instance

define([ethernet_instance_], [dnl
  ethernet_mac : ethernet
    generic map (
      DATA_WIDTH    => DATA_WIDTH,
      ADDRESS_WIDTH => ETHERNET_BUFFER_ADDRESS_WIDTH
      )
    port map (
      -- Wishbone common interface
      wb_rst_i                => wb_rst_i,
      wb_clk_i                => wb_clk_i,
      self_mac_addr_in        => self_mac_addr,
      -- Ethernet transmit Wishbone slave interface
      ip_xmit_wb_cyc_i        => eth_xmit_wb_cyc,
      ip_xmit_wb_stb_i        => eth_xmit_wb_stb,
      ip_xmit_wb_ack_o        => eth_xmit_wb_ack,
      ip_xmit_wb_dat_i        => eth_xmit_wb_dat,
      ip_xmit_type_length_in  => eth_xmit_type_length,
      ip_xmit_dest_addr_in    => eth_xmit_dest_addr,
      ip_xmit_total_length_in => eth_xmit_total_length,
      xmit_debug_led_out      => eth_xmit_debug_led_out,
      -- Ethernet PHY interface
      eth_xmit_clock          => eth_xmit_clock,
      eth_xmit_data_out       => eth_xmit_data_out,
      eth_xmit_enable         => eth_xmit_enable,
      -- Ethernet receive Wishbone master interface
      ip_recv_wb_cyc_o        => eth_recv_wb_cyc,
      ip_recv_wb_stb_o        => eth_recv_wb_stb,
      ip_recv_wb_dat_o        => eth_recv_wb_dat,
      ip_recv_wb_ack_i        => eth_recv_wb_ack,
      ip_recv_type_length_out => eth_recv_type_length,
      ip_recv_error_out       => eth_recv_error,
      recv_debug_led_out      => eth_recv_debug_led_out,
      -- Ethernet PHY receive interface
      eth_recv_clock          => eth_recv_clock,
      eth_recv_data_in        => eth_recv_data_in,
      eth_recv_data_valid     => eth_recv_data_valid
      );
])

###############################################################################
# Top-level IP Wishbone signals

define([ip_wb_signals_], [dnl
  signal ip_xmit_wb_cyc        : std_logic;
  signal ip_xmit_wb_stb        : std_logic;
  signal ip_xmit_wb_dat        : std_logic_vector(0 to DATA_WIDTH-1);
  signal ip_xmit_wb_ack        : std_logic;
  signal ip_xmit_wb_err        : std_logic;
  signal ip_xmit_dest_ip_addr  : ip_address;
  signal ip_xmit_protocol      : ip_protocol;
  signal ip_xmit_id            : ip_id;
  signal ip_xmit_total_length  : ip_total_length;
  signal ip_xmit_dont_fragment : std_logic;

      -- Wishbone master interface for ip_receive to transport layer
  signal ip_recv_wb_cyc        : std_logic;
  signal ip_recv_wb_stb        : std_logic;
  signal ip_recv_wb_dat        : std_logic_vector(0 to DATA_WIDTH-1);
  signal ip_recv_wb_ack        : std_logic;
  signal ip_recv_src_ip_addr   : ip_address;
  signal ip_recv_dest_ip_addr  : ip_address;
  signal ip_recv_protocol      : ip_protocol;
  signal ip_recv_id            : ip_id;
  signal ip_recv_total_length  : ip_total_length;
])

###############################################################################
# Top-level IP instance

define([ip_instance_], [dnl
  ip_controller : ip
    generic map (
      DATA_WIDTH                => DATA_WIDTH,
      ARP_TABLE_DEPTH           => ARP_TABLE_DEPTH,
      ADDRESS_WIDTH             => IP_BUFFER_ADDRESS_WIDTH,
      BUFFER_COUNT_WIDTH        => IP_BUFFER_COUNT_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i                  => wb_clk_i,
      wb_rst_i                  => wb_rst_i,
      self_mac_addr             => self_mac_addr,
      self_ip_addr              => self_ip_addr,
      dhcp_status_load          => dhcp_status_load,
      gateway_ip_addr_in        => gateway_ip_addr_in,
      gateway_load_in           => gateway_load_in,
      recv_debug_led_out        => ip_recv_debug_led_out,
      trans_debug_led_out       => ip_trans_debug_led_out,
      xmit_debug_led_out        => ip_xmit_debug_led_out,
      arp_debug_led_out         => ip_arp_debug_led_out,
      arp_xmit_debug_led_out    => ip_arp_xmit_debug_led_out,
      arp_recv_debug_led_out    => ip_arp_recv_debug_led_out,
      eth_debug_led_out         => ip_eth_debug_led_out,
      ip_debug_led_out          => ip_debug_led_out,
      ip_buffer_debug_led_out   => ip_buffer_debug_led_out,
      -- Wishbone slave interface from transport layer to ip_transmit
      trans_xmit_wbs_cyc_i      => ip_xmit_wb_cyc,
      trans_xmit_wbs_stb_i      => ip_xmit_wb_stb,
      trans_xmit_wbs_dat_i      => ip_xmit_wb_dat,
      trans_xmit_wbs_ack_o      => ip_xmit_wb_ack,
      trans_xmit_wbs_err_o      => ip_xmit_wb_err,
      trans_xmit_dest_ip_addr   => ip_xmit_dest_ip_addr,
      trans_xmit_protocol       => ip_xmit_protocol,
      trans_xmit_id             => ip_xmit_id,
      trans_xmit_total_length   => ip_xmit_total_length,
      trans_xmit_dont_fragment  => ip_xmit_dont_fragment,
      -- Wishbone master interface for ip_receive to transport layer
      trans_recv_wbm_cyc_o      => ip_recv_wb_cyc,
      trans_recv_wbm_stb_o      => ip_recv_wb_stb,
      trans_recv_wbm_dat_o      => ip_recv_wb_dat,
      trans_recv_wbm_ack_i      => ip_recv_wb_ack,
      trans_recv_src_ip_addr    => ip_recv_src_ip_addr,
      trans_recv_dest_ip_addr   => ip_recv_dest_ip_addr,
      trans_recv_protocol       => ip_recv_protocol,
      trans_recv_id             => ip_recv_id,
      trans_recv_total_length   => ip_recv_total_length,
      -- Wishbone master interface to ethernet_transmit
      eth_xmit_wbm_cyc_o        => eth_xmit_wb_cyc,
      eth_xmit_wbm_stb_o        => eth_xmit_wb_stb,
      eth_xmit_wbm_dat_o        => eth_xmit_wb_dat,
      eth_xmit_wbm_ack_i        => eth_xmit_wb_ack,
      eth_xmit_dest_addr        => eth_xmit_dest_addr,
      eth_xmit_type_length      => eth_xmit_type_length,
      eth_xmit_total_length     => eth_xmit_total_length,
      -- Wishbone slave interface from ethernet_receive
      eth_recv_wbs_cyc_i        => eth_recv_wb_cyc,
      eth_recv_wbs_stb_i        => eth_recv_wb_stb,
      eth_recv_wbs_dat_i        => eth_recv_wb_dat,
      eth_recv_wbs_ack_o        => eth_recv_wb_ack,
      eth_recv_type_length      => eth_recv_type_length,
      eth_recv_error            => eth_recv_error
      );
])

###############################################################################
# ICMP signals

define([icmp_wb_signals_], [dnl
  signal icmp_xmit_wb_cyc        : std_logic;
  signal icmp_xmit_wb_stb        : std_logic;
  signal icmp_xmit_wb_dat        : std_logic_vector(0 to DATA_WIDTH-1);
  signal icmp_xmit_wb_ack        : std_logic;
  signal icmp_xmit_dest_ip_addr  : ip_address;
  signal icmp_xmit_protocol      : ip_protocol;
  signal icmp_xmit_id            : ip_id;
  signal icmp_xmit_total_length  : ip_total_length;
  signal icmp_xmit_dont_fragment : std_logic;
  signal icmp_recv_wb_cyc        : std_logic;
  signal icmp_recv_wb_ack        : std_logic;
])

###############################################################################
# Top-level ICMP instance

define([icmp_instance_], [dnl
  pinger : icmp
    generic map (
      DATA_WIDTH    => DATA_WIDTH,
      ADDRESS_WIDTH => ICMP_BUFFER_ADDRESS_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i            => wb_clk_i,
      wb_rst_i            => wb_rst_i,
      debug_led_out       => icmp_debug_led_out,
      -- Wishbone master interface (from icmp_transmit to to ip_transmit)
      xmit_wbm_cyc_o        => icmp_xmit_wb_cyc,
      xmit_wbm_stb_o        => icmp_xmit_wb_stb,
      xmit_wbm_dat_o        => icmp_xmit_wb_dat,
      xmit_wbm_ack_i        => icmp_xmit_wb_ack,
      xmit_dest_addr_out    => icmp_xmit_dest_ip_addr,
      xmit_protocol_out     => icmp_xmit_protocol,
      xmit_id_out           => icmp_xmit_id,
      xmit_total_length_out => icmp_xmit_total_length,
      xmit_dont_fragment    => icmp_xmit_dont_fragment,
      xmit_debug_led_out    => icmp_xmit_debug_led_out,
      -- Wishbone slave interface (from ip_receive to icmp_receive)
      recv_wbs_cyc_i        => ip_recv_wb_cyc,
      recv_wbs_stb_i        => ip_recv_wb_stb,
      recv_wbs_dat_i        => ip_recv_wb_dat,
      recv_wbs_ack_o        => icmp_recv_wb_ack,
      recv_protocol_in      => ip_recv_protocol,
      recv_src_addr_in      => ip_recv_src_ip_addr,
      recv_dest_addr_in     => ip_recv_dest_ip_addr,
      recv_id_in            => ip_recv_id,
      recv_total_length_in  => ip_recv_total_length,
      recv_debug_led_out    => icmp_recv_debug_led_out
      );
])

###############################################################################
# UDP receiver signals

define([udp_recv_signals_], [dnl
  signal udp_recv_wb_cyc         : std_logic;
  signal udp_recv_wb_ack         : std_logic;
])

###############################################################################
# UDP receiver instance

define([udp_receive_instance_], [dnl
  udp_receiver : udp_receive
    generic map (
      DATA_WIDTH          => DATA_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i            => wb_clk_i,
      wb_rst_i            => wb_rst_i,
      -- Wishbone master signals
      wbm_cyc_o           => udp_recv_wbm_cyc_o,
      wbm_stb_o           => udp_recv_wbm_stb_o,
      wbm_dat_o           => udp_recv_wbm_dat_o,
      wbm_ack_i           => udp_recv_wbm_ack_i,
     -- checksum_error_out     
      -- Wishbone slave signals
      wbs_cyc_i           => udp_recv_wb_cyc,
      wbs_stb_i           => ip_recv_wb_stb,
      wbs_dat_i           => ip_recv_wb_dat,
      wbs_ack_o           => udp_recv_wb_ack,

      src_port_out        => udp_recv_src_port_out,
      dest_port_out       => udp_recv_dest_port_out,
      length_out          => udp_recv_length_out,
      src_ip_addr_in      => ip_recv_src_ip_addr,
      src_ip_addr_out     => udp_recv_src_ip_addr_out,
--      dest_ip_addr_in     => ip_recv_dest_ip_addr,
      debug_led_out       => udp_recv_debug_led_out
    );
])

###############################################################################
# UDP transmit signals

define([udp_xmit_signals_], [dnl
  signal udp_xmit_wb_cyc       : std_logic;
  signal udp_xmit_wb_stb       : std_logic;
  signal udp_xmit_wb_dat       : std_logic_vector(0 to DATA_WIDTH-1);
  signal udp_xmit_wb_ack       : std_logic;
  signal udp_xmit_id           : ip_id;
  signal udp_xmit_total_length : ip_total_length;
])

###############################################################################
# UDP transmitter instance

define([udp_transmit_instance_], [dnl
  udp_transmitter : udp_transmit
    generic map (
      DATA_WIDTH          => DATA_WIDTH,
      ADDRESS_WIDTH       => UDP_BUFFER_ADDRESS_WIDTH
    )
    port map (
      -- Wishbone common signals
      wb_clk_i            => wb_clk_i,
      wb_rst_i            => wb_rst_i,
      -- Wishbone master signals
      wbm_cyc_o           => udp_xmit_wb_cyc,
      wbm_stb_o           => udp_xmit_wb_stb,
      wbm_dat_o           => udp_xmit_wb_dat,
      wbm_ack_i           => udp_xmit_wb_ack,
      -- Wishbone slave signals
      wbs_cyc_i           => udp_xmit_wbs_cyc_i,
      wbs_stb_i           => udp_xmit_wbs_stb_i,
      wbs_dat_i           => udp_xmit_wbs_dat_i,
      wbs_ack_o           => udp_xmit_wbs_ack_o,
      -- Non-wishbone slave interface, synced to signals above
      src_port_in         => udp_xmit_src_port_in,
      dest_port_in        => udp_xmit_dest_port_in,
      length_in           => udp_xmit_length_in,
      src_ip_addr_in      => self_ip_addr,
      dest_ip_addr_in     => udp_xmit_dest_ip_addr_in,
      length_out          => udp_xmit_total_length,
      debug_led_out       => udp_xmit_debug_led_out
    );

  udp_xmit_id <= X"2222"; -- for simplicity, all datagrams have same id
--  udp_xmit_total_length <= udp_xmit_length_in + UDP_HEADER_BYTE_LENGTH;
])

###############################################################################
# Network signals

define([network_internal_signals_], [dnl
ethernet_wb_signals_
ip_wb_signals_
icmp_wb_signals_
udp_recv_signals_
udp_xmit_signals_
])

###############################################################################
# Network component declarations
define([network_component_declarations_], [dnl
ethernet_component_
ip_component_
icmp_component_
udp_receive_component_
udp_transmit_component_
])

###############################################################################
# Network component instances

define([network_component_instances_], [dnl
ethernet_instance_
ip_instance_

icmp_gen : if (ENABLE_ICMP) generate
icmp_instance_
end generate icmp_gen;

icmp_notgen : if (not ENABLE_ICMP) generate
  icmp_xmit_wb_cyc <= '0';
  icmp_xmit_wb_stb <= '0';
  icmp_recv_wb_ack <= ip_recv_wb_stb;
  icmp_xmit_wb_dat <= (others => '0');
  icmp_xmit_dest_ip_addr <= (others => '0');
  icmp_xmit_id <= (others => '0');
  icmp_xmit_total_length <= (others => '0');
end generate icmp_notgen;

udp_receive_instance_
udp_transmit_instance_
])

# Renable output for processed file
divert(0)dnl