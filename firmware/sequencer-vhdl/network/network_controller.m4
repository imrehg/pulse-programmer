dnl-*-VHDL-*-
-- Top-level network controller.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([network_controller], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
   ETHERNET_BUFFER_ADDRESS_WIDTH : positive := 8;
   ARP_TABLE_DEPTH               : positive := 3;
   IP_BUFFER_ADDRESS_WIDTH       : positive := 10;
   IP_BUFFER_COUNT_WIDTH         : natural  := 1;
   ICMP_BUFFER_ADDRESS_WIDTH     : positive := 10;
   UDP_BUFFER_ADDRESS_WIDTH      : positive := 10;
   ENABLE_ICMP                   : boolean  := true;
],[dnl -- Ports ---------------------------------------------------------------
  wb_clk_i : in std_logic;
  wb_rst_i : in std_logic;
ethernet_phy_transmit_ports_
ethernet_phy_receive_ports_
udp_recv_master_ports_
udp_xmit_slave_ports_
  self_mac_addr            : in  mac_address := SELF_MAC_ADDRESS;
  self_ip_addr             : in  ip_address;
  dhcp_status_load         : in  std_logic;
  gateway_ip_addr_in       : in  ip_address;
  gateway_load_in          : in  std_logic;
debug_led_ports_
],[dnl -- Declarations --------------------------------------------------------
network_internal_signals_
network_component_declarations_

  constant TRANSPORT_PROTOCOL_COUNT : positive := 2;
  signal ip_xmit_arbiter_ack : multibus_bit(0 to TRANSPORT_PROTOCOL_COUNT-1);
  signal ip_xmit_arbiter_gnt : multibus_bit(0 to TRANSPORT_PROTOCOL_COUNT-1);

  -- One more bit than normal b/c of unknown master, used to indicate
  -- that when an unknown protocol (not the "null master") requests the bus
  signal ip_recv_arbiter_gnt : multibus_bit(0 to TRANSPORT_PROTOCOL_COUNT);
],[dnl -- Body ----------------------------------------------------------------
network_component_instances_

    -- IP transmit arbiter ----------------------------------------------------
    ip_xmit_arbiter : wb_intercon
    generic map (
      MASTER_COUNT  => TRANSPORT_PROTOCOL_COUNT
      )
    port map (
      wb_clk_i  => wb_clk_i,
      wb_rst_i  => wb_rst_i,

      wbm_cyc_i => (icmp_xmit_wb_cyc, udp_xmit_wb_cyc),
      wbm_stb_i => (icmp_xmit_wb_stb, udp_xmit_wb_stb),
      wbm_dat_i => (icmp_xmit_wb_dat, udp_xmit_wb_dat),
      wbm_ack_o => ip_xmit_arbiter_ack,
      wbm_gnt_o => ip_xmit_arbiter_gnt,

      wbs_cyc_o => ip_xmit_wb_cyc,
      wbs_stb_o => ip_xmit_wb_stb,
      wbs_dat_o => ip_xmit_wb_dat,
      wbs_ack_i => ip_xmit_wb_ack,
      debug_led_out => trans_xmit_debug_led_out
      );

   icmp_xmit_wb_ack       <= ip_xmit_arbiter_ack(0);
   udp_xmit_wb_ack        <= ip_xmit_arbiter_ack(1);

   -- Multiplex non-Wishbone transmit signals
   with ip_xmit_arbiter_gnt select
     ip_xmit_dest_ip_addr <=
     icmp_xmit_dest_ip_addr    when B"10",
     udp_xmit_dest_ip_addr_in  when B"01",
     (others => '0')           when others;
   with ip_xmit_arbiter_gnt select
     ip_xmit_protocol <=
     ICMP_PROTOCOL_TYPE        when B"10",
     UDP_PROTOCOL_TYPE         when B"01",
     (others => '0')           when others;
   with ip_xmit_arbiter_gnt select
     ip_xmit_id <=
     icmp_xmit_id              when B"10",
     udp_xmit_id               when B"01",
     (others => '0')           when others;
   with ip_xmit_arbiter_gnt select
     ip_xmit_total_length <=
     icmp_xmit_total_length    when B"10",
     udp_xmit_total_length     when B"01",
     (others => '0')           when others;
   with ip_xmit_arbiter_gnt select
     ip_xmit_dont_fragment <=
     icmp_xmit_dont_fragment   when B"10",
     udp_xmit_dont_fragment_in when B"01",
     '1'                       when others;

   -- IP receive arbiter
   process(wb_rst_i, wb_clk_i, ip_recv_protocol, ip_recv_wb_cyc,
           ip_recv_arbiter_gnt, ip_recv_wb_stb, ip_recv_wb_ack, ip_recv_wb_dat,
           ip_recv_src_ip_addr, icmp_recv_wb_ack, udp_recv_wb_ack)

   begin
     if (wb_rst_i = '1') then
       ip_recv_arbiter_gnt <= B"000";
     elsif (rising_edge(wb_clk_i)) then
       if (ip_recv_wb_cyc = '1') then
         case (ip_recv_protocol) is
           when ICMP_PROTOCOL_TYPE =>
             ip_recv_arbiter_gnt <= B"100";
           when UDP_PROTOCOL_TYPE =>
             ip_recv_arbiter_gnt <= B"010";
           when others =>
             ip_recv_arbiter_gnt <= B"001";
         end case;
       else
         ip_recv_arbiter_gnt <= B"000";
       end if;
     end if;                            -- rising_edge(wb_clk_i)

     icmp_recv_wb_cyc   <= ip_recv_wb_cyc and ip_recv_arbiter_gnt(0);
     udp_recv_wb_cyc    <= ip_recv_wb_cyc and ip_recv_arbiter_gnt(1);

     case (ip_recv_arbiter_gnt) is
       when B"100" =>
         ip_recv_wb_ack <= icmp_recv_wb_ack;
       when B"010" =>
         ip_recv_wb_ack <= udp_recv_wb_ack;
       when B"001" =>
         ip_recv_wb_ack <= ip_recv_wb_stb;
       when others =>
         ip_recv_wb_ack <= '0';
     end case;

   end process;
])
