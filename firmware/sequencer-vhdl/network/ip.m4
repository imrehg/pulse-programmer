dnl-*-VHDL-*-
-- Top-level IP module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([ip], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
    ADDRESS_WIDTH      : positive := 10;
    ARP_TABLE_DEPTH    : positive := 3;
    BUFFER_COUNT_WIDTH : natural  := 1;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
  self_mac_addr             : in  mac_address := SELF_MAC_ADDRESS;
  self_ip_addr              : in  ip_address;
  dhcp_status_load          : in  std_logic;
  gateway_ip_addr_in        : in  ip_address;
  gateway_load_in           : in  std_logic;
  recv_debug_led_out        : out byte;
  trans_debug_led_out       : out byte;
  xmit_debug_led_out        : out byte;
  arp_debug_led_out         : out byte;
  arp_xmit_debug_led_out    : out byte;
  arp_recv_debug_led_out    : out byte;
  eth_debug_led_out         : out byte;
  ip_debug_led_out          : out byte;
  ip_buffer_debug_led_out   : out multibus_byte(0 to 2**BUFFER_COUNT_WIDTH-1);
  -- Wishbone slave interface from transport layer to ip_transmit
  trans_xmit_wbs_cyc_i      : in  std_logic;
  trans_xmit_wbs_stb_i      : in  std_logic;
  trans_xmit_wbs_dat_i      : in  std_logic_vector(0 to DATA_WIDTH-1);
  trans_xmit_wbs_ack_o      : out std_logic;
  trans_xmit_wbs_err_o      : out std_logic;
  trans_xmit_dest_ip_addr   : in  ip_address;
  trans_xmit_protocol       : in  ip_protocol;
  trans_xmit_id             : in  ip_id;
  trans_xmit_total_length   : in  ip_total_length;
  trans_xmit_dont_fragment  : in  std_logic := '0';
  -- Wishbone master interface for ip_receive to transport layer
  trans_recv_wbm_cyc_o      : out std_logic;
  trans_recv_wbm_stb_o      : out std_logic;
  trans_recv_wbm_dat_o      : out std_logic_vector(0 to DATA_WIDTH-1);
  trans_recv_wbm_ack_i      : in  std_logic;
  trans_recv_src_ip_addr    : out ip_address;
  trans_recv_dest_ip_addr   : out ip_address;
  trans_recv_protocol       : out ip_protocol;
  trans_recv_id             : out ip_id;
  trans_recv_total_length   : out ip_total_length;

  -- Wishbone master interface to ethernet_transmit
  eth_xmit_wbm_cyc_o        : out std_logic;
  eth_xmit_wbm_stb_o        : out std_logic;
  eth_xmit_wbm_dat_o        : out std_logic_vector(0 to DATA_WIDTH-1);
  eth_xmit_wbm_ack_i        : in  std_logic;
  eth_xmit_dest_addr        : out mac_address;
  eth_xmit_type_length      : out ethernet_type_length;
  eth_xmit_total_length     : out ip_total_length;

  -- Wishbone slave interface from ethernet_receive
  eth_recv_wbs_cyc_i        : in  std_logic;
  eth_recv_wbs_stb_i        : in  std_logic;
  eth_recv_wbs_dat_i        : in  std_logic_vector(0 to DATA_WIDTH-1);
  eth_recv_wbs_ack_o        : out std_logic;
  eth_recv_type_length      : in  ethernet_type_length;
  eth_recv_error            : in  std_logic;
],[dnl -- Declarations --------------------------------------------------------
  -- Signals to arbitrate between ARP receive and IP receive
  -- ARP slave, IP slave, and unknown slave (different from null slave)
  signal arp_recv_wb_cyc      : std_logic;
  signal ip_recv_wb_cyc       : std_logic;
  signal arp_recv_wb_ack      : std_logic;
  signal ip_recv_wb_ack       : std_logic;
  signal eth_recv_arbiter_gnt : multibus_bit(0 to 2);
  constant arp_total_length : unsigned :=
    to_unsigned(ARP_BYTE_LENGTH, IP_TOTAL_LENGTH_WIDTH);
  
],[dnl -- Body ----------------------------------------------------------------
-------------------------------------------------------------------------------
-- TRANSMIT SIDE --------------------------------------------------------------
-------------------------------------------------------------------------------
  transmit_block: block

    ---------------------------------------------------------------------------
    -- Transmitter constants and signals

    -- 500 microseconds
    constant ARP_RETRY_COUNT       : positive := 50000;
    
    -- slave signals between IP and ARP
    signal arp_wb_stb              : std_logic;
    signal arp_wb_adr              : ip_address;
    signal arp_wb_dat              : mac_address;
    signal arp_wb_ack              : std_logic;
    signal arp_wb_err              : std_logic;

    -- Wishbone master signals (to Ethernet)
    signal ip_xmit_wb_cyc          : std_logic;
    signal ip_xmit_wb_stb          : std_logic;
    signal ip_xmit_wb_dat          : std_logic_vector(0 to DATA_WIDTH-1);
    signal ip_xmit_wb_ack          : std_logic;
    signal ip_xmit_wb_gnt          : std_logic;

    signal ip_xmit_type_length     : ethernet_type_length;
    signal ip_xmit_dest_addr       : mac_address;
    signal ip_xmit_total_length    : ip_total_length;

    -- Wishbone slave signals (from ip_transmit)
    signal ips_wb_cyc              : std_logic;
    signal ips_wb_stb              : std_logic;
    signal ips_wb_dat              : std_logic_vector(0 to DATA_WIDTH-1);
    signal ips_wb_ack              : std_logic;

    -- ARP transmit outputs
    signal arp_xmit_wb_cyc         : std_logic;
    signal arp_xmit_wb_stb         : std_logic;
    signal arp_xmit_wb_ack         : std_logic;
    signal arp_xmit_wb_dat         : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal arp_xmit_wb_gnt         : std_logic;
    
    signal arp_xmit_type_length    : ethernet_type_length;
    signal arp_xmit_dest_addr      : mac_address;
    
    signal eth_xmit_arbiter_ack    : multibus_bit(0 to 1);
    signal eth_xmit_arbiter_gnt    : multibus_bit(0 to 1);

    signal ip_xmit_accept          : std_logic;
    signal ip_xmit_discard         : std_logic;

    ---------------------------------------------------------------------------
    -- Transmitter component declarations
    
arp_component_
ip_transmit_component_

  begin  -- block transmit_block
    
    arp_module : arp
      generic map (
        DATA_WIDTH           => DATA_WIDTH,
        TABLE_DEPTH          => ARP_TABLE_DEPTH
        )
      port map (
        -- Network interface
        wb_clk_i             => wb_clk_i,
        wb_rst_i             => wb_rst_i,
        self_mac_addr        => self_mac_addr,
        self_ip_addr         => self_ip_addr,
        dhcp_status_load     => dhcp_status_load,
        gateway_set_in       => gateway_load_in,
        gateway_ip_addr_in   => gateway_ip_addr_in,
        debug_led_out        => arp_debug_led_out,
        -- IP wishbone slave interface
        ip_wb_stb_i          => arp_wb_stb,
        ip_wb_adr_i          => arp_wb_adr,
        ip_wb_dat_o          => arp_wb_dat,
        ip_wb_ack_o          => arp_wb_ack,
        ip_wb_err_o          => arp_wb_err,
        -- Ethernet transmit Wishbone interface
        eth_xmit_wb_cyc_o    => arp_xmit_wb_cyc,
        eth_xmit_wb_stb_o    => arp_xmit_wb_stb,
        eth_xmit_wb_ack_i    => arp_xmit_wb_ack,
        eth_xmit_wb_dat_o    => arp_xmit_wb_dat,
        eth_xmit_type_length => arp_xmit_type_length,
        eth_xmit_dest_addr   => arp_xmit_dest_addr,
        xmit_debug_led_out   => arp_xmit_debug_led_out,
        -- Ethernet receive Wishbone interface
        eth_recv_wb_cyc_i    => arp_recv_wb_cyc,
        eth_recv_wb_stb_i    => eth_recv_wbs_stb_i,
        eth_recv_wb_dat_i    => eth_recv_wbs_dat_i,
        eth_recv_wb_ack_o    => arp_recv_wb_ack,
        eth_recv_error       => eth_recv_error,
        recv_debug_led_out   => arp_recv_debug_led_out
        );

    -- Multiplex non-Wishbone ports
    eth_xmit_dest_addr <= ip_xmit_dest_addr when (ip_xmit_wb_gnt = '1')
                          else arp_xmit_dest_addr;
    eth_xmit_type_length <= IP_TYPE_LENGTH when (ip_xmit_wb_gnt = '1')
                            else arp_xmit_type_length;
    eth_xmit_total_length <= ip_xmit_total_length when (ip_xmit_wb_gnt = '1')
                            else arp_total_length;
    
    eth_xmit_arbiter : wb_intercon
      generic map (
        MASTER_COUNT  => 2
        )
      port map (
        wb_clk_i      => wb_clk_i,
        wb_rst_i      => wb_rst_i,

        wbm_cyc_i     => (ip_xmit_wb_cyc, arp_xmit_wb_cyc),
        wbm_stb_i     => (ip_xmit_wb_stb, arp_xmit_wb_stb),
        wbm_dat_i     => (ip_xmit_wb_dat, arp_xmit_wb_dat),
        wbm_ack_o     => eth_xmit_arbiter_ack,
        wbm_gnt_o     => eth_xmit_arbiter_gnt,

        wbs_cyc_o     => eth_xmit_wbm_cyc_o,
        wbs_stb_o     => eth_xmit_wbm_stb_o,
        wbs_dat_o     => eth_xmit_wbm_dat_o,
        wbs_ack_i     => eth_xmit_wbm_ack_i,

        debug_led_out => eth_debug_led_out
        );

    ip_xmit_wb_ack  <= eth_xmit_arbiter_ack(0);
    arp_xmit_wb_ack <= eth_xmit_arbiter_ack(1);
    ip_xmit_wb_gnt  <= eth_xmit_arbiter_gnt(0);
    arp_xmit_wb_gnt <= eth_xmit_arbiter_gnt(1);

    ip_transmitter : ip_transmit
      generic map (
        DATA_WIDTH    => DATA_WIDTH
        )
      port map (
        -- Wishbone common signals
        wb_clk_i         => wb_clk_i,
        wb_rst_i         => wb_rst_i,
        -- Wishbone master interface (e.g. to ethernet_transmit)
        wbm_cyc_o        => ip_xmit_wb_cyc,
        wbm_stb_o        => ip_xmit_wb_stb,
        wbm_dat_o        => ip_xmit_wb_dat,
        wbm_ack_i        => ip_xmit_wb_ack,
        -- Wishbone slave interface (e.g. from tcp)
        wbs_cyc_i        => ips_wb_cyc,
        wbs_stb_i        => ips_wb_stb,
        wbs_dat_i        => ips_wb_dat,
        wbs_ack_o        => ips_wb_ack,
        total_length_out => ip_xmit_total_length,
        -- Non-wishbone slave interface, synced to signals above
        dest_ip_addr_in  => trans_xmit_dest_ip_addr,
        src_ip_addr_in   => self_ip_addr,
        dont_fragment_in => trans_xmit_dont_fragment,
        id_in            => trans_xmit_id,
        protocol_in      => trans_xmit_protocol,
        total_length_in  => trans_xmit_total_length,
        debug_led_out    => xmit_debug_led_out
        );

--    trans_debug_led_out <= ip_xmit_wb_dat;

    ip_debug_led_out(2) <= ip_xmit_accept;
    ip_debug_led_out(3) <= ip_xmit_discard;
    ip_debug_led_out(4) <= arp_wb_ack;
    ip_debug_led_out(5) <= arp_wb_stb;

    trans_xmit_wbs_ack_o <= trans_xmit_wbs_stb_i when (ip_xmit_discard = '1')
                                                 else ips_wb_ack;

    ips_wb_cyc <= trans_xmit_wbs_cyc_i and ip_xmit_accept;
    ips_wb_stb <= trans_xmit_wbs_stb_i and ip_xmit_accept;
    ips_wb_dat <= trans_xmit_wbs_dat_i;

    ip_process : process(wb_clk_i, wb_rst_i)

      type ip_process_states is (
        idle,
        waiting,
        lookup
        );

      variable state : ip_process_states;

    begin
      if (wb_rst_i = '1') then
        arp_wb_stb      <= '0';
        ip_xmit_discard <= '0';
        ip_xmit_accept  <= '0';
        state           := idle;
        
      elsif (rising_edge(wb_clk_i)) then

        case (state) is
          ---------------------------------------------------------------------
          when idle =>
            if (trans_xmit_wbs_cyc_i = '1') then
              arp_wb_adr <= trans_xmit_dest_ip_addr;
              arp_wb_stb <= '1';
              state      := lookup;
            end if;
          ---------------------------------------------------------------------
          when lookup =>
            if (arp_wb_ack = '1') then
              ip_xmit_dest_addr <= arp_wb_dat;
              arp_wb_stb      <= '0';
              trans_xmit_wbs_err_o <= arp_wb_err;
              state := waiting;
              if (arp_wb_err = '0') then
                -- the MAC address was found and is on ip_xmit_dest_addr
                ip_xmit_accept       <= '1';
              else
                ip_xmit_discard      <= '1';
              end if;
            end if;
          ---------------------------------------------------------------------
          when waiting =>
            if ((trans_xmit_wbs_cyc_i = '0') and (arp_wb_ack = '0')) then
              ip_xmit_discard <= '0';
              ip_xmit_accept  <= '0';
              state           := idle;
            end if;

          when others => null;
        end case;
      end if;
    end process;

  end block transmit_block;

-------------------------------------------------------------------------------
-- RECEIVER ARBITER
-------------------------------------------------------------------------------
  recv_process : process(wb_rst_i, wb_clk_i, eth_recv_type_length,
                         eth_recv_wbs_cyc_i, eth_recv_wbs_stb_i,
                         eth_recv_arbiter_gnt, ip_recv_wb_ack, arp_recv_wb_ack)

   begin
     if (wb_rst_i = '1') then
       eth_recv_arbiter_gnt <= B"000";
     elsif (rising_edge(wb_clk_i)) then
       if (eth_recv_wbs_cyc_i = '1') then
         case (eth_recv_type_length) is
           when ARP_TYPE_LENGTH =>
             eth_recv_arbiter_gnt <= B"100";
           when IP_TYPE_LENGTH =>
             eth_recv_arbiter_gnt <= B"010";
           when others =>
             eth_recv_arbiter_gnt <= B"001";
         end case;
       else
         eth_recv_arbiter_gnt <= B"000";
       end if;
     end if;                            -- rising_edge(wb_clk_i)

     arp_recv_wb_cyc <= eth_recv_wbs_cyc_i and eth_recv_arbiter_gnt(0);
     ip_recv_wb_cyc  <= eth_recv_wbs_cyc_i and eth_recv_arbiter_gnt(1);

     ip_debug_led_out(7) <= eth_recv_arbiter_gnt(0);
     ip_debug_led_out(6) <= eth_recv_arbiter_gnt(1);

     case (eth_recv_arbiter_gnt) is
       when B"100" =>
         eth_recv_wbs_ack_o <= arp_recv_wb_ack;
       when B"010" =>
         eth_recv_wbs_ack_o <= ip_recv_wb_ack;
       when B"001" =>
         eth_recv_wbs_ack_o <= eth_recv_wbs_stb_i;
       when others =>
         eth_recv_wbs_ack_o <= '0';
     end case;

   end process;

-------------------------------------------------------------------------------
-- RECEIVE SIDE ---------------------------------------------------------------
-------------------------------------------------------------------------------
  receiver_block : block

    ---------------------------------------------------------------------------
    -- Component declarations

ip_receive_component_
ip_transport_component_

    ---------------------------------------------------------------------------
    -- Signal declarations
    
    signal ip_recv_cyc             : std_logic;
    signal ip_recv_stb             : std_logic;
    signal ip_recv_dat             : std_logic_vector(0 to DATA_WIDTH-1);
    signal ip_recv_ack             : std_logic;
    signal ip_recv_src_ip_addr     : ip_address;
    signal ip_recv_dest_ip_addr    : ip_address;
    signal ip_recv_protocol        : ip_protocol;
    signal ip_recv_id              : ip_id;
    signal ip_recv_total_length    : ip_total_length;
    signal ip_recv_fragment_offset : ip_frag_offset;
    signal ip_recv_more_fragments  : std_logic;
    signal ip_recv_checksum_error  : std_logic;

  begin

--     ip_debug_led_out(2) <= ip_recv_cyc;
--     ip_debug_led_out(1) <= ip_recv_stb;
--     ip_debug_led_out(0) <= ip_recv_ack;

    ip_receiver : ip_receive
      generic map (
        DATA_WIDTH => DATA_WIDTH
        )
      port map (
        -- Wishbone common signals
        wb_clk_i            => wb_clk_i,
        wb_rst_i            => wb_rst_i,
        -- Wishbone master interface (to ip_transport)
        wbm_cyc_o           => ip_recv_cyc,
        wbm_stb_o           => ip_recv_stb,
        wbm_dat_o           => ip_recv_dat,
        wbm_ack_i           => ip_recv_ack,
        src_ip_addr_out     => ip_recv_src_ip_addr,
        dest_ip_addr_out    => ip_recv_dest_ip_addr,
        protocol_out        => ip_recv_protocol,
        id_out              => ip_recv_id,
        total_length_out    => ip_recv_total_length,
        fragment_offset_out => ip_recv_fragment_offset,
        more_fragments_out  => ip_recv_more_fragments,
        checksum_error_out  => ip_recv_checksum_error,
        -- Wishbone slave interface (from ethernet frame)
        wbs_cyc_i           => ip_recv_wb_cyc,
        wbs_stb_i           => eth_recv_wbs_stb_i,
        wbs_dat_i           => eth_recv_wbs_dat_i,
        wbs_ack_o           => ip_recv_wb_ack,
        checksum_error_in   => eth_recv_error,
        debug_led_out       => recv_debug_led_out
        );

    ip_transporter : ip_transport
      generic map (
        DATA_WIDTH           => DATA_WIDTH,
        BUFFER_ADDRESS_WIDTH => ADDRESS_WIDTH,
        BUFFER_COUNT_WIDTH   => BUFFER_COUNT_WIDTH
        )
      port map (
        -- Wishbone common signals
        wb_clk_i           => wb_clk_i,
        wb_rst_i           => wb_rst_i,
        -- Wishbone master interface (e.g. to a transport protocol)
        wbm_cyc_o          => trans_recv_wbm_cyc_o,
        wbm_stb_o          => trans_recv_wbm_stb_o,
        wbm_dat_o          => trans_recv_wbm_dat_o,
        wbm_ack_i          => trans_recv_wbm_ack_i,
        self_ip_addr_in    => self_ip_addr,
        src_ip_addr_out    => trans_recv_src_ip_addr,
        dest_ip_addr_out   => trans_recv_dest_ip_addr,
        protocol_out       => trans_recv_protocol,
        id_out             => trans_recv_id,
        length_out         => trans_recv_total_length,
        debug_led_out      => trans_debug_led_out,
        buffer_debug_led_out => ip_buffer_debug_led_out,
        -- Wishbone slave interface (e.g. from ip_receive)
        wbs_cyc_i          => ip_recv_cyc,
        wbs_stb_i          => ip_recv_stb,
        wbs_dat_i          => ip_recv_dat,
        wbs_ack_o          => ip_recv_ack,
        src_ip_addr_in     => ip_recv_src_ip_addr,
        dest_ip_addr_in    => ip_recv_dest_ip_addr,
        protocol_in        => ip_recv_protocol,
        id_in              => ip_recv_id,
        length_in          => ip_recv_total_length,
        fragment_offset_in => ip_recv_fragment_offset,
        more_fragments_in  => ip_recv_more_fragments,
        checksum_error_in  => '0'
        );

  end block;
])
