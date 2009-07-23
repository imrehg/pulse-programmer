---*-VHDL-*-
-- Pulse Transfer Protocol receive module
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

network_receive_unit_([ptp_receive],
[dnl -- GENERICS --------------------------------------------------------------
 ],
[dnl -- PORT ------------------------------------------------------
    -- Non-wishbone slave interface, synced to signals above
    src_id_out          : out ptp_id_type;
    dest_id_out         : out ptp_id_type;
    major_version_out   : out byte;
    minor_version_out   : out byte;
    opcode_out          : out ptp_opcode_type;
    length_out          : out ptp_length_type;
],
[dnl -- DECLARATIONS ----------------------------------------------------------
],
[dnl -- BYTE COUNT RANGE ------------------------------------------------------
    PTP_HEADER_BYTE_LENGTH],
[dnl -- RECEIVER HEADER ENTRIES -----------------------------------------------
  [dnl --- Source ID
                src_id_out                 <= wbs_dat_i;           ],
  [dnl --- Destination ID
                dest_id_out                <= wbs_dat_i;           ],
  [dnl --- Firmware Version Number
                major_version_out          <= wbs_dat_i;           ],
  [dnl
                minor_version_out          <= wbs_dat_i;           ],
  [dnl --- Opcode
                opcode_out                 <= wbs_dat_i;           ],
  [dnl --- Zero
                                                                   ],
  [dnl --- Length
                length_out       (0 to  7) <= unsigned(wbs_dat_i); ],
  [dnl
                length_out       (8 to 15) <= unsigned(wbs_dat_i); ],
  [dnl --- Checksum
                received_checksum(0 to  7) <= wbs_dat_i;           ],
  [dnl
                received_checksum(8 to 15) <= wbs_dat_i;           ]
])
