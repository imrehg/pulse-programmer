dnl--*-VHDL-*-
-- Top-level ARP module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([arp], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
  TABLE_DEPTH           : positive := 3;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
  -- Ethernet interface
  self_mac_addr         : in     mac_address;
  -- IP layer common interface
  self_ip_addr          : in     ip_address;
  dhcp_status_load      : in     std_logic;
  gateway_set_in        : in     std_logic;
  gateway_ip_addr_in    : in     ip_address;
  debug_led_out         : buffer byte;
  -- IP wishbone slave interface
  ip_wb_stb_i           : in     std_logic;
  ip_wb_adr_i           : in     ip_address;
  ip_wb_dat_o           : out    mac_address;
  ip_wb_ack_o           : buffer std_logic;
  ip_wb_err_o           : buffer std_logic;
  -- Ethernet transmit Wishbone interface
  eth_xmit_wb_cyc_o     : out    std_logic;
  eth_xmit_wb_stb_o     : out    std_logic;
  eth_xmit_wb_ack_i     : in     std_logic;
  eth_xmit_wb_dat_o     : out    std_logic_vector(DATA_WIDTH-1 downto 0);
  eth_xmit_type_length  : out    ethernet_type_length;
  eth_xmit_dest_addr    : out    mac_address;
  xmit_debug_led_out    : out    byte;
  -- Ethernet receive Wishbone interface
  eth_recv_wb_cyc_i     : in     std_logic;
  eth_recv_wb_stb_i     : in     std_logic;
  eth_recv_wb_dat_i     : in     std_logic_vector(DATA_WIDTH-1 downto 0);
  eth_recv_wb_ack_o     : out    std_logic;
  eth_recv_error        : in     std_logic;
  recv_debug_led_out    : out    byte;
],[dnl -- Declarations --------------------------------------------------------
arp_transmit_component_
arp_receive_component_
  -- Lookup table signals
  signal lut_wb_stb_o           : std_logic;
  signal lut_wb_we_o            : std_logic;
  signal lut_wb_adr_o           : ip_address;
  signal lut_wb_dat_o           : mac_address;
  signal lut_wb_dat_i           : mac_address;
  signal lut_wb_ack_i           : std_logic;
  signal lut_wb_err_i           : std_logic;

  -- ARP transmitter signals
  signal arp_transmit_enable    : std_logic;
  signal arp_transmit_done      : std_logic;
  signal arp_transmit_opcode    : arp_opcode;
  signal arp_xmit_dest_mac_addr : mac_address;
  signal arp_xmit_dest_ip_addr  : ip_address;

  -- ARP receiver signals
  signal arp_receive_opcode     : arp_opcode;
  signal arp_receive_strobe     : std_logic;
  signal arp_receive_ack        : std_logic;
  signal arp_recv_src_mac_addr  : mac_address;
  signal arp_recv_src_ip_addr   : ip_address;
  signal arp_recv_dest_mac_addr : mac_address;
  signal arp_recv_dest_ip_addr  : ip_address;

  -- Gateway signals to handle router case
  signal gateway_ip_addr : ip_address;
  signal gateway_ip_latched : boolean;
  signal gateway_set : std_logic;
  signal use_gateway : boolean;

],[dnl -- Body ----------------------------------------------------------------
  transmitter : arp_transmit
    generic map (
      DATA_WIDTH => DATA_WIDTH
      )
    port map (
      -- Wishbone master interface to ethernet_transmit
      wb_clk_i        => wb_clk_i,
      wb_rst_i        => wb_rst_i,
      wb_cyc_o        => eth_xmit_wb_cyc_o,
      wb_stb_o        => eth_xmit_wb_stb_o,
      wb_dat_o        => eth_xmit_wb_dat_o,
      wb_ack_i        => eth_xmit_wb_ack_i,
      -- ARP interface
      s_stb_i         => arp_transmit_enable,
      s_ack_o         => arp_transmit_done,
      dest_ip_addr    => arp_xmit_dest_ip_addr,
      dest_mac_addr   => arp_xmit_dest_mac_addr,
      src_ip_addr     => self_ip_addr,
      src_mac_addr    => self_mac_addr,
      opcode_in       => arp_transmit_opcode,
      debug_led_out   => xmit_debug_led_out
      );

  eth_xmit_type_length <= ARP_TYPE_LENGTH;
  eth_xmit_dest_addr   <= arp_xmit_dest_mac_addr;

  -- This module is in reset whenever we are not receiving
  receiver : arp_receive
    generic map (
      DATA_WIDTH => DATA_WIDTH
      )
    port map (
      -- Wishbone slave interface to ethernet_receive
      wb_clk_i      => wb_clk_i,
      wb_rst_i      => wb_rst_i,
      wb_cyc_i      => eth_recv_wb_cyc_i,
      wb_stb_i      => eth_recv_wb_stb_i,
      wb_dat_i      => eth_recv_wb_dat_i,
      wb_ack_o      => eth_recv_wb_ack_o,
      -- ARP interface
      m_stb_o       => arp_receive_strobe,
      m_ack_i       => arp_receive_ack,
      src_mac_addr  => arp_recv_src_mac_addr,
      src_ip_addr   => arp_recv_src_ip_addr,
      dest_mac_addr => arp_recv_dest_mac_addr,
      dest_ip_addr  => arp_recv_dest_ip_addr,
      opcode_out    => arp_receive_opcode,
      debug_led_out => recv_debug_led_out
      );

  arp_table : lookup_table
    generic map (
      KEY_WIDTH   => IP_ADDRESS_WIDTH,
      VALUE_WIDTH => MAC_ADDRESS_WIDTH,
      DEPTH       => TABLE_DEPTH
      )
    port map (
      wb_clk_i    => wb_clk_i,
      wb_rst_i    => wb_rst_i,
      wb_stb_i    => lut_wb_stb_o,
      wb_we_i     => lut_wb_we_o,
      wb_adr_i    => lut_wb_adr_o,
      wb_dat_i    => lut_wb_dat_o,
      wb_dat_o    => lut_wb_dat_i,
      wb_ack_o    => lut_wb_ack_i,
      wb_err_o    => lut_wb_err_i
    );

-------------------------------------------------------------------------------
  arp_process : process(wb_rst_i, wb_clk_i, arp_receive_strobe, debug_led_out)

    type arp_states is (
      idle,
      looking_up,
      transmit_wait,
      looking_up_wait,
      receiving,
      receiving_merge,
      receiving_wait,
      receiving_reply,
      receiving_done
      );

    variable state          : arp_states;
     -- True when a frame is addressed to us
    variable self_addressed : boolean;

  begin

    if (wb_rst_i = '1') then
      ip_wb_ack_o          <= '0';
      arp_receive_ack      <= '0';
      arp_transmit_enable  <= '0';
      gateway_ip_latched   <= false;
      gateway_set          <= '0';
      use_gateway          <= false;
      state                := idle;

    elsif (rising_edge(wb_clk_i)) then

      case (state) is
-------------------------------------------------------------------------------
        when idle =>
          if (use_gateway) then
            lut_wb_stb_o <= '1';
            lut_wb_we_o  <= '0';
            lut_wb_adr_o <= gateway_ip_addr;
            state := looking_up;
          elsif (ip_wb_stb_i = '1') then
            if (ip_wb_adr_i = BROADCAST_IP_ADDRESS) then
              debug_led_out(3 downto 0) <= B"0010";
              ip_wb_dat_o          <= BROADCAST_MAC_ADDRESS;
              ip_wb_ack_o          <= '1';
              ip_wb_err_o          <= '0';
              state                := looking_up_wait;
            else
              debug_led_out(3 downto 0) <= B"0011";
              -- if IP master requests an address, look it up
              lut_wb_stb_o <= '1';
              lut_wb_we_o  <= '0';
              lut_wb_adr_o <= ip_wb_adr_i;
              state        := looking_up;
            end if;
          elsif ((arp_receive_strobe = '1') and (dhcp_status_load = '1')) then
            debug_led_out(3 downto 0) <= B"0100";
            -- if ARP receiver parses a valid frame and ethernet receiver
            -- says checksum is okay, lookup up the sender addresses.
            lut_wb_we_o  <= '0';
            lut_wb_stb_o <= '1';
            lut_wb_adr_o <= arp_recv_src_ip_addr;
            if (arp_recv_dest_ip_addr = self_ip_addr) then
              self_addressed := true;
            else
              self_addressed := false;
            end if;
            state := receiving;
          elsif ((not gateway_ip_latched) and (gateway_set_in = '1')) then
            gateway_ip_latched <= true;
            -- Latch here for improved performance
            gateway_ip_addr <= gateway_ip_addr_in;
          end if;
-------------------------------------------------------------------------------
        when receiving =>
          debug_led_out(3 downto 0) <= B"0101";
          if (lut_wb_ack_i = '1') then
            lut_wb_stb_o <= '0';
            if ((arp_recv_src_ip_addr = gateway_ip_addr) and
                (gateway_ip_latched)) then
              -- if our gateway ip address is latched and this is the
              -- reply from it, report that it is ready for future use.
              gateway_set <= '1';
            end if;
            if ((lut_wb_err_i = '0') or self_addressed) then
              -- merge if this IP address is already in our lookup table,
              -- or we are the recipient of this frame
              state := receiving_merge;
            else
              -- we don't have a reason to merge this address into our table
              arp_receive_ack <= '1';
              state           := receiving_done;
            end if;
          end if;
-------------------------------------------------------------------------------
        when receiving_merge =>
          debug_led_out(3 downto 0) <= B"0110";
          if (lut_wb_ack_i = '0') then
            -- merge the address into our table
            lut_wb_stb_o <= '1';
            lut_wb_we_o  <= '1';
            lut_wb_adr_o <= arp_recv_src_ip_addr;
            lut_wb_dat_o <= arp_recv_src_mac_addr;
            state        := receiving_reply;
          end if;
-------------------------------------------------------------------------------
        when receiving_reply =>
          debug_led_out(3 downto 0) <= B"0111";
          -- after lookup table is done merging, reply to any requests
          if (lut_wb_ack_i = '1') then
            lut_wb_stb_o <= '0';
            lut_wb_we_o  <= '0';
            -- this is a performance hack b/c checking all 16 bits is slow
            if ((arp_receive_opcode(1 downto 0) =
                 ARP_REQUEST_OPCODE(1 downto 0)) and self_addressed) then
              arp_transmit_enable    <= '1';
              arp_xmit_dest_mac_addr <= arp_recv_src_mac_addr;
              arp_xmit_dest_ip_addr  <= arp_recv_src_ip_addr;
              arp_transmit_opcode    <= ARP_REPLY_OPCODE;
              state                  := receiving_wait;
            else
              arp_receive_ack        <= '1';
              state                  := receiving_done;
            end if;
          end if;
-------------------------------------------------------------------------------
        when receiving_wait =>
          debug_led_out(3 downto 0) <= B"1000";
          -- wait for the ARP transmitter to finish
          if (arp_transmit_done = '1') then
            arp_transmit_enable <= '0';
            arp_receive_ack     <= '1';
            state               := receiving_done;
          end if;
-------------------------------------------------------------------------------
        when receiving_done =>
          debug_led_out(3 downto 0) <= B"1001";
          -- wait for the ARP receiver to release us
          if (arp_receive_strobe = '0') then
            arp_receive_ack <= '0';
            state           := idle;
          end if;
-------------------------------------------------------------------------------
        when looking_up =>
          debug_led_out(3 downto 0) <= B"1010";
          if (lut_wb_ack_i = '1') then
            lut_wb_stb_o <= '0';
            ip_wb_err_o  <= lut_wb_err_i and (not gateway_set);

            if (lut_wb_err_i = '1') then
              if ((not use_gateway) and (gateway_ip_latched)) then
                -- if we need to use the gateway, ack immediately to discard
                ip_wb_ack_o  <= '1';
                use_gateway <= true;
                state := looking_up_wait;
              else
                if (use_gateway) then
                  -- only use the gateway once per packet
                  -- and substitute its IP addr in the ARP request
                  use_gateway <= false;
                  arp_xmit_dest_ip_addr  <= gateway_ip_addr;
                else
                  -- if this is not a gateway use, ack immediately to discard
                  ip_wb_ack_o           <= '1';
                  arp_xmit_dest_ip_addr <= ip_wb_adr_i;
                end if;
                -- if we didn't find the address we're looking for,
                -- we have to request it and discard this packet
                arp_transmit_enable    <= '1';
                arp_xmit_dest_mac_addr <= BROADCAST_MAC_ADDRESS;
                arp_transmit_opcode    <= ARP_REQUEST_OPCODE;
                state                  := transmit_wait;
              end if;
            else
              -- If we found the MAC address we are looking for,
              -- whether it was the gateway or not, assume we don't need
              -- the gateway for the next call (otherwise we loop in idle).
              use_gateway   <= false;
              if (not use_gateway) then
                -- only raise ack if we were not using the gateway
                ip_wb_ack_o <= '1';
              end if;
              ip_wb_dat_o   <= lut_wb_dat_i;
              state         := looking_up_wait;
            end if;
          end if;
-------------------------------------------------------------------------------
        when transmit_wait =>
          debug_led_out(3 downto 0) <= B"1011";
          if (arp_transmit_done = '1') then
            arp_transmit_enable <= '0';
            state               := looking_up_wait;
           end if;
-------------------------------------------------------------------------------
        when looking_up_wait =>
          debug_led_out(3 downto 0) <= B"1100";
          if (ip_wb_stb_i = '0') then
            ip_wb_ack_o          <= '0';
            state                := idle;
          end if;
-------------------------------------------------------------------------------
        when others => null;
--          ip_wb_ack_o          <= '0';
--          arp_receive_ack      <= '0';
--          arp_transmit_enable  <= '0';
--          state                := idle;
-------------------------------------------------------------------------------
      end case;

    end if;

  end process;

  debug_led_out(4) <= ip_wb_stb_i;
  debug_led_out(5) <= ip_wb_ack_o;
  debug_led_out(6) <= arp_transmit_enable;
  debug_led_out(7) <= arp_receive_strobe;
])
