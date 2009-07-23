dnl-*-VHDL-*-
-- PTP daisy-chain network level router.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([ptp_daisy_router], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.ptp.all;
],[dnl -- Generics ------------------------------------------------------------
data_generic_
  ADDRESS_WIDTH : positive := 10;
  -- for testing (to remain constant across future versions)
  MAJOR_VERSION : std_logic_vector(0 to 7) := X"00";
  MINOR_VERSION : std_logic_vector(0 to 7) := X"01";
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   -- Wishbone slave transmit interface from top-level PTP
wb_xmit_slave_port_
   xmit_dest_id_in      : in     ptp_id_type;
   xmit_opcode_in       : in     ptp_opcode_type;
   xmit_length_in       : in     ptp_length_type;
   -- Wishbone master transmit interface to daisy-chain link layer
wb_xmit_master_port_
   xmit_interface_out   : buffer ptp_interface_type;
   xmit_length_out      : out    ptp_length_type;
   -- Wishbone master receive interface to top-level PTP
wb_recv_master_port_
   recv_src_id_out      : buffer ptp_id_type;
   recv_dest_id_out     : buffer ptp_id_type;
   recv_opcode_out      : buffer ptp_opcode_type;
   recv_length_out      : buffer ptp_length_type;
   -- Wishbone slave receive interface to daisy-chain link layer
wb_recv_slave_port_
   self_id_in           : in     ptp_id_type;
   chain_initiator_in   : in     boolean;
   debug_led_out        : out    byte;
   buffer_debug_led_out : out    byte;
],[dnl -- Declarations --------------------------------------------------------
  signal link_xmit_wbs_cyc       : std_logic;
  signal link_xmit_wbs_stb       : std_logic;
  signal link_xmit_wbs_dat       : std_logic_vector(0 to DATA_WIDTH-1);
  signal link_xmit_wbs_ack       : std_logic;
  signal route_recv_wbm_cyc      : std_logic;

  signal link_recv_wbm_cyc       : std_logic;
  signal link_recv_wbm_stb       : std_logic;
  signal link_recv_wbm_dat       : std_logic_vector(0 to DATA_WIDTH-1);
  signal link_recv_wbm_ack       : std_logic;
--  signal link_recv_checksum_error : std_logic;

  signal link_recv_src_id_out    : ptp_id_type;
  signal link_recv_dest_id_out   : ptp_id_type;
  signal link_recv_major_version : std_logic_vector(0 to 7);
  signal link_recv_opcode_out    : ptp_opcode_type;
  signal link_recv_length_out    : ptp_length_type;

  signal buffer_wbm_cyc          : std_logic;
  signal buffer_wbm_ack          : std_logic;
  signal buffer_reload           : std_logic;
  signal buffer_match            : std_logic;

  signal link_xmit_src_id        : ptp_id_type;
  signal link_xmit_dest_id       : ptp_id_type;
  signal link_xmit_opcode        : ptp_opcode_type;
  signal link_xmit_length        : ptp_length_type;

  signal router_forward          : boolean;

  signal xmit_arbiter_gnt        : multibus_bit(0 to 1);
  signal xmit_arbiter_ack        : multibus_bit(0 to 1);

  signal top_recv_wb_stb         : std_logic;
  signal top_recv_wb_dat         : std_logic_vector(0 to DATA_WIDTH-1);

ptp_buffer_component_
ptp_transmit_component_
ptp_receive_component_
],[dnl -- Body ----------------------------------------------------------------
  transmitter : ptp_transmit
    generic map (
      DATA_WIDTH        => DATA_WIDTH,
      ADDRESS_WIDTH     => ADDRESS_WIDTH,
      MAJOR_VERSION     => MAJOR_VERSION,
      MINOR_VERSION     => MINOR_VERSION
      )
    port map (
      -- Wishbone common signals
      wb_clk_i          => wb_clk_i,
      wb_rst_i          => wb_rst_i,
      -- Wishbone master signals
      wbm_cyc_o         => xmit_wbm_cyc_o,
      wbm_stb_o         => xmit_wbm_stb_o,
      wbm_dat_o         => xmit_wbm_dat_o,
      wbm_ack_i         => xmit_wbm_ack_i,
      interface_out     => xmit_interface_out,
      length_out        => xmit_length_out,
      -- Wishbone slave signals
      wbs_cyc_i         => link_xmit_wbs_cyc,
      wbs_stb_i         => link_xmit_wbs_stb,
      wbs_dat_i         => link_xmit_wbs_dat,
      wbs_ack_o         => link_xmit_wbs_ack,
      src_id_in         => link_xmit_src_id,
      dest_id_in        => link_xmit_dest_id,
      opcode_in         => link_xmit_opcode,
      length_in         => link_xmit_length,
      self_id_in        => self_id_in,
      chain_initiator_in => chain_initiator_in,
      debug_led_out     => xmit_debug_led_out
      );
-------------------------------------------------------------------------------
  receiver : ptp_receive
    generic map (
      DATA_WIDTH        => DATA_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i           => wb_clk_i,
      wb_rst_i           => wb_rst_i,
      -- Wishbone master signals
      wbm_cyc_o          => link_recv_wbm_cyc,
      wbm_stb_o          => link_recv_wbm_stb,
      wbm_dat_o          => link_recv_wbm_dat,
      wbm_ack_i          => link_recv_wbm_ack,
--      checksum_error_out => link_recv_checksum_error,
      -- Wishbone slave signals
      wbs_cyc_i          => recv_wbs_cyc_i,
      wbs_stb_i          => recv_wbs_stb_i,
      wbs_dat_i          => recv_wbs_dat_i,
      wbs_ack_o          => recv_wbs_ack_o,
      checksum_error_in  => '0',
      -- Non-wishbone slave interface, synced to signals above
      src_id_out         => link_recv_src_id_out,
      dest_id_out        => link_recv_dest_id_out,
      major_version_out  => link_recv_major_version,
      --minor_version_out =>
      opcode_out         => link_recv_opcode_out,
      length_out         => link_recv_length_out,
      debug_led_out      => recv_debug_led_out
      );

--  debug_led_out(7) <= link_recv_checksum_error;
  debug_led_out(6) <= link_recv_wbm_cyc;
--  debug_led_out(5) <= link_recv_wbm_stb;
--  debug_led_out(4) <= link_recv_wbm_ack;
  debug_led_out(5) <= link_xmit_dest_id(7);
  debug_led_out(4) <= link_xmit_wbs_cyc;
  debug_led_out(3) <= xmit_wbm_cyc_o;
  debug_led_out(2) <= link_xmit_wbs_ack;
-------------------------------------------------------------------------------
  reload_buffer : ptp_buffer
    generic map (
      DATA_WIDTH       => DATA_WIDTH,
      ADDRESS_WIDTH    => ADDRESS_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i          => wb_clk_i,
      wb_rst_i          => wb_rst_i,
      -- Wishbone master interface to transport layer
      -- Wishbone master signals
      wbm_cyc_o         => buffer_wbm_cyc,
      wbm_stb_o         => top_recv_wb_stb,
      wbm_dat_o         => top_recv_wb_dat,
      wbm_ack_i         => buffer_wbm_ack,
      -- Wishbone slave interface from ip_receive
      -- Wishbone slave signals
      wbs_cyc_i         => (link_recv_wbm_cyc or buffer_reload),
      wbs_stb_i         => link_recv_wbm_stb,
      wbs_dat_i         => link_recv_wbm_dat,
      wbs_ack_o         => link_recv_wbm_ack,
      -- Wishbone header slave interface, with same cyc_i as above.
      load              => link_recv_wbm_cyc,
      match_ack         => buffer_match,
      length_in         => (link_recv_length_out - PTP_HEADER_BYTE_LENGTH),
      length_out        => recv_length_out,
      -- Non-wishbone slave inputs synced with above
      src_id_in         => link_recv_src_id_out,
      dest_id_in        => link_recv_dest_id_out,
      opcode_in         => link_recv_opcode_out,
      checksum_error_in => '0', --link_recv_checksum_error,
      -- Non-wishbone master outputs synced with above
      src_id_out        => recv_src_id_out,
      dest_id_out       => recv_dest_id_out,
      opcode_out        => recv_opcode_out,
      -- assert to replay last loaded buffer.
      reload            => buffer_reload,
      debug_led_out     => buffer_debug_led_out
    );

-------------------------------------------------------------------------------
-- Transmit arbiter from either link-layer receiver or application layer
    xmit_arbiter : wb_intercon
      generic map (
        MASTER_COUNT  => 2
        )
      port map (
        wb_clk_i      => wb_clk_i,
        wb_rst_i      => wb_rst_i,

        wbm_cyc_i     => (xmit_wbs_cyc_i, route_recv_wbm_cyc),
        wbm_stb_i     => (xmit_wbs_stb_i, top_recv_wb_stb),
        wbm_dat_i     => (xmit_wbs_dat_i, top_recv_wb_dat),
        wbm_ack_o     => xmit_arbiter_ack,
        wbm_gnt_o     => xmit_arbiter_gnt,

        wbs_cyc_o     => link_xmit_wbs_cyc,
        wbs_stb_o     => link_xmit_wbs_stb,
        wbs_dat_o     => link_xmit_wbs_dat,
        wbs_ack_i     => link_xmit_wbs_ack
        );

    xmit_wbs_ack_o    <= xmit_arbiter_ack(0);

    route_recv_wbm_cyc <= buffer_wbm_cyc when (router_forward) else '0';
    buffer_wbm_ack     <= xmit_arbiter_ack(1) when (router_forward) else
                          recv_wbm_ack_i;
    recv_wbm_stb_o     <= top_recv_wb_stb;
    recv_wbm_dat_o     <= top_recv_wb_dat;

    with xmit_arbiter_gnt select
      link_xmit_src_id <=
      self_id_in       when B"10",
      recv_src_id_out  when others;
    with xmit_arbiter_gnt select
      link_xmit_dest_id <=
      xmit_dest_id_in  when B"10",
      recv_dest_id_out when others;
    with xmit_arbiter_gnt select
      link_xmit_opcode <=
      xmit_opcode_in   when B"10",
      recv_opcode_out  when others;
    with xmit_arbiter_gnt select
      link_xmit_length <=
      xmit_length_in   when B"10",
      recv_length_out  when others;
-------------------------------------------------------------------------------
-- Routing process
  receiving : process(wb_rst_i, wb_clk_i)

    type route_state_type is (
      idle,
      forward_start,
      forward_stop,
      pass_up_recv
    );

    variable state          : route_state_type;
    variable forward_reload : boolean;

  begin

    if (wb_rst_i = '1') then
      recv_wbm_cyc_o <= '0';
      router_forward <= false;
      forward_reload := false;
      buffer_reload <= '0';

    elsif (rising_edge(wb_clk_i)) then
     case (state) is
       when idle =>
         if (buffer_wbm_cyc = '1') then
           if ((recv_dest_id_out = self_id_in) or
               (recv_dest_id_out = PTP_BROADCAST_ID)) then
             -- if a link-level message is for us, receive it now
             state          := pass_up_recv;
             recv_wbm_cyc_o <= '1';
             if (recv_dest_id_out = PTP_BROADCAST_ID) then
               forward_reload := true;
             end if;
           else
             forward_reload := true;
             -- otherwise forward it
             router_forward <= true;
             state          := forward_start;
           end if;  
--          elsif (forward_reload) then
--            buffer_reload  <= '1';
--            router_forward <= true;
--            state          := forward_start;
         end if;

       when forward_start =>
         if (buffer_wbm_cyc = '1') then
           buffer_reload  <= '0';
           forward_reload := false;
           state          := forward_stop;
         end if;

       when forward_stop =>
         if (buffer_wbm_cyc = '0') then
           router_forward <= false;
           state := idle;
         end if;

       when pass_up_recv =>
         if (buffer_wbm_cyc = '0') then
           recv_wbm_cyc_o <= '0';
           if (forward_reload) then
             buffer_reload  <= '1';
             router_forward <= true;
             state          := forward_start;
           else
             state          := idle;
           end if;
         end if;

       when others =>
         recv_wbm_cyc_o <= '0';
         router_forward <= false;
         forward_reload := false;
         buffer_reload <= '0';
         state := idle;

     end case;

    end if; -- rising_edge(wb_clk_i)

  end process;
    
])
