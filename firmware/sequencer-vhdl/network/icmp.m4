---*-VHDL-*-
-- Top-level ICMP module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Currently only handles echo requests and replies.
-- IETF RFC 792.

unit_([icmp], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
    ADDRESS_WIDTH : positive := 7;       -- 2**7 = 128 byte ping data
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
    debug_led_out         : out byte;
    -- Wishbone master interface (from icmp_transmit to to ip_transmit)
wb_xmit_master_port_
--    ip_wbm_err_i        : in  std_logic;
    xmit_dest_addr_out    : out ip_address;
    xmit_protocol_out     : out ip_protocol;
    xmit_id_out           : out ip_id;
    xmit_total_length_out : out ip_total_length;
    xmit_dont_fragment    : out std_logic;
    -- Wishbone slave interface (from ip_receive to icmp_receive)
wb_recv_slave_port_
    recv_src_addr_in      : in  ip_address;
    recv_dest_addr_in     : in  ip_address;
    recv_protocol_in      : in  ip_protocol;
    recv_id_in            : in  ip_id;
    recv_total_length_in  : in  ip_total_length;
],[dnl -- Declarations --------------------------------------------------------
  constant ICMP_DEFAULT_ID : ip_id := X"2222";

  signal recv_cyc          : std_logic;
  signal recv_ack          : std_logic;
  signal xmit_cyc          : std_logic;

icmp_transmit_component_
icmp_receive_component_

  signal icmp_id           : icmp_id_type;
  signal icmp_sequence     : icmp_sequence_type;
  signal icmp_wb_cyc       : std_logic;
  signal icmp_wb_stb       : std_logic;
  signal icmp_wb_dat       : std_logic_vector(0 to DATA_WIDTH-1);
  signal icmp_wb_ack       : std_logic;
  signal icmp_total_length : ip_total_length;
  signal icmp_type         : icmp_type_type;

  signal icmp_discard      : boolean;
  signal master_hold       : boolean;
],[dnl -- Body ----------------------------------------------------------------
  xmit_dont_fragment    <= '1';
  xmit_protocol_out     <= ICMP_PROTOCOL_TYPE;
  xmit_dest_addr_out    <= recv_src_addr_in;
  xmit_id_out           <= recv_id_in;
  icmp_total_length     <= recv_total_length_in;
  xmit_total_length_out <= recv_total_length_in;

--   debug_led_out(7)          <= recv_wbs_cyc_i;
--   debug_led_out(6)          <= icmp_wb_cyc;
--   debug_led_out(5)          <= recv_wbs_ack_o;
--   debug_led_out(4)          <= icmp_wb_ack;
--   debug_led_out(3 downto 0) <= icmp_type(4 to 7);
  debug_led_out <= icmp_type;

  -- loop back auxiliary signals
  process(wb_rst_i, wb_clk_i, recv_wbs_cyc_i)

  begin

    if (rising_edge(wb_clk_i)) then
      if ((recv_wbs_cyc_i = '1') and
          (recv_protocol_in = ICMP_PROTOCOL_TYPE)) then
        recv_cyc       <= '1';
      else
        recv_cyc       <= '0';
      end if;
      if (icmp_wb_cyc = '1') then
        if (recv_wbs_cyc_i = '0') then
          master_hold <= false;
        end if;
        if (icmp_type = ICMP_ECHO_REQUEST_TYPE) then
          xmit_cyc     <= '1';
        else
          xmit_cyc     <= '0';
          icmp_discard <= true;
        end if;
      else
        xmit_cyc       <= '0';
        icmp_discard   <= false;
        if (recv_wbs_cyc_i = '1') then
          master_hold    <= true;
        end if;
      end if;
    end if;

  end process;

  transmitter : icmp_transmit
    generic map (
      DATA_WIDTH      => DATA_WIDTH,
      ADDRESS_WIDTH   => ADDRESS_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i        => wb_clk_i,
      wb_rst_i        => wb_rst_i,
      -- Wishbone master interface (e.g. to ip_transmit)
      wbm_cyc_o       => xmit_wbm_cyc_o,
      wbm_stb_o       => xmit_wbm_stb_o,
      wbm_dat_o       => xmit_wbm_dat_o,
      wbm_ack_i       => xmit_wbm_ack_i,
--      wbm_err_i       => ip_wbm_err_i,
      -- Wishbone slave interface (e.g. from top-level icmp)
      wbs_cyc_i       => xmit_cyc,
      wbs_stb_i       => icmp_wb_stb,
      wbs_dat_i       => icmp_wb_dat,
      wbs_ack_o       => icmp_wb_ack,
      -- Non-wishbone slave interface, synced to signals above
      type_in         => ICMP_ECHO_REPLY_TYPE,
      id_in           => icmp_id,
      sequence_in     => icmp_sequence,
      length_in       => icmp_total_length,
      debug_led_out   => xmit_debug_led_out
      );

  receiver : icmp_receive
    generic map (
      DATA_WIDTH      => DATA_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i       => wb_clk_i,
      wb_rst_i       => wb_rst_i,
      -- Wishbone master interface (to top-level icmp)
      wbm_cyc_o      => icmp_wb_cyc,
      wbm_stb_o      => icmp_wb_stb,
      wbm_dat_o      => icmp_wb_dat,
      wbm_ack_i      => recv_ack,
      type_out       => icmp_type,
      id_out         => icmp_id,
      sequence_out   => icmp_sequence,
--       checksum_error => icmp_checksum_error,
      -- Wishbone slave interface (from ip_receive)
      wbs_cyc_i      => recv_cyc,
      wbs_stb_i      => recv_wbs_stb_i,
      wbs_dat_i      => recv_wbs_dat_i,
      wbs_ack_o      => recv_wbs_ack_o,
      debug_led_out  => recv_debug_led_out
      );

  recv_ack <= icmp_wb_ack when (xmit_cyc = '1')               else
              icmp_wb_stb when (icmp_discard and master_hold) else '0';
])
