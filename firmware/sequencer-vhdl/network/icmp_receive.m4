---*-VHDL-*-
-- ICMP receive module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Decodes an ICMP packet according to IETF RFC 792.

-------------------------------------------------------------------------------
transport_receive_unit_([icmp_receive],
[dnl-- GENERICS ---------------------------------------------------------------
 ],
[dnl-- PORT -------------------------------------------------------------------
    type_out            : out    icmp_type_type;
    id_out              : out    icmp_id_type;
    sequence_out        : out    icmp_sequence_type;
],
[dnl-- BYTE COUNT RANGE -------------------------------------------------------
ICMP_HEADER_BYTE_LENGTH],
[dnl-- RECEIVER HEADER ENTRIES ------------------------------------------------
  [dnl -- Type
                checksum_word_in (0 to 7)  <= wbs_dat_i;
                type_out                   <= wbs_dat_i;  ],
  [dnl -- Zero
                checksum_word_in (8 to 15) <= wbs_dat_i;  ],
  [dnl -- Checksum
                received_checksum(0 to  7) <= wbs_dat_i;
                checksum_word_in (0 to  7) <= X"00";      ],
  [dnl
                received_checksum(8 to 15) <= wbs_dat_i;
                checksum_word_in (8 to 15) <= X"00";      ],
  [dnl -- Identification
                id_out           (0 to  7) <= wbs_dat_i;
                checksum_word_in (0 to  7) <= wbs_dat_i;  ],
  [dnl
                id_out           (8 to 15) <= wbs_dat_i;
                checksum_word_in (8 to 15) <= wbs_dat_i;  ],
  [dnl -- Sequence
                sequence_out     (0 to  7) <= wbs_dat_i;
                checksum_word_in (0 to  7) <= wbs_dat_i;  ],
  [dnl
                sequence_out     (8 to 15) <= wbs_dat_i;
                checksum_word_in (8 to 15) <= wbs_dat_i;  ]])
