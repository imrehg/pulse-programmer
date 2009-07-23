---*-VHDL-*-
-- UDP receive module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Decodes a UDP packet according to IETF RFC 768.

-------------------------------------------------------------------------------
transport_receive_unit_([udp_receive],
[dnl-- GENERICS ---------------------------------------------------------------
 ],
[dnl-- PORT -------------------------------------------------------------------
    src_port_out        : out    udp_port_type;
    dest_port_out       : out    udp_port_type;
    length_out          : out    udp_length_type;
    src_ip_addr_in      : in     ip_address;
--    dest_ip_addr_in     : in     ip_address;
    src_ip_addr_out     : out    ip_address;
],
[dnl-- BYTE COUNT RANGE -------------------------------------------------------
UDP_HEADER_BYTE_LENGTH],
[dnl-- RECEIVER HEADER ENTRIES ------------------------------------------------
  [dnl --- Source Port
                src_ip_addr_out            <= src_ip_addr_in;  -- abuse
                checksum_word_in (0 to 7)  <= wbs_dat_i;
                src_port_out     (0 to 7)  <= wbs_dat_i;           ],
  [dnl
                checksum_word_in (8 to 15) <= wbs_dat_i;
                src_port_out     (8 to 15) <= wbs_dat_i;           ],
  [dnl --- Destination Port
                dest_port_out    (0 to  7) <= wbs_dat_i;
                checksum_word_in (0 to  7) <= wbs_dat_i;           ],
  [dnl
                dest_port_out    (8 to 15) <= wbs_dat_i;
                checksum_word_in (8 to 15) <= wbs_dat_i;           ],
  [dnl --- Length
                length_out       (0 to  7) <= unsigned(wbs_dat_i);
                checksum_word_in (0 to  7) <= wbs_dat_i;           ],
  [dnl
                length_out       (8 to 15) <= unsigned(wbs_dat_i);
                checksum_word_in (8 to 15) <= wbs_dat_i;           ],
  [dnl --- Checksum
                received_checksum(0 to  7) <= wbs_dat_i;
                checksum_word_in (0 to  7) <= wbs_dat_i;           ],
  [dnl
                received_checksum(8 to 15) <= wbs_dat_i;
                checksum_word_in (8 to 15) <= wbs_dat_i;           ]])
