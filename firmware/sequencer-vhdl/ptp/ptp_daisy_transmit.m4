---*-VHDL-*-
-- PTP daisy-chain transmitter module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([ptp_daisy_transmit], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
   STABLE_COUNT  : positive := 3;
   ABORT_TIMEOUT : positive := 10;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   -- Wishbone Daisy-chain transmit interface
wb_xmit_slave_port_
   debug_led_out          : out    byte;
   busy_out               : out    boolean;
   -- Wishbone daisy-chain receive interface
   -- Non-Wishbone physical daisy-chain pins
   daisy_xmit_stb_ack     : out    std_logic;
   daisy_xmit_dat_cyc     : out    std_logic;
   daisy_recv_stb_ack     : in     std_logic;
   daisy_recv_dat_cyc     : in     std_logic;
],[dnl -- Declarations --------------------------------------------------------
  signal xmit_byte        : std_logic_vector(0 to 7);  
  signal bit_count        : natural range 0 to 10;
  signal xmit_stb_ack     : std_logic;
  signal xmit_dat_cyc     : std_logic;
  signal ack_stable_count : natural range 0 to STABLE_COUNT+1;
  signal timeout_counter  : natural range 0 to ABORT_TIMEOUT+1;
],[dnl -- Body ----------------------------------------------------------------

  debug_led_out(7) <= xmit_stb_ack;
  debug_led_out(6) <= xmit_dat_cyc;
  debug_led_out(5) <= daisy_recv_stb_ack;
  debug_led_out(4) <= daisy_recv_dat_cyc;

  daisy_xmit_stb_ack <= xmit_stb_ack;
  daisy_xmit_dat_cyc <= xmit_dat_cyc;
   
  process(wb_clk_i, wb_rst_i)

    type daisy_state_type is (
      idle,
      transmit_start,
      transmit_start_ack,
      transmit_byte,
      transmit_bit_start,
      transmit_bit,
      transmit_bit_ack,
      transmit_byte_done,
      transmit_byte_done_ack,
      transmit_interbyte_wait,
      timed_out,
      transmit_stop,
      transmit_stop_ack
      );

    variable state : daisy_state_type;

  begin

    if (wb_rst_i = '1') then
      xmit_stb_ack   <= '0';
      xmit_dat_cyc   <= '0';
      xmit_wbs_ack_o <= '0';
      busy_out       <= false;
      state          := idle;

    elsif (rising_edge(wb_clk_i)) then

      case (state) is
-------------------------------------------------------------------------------
        when idle =>
          debug_led_out(3 downto 0) <= B"0001";
          if (xmit_wbs_cyc_i = '1') then
            busy_out         <= true;
            xmit_stb_ack     <= '0';
            xmit_dat_cyc     <= '1';
            ack_stable_count <= 0;
            timeout_counter  <= 0;
            state            := transmit_start;
          end if;
-------------------------------------------------------------------------------
        when transmit_start =>
          debug_led_out(3 downto 0) <= B"0010";
          -- wait for our receiver's signals to go high for ack
ptp_stable_timeout_(dnl
[(daisy_recv_stb_ack = '1') and (daisy_recv_dat_cyc = '1')],
[
              xmit_stb_ack     <= '0';
              xmit_dat_cyc     <= '0';
],[transmit_start_ack],[idle])
-------------------------------------------------------------------------------
        when transmit_start_ack =>
          debug_led_out(3 downto 0) <= B"0011";
          -- wait for our receiver's signals to go low to send next byte
ptp_stable_timeout_(dnl
[(daisy_recv_stb_ack = '0') and (daisy_recv_dat_cyc = '0')],
[
],[transmit_byte])
-------------------------------------------------------------------------------
        when transmit_byte =>
          debug_led_out(3 downto 0) <= B"0100";
          if (xmit_wbs_stb_i = '1') then
            -- latch our Wishbone master's input byte but ack it when done
            xmit_byte <= xmit_wbs_dat_i;
            bit_count <= 0;
            -- strobe our receiver
            state := transmit_bit_start;
          elsif (xmit_wbs_cyc_i = '0') then
            -- no more bytes from our Wishbone master
            state := transmit_stop;
          end if;
-------------------------------------------------------------------------------
        when transmit_bit_start =>
          debug_led_out(3 downto 0) <= B"0101";
          xmit_wbs_ack_o <= '0';
          bit_count <= bit_count + 1;
          xmit_byte <= B"0" & xmit_byte(0 to 6);
          if (bit_count >= 8) then
            xmit_stb_ack <= '0';
            xmit_dat_cyc <= '0';
            state        := transmit_byte_done;
          else 
            xmit_dat_cyc <= xmit_byte(7);
            xmit_stb_ack <= '1';
            state        := transmit_bit;
          end if;
-------------------------------------------------------------------------------
        when transmit_bit =>
          debug_led_out(3 downto 0) <= B"0110";
ptp_stable_timeout_(dnl
[daisy_recv_stb_ack = '1'],
[
              xmit_stb_ack <= '0';
              xmit_dat_cyc <= '0';
],[transmit_bit_ack])
-------------------------------------------------------------------------------
        when transmit_bit_ack =>
          debug_led_out(3 downto 0) <= B"0111";
          -- wait for receiver to acknowledge stb and latch data bit
ptp_stable_timeout_(dnl
[(daisy_recv_stb_ack = '0') and (daisy_recv_dat_cyc = '0')],
[
],[transmit_bit_start])
-------------------------------------------------------------------------------
        when transmit_byte_done =>
          debug_led_out(3 downto 0) <= B"1000";
          -- wait for receiver to strobe on "9th" bit
ptp_stable_timeout_(dnl
[daisy_recv_stb_ack = '1'],
[
            xmit_stb_ack <= '1';
            xmit_wbs_ack_o <= '1';
],[transmit_byte_done_ack])
-------------------------------------------------------------------------------
        when transmit_byte_done_ack =>
          xmit_wbs_ack_o <= '0';
          debug_led_out(3 downto 0) <= B"1001";
ptp_stable_timeout_(dnl
[daisy_recv_stb_ack = '0'],
[
              xmit_stb_ack <= '0';
],[transmit_interbyte_wait])
-------------------------------------------------------------------------------
        when transmit_interbyte_wait =>
          -- insert enough space between 9th bit ack and next byte
ptp_stable_timeout_(dnl
[daisy_recv_stb_ack = '0'],
[],[transmit_byte])
-------------------------------------------------------------------------------
        when timed_out =>
          debug_led_out(3 downto 0) <= B"1010";
          xmit_stb_ack <= '0';
          xmit_dat_cyc <= '0';
          ack_stable_count <= 0;
          timeout_counter <= 0;
          -- ack out the rest of our Wishbone master's data before stopping
          xmit_wbs_ack_o <= xmit_wbs_stb_i;
          if (xmit_wbs_cyc_i = '0') then
            state := transmit_stop;
          end if;
-------------------------------------------------------------------------------
        when transmit_stop =>
          debug_led_out(3 downto 0) <= B"1011";
          xmit_stb_ack <= '0';
          xmit_dat_cyc <= '1';
ptp_stable_timeout_(dnl          
[(daisy_recv_stb_ack = '1') and (daisy_recv_dat_cyc = '1')],
[
],[transmit_stop_ack])
-------------------------------------------------------------------------------
        when transmit_stop_ack =>
          debug_led_out(3 downto 0) <= B"1100";
          xmit_stb_ack <= '0';
          xmit_dat_cyc <= '0';
ptp_stable_timeout_(dnl
[(daisy_recv_stb_ack <= '0') and (daisy_recv_dat_cyc <= '0')],
[
          busy_out <= false;
],[idle])
-------------------------------------------------------------------------------
        when others =>
          -- timed out
          debug_led_out(3 downto 0) <= B"1101";
          busy_out         <= false;
          xmit_stb_ack     <= '0';
          xmit_dat_cyc     <= '0';
          ack_stable_count <= 0;
          timeout_counter  <= 0;
          state            := transmit_stop;
-------------------------------------------------------------------------------
      end case;

    end if; -- rising_edge(wb_clk_i)

  end process;

])
