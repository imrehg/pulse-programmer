---*-VHDL-*-
-- ICMP transmit module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Decodes an ICMP packet according to IETF RFC 792.

-------------------------------------------------------------------------------
transport_transmit_unit_([icmp_transmit], dnl
  [dnl -- GENERICS ------------------------------------------------------------
    ADDRESS_WIDTH       : positive := 6;
],[dnl -- PORT ----------------------------------------------------------------
    -- Non-wishbone slave interface, synced to signals above
    type_in             : in  icmp_type_type;
    id_in               : in  icmp_id_type;
    sequence_in         : in  icmp_sequence_type;
    length_in           : in  ip_total_length;],
[dnl -- BYTE COUNT RANGE ------------------------------------------------------
ICMP_HEADER_BYTE_LENGTH],
[dnl -- CHECKSUM ADDRESS ------------------------------------------------------
2],
[dnl -- Transmit Header -------------------------------------------------------
  [dnl --- Type
                mem_dat_i                  <= type_in;
                checksum_word_in           <= type_in & X"00";  ],
  [dnl --- Code (zero)
                mem_dat_i                  <= X"00";            ],
  [dnl --- Checksum Placeholder
                mem_dat_i                  <= X"00";
                checksum_word_in           <= X"0000";          ],
  [dnl
                mem_dat_i                  <= X"00";            ],
  [dnl --- Identification
                mem_dat_i                  <= id_in( 0 to  7);
                checksum_word_in           <= id_in;            ],
  [dnl
                mem_dat_i                  <= id_in( 8 to 15);  ],
  [dnl --- Sequence
                mem_dat_i                  <= sequence_in(0 to  7);
                checksum_word_in           <= sequence_in;          ],
  [dnl
                mem_dat_i                  <= sequence_in(8 to 15); ]
],[dnl --- Pseudo-Header Entries
],[dnl --- Memory End
length_in])
