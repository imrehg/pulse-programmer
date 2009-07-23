dnl-*-VHDL-*-
-- AVR interface to the PTP.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

avr_interface_unit_([ptp_avr_interface], dnl
  [dnl -- Ports ---------------------------------------------------------------
   self_id_in : in ptp_id_type;
],[dnl -- Write Address Decoding ----------------------------------------------
          when AVR_PTP_XMIT_BUFFER_HIGH_BYTE =>
            xmit_buffer_start_out(15 downto 8) <= data_port_in;
          when AVR_PTP_XMIT_BUFFER_LOW_BYTE =>
            xmit_buffer_start_out( 7 downto 0) <= data_port_in;
          when AVR_PTP_RECV_BUFFER_HIGH_BYTE =>
            recv_buffer_start_out(15 downto 8) <= data_port_in;
          when AVR_PTP_RECV_BUFFER_LOW_BYTE =>
            recv_buffer_start_out( 7 downto 0) <= data_port_in;
          when AVR_PTP_XMIT_LENGTH_HIGH_BYTE =>
            xmit_length_out      (0 to 7) <= unsigned(data_port_in);
          when AVR_PTP_XMIT_LENGTH_LOW_BYTE =>
            xmit_length_out      (8 to 15) <= unsigned(data_port_in);
],[dnl -- Read Address Decoding -----------------------------------------------
          when AVR_PTP_RECV_LENGTH_HIGH_BYTE =>
            data_port_out <= std_logic_vector(recv_length_in(0 to 7));
          when AVR_PTP_RECV_LENGTH_LOW_BYTE =>
            data_port_out <= std_logic_vector(recv_length_in(8 to 15));
          when AVR_PTP_SELF_ID =>
            data_port_out <= self_id_in;
])
