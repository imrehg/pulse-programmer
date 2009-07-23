dnl-*-VHDL-*-
-- Pulse Transfer Protocol trigger and program loading module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

ptp_unit_([ptp_trigger], dnl
  [dnl -- Generics ------------------------------------------------------------
],[dnl -- Ports ---------------------------------------------------------------
   current_trigger_out  : out trigger_index_type;
   pcp_start_addr_out   : out sram_address_type;
],[dnl -- Declarations --------------------------------------------------------
  signal current_trigger : trigger_index_type;
],[dnl -- Additional State Names ----------------------------------------------
   extract_subopcode,
   extract_prefix,
   extract_address_high_byte,
   extract_address_low_byte,
   extract_length_high_byte,
   extract_length_low_byte,
   extract_trigger_source,
   send_reply,
   wait_ack,
],[dnl -- Reset Behaviour -----------------------------------------------------
],[dnl -- Cyc Behaviour -------------------------------------------------------
            xmit_dest_id_out <= recv_src_id_in;
            state            := extract_trigger_source;
            ack_enable     <= '1';
],[dnl -- Additional State Behaviour ------------------------------------------
        when extract_trigger_source =>
          if (recv_wbs_stb_i = '1') then
            current_trigger <= to_integer(unsigned(recv_wbs_dat_i));
            state := extract_prefix;
          end if;
        -----------------------------------------------------------------------
        when extract_prefix =>
          if (recv_wbs_stb_i = '1') then
            pcp_start_addr_out(18 downto 16) <= recv_wbs_dat_i(5 to 7);
            state := extract_address_high_byte;
          end if;
          debug_led_out <= recv_wbs_dat_i;
        -----------------------------------------------------------------------
        when extract_address_high_byte =>
          if (recv_wbs_stb_i = '1') then
            pcp_start_addr_out(15 downto 8) <= recv_wbs_dat_i;
            state := extract_address_low_byte;
          end if;
          debug_led_out <= recv_wbs_dat_i;
        -----------------------------------------------------------------------
        when extract_address_low_byte =>
          if (recv_wbs_stb_i = '1') then
            pcp_start_addr_out(7 downto 0) <= recv_wbs_dat_i;
            state := extract_length_high_byte;
          end if;
          debug_led_out <= recv_wbs_dat_i;
        -----------------------------------------------------------------------
        when extract_length_high_byte =>
          if (recv_wbs_stb_i = '1') then
--            pcp_dma_length_out(0 to 7) <= unsigned(recv_wbs_dat_i);
            state := extract_length_low_byte;
          end if;
          debug_led_out <= recv_wbs_dat_i;
        -----------------------------------------------------------------------
        when extract_length_low_byte =>
          if (recv_wbs_stb_i = '1') then
--            pcp_dma_length_out(8 to 15) <= unsigned(recv_wbs_dat_i);
            -- ack out any errant bytes
            ack_enable <= '1';
            state      := send_reply;
          end if;
          debug_led_out <= recv_wbs_dat_i;
        -----------------------------------------------------------------------
        when send_reply =>
          if (recv_wbs_cyc_i = '0') then
            xmit_wbm_cyc_o  <= '1';
            xmit_wbm_stb_o  <= '1';
            -- the first payload byte of reply is always the trigger source
            xmit_wbm_dat_o <= std_logic_vector(to_unsigned(current_trigger,
                                                           DATA_WIDTH));
            state := wait_ack;
          end if;
        -----------------------------------------------------------------------
        when wait_ack =>
          ack_enable <= '0';            
          if (xmit_wbm_ack_i = '1') then
            xmit_wbm_stb_o <= '0';
            state := done_state;
          end if;
],[dnl -- Async Assignments ---------------------------------------------------
  xmit_opcode_out     <= PTP_TRIGGER_REPLY_OPCODE;
  xmit_length_out     <= X"0001";
  current_trigger_out <= current_trigger;
])
