dnl-*-VHDL-*-
-- Pulse Transfer Protocol Debugging module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

ptp_unit_([ptp_debug], dnl
  [dnl -- Generics ------------------------------------------------------------
],[dnl -- Ports ---------------------------------------------------------------
   led_wb_cyc_o : out    std_logic;
   led_wb_dat_o : buffer byte;
   led_wb_stb_o : out    std_logic;
   led_wb_ack_i : in     std_logic;
   self_mac_byte: in     byte;
],[dnl -- Declarations --------------------------------------------------------
   signal subopcode : ptp_opcode_type;
],[dnl -- Additional State Names ----------------------------------------------
   extract_subopcode,
   extract_suboperands,
   send_reply,
   wait_reply_subopcode_ack,
   wait_reply_led_ack,
   wait_reply_release,
   wait_led_process,
   wait_led_slave_release,
],[dnl -- Reset Behaviour -----------------------------------------------------
   led_wb_cyc_o <= '0';
   led_wb_stb_o <= '0';
],[dnl -- Cyc Behaviour -------------------------------------------------------
            xmit_dest_id_out <= recv_src_id_in;
            ack_enable       <= '1';
            state            := extract_subopcode;
],[dnl -- Additional State Behaviour ------------------------------------------
        when extract_subopcode =>
          debug_led_out(3 downto 0) <= B"0001";
          if (recv_wbs_stb_i = '1') then
            subopcode <= recv_wbs_dat_i;
            state := extract_suboperands;
          end if;
-------------------------------------------------------------------------------
        when extract_suboperands =>
          debug_led_out(3 downto 0) <= B"0010";
          if (recv_wbs_stb_i = '1') then
            case (subopcode) is
              when PTP_DEBUG_LED_SUBOPCODE =>
                led_wb_dat_o <= recv_wbs_dat_i;
                led_wb_cyc_o <= '1';
                led_wb_stb_o <= '1';
                state := wait_led_process;
              when PTP_DEBUG_MAC_SUBOPCODE =>
                state := send_reply;
              when others =>
                null;
            end case;
          end if;
-------------------------------------------------------------------------------
        when send_reply =>
          state := send_reply;
          xmit_wbm_cyc_o <= '1';
          xmit_wbm_stb_o <= '1';
          xmit_wbm_dat_o <= subopcode;
          state := wait_reply_subopcode_ack;
-------------------------------------------------------------------------------
        when wait_reply_subopcode_ack =>
          if (xmit_wbm_ack_i = '1') then
            case (subopcode) is
              when PTP_DEBUG_LED_SUBOPCODE =>
                xmit_wbm_dat_o <= led_wb_dat_o;
              when PTP_DEBUG_MAC_SUBOPCODE =>
                xmit_wbm_dat_o <= self_mac_byte;
              when others => null;
            end case;
            state := wait_reply_led_ack;
          end if;
-------------------------------------------------------------------------------
        when wait_reply_led_ack =>
          if (xmit_wbm_ack_i = '1') then
            xmit_wbm_stb_o <= '0';
            state := wait_reply_release;
          end if;
-------------------------------------------------------------------------------
        when wait_reply_release =>
          if (xmit_wbm_ack_i = '0') then
            xmit_wbm_cyc_o <= '0';
            state := done_state;
          end if;
-------------------------------------------------------------------------------
        when wait_led_process =>
          if (led_wb_ack_i = '1') then
            led_wb_stb_o <= '0';
            state        := wait_led_slave_release;
          end if;
-------------------------------------------------------------------------------
        when wait_led_slave_release =>
          if (led_wb_ack_i = '0') then
            led_wb_cyc_o <= '0';
            state        := send_reply;
          end if;
],[dnl -- Async Assignments ---------------------------------------------------
  xmit_opcode_out      <= PTP_DEBUG_REPLY_OPCODE;
  xmit_length_out      <= X"0002";
])
