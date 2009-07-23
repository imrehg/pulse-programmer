dnl-*-VHDL-*-
-- Top-level DHCP module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Based on inputs supplied to it from the top-level IP module, this
-- transmitter constructs a valid payload and feeds it to the
-- ethernet_transmit module via a Wishbone interface.

-- An IP datagram has a header in 32-bit chunks with a minimum of 20 octets
-- See IETF RFC 791 for more details.

unit_([dhcp], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
   RETRY_TIMEOUT   : positive := 500;
   MAX_RETRY_COUNT : positive := 2;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   enable_dynamic_addr_in : in     std_logic;
   -- Transmit Wishbone master interface to UDP
   xmit_wbm_cyc_o         : out    std_logic;
   xmit_wbm_stb_o         : out    std_logic;
   xmit_wbm_dat_o         : out    std_logic_vector(0 to DATA_WIDTH-1);
   xmit_wbm_ack_i         : in     std_logic;
   xmit_dest_ip_addr_out  : out    ip_address;
   xmit_src_port_out      : out    udp_port_type;
   xmit_dest_port_out     : out    udp_port_type;
   xmit_length_out        : out    udp_length_type;
   xmit_dont_fragment_out : out    std_logic;
   -- Receive Wishbone slave interface from UDP
   recv_wbs_cyc_i         : in     std_logic;
   recv_wbs_stb_i         : in     std_logic;
   recv_wbs_dat_i         : in     std_logic_vector(0 to DATA_WIDTH-1);
   recv_wbs_ack_o         : out    std_logic;
   recv_src_port_in       : in     udp_port_type;
   recv_dest_port_in      : in     udp_port_type;
   recv_length_in         : in     udp_length_type;
   -- Non-wishbone slave interface, synced to signals above
   self_mac_addr_in       : in     mac_address := SELF_MAC_ADDRESS;
   self_ip_addr_out       : out    ip_address;
   timed_out              : buffer std_logic;
   status_load_out        : out    std_logic;
   gateway_ip_addr_out    : out    ip_address;
   debug_led_out          : out    byte;
],[dnl -- Declarations --------------------------------------------------------
dnl byte_count_signals_(DHCP_FILE_BYTE_LENGTH)
   signal xmit_ip_addr        : ip_address;
   signal server_ip_addr      : ip_address;
   signal xmit_cyc            : std_logic;
   signal xmit_ack            : std_logic;
   signal xmit_message_type   : dhcp_messagetype_type;
   signal recv_cyc            : std_logic;
   signal recv_ack            : std_logic;
   signal recv_message_type   : dhcp_messagetype_type;
   signal recv_server_ip_addr : ip_address;
   signal recv_self_ip_addr   : ip_address;
   signal xmit_debug_led      : byte;
   signal gateway_ip_addr     : ip_address;
   signal mac_ending          : unsigned(5 downto 0);
   signal static_ip_addr      : ip_address;
dhcp_receive_component_
dhcp_transmit_component_
],[dnl -- Body ----------------------------------------------------------------

  mac_ending <= B"00" & unsigned(self_mac_addr_in(43 downto 40));
  static_ip_addr(0 to 25) <= IP_INTERNAL_SUBNET(0 to 25);
  static_ip_addr(26 to 31) <= std_logic_vector(
    unsigned(IP_INTERNAL_SUBNET(26 to 31)) + mac_ending);
   
  transmitter : dhcp_transmit
    generic map (
      DATA_WIDTH        => DATA_WIDTH,
      RETRY_TIMEOUT     => RETRY_TIMEOUT,
      MAX_RETRY_COUNT   => MAX_RETRY_COUNT
      )
    port map (
    -- Wishbone common signals
    wb_clk_i            => wb_clk_i,
    wb_rst_i            => wb_rst_i,
    -- Wishbone master signals
    wbm_cyc_o           => xmit_wbm_cyc_o,
    wbm_stb_o           => xmit_wbm_stb_o,
    wbm_dat_o           => xmit_wbm_dat_o,
    wbm_ack_i           => xmit_wbm_ack_i,
    s_cyc_i             => xmit_cyc,
    s_ack_o             => xmit_ack,
    -- Non-wishbone slave interface, synced to signals above
    self_mac_addr_in    => self_mac_addr_in,
    message_type_in     => xmit_message_type,
    server_ip_addr_in   => server_ip_addr,
    self_ip_addr_in     => xmit_ip_addr,
    timed_out           => timed_out,
    debug_led_out       => xmit_debug_led
    );

 receiver : dhcp_receive 
   generic map (
     DATA_WIDTH         => DATA_WIDTH
     )
   port map (
    -- Wishbone common signals
    wb_clk_i            => wb_clk_i,
    wb_rst_i            => wb_rst_i,
    -- Wishbone slave signals
    wbs_cyc_i           => recv_wbs_cyc_i,
    wbs_stb_i           => recv_wbs_stb_i,
    wbs_dat_i           => recv_wbs_dat_i,
    wbs_ack_o           => recv_wbs_ack_o,
    m_cyc_o             => recv_cyc,
    m_ack_i             => recv_ack,
    -- Non-wishbone slave interface, synced to signals above
    message_type_out    => recv_message_type,
    server_ip_addr_out  => recv_server_ip_addr,
    router_ip_addr_out  => gateway_ip_addr,
    self_ip_addr_out    => recv_self_ip_addr,
    self_mac_addr_in    => self_mac_addr_in
    );

  xmit_dest_port_out    <= DHCP_SERVER_PORT;
  xmit_src_port_out     <= DHCP_CLIENT_PORT;
  xmit_length_out       <= to_unsigned(DHCP_BYTE_LENGTH, UDP_LENGTH_WIDTH);
  xmit_dont_fragment_out <= '1';

  gateway_ip_addr_out   <= gateway_ip_addr;
   
  process(wb_rst_i, wb_clk_i, timed_out)

    type dhcp_states is (
      idle,
      discovering,
      discovering_wait,
      selecting,
      requesting,
      bound,
      timed_out_state
      );

    variable state : dhcp_states;

  begin

    if (wb_rst_i = '1') then
      xmit_cyc         <= '0';
      recv_ack         <= '0';
      status_load_out  <= '0';
      state            := idle;
    elsif (rising_edge(wb_clk_i)) then

      case (state) is
-------------------------------------------------------------------------------
        when idle =>
          debug_led_out(2 downto 0) <= B"000";
          self_ip_addr_out  <= (others => '0');
          xmit_dest_ip_addr_out <= BROADCAST_IP_ADDRESS;
          server_ip_addr    <= BROADCAST_IP_ADDRESS;
          xmit_message_type <= DHCP_DISCOVER_MESSAGE_TYPE;
          xmit_ip_addr      <= (others => '0');
          xmit_cyc          <= '1';
          recv_ack          <= '0';
          state             := discovering;
-------------------------------------------------------------------------------
        when discovering =>
          debug_led_out(2 downto 0) <= B"010";
          -- let receiver ack itself until we get offer message
          recv_ack <= recv_cyc;
          if (recv_cyc = '1') then
            if (recv_message_type = DHCP_OFFER_MESSAGE_TYPE) then
              xmit_ip_addr   <= recv_self_ip_addr;
              server_ip_addr <= recv_server_ip_addr;
              state          := discovering_wait;
            end if;
          elsif (timed_out = '1') then
            state := timed_out_state;
          end if;
-------------------------------------------------------------------------------
        when discovering_wait =>
          debug_led_out(2 downto 0) <= B"011";
          if (xmit_ack = '1') then
            xmit_cyc <= '0';
            state    := selecting;
          end if;
-------------------------------------------------------------------------------
        when selecting =>
          debug_led_out(2 downto 0) <= B"100";
          if (recv_cyc = '0') then
            recv_ack          <= '0';
            if (enable_dynamic_addr_in = '1') then
              xmit_message_type <= DHCP_REQUEST_MESSAGE_TYPE;
            else
              -- If we statically assign IP addr, just get the router but
              -- decline the offered dynamic address.
              xmit_message_type <= DHCP_DECLINE_MESSAGE_TYPE;
            end if;
            xmit_cyc          <= '1';
            state             := requesting;
          end if;
-------------------------------------------------------------------------------
        when requesting =>
          debug_led_out(2 downto 0) <= B"101";
          recv_ack <= recv_cyc;
          if (recv_cyc = '1') then
            case (recv_message_type) is
              when DHCP_ACK_MESSAGE_TYPE =>
                if (enable_dynamic_addr_in = '1') then
                  self_ip_addr_out <= recv_self_ip_addr;
                else
                  self_ip_addr_out <= static_ip_addr;
                end if;
                state        := bound;
              when DHCP_NAK_MESSAGE_TYPE =>
                xmit_cyc     <= '0';
                state        := idle;
              when others => null;
            end case;
          elsif (timed_out = '1') then
            if (enable_dynamic_addr_in = '1') then
              state := timed_out_state;
            else
              -- Go to bound anyway; it's not our fault if decline is ignored
              self_ip_addr_out <= static_ip_addr;
              state := bound;
            end if;
          end if;
-------------------------------------------------------------------------------
        when bound =>
          debug_led_out(2 downto 0) <= B"110";
          recv_ack <= '0';
          xmit_cyc <= '0';
          status_load_out <= '1';
-------------------------------------------------------------------------------
        when others =>
          -- timed_out_state
          xmit_cyc         <= '0';
          recv_ack         <= '0';
          status_load_out  <= '1';
          if (enable_dynamic_addr_in = '1') then
            self_ip_addr_out <= SELF_AUTO_IP_ADDRESS;
          else
            self_ip_addr_out <= static_ip_addr;
          end if;
          
      end case;

    end if; -- rising_edge(wb_clk_i)
  end process;

  debug_led_out(7) <= xmit_cyc;
  debug_led_out(6) <= xmit_ack;
  debug_led_out(5) <= recv_cyc;
  debug_led_out(4) <= recv_ack;
  debug_led_out(3) <= '0';
])
