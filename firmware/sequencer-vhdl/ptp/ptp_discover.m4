dnl-*-VHDL-*-
-- Pulse Transfer Protocol Discover module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

ptp_unit_([ptp_discover], dnl
  [dnl -- Generics ------------------------------------------------------------
],[dnl -- Ports ---------------------------------------------------------------
   mac_byte_in     : in  byte;
   self_id_out     : out ptp_id_type;
],[dnl -- Declarations --------------------------------------------------------
   signal slave_id   : ptp_id_type;
   signal self_id    : ptp_id_type;
   signal discovered : boolean;
],[dnl -- Additional State Names ----------------------------------------------
   extract_id         ,
   initiate_slave     ,
   initiate_slave_ack ,
   generate_reply     ,
   return_mac_byte    ,
   generate_reply_ack ,
   generate_reply_done,
],[dnl -- Reset Behaviour -----------------------------------------------------
   self_id_out <= PTP_AUTO_SELF_ID;
   discovered  <= false;
],[dnl -- Cyc Behaviour -------------------------------------------------------
    state := extract_id;
    ack_enable <= '1';
],[dnl -- Additional State Behaviour ------------------------------------------
        when extract_id =>
          xmit_wbm_dat_o   <= slave_id;
          if (discovered) then
            -- we can only be discovered once. like America.
            state := generate_reply;
          elsif (recv_wbs_stb_i = '1') then
            state       := initiate_slave;
            self_id     <= recv_wbs_dat_i;
            slave_id    <= std_logic_vector(unsigned(recv_wbs_dat_i) + 1);
          end if;
        -----------------------------------------------------------------------
        when initiate_slave =>
          xmit_wbm_cyc_o   <= '1';
          xmit_wbm_stb_o   <= '1';
          xmit_opcode_out  <= PTP_DISCOVER_REQUEST_OPCODE;
          xmit_dest_id_out <= PTP_AUTO_SELF_ID;
          state            := initiate_slave_ack;
        -----------------------------------------------------------------------
        when initiate_slave_ack =>
          if (xmit_wbm_ack_i = '1') then
            xmit_wbm_cyc_o <= '0';
            xmit_wbm_stb_o <= '0';
            state          := generate_reply;
          end if;
        -----------------------------------------------------------------------
        when generate_reply =>
          if (xmit_wbm_ack_i = '0') then
            xmit_wbm_cyc_o   <= '1';
            xmit_wbm_stb_o   <= '1';
            xmit_opcode_out  <= PTP_DISCOVER_REPLY_OPCODE;
            xmit_dest_id_out <= PTP_HOST_ID;
            -- update our ID here so the host knows we are discovered
            self_id_out    <= self_id;
--             xmit_dest_id_out <= recv_src_id_in;
            state := return_mac_byte;
          end if;
        -----------------------------------------------------------------------
        when return_mac_byte =>
          if (xmit_wbm_ack_i = '1') then
            xmit_wbm_dat_o  <= mac_byte_in;
            state := generate_reply_ack;
          end if;
        -----------------------------------------------------------------------
        when generate_reply_ack =>
          if (xmit_wbm_ack_i = '1') then
            xmit_wbm_stb_o <= '0';
            state          := generate_reply_done;
          end if;
        -----------------------------------------------------------------------
        when generate_reply_done =>
          if (xmit_wbm_ack_i = '0') then
            discovered <= true;
            state      := done_state;
          end if;
],[dnl -- Async Assignments ---------------------------------------------------
  xmit_length_out  <= X"0002";
])
