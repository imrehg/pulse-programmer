dnl-*-VHDL-*-
-- PTP module start module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

ptp_unit_([ptp_start], dnl
  [dnl -- Generics ------------------------------------------------------------
],[dnl -- Ports ---------------------------------------------------------------
   pcp_reset_out : out std_logic;
   avr_reset_out : out std_logic;
],[dnl -- Declarations --------------------------------------------------------
],[dnl -- Additional State Names ----------------------------------------------
   extract_subopcode,
   wait_ack,
],[dnl -- Reset Behaviour -----------------------------------------------------
        pcp_reset_out  <= '1';
        avr_reset_out  <= '1';
],[dnl -- Cyc Behaviour -------------------------------------------------------
        xmit_dest_id_out <= recv_src_id_in;
        xmit_wbm_cyc_o   <= '1';
        ack_enable       <= '1';
        state            := extract_subopcode;
],[dnl -- Additional State Behaviour ------------------------------------------
        when extract_subopcode =>
          debug_led_out(3 downto 0) <= B"0001";
          if (recv_wbs_stb_i = '1') then
            case (recv_wbs_dat_i) is
              when PTP_START_PCP_RESUME_SUBOPCODE =>
                pcp_reset_out <= '0';
              when PTP_START_PCP_SUSPEND_SUBOPCODE =>
                pcp_reset_out <= '1';
              when PTP_START_AVR_RESUME_SUBOPCODE =>
                avr_reset_out <= '0';
              when PTP_START_AVR_SUSPEND_SUBOPCODE =>
                avr_reset_out <= '1';
              when others =>
                null;
            end case;
            xmit_wbm_stb_o <= '1';
            xmit_wbm_dat_o <= recv_wbs_dat_i;
            state := wait_ack;
          end if;
-------------------------------------------------------------------------------
        when wait_ack =>
          if (xmit_wbm_ack_i = '1') then
            xmit_wbm_stb_o <= '0';
            state := done_state;
          end if;
],[dnl -- Async Assignments ---------------------------------------------------
  xmit_opcode_out      <= PTP_START_REPLY_OPCODE;
  xmit_length_out      <= X"0001";
])
