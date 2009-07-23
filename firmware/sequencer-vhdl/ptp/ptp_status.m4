dnl-*-VHDL-*-
-- PTP module status module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

ptp_unit_([ptp_status], dnl
  [dnl -- Generics ------------------------------------------------------------
],[dnl -- Ports ---------------------------------------------------------------
   pcp_reset_in            : in  std_logic;
   avr_reset_in            : in  std_logic;
   pcp_halted_in           : in  std_logic;
   current_trigger_in      : in  trigger_index_type;
   chain_initiator         : in  boolean;
   chain_terminator        : in  boolean;
],[dnl -- Declarations --------------------------------------------------------
],[dnl -- Additional State Names ----------------------------------------------
   report_status,
   report_scale,
   wait_ack,
],[dnl -- Reset Behaviour -----------------------------------------------------
],[dnl -- Cyc Behaviour -------------------------------------------------------
        xmit_dest_id_out <= recv_src_id_in;
        xmit_wbm_cyc_o   <= '1';
        ack_enable       <= '1';
        state            := report_status;
],[dnl -- Additional State Behaviour ------------------------------------------
        when report_status =>
          debug_led_out(3 downto 0) <= B"0001";
          xmit_wbm_dat_o(0 to 3) <=
            std_logic_vector(to_unsigned(current_trigger_in, 4));
          xmit_wbm_dat_o(4) <= avr_reset_in;
          xmit_wbm_dat_o(5) <= pcp_reset_in;
          if (chain_initiator) then
            xmit_wbm_dat_o(6) <= '1';
          else
            xmit_wbm_dat_o(6) <= '0';
          end if;
          if (chain_terminator) then
            xmit_wbm_dat_o(7) <= '1';
          else
            xmit_wbm_dat_o(7) <= '0';
          end if;
          xmit_wbm_stb_o <= '1';
          state := report_scale;
-------------------------------------------------------------------------------
        when report_scale =>
          if (xmit_wbm_ack_i = '1') then
            xmit_wbm_dat_o(0) <= pcp_halted_in;
            xmit_wbm_dat_o(1) <= '0';
            xmit_wbm_dat_o(2 to 7) <= (others => '0');
            state := wait_ack;
          end if;
-------------------------------------------------------------------------------
        when wait_ack =>
          if (xmit_wbm_ack_i = '1') then
            xmit_wbm_stb_o <= '0';
            state := done_state;
          end if;
],[dnl -- Async Assignments ---------------------------------------------------
  xmit_opcode_out      <= PTP_STATUS_REPLY_OPCODE;
  xmit_length_out      <= X"0002";
])
