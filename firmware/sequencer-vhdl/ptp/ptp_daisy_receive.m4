---*-VHDL-*-
-- PTP daisy-chain receiver module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
unit_([ptp_daisy_receive], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
   STABLE_COUNT  : positive := 3;
   ABORT_TIMEOUT : positive := 10;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   -- Wishbone Daisy-chain transmit interface
wb_recv_master_port_
   debug_led_out      : out byte;
   busy_out           : out boolean;
   -- Wishbone daisy-chain receive interface
   -- Non-Wishbone physical daisy-chain pins
   daisy_xmit_stb_ack : out std_logic;
   daisy_xmit_dat_cyc : out std_logic;
   daisy_recv_stb_ack : in  std_logic;
   daisy_recv_dat_cyc : in  std_logic;
],[dnl -- Declarations --------------------------------------------------------
  signal recv_byte        : std_logic_vector(0 to 7);  
  signal bit_count        : natural range 0 to 10;
  signal xmit_stb_ack     : std_logic;
  signal xmit_dat_cyc     : std_logic;
  signal ack_stable_count : natural range 0 to STABLE_COUNT+1;
  signal cyc_stable_count : natural range 0 to STABLE_COUNT+1;
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
      receive_start,
      receive_bit,
      receive_bit_ack,
      receive_wb_ack,
      receive_last_bit,
      receive_byte_done,
      receive_stop,
      timed_out
      );

    variable state : daisy_state_type;

  begin

    if (wb_rst_i = '1') then
      state            := idle;
      xmit_stb_ack     <= '0';
      xmit_dat_cyc     <= '0';
      recv_wbm_cyc_o   <= '0';
      recv_wbm_stb_o   <= '0';
      ack_stable_count <= 0;
      cyc_stable_count <= 0;
      timeout_counter  <= 0;
      busy_out         <= false;

    elsif (rising_edge(wb_clk_i)) then

      case (state) is
-------------------------------------------------------------------------------
        when idle =>
          debug_led_out(3 downto 0) <= B"0001";
          -- wait for our transmitter, then ack it
          if ((daisy_recv_stb_ack = '0') and (daisy_recv_dat_cyc = '1')) then
            if (ack_stable_count >= STABLE_COUNT-1) then
              recv_wbm_cyc_o   <= '1';
              xmit_stb_ack     <= '1';
              xmit_dat_cyc     <= '1';
              ack_stable_count <= 0;
              timeout_counter  <= 0;
              busy_out         <= true;
              state            := receive_start;
            else
              ack_stable_count <= ack_stable_count + 1;
            end if;
          else
            ack_stable_count <= 0;
          end if;
-------------------------------------------------------------------------------
        when receive_start =>
          debug_led_out(3 downto 0) <= B"0010";
          -- wait for our transmitter's signals to go low and then lower acks
ptp_stable_timeout_(dnl
[(daisy_recv_stb_ack = '0') and (daisy_recv_dat_cyc = '0')],
[
              xmit_stb_ack     <= '0';
              xmit_dat_cyc     <= '0';
              bit_count        <= 0;
],[receive_bit],[idle])
-------------------------------------------------------------------------------
        when receive_bit =>
          debug_led_out(3 downto 0) <= B"0011";

          if (bit_count >= 8) then
            -- if this is the last bit, signal ack and
            -- latch out byte to Wishbone slave
            if (ack_stable_count >= STABLE_COUNT) then
              recv_wbm_stb_o   <= '1';
              recv_wbm_dat_o   <= recv_byte;
              xmit_stb_ack     <= '1';
              timeout_counter  <= 0;
              ack_stable_count <= 0;
              state            := receive_wb_ack;
            else
              ack_stable_count <= ack_stable_count + 1;
            end if;
          else
            if (daisy_recv_stb_ack = '1') then
              if (ack_stable_count >= STABLE_COUNT-1) then
                -- latch the next bit from our daisy-chain transmitter
                bit_count        <= bit_count + 1;
                recv_byte        <= daisy_recv_dat_cyc & recv_byte(0 to 6);
                xmit_stb_ack     <= '1';
                ack_stable_count <= 0;
                timeout_counter  <= 0;
                state            := receive_bit_ack;
              else
                ack_stable_count <= ack_stable_count + 1;
              end if;
            else
              ack_stable_count <= 0;
              if (daisy_recv_dat_cyc = '1') then
                if (cyc_stable_count >= STABLE_COUNT-1) then
                  -- transmitter is signalling end
                  xmit_stb_ack     <= '1';
                  xmit_dat_cyc     <= '1';
                  cyc_stable_count <= 0;
                  timeout_counter  <= 0;
                  state            := receive_stop;
                else
                  cyc_stable_count <= cyc_stable_count + 1;
                end if;
              else
                cyc_stable_count <= 0;
                 if (timeout_counter >= ABORT_TIMEOUT-1) then
                   state := timed_out;
                 else
                   timeout_counter <= timeout_counter + 1;
                 end if;
              end if;
            end if;
          end if;
-------------------------------------------------------------------------------
        when receive_bit_ack =>
          debug_led_out(3 downto 0) <= B"0100";
ptp_stable_timeout_(dnl
[(daisy_recv_stb_ack = '0')],
[
              xmit_stb_ack     <= '0';
],[receive_bit])
-------------------------------------------------------------------------------
        when receive_wb_ack =>
          debug_led_out(3 downto 0) <= B"0101";
          if (recv_wbm_ack_i = '1') then
            recv_wbm_stb_o <= '0';
            state := receive_last_bit;
          end if;
-------------------------------------------------------------------------------
        when receive_last_bit =>
          debug_led_out(3 downto 0) <= B"0110";
ptp_stable_timeout_(dnl
[(daisy_recv_stb_ack = '1')],
[
              xmit_stb_ack     <= '0';
],[receive_byte_done])
-------------------------------------------------------------------------------
        when receive_byte_done =>
          debug_led_out(3 downto 0) <= B"0111";
          bit_count <= 0;
          if ((recv_wbm_ack_i = '0') and (daisy_recv_stb_ack = '0')) then
            -- wait for both slave's ack and daisy master's strobe to fall
            state := receive_bit;
          end if;
-------------------------------------------------------------------------------
        when receive_stop =>
          debug_led_out(3 downto 0) <= B"1000";
          recv_wbm_cyc_o <= '0';
          if ((daisy_recv_stb_ack = '0') and (daisy_recv_dat_cyc = '0')) then
            if (ack_stable_count >= STABLE_COUNT-1) then
              xmit_stb_ack     <= '0';
              xmit_dat_cyc     <= '0';
              ack_stable_count <= 0;
              timeout_counter  <= 0;
              busy_out         <= false;
              state            := idle;
            else
              ack_stable_count <= ack_stable_count + 1;
            end if;
          else
            ack_stable_count <= 0;
          end if;
-------------------------------------------------------------------------------
        when others =>
          -- timed_out
          debug_led_out(3 downto 0) <= B"1001";
          xmit_stb_ack     <= '0';
          xmit_dat_cyc     <= '0';
          ack_stable_count <= 0;
          cyc_stable_count <= 0;
          timeout_counter  <= 0;
          busy_out         <= true;
          -- give our master a chance to terminate us
          state            := receive_bit;
-------------------------------------------------------------------------------
      end case;

    end if; -- rising_edge(wb_clk_i)

  end process;

])
