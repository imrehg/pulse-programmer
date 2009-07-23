divert(-1)dnl
# Macros for network instances and signals to include in top-level sequencer.
# ---------------------------------------------------------------------------
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
# ---------------------------------------------------------------------------

###############################################################################
# Network clock divider signals

define([network_clock_signals_], [dnl
  signal network_clock : std_logic;
])

###############################################################################
# Ethernet PHY transmit ports

define([ethernet_phy_transmit_ports_], [dnl
    -- Ethernet PHY interface
    eth_xmit_clock           : in  std_logic;
    eth_xmit_data_out        : out nibble;
    eth_xmit_enable          : out std_logic;
])

###############################################################################
# Ethernet PHY receive ports

define([ethernet_phy_receive_ports_], [dnl
    -- Ethernet PHY receive interface
    eth_recv_clock           : in  std_logic;
    eth_recv_data_in         : in  nibble;
    eth_recv_data_valid      : in  std_logic;
])

###############################################################################
# External UDP receive slave ports

define([udp_recv_master_ports_], [dnl
  udp_recv_wbm_cyc_o       : out std_logic;
  udp_recv_wbm_stb_o       : out std_logic;
  udp_recv_wbm_dat_o       : out std_logic_vector(0 to DATA_WIDTH-1);
  udp_recv_wbm_ack_i       : in  std_logic;
  udp_recv_src_ip_addr_out : out ip_address;
  udp_recv_src_port_out    : out udp_port_type;
  udp_recv_dest_port_out   : out udp_port_type;
  udp_recv_length_out      : out udp_length_type;
  udp_recv_debug_led_out   : out byte;
])

###############################################################################
# External UDP transmit slave ports

define([udp_xmit_slave_ports_], [dnl
  udp_xmit_wbs_cyc_i        : in  std_logic;
  udp_xmit_wbs_stb_i        : in  std_logic;
  udp_xmit_wbs_dat_i        : in  std_logic_vector(0 to DATA_WIDTH-1);
  udp_xmit_wbs_ack_o        : out std_logic;
  udp_xmit_dont_fragment_in : in  std_logic;
  udp_xmit_src_port_in      : in  udp_port_type;
  udp_xmit_dest_port_in     : in  udp_port_type;
  udp_xmit_length_in        : in  udp_length_type;
  udp_xmit_dest_ip_addr_in  : in  ip_address;
  udp_xmit_debug_led_out    : out byte;
])

###############################################################################
# Debugging LED ports

define([debug_led_ports_], [dnl
   eth_xmit_debug_led_out    : out byte;
   eth_recv_debug_led_out    : out byte;
   ip_recv_debug_led_out     : out byte;
   ip_trans_debug_led_out    : out byte;
   ip_xmit_debug_led_out     : out byte;
   ip_arp_debug_led_out      : out byte;
   ip_arp_xmit_debug_led_out : out byte;
   ip_arp_recv_debug_led_out : out byte;
   ip_eth_debug_led_out      : out byte;
   ip_debug_led_out          : out byte;
   ip_buffer_debug_led_out   : out multibus_byte(0 to
                                                 2**IP_BUFFER_COUNT_WIDTH-1);
   icmp_debug_led_out        : out byte;
   icmp_xmit_debug_led_out   : out byte;
   icmp_recv_debug_led_out   : out byte;
   trans_xmit_debug_led_out  : out byte;
])

###############################################################################
# Top-level Network controller instance

define([network_instance_], [dnl
  network_top : network_controller
    generic map (
      DATA_WIDTH                    => NETWORK_DATA_WIDTH,
      ETHERNET_BUFFER_ADDRESS_WIDTH => ETHERNET_BUFFER_ADDRESS_WIDTH,
      ARP_TABLE_DEPTH               => ARP_TABLE_DEPTH,
      IP_BUFFER_COUNT_WIDTH         => IP_BUFFER_COUNT_WIDTH,
      IP_BUFFER_ADDRESS_WIDTH       => IP_BUFFER_ADDRESS_WIDTH,
      ICMP_BUFFER_ADDRESS_WIDTH     => ICMP_BUFFER_ADDRESS_WIDTH,
      UDP_BUFFER_ADDRESS_WIDTH      => UDP_BUFFER_ADDRESS_WIDTH,
      ENABLE_ICMP                   => NETWORK_ICMP_ENABLE
      )
    port map (
      -- Wishbone common interface
      wb_rst_i                  => wb_rst_i,
      wb_clk_i                  => network_clock,
      -- Debugging LED outputs
      eth_xmit_debug_led_out    => eth_xmit_debug_led,
      eth_recv_debug_led_out    => eth_recv_debug_led,
      ip_recv_debug_led_out     => ip_recv_debug_led,
      ip_trans_debug_led_out    => ip_trans_debug_led,
      ip_xmit_debug_led_out     => ip_xmit_debug_led,
      ip_arp_debug_led_out      => ip_arp_debug_led,
      ip_arp_xmit_debug_led_out => ip_arp_xmit_debug_led,
      ip_arp_recv_debug_led_out => ip_arp_recv_debug_led,
      ip_eth_debug_led_out      => ip_eth_debug_led,
      ip_debug_led_out          => ip_debug_led,
      trans_xmit_debug_led_out  => trans_xmit_debug_led,
      icmp_xmit_debug_led_out   => icmp_xmit_debug_led,
      icmp_recv_debug_led_out   => icmp_recv_debug_led,
      icmp_debug_led_out        => icmp_debug_led,
      udp_xmit_debug_led_out    => udp_xmit_debug_led,
      udp_recv_debug_led_out    => udp_recv_debug_led,
      -- Ethernet PHY interface
      eth_xmit_clock            => ether_tx_clk,
      eth_xmit_data_out         => ether_txd,
      eth_xmit_enable           => ether_tx_en,
      -- Ethernet PHY receive interface
      eth_recv_clock            => ether_rx_clk,
      eth_recv_data_in          => ether_rxd,
      eth_recv_data_valid       => ether_rx_dv,
      -- Self IP address
      self_mac_addr             => self_mac_addr,
      self_ip_addr              => self_ip_addr,
      dhcp_status_load          => dhcp_status_load,
      gateway_load_in           => dhcp_status_load,
      gateway_ip_addr_in        => gateway_ip_addr,
      -- UDP transmit interface
      udp_xmit_wbs_cyc_i        => udp_xmit_wb_cyc,
      udp_xmit_wbs_stb_i        => udp_xmit_wb_stb,
      udp_xmit_wbs_dat_i        => udp_xmit_wb_dat,
      udp_xmit_wbs_ack_o        => udp_xmit_wb_ack,
      udp_xmit_src_port_in      => udp_xmit_src_port,
      udp_xmit_dest_port_in     => udp_xmit_dest_port,
      udp_xmit_length_in        => udp_xmit_length,
      udp_xmit_dest_ip_addr_in  => udp_xmit_dest_ip_addr,
      udp_xmit_dont_fragment_in => udp_xmit_dont_fragment,
      -- UDP receive interface
      udp_recv_wbm_cyc_o        => udp_recv_wb_cyc,
      udp_recv_wbm_stb_o        => udp_recv_wb_stb,
      udp_recv_wbm_dat_o        => udp_recv_wb_dat,
      udp_recv_wbm_ack_i        => udp_recv_wb_ack,
      udp_recv_src_ip_addr_out  => udp_recv_src_ip_addr,
      udp_recv_src_port_out     => udp_recv_src_port,
      udp_recv_dest_port_out    => udp_recv_dest_port,
      udp_recv_length_out       => udp_recv_length
      );

  network_detector : process(wb_rst_i, network_clock)

    type detect_state_type is (
      idle,
      detected
      );

    variable state            : detect_state_type;
    variable stable_count     : natural range 0 to
                                        NETWORK_DETECT_STABLE_COUNT+1;

  begin

    if (wb_rst_i = '1') then
      network_detected <= '0';
      stable_count     := 0;
      state            := idle;

    elsif (rising_edge(network_clock)) then
      case (state) is
        when (idle) =>
          if (ether_rx_dv = '1') then
            if (stable_count >= NETWORK_DETECT_STABLE_COUNT-1) then
              network_detected <= '1';
              state := detected;
            else
              stable_count := stable_count + 1;
            end if;
          else
            stable_count := 0;
            if (dhcp_status_load = '1') then
              state := detected;
            end if;
          end if;
        when others =>
          -- detected; get stuck here
          null;
      end case;
    end if;

  end process;

])

###############################################################################
# Top-level DHCP signals

define([dhcp_signals_], [dnl
  -- DHCP transmit signals
  signal dhcp_xmit_wb_cyc       : std_logic;
  signal dhcp_xmit_wb_stb       : std_logic;
  signal dhcp_xmit_wb_dat       : std_logic_vector(0 to NETWORK_DATA_WIDTH-1);
  signal dhcp_xmit_wb_ack       : std_logic;
  signal dhcp_xmit_dest_ip_addr : ip_address;
  signal dhcp_xmit_src_port     : udp_port_type;
  signal dhcp_xmit_dest_port    : udp_port_type;
  signal dhcp_xmit_length       : udp_length_type;
  signal dhcp_xmit_dont_fragment : std_logic;
  signal dhcp_timed_out         : std_logic;
  signal dhcp_status_load       : std_logic;
  signal gateway_ip_addr        : ip_address;
  -- DHCP receive signals
  signal dhcp_recv_wb_cyc       : std_logic;
  signal dhcp_recv_wb_ack       : std_logic;
  signal mac_address_latched    : std_logic;
  signal dhcp_enable            : std_logic;
])

###############################################################################
# Top-level DHCP instance

define([dhcp_instance_], [dnl
dhcp_top : dhcp
  generic map (
    DATA_WIDTH          => NETWORK_DATA_WIDTH,
    RETRY_TIMEOUT       => DHCP_RETRY_TIMEOUT,
    MAX_RETRY_COUNT     => DHCP_MAX_RETRY_COUNT
    )
  port map (
    -- Wishbone common signals
    wb_clk_i             => network_clock,
    wb_rst_i             => wb_rst_i or (not mac_address_latched),
    enable_dynamic_addr_in => dhcp_enable,
    -- Transmit Wishbone master interface to UDP
   xmit_wbm_cyc_o        => dhcp_xmit_wb_cyc,
   xmit_wbm_stb_o        => dhcp_xmit_wb_stb,
   xmit_wbm_dat_o        => dhcp_xmit_wb_dat,
   xmit_wbm_ack_i        => dhcp_xmit_wb_ack,
   xmit_dest_ip_addr_out => dhcp_xmit_dest_ip_addr,
   xmit_src_port_out     => dhcp_xmit_src_port,
   xmit_dest_port_out    => dhcp_xmit_dest_port,
   xmit_length_out       => dhcp_xmit_length,
   xmit_dont_fragment_out => dhcp_xmit_dont_fragment,
   -- Receive Wishbone slave interface from UDP
   recv_wbs_cyc_i        => dhcp_recv_wb_cyc,
   recv_wbs_stb_i        => udp_recv_wb_stb,
   recv_wbs_dat_i        => udp_recv_wb_dat,
   recv_wbs_ack_o        => dhcp_recv_wb_ack,
--   recv_src_ip_addr_in   => udp_recv_src_ip_addr,
   recv_src_port_in      => udp_recv_src_port,
   recv_dest_port_in     => udp_recv_dest_port,
   recv_length_in        => udp_recv_length,
   -- Non-wishbone slave interface, synced to signals above
   self_mac_addr_in      => self_mac_addr,
   self_ip_addr_out      => self_ip_addr,
   timed_out             => dhcp_timed_out,
   status_load_out       => dhcp_status_load,
   gateway_ip_addr_out   => gateway_ip_addr,
   debug_led_out         => dhcp_debug_led
   );
])

###############################################################################
# UDP xmit arbiter signals

define([udp_xmit_arbiter_signals_], [dnl
  constant UDP_MASTER_COUNT : positive := 2;
  signal udp_xmit_arbiter_ack : multibus_bit(0 to UDP_MASTER_COUNT-1);
  signal udp_xmit_arbiter_gnt : multibus_bit(0 to UDP_MASTER_COUNT-1);
  -- One more master for the unknown master (separate from null master)
  signal udp_recv_arbiter_gnt : multibus_bit(0 to UDP_MASTER_COUNT);
])

###############################################################################
# UDP transmit arbiter

define([udp_xmit_arbiter_instance_], [dnl

  udp_xmit_arbiter : wb_intercon
    generic map (
      MASTER_COUNT => UDP_MASTER_COUNT
      )
    port map (
      wb_clk_i  => network_clock,
      wb_rst_i  => wb_rst_i,
      wbm_cyc_i => (dhcp_xmit_wb_cyc, ptp_udp_xmit_wb_cyc),
      wbm_stb_i => (dhcp_xmit_wb_stb, ptp_udp_xmit_wb_stb),
      wbm_dat_i => (dhcp_xmit_wb_dat, ptp_udp_xmit_wb_dat),
      wbm_ack_o => udp_xmit_arbiter_ack,
      wbm_gnt_o => udp_xmit_arbiter_gnt,
      wbs_cyc_o => udp_xmit_wb_cyc,
      wbs_stb_o => udp_xmit_wb_stb,
      wbs_dat_o => udp_xmit_wb_dat,
      wbs_ack_i => udp_xmit_wb_ack
      );

   dhcp_xmit_wb_ack    <= udp_xmit_arbiter_ack(0);
   ptp_udp_xmit_wb_ack <= udp_xmit_arbiter_ack(1);

   with udp_xmit_arbiter_gnt select
     udp_xmit_dest_ip_addr <=
     dhcp_xmit_dest_ip_addr when B"10",
     ptp_udp_xmit_dest_ip_addr  when B"01",
     (others => '0')        when others;
   with udp_xmit_arbiter_gnt select
     udp_xmit_src_port <=
     dhcp_xmit_src_port     when B"10",
     ptp_udp_xmit_src_port  when B"01",
     (others => '0')        when others;
   with udp_xmit_arbiter_gnt select
     udp_xmit_dest_port <=
     dhcp_xmit_dest_port    when B"10",
     ptp_udp_xmit_dest_port when B"01",
     (others => '0')        when others;
   with udp_xmit_arbiter_gnt select
     udp_xmit_length <=
     dhcp_xmit_length       when B"10",
     ptp_udp_xmit_length    when B"01",
     (others => '0')        when others;
   with udp_xmit_arbiter_gnt select
     udp_xmit_dont_fragment <=
     '1'                    when B"10",
     ptp_udp_xmit_dont_fragment when B"01",
     '0'                    when others;

   -- UDP receive arbiter
   process(wb_rst_i, network_clock, udp_recv_dest_port, udp_recv_wb_cyc,
           udp_recv_arbiter_gnt, udp_recv_wb_stb, udp_recv_wb_ack,
           dhcp_recv_wb_ack, ptp_udp_recv_wb_ack)

   begin
     if (wb_rst_i = '1') then
       udp_recv_arbiter_gnt <= B"000";
     elsif (rising_edge(network_clock)) then
       if (udp_recv_wb_cyc = '1') then
         if (udp_recv_dest_port = DHCP_CLIENT_PORT) then
           udp_recv_arbiter_gnt <= B"100";
         elsif (udp_recv_dest_port = ptp_server_port) then
           udp_recv_arbiter_gnt <= B"010";
         else
           udp_recv_arbiter_gnt <= B"001";
         end if;
       else
         udp_recv_arbiter_gnt <= B"000";
       end if;
     end if;

     dhcp_recv_wb_cyc <= udp_recv_wb_cyc and udp_recv_arbiter_gnt(0);
     ptp_udp_recv_wb_cyc  <= udp_recv_wb_cyc and udp_recv_arbiter_gnt(1);

     case (udp_recv_arbiter_gnt) is
       when B"100" =>
         udp_recv_wb_ack <= dhcp_recv_wb_ack;
       when B"010" =>
         udp_recv_wb_ack <= ptp_udp_recv_wb_ack;
       when B"001" =>
         udp_recv_wb_ack <= udp_recv_wb_stb;
       when others =>
         udp_recv_wb_ack <= '0';
     end case;

   end process;
])

###############################################################################
define([network_udp_signals_], [dnl
  -- UDP transmit signals
  signal udp_xmit_wb_cyc        : std_logic;
  signal udp_xmit_wb_stb        : std_logic;
  signal udp_xmit_wb_dat        : std_logic_vector(0 to NETWORK_DATA_WIDTH-1);
  signal udp_xmit_wb_ack        : std_logic;
  signal udp_xmit_src_port      : udp_port_type;
  signal udp_xmit_dest_port     : udp_port_type;
  signal udp_xmit_length        : udp_length_type;
  signal udp_xmit_dest_ip_addr  : ip_address;
  signal udp_xmit_dont_fragment : std_logic;
  -- UDP receive signals
  signal udp_recv_wb_cyc        : std_logic;
  signal udp_recv_wb_stb        : std_logic;
  signal udp_recv_wb_dat        : std_logic_vector(0 to NETWORK_DATA_WIDTH-1);
  signal udp_recv_wb_ack        : std_logic;
  signal udp_recv_src_ip_addr   : ip_address;
  signal udp_recv_src_port      : udp_port_type;
  signal udp_recv_dest_port     : udp_port_type;
  signal udp_recv_length        : udp_length_type;
])

###############################################################################
define([network_ip_signals_], [dnl
  signal self_ip_addr           : ip_address;
  signal self_mac_addr          : mac_address;
])

###############################################################################
define([network_debug_led_signals_], [dnl
  -- Debugging LED outputs
  signal eth_xmit_debug_led     : byte;
  signal eth_recv_debug_led     : byte;
  signal ip_recv_debug_led      : byte;
  signal ip_trans_debug_led     : byte;
  signal ip_xmit_debug_led      : byte;
  signal ip_arp_debug_led       : byte;
  signal ip_arp_xmit_debug_led  : byte;
  signal ip_arp_recv_debug_led  : byte;
  signal ip_eth_debug_led       : byte;
  signal ip_debug_led           : byte;
  signal trans_xmit_debug_led   : byte;
  signal udp_xmit_debug_led     : byte;
  signal udp_recv_debug_led     : byte;
  signal icmp_xmit_debug_led    : byte;
  signal icmp_recv_debug_led    : byte;
  signal icmp_debug_led         : byte;
  signal dhcp_debug_led         : byte;
])

define([network_common_signals_], [dnl
  signal network_detected       : std_logic;
])

define([mac_address_detector_], [dnl
  self_mac_addr(39 downto  0) <= SELF_MAC_ADDRESS(39 downto  0);
  self_mac_addr(47 downto 44) <= SELF_MAC_ADDRESS(47 downto 44);

  mac_address_detector : process(network_clock, wb_rst_i, mac_address_latched)

    variable stable_counter : natural range 0 to 3;

  begin
    if (wb_rst_i = '1') then
      mac_address_latched <= '0';
      stable_counter := 0;
      self_mac_addr(43 downto 40) <= (others => '0');
    elsif (rising_edge(network_clock) and (mac_address_latched = '0')) then
      if (stable_counter = 3) then
        mac_address_latched <= '1';
      elsif (self_mac_addr(43 downto 40) = nswitch(4 downto 1)) then
        stable_counter := stable_counter + 1;
      else
        self_mac_addr(43 downto 40) <= nswitch(4 downto 1);
        stable_counter := 0;
      end if;  
    end if;

  end process;

])

###############################################################################
# Signals for top-level network controller

define([network_signals_], [dnl
network_common_signals_
network_ip_signals_
network_debug_led_signals_
network_udp_signals_

network_clock_signals_
udp_xmit_arbiter_signals_
dhcp_signals_

network_controller_component_
dhcp_component_
])

###############################################################################
# All network instances
define([network_instances_], [dnl
dnl network_clock_instance_
network_instance_
udp_xmit_arbiter_instance_
dhcp_instance_
mac_address_detector_

  ptp_server_port(0 to 11)  <= PTP_SERVER_PORT_0(0 to 11);
  ptp_server_port(12 to 15) <= self_mac_addr(43 downto 40);
  dhcp_enable               <= nswitch(5);

])

# Renable output for processed file
divert(0)dnl