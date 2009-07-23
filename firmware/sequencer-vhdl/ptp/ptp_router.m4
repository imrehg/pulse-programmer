dnl-*-VHDL-*-
-- PTP module router between daisy-chain and UDP.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([ptp_router], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.ptp.all;
],[dnl -- Generics ------------------------------------------------------------
data_generic_
   ADDRESS_WIDTH    : positive := 10;
   STABLE_COUNT     : positive := 1;
   ABORT_TIMEOUT    : positive := 10;
   -- for testing (to remain constant across future versions)
   MAJOR_VERSION : std_logic_vector(0 to 7) := X"00";
   MINOR_VERSION : std_logic_vector(0 to 7) := X"01";
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   -- Transmit slave interface from top-level PTP
wb_xmit_slave_port_
   xmit_src_id_in                   : in  ptp_id_type;
   xmit_dest_id_in                  : in  ptp_id_type;
   xmit_opcode_in                   : in  ptp_opcode_type;
   xmit_length_in                   : in  ptp_length_type;
   xmit_debug_led_out               : out byte;
   -- Receive Wishbone master interface to top-level PTP
wb_recv_master_port_
   recv_src_id_out                  : out    ptp_id_type;
   recv_dest_id_out                 : out    ptp_id_type;
   recv_opcode_out                  : out    ptp_opcode_type;
   recv_length_out                  : out    ptp_length_type;
   recv_debug_led_out               : out    byte;
   -- Receive slave interface from AVR
   avr_recv_wbs_cyc_i               : in     std_logic;
   avr_recv_wbs_stb_i               : in     std_logic;
   avr_recv_wbs_dat_i               : in     std_logic_vector(DATA_WIDTH-1
                                                              downto 0);
   avr_recv_wbs_ack_o               : out    std_logic;
   -- Transmit master inteface from AVR
   avr_xmit_wbm_cyc_o               : buffer std_logic;
   avr_xmit_wbm_stb_o               : out    std_logic;
   avr_xmit_wbm_dat_o               : out    std_logic_vector(DATA_WIDTH-1
                                                              downto 0);
   avr_xmit_wbm_ack_i               : in     std_logic;
   -- Transmit Wishbone master interface to UDP
   udp_xmit_wbm_cyc_o               : buffer std_logic;
   udp_xmit_wbm_stb_o               : out    std_logic;
   udp_xmit_wbm_dat_o               : out    std_logic_vector(0 to
                                                              DATA_WIDTH-1);
   udp_xmit_wbm_ack_i               : in     std_logic;
   udp_xmit_dest_ip_addr_out        : out    ip_address;
--   udp_xmit_src_port_out            : out    udp_port_type;
   udp_xmit_dest_port_out           : out    udp_port_type;
   udp_xmit_length_out              : out    udp_length_type;
   udp_xmit_dont_fragment_out       : out    std_logic;
   -- Receive Wishbone slave interface from UDP
   udp_recv_wbs_cyc_i               : in     std_logic;
   udp_recv_wbs_stb_i               : in     std_logic;
   udp_recv_wbs_dat_i               : in     std_logic_vector(0 to
                                                              DATA_WIDTH-1);
   udp_recv_wbs_ack_o               : buffer std_logic;
   udp_recv_src_ip_addr_in          : in     ip_address;
   udp_recv_src_port_in             : in     udp_port_type;
   udp_recv_dest_port_in            : in     udp_port_type;
   udp_recv_length_in               : in     udp_length_type;
   -- Physical daisy chain pins to master
   daisy_master_xmit_stb_ack        : buffer std_logic;
   daisy_master_xmit_dat_cyc        : buffer std_logic;
   daisy_master_recv_stb_ack        : in     std_logic;
   daisy_master_recv_dat_cyc        : in     std_logic;
   -- Physical daisy chain pins to slave
   daisy_slave_xmit_stb_ack         : buffer std_logic;
   daisy_slave_xmit_dat_cyc         : buffer std_logic;
   daisy_slave_recv_stb_ack         : in     std_logic;
   daisy_slave_recv_dat_cyc         : in     std_logic;
   -- Debugging LEDs outputs
   link_master_xmit_debug_led_out   : out    byte;
   link_master_recv_debug_led_out   : out    byte;
   link_slave_xmit_debug_led_out    : out    byte;
   link_slave_recv_debug_led_out    : out    byte;
   link_state_debug_led_out         : out    byte;
   link_recv_arbiter_debug_led_out  : out    byte;
   link_debug_led_out               : out    byte;
   route_debug_led_out              : out    byte;
   route_buffer_debug_led_out       : out    byte;
   route_recv_arbiter_debug_led_out : out    byte;
   route_recv_debug_led_out         : out    byte;
   route_xmit_debug_led_out         : out    byte;
   debug_led_out                    : out    byte;

   self_id_in                       : in     ptp_id_type;
   chain_initiator                  : in     boolean;
   chain_terminator                 : in     boolean;
],[dnl -- Declarations --------------------------------------------------------
   signal self_id                   : ptp_id_type;
   signal link_xmit_discard         : boolean;

   -- Daisy-chain router signals
   signal route_xmit_wb_cyc   : std_logic;
   signal route_xmit_wb_stb   : std_logic;
   signal route_xmit_wb_dat   : std_logic_vector(0 to DATA_WIDTH-1);
   signal route_xmit_wb_ack   : std_logic;
   signal route_xmit_length   : ptp_length_type;
   
   signal route_recv_wb_cyc   : std_logic;
   signal route_recv_wb_stb   : std_logic;
   signal route_recv_wb_dat   : std_logic_vector(0 to DATA_WIDTH-1);
   signal route_recv_wb_ack   : std_logic;

   -- Daisy-chain link-level signals
   signal link_xmit_wb_cyc    : std_logic;
   signal link_xmit_wb_stb    : std_logic;
   signal link_xmit_wb_dat    : std_logic_vector(0 to DATA_WIDTH-1);
   signal link_xmit_wb_ack    : std_logic;
   signal link_xmit_interface : ptp_interface_type;

   signal link_recv_wb_cyc    : std_logic;
   signal link_recv_wb_stb    : std_logic;
   signal link_recv_wb_dat    : std_logic_vector(0 to DATA_WIDTH-1);
   signal link_recv_wb_ack    : std_logic;

   -- Receiver arbiter signals
   constant RECEIVE_MASTER_COUNT : positive := 3;
   signal recv_arbiter_gnt : multibus_bit(0 to RECEIVE_MASTER_COUNT-1);
   signal recv_arbiter_ack : multibus_bit(0 to RECEIVE_MASTER_COUNT-1);
   
ptp_daisy_link_component_
ptp_daisy_router_component_
],[dnl -- Body ----------------------------------------------------------------
  -- Signal multiplexing between daisy-chain link layer and UDP
  udp_xmit_wbm_stb_o <= route_xmit_wb_stb;
  udp_xmit_wbm_dat_o <= route_xmit_wb_dat;
  link_xmit_wb_stb   <= route_xmit_wb_stb;
  link_xmit_wb_dat   <= route_xmit_wb_dat;
  avr_xmit_wbm_stb_o <= route_xmit_wb_stb;
  avr_xmit_wbm_dat_o <= route_xmit_wb_dat;

  -- Depending on where we are transmitting a packet, mux ack accordingly
  route_xmit_wb_ack  <= udp_xmit_wbm_ack_i when (udp_xmit_wbm_cyc_o = '1') else
                        link_xmit_wb_ack   when (link_xmit_wb_cyc   = '1') else
                        avr_xmit_wbm_ack_i when (avr_xmit_wbm_cyc_o = '1') else
                        route_xmit_wb_stb  when (link_xmit_discard)        else
                        '0';

  udp_xmit_dont_fragment_out <= '0';
-------------------------------------------------------------------------------
-- Arbiter between UDP receive, slave receive, and AVR receive to top-level PTP
  recv_arbiter : wb_intercon
    generic map (
      MASTER_COUNT  => RECEIVE_MASTER_COUNT
      )
    port map (
      wb_clk_i      => wb_clk_i,
      wb_rst_i      => wb_rst_i,

      wbm_cyc_i     => (udp_recv_wbs_cyc_i, avr_recv_wbs_cyc_i,
                        link_recv_wb_cyc),
      wbm_stb_i     => (udp_recv_wbs_stb_i, avr_recv_wbs_stb_i,
                        link_recv_wb_stb),
      wbm_dat_i     => (udp_recv_wbs_dat_i, avr_recv_wbs_dat_i,
                        link_recv_wb_dat),
      wbm_ack_o     => recv_arbiter_ack,
      wbm_gnt_o     => recv_arbiter_gnt,

      wbs_cyc_o     => route_recv_wb_cyc,
      wbs_stb_o     => route_recv_wb_stb,
      wbs_dat_o     => route_recv_wb_dat,
      wbs_ack_i     => route_recv_wb_ack,
      debug_led_out => route_recv_arbiter_debug_led_out
      );

  udp_recv_wbs_ack_o    <= recv_arbiter_ack(0);
  avr_recv_wbs_ack_o    <= recv_arbiter_ack(1);
  link_recv_wb_ack      <= recv_arbiter_ack(2);

-------------------------------------------------------------------------------
-- Process for latching UDP fields for the return packet
-- or for deciding chain initiator/terminator routing.
  process(wb_rst_i, wb_clk_i)

    variable ip_addr_latched    : boolean;
--     variable length_latched     : boolean;
--     variable avr_master_latched : boolean;
    variable route_xmit_latched : boolean;

  begin
    if (wb_rst_i = '1') then
--       udp_xmit_length_out <= (others => '0');
      ip_addr_latched    := false;
--       length_latched     := false;
--       avr_master_latched := false;
      route_xmit_latched := false;

    elsif (rising_edge(wb_clk_i)) then

      -- latch incoming src ip addr on rising edge for dest of outgoing packet
      if (udp_recv_wbs_cyc_i = '1') then
        if (not ip_addr_latched) then
          ip_addr_latched := true;
          udp_xmit_dest_ip_addr_out <= udp_recv_src_ip_addr_in;
          udp_xmit_dest_port_out    <= udp_recv_src_port_in;
        end if;
      else
        ip_addr_latched := false;
      end if;

      -- latch incoming length from PTP application layer on rising edge
      -- for dest length of outgoing UDP/AVR (both share udp_xmit_length_out)
--       if (xmit_wbs_cyc_i = '1') then
--         if (not length_latched) then
--           length_latched := true;
--           udp_xmit_length_out <= xmit_length_in + PTP_HEADER_BYTE_LENGTH;
--           if ((xmit_dest_id_in = PTP_AVR_ID) and chain_initiator) then
--             avr_master_latched := true;
--           else
--             avr_master_latched := false;
--           end if;
--         end if;
--       else
--         length_latched := false;
--       end if;

      -- determine routing for chains.
      if (route_xmit_wb_cyc = '1') then
        if (not route_xmit_latched) then
          route_xmit_latched := true;
          if (link_xmit_interface = to_avr) then
--           if (avr_master_latched) then
            -- this has to go before the normal master, UDP host
            avr_xmit_wbm_cyc_o <= '1';
--             avr_master_latched := false;
          elsif ((link_xmit_interface = to_master) and (chain_initiator)) then
--             debug_led_out(1 downto 0) <= B"01";
            -- Initiators don't have a master and shouldn't wait for one;
            -- they should forward to their pseudo-master, the UDP, or
            -- the AVR, depending on the address
            udp_xmit_wbm_cyc_o <= '1';
          elsif ((link_xmit_interface /= to_slave) or
                 (not chain_terminator)) then
--             debug_led_out(1 downto 0) <= B"10";
            -- if we are not the initiator trying to forward to our master,
            -- or not the terminator trying to forward to our slave,
            -- pass it through here.
            link_xmit_wb_cyc <= '1';
          else
--             debug_led_out(1 downto 0) <= B"11";
            -- Terminators should just discard slave packets.
            link_xmit_discard <= true;
          end if;
        end if;
      else
--         debug_led_out(1 downto 0) <= B"00";
        route_xmit_latched := false;
        udp_xmit_wbm_cyc_o <= '0';
        avr_xmit_wbm_cyc_o <= '0';
        link_xmit_wb_cyc   <= '0';
        link_xmit_discard  <= false;
      end if;

    end if;

  end process;

  udp_xmit_length_out <= route_xmit_length + PTP_HEADER_BYTE_LENGTH;

  debug_led_out(0) <= '1' when (link_xmit_interface = to_avr) else '0';
  debug_led_out(1) <= '1' when (link_xmit_interface = to_slave) else '0';
  debug_led_out(2) <= '1' when (link_xmit_interface = to_master) else '0';
  debug_led_out(3) <= udp_xmit_wbm_cyc_o;
  debug_led_out(4) <= avr_xmit_wbm_cyc_o;
  debug_led_out(5) <= xmit_wbs_cyc_i;
  debug_led_out(6) <= xmit_wbs_ack_o;
  debug_led_out(7) <= route_xmit_wb_cyc;

  route_recv_debug_led_out <= route_recv_wb_dat;
  route_xmit_debug_led_out(7) <= route_recv_wb_cyc;
  route_xmit_debug_led_out(6) <= route_recv_wb_stb;
  route_xmit_debug_led_out(5) <= route_recv_wb_ack;
-------------------------------------------------------------------------------
  daisy_router : ptp_daisy_router
    generic map (
      DATA_WIDTH           => DATA_WIDTH,
      ADDRESS_WIDTH        => ADDRESS_WIDTH,
      MAJOR_VERSION        => MAJOR_VERSION,
      MINOR_VERSION        => MINOR_VERSION
      )
    port map (
      -- Wishbone common signals
      wb_clk_i             => wb_clk_i,
      wb_rst_i             => wb_rst_i,
      -- Wishbone slave transmit interface from top-level PTP
      xmit_wbs_cyc_i       => xmit_wbs_cyc_i,
      xmit_wbs_stb_i       => xmit_wbs_stb_i,
      xmit_wbs_dat_i       => xmit_wbs_dat_i,
      xmit_wbs_ack_o       => xmit_wbs_ack_o,
      xmit_dest_id_in      => xmit_dest_id_in,
      xmit_opcode_in       => xmit_opcode_in,
      xmit_length_in       => xmit_length_in,
      -- Wishbone master transmit interface to daisy-chain link layer/UDP/AVR
      xmit_wbm_cyc_o       => route_xmit_wb_cyc,
      xmit_wbm_stb_o       => route_xmit_wb_stb,
      xmit_wbm_dat_o       => route_xmit_wb_dat,
      xmit_wbm_ack_i       => route_xmit_wb_ack,
      xmit_debug_led_out   => xmit_debug_led_out,
      xmit_interface_out   => link_xmit_interface,
      xmit_length_out      => route_xmit_length,
      -- Wishbone master receive interface to top-level PTP
      recv_wbm_cyc_o       => recv_wbm_cyc_o,
      recv_wbm_stb_o       => recv_wbm_stb_o,
      recv_wbm_dat_o       => recv_wbm_dat_o,
      recv_wbm_ack_i       => recv_wbm_ack_i,
      recv_src_id_out      => recv_src_id_out,
      recv_dest_id_out     => recv_dest_id_out,
      recv_opcode_out      => recv_opcode_out,
      recv_length_out      => recv_length_out,
      -- Wishbone slave receive interface to daisy-chain link layer/UDP/AVR
      recv_wbs_cyc_i       => route_recv_wb_cyc,
      recv_wbs_stb_i       => route_recv_wb_stb,
      recv_wbs_dat_i       => route_recv_wb_dat,
      recv_wbs_ack_o       => route_recv_wb_ack,
      recv_debug_led_out   => recv_debug_led_out,
      -- ID of this programmer
      self_id_in           => self_id_in,
      chain_initiator_in   => chain_initiator,
      debug_led_out        => route_debug_led_out,
      buffer_debug_led_out => route_buffer_debug_led_out
      );

-------------------------------------------------------------------------------
  daisy_link : ptp_daisy_link
    generic map (
      DATA_WIDTH                 => DATA_WIDTH,
      STABLE_COUNT               => STABLE_COUNT,
      ABORT_TIMEOUT              => ABORT_TIMEOUT
      )
    port map (
      -- Wishbone common signals
      wb_clk_i                   => wb_clk_i,
      wb_rst_i                   => wb_rst_i,
     -- Daisy-chain Wishbone transmit interface
      xmit_wbs_cyc_i             => link_xmit_wb_cyc,
      xmit_wbs_stb_i             => link_xmit_wb_stb,
      xmit_wbs_dat_i             => link_xmit_wb_dat,
      xmit_wbs_ack_o             => link_xmit_wb_ack,
      xmit_interface_in          => link_xmit_interface,
      -- Daisy-chain Wishbone receive interface
      recv_wbm_cyc_o             => link_recv_wb_cyc,
      recv_wbm_stb_o             => link_recv_wb_stb,
      recv_wbm_dat_o             => link_recv_wb_dat,
      recv_wbm_ack_i             => link_recv_wb_ack,
      -- Physical daisy chain pins to master
      master_xmit_stb_ack        => daisy_master_xmit_stb_ack,
      master_xmit_dat_cyc        => daisy_master_xmit_dat_cyc,
      master_recv_stb_ack        => daisy_master_recv_stb_ack,
      master_recv_dat_cyc        => daisy_master_recv_dat_cyc,
      -- Physical daisy chain pins to slave
      slave_xmit_stb_ack         => daisy_slave_xmit_stb_ack,
      slave_xmit_dat_cyc         => daisy_slave_xmit_dat_cyc,
      slave_recv_stb_ack         => daisy_slave_recv_stb_ack,
      slave_recv_dat_cyc         => daisy_slave_recv_dat_cyc,
      debug_led_out              => link_debug_led_out,
      master_xmit_debug_led_out  => link_master_xmit_debug_led_out,
      master_recv_debug_led_out  => link_master_recv_debug_led_out,
      slave_xmit_debug_led_out   => link_slave_xmit_debug_led_out,
      slave_recv_debug_led_out   => link_slave_recv_debug_led_out,
      recv_arbiter_debug_led_out => link_recv_arbiter_debug_led_out,
      state_debug_led_out        => link_state_debug_led_out
      );
-------------------------------------------------------------------------------
])
