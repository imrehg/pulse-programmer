---*-VHDL-*-
-- IP receive module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Decodes the IP header according to IETF RFC 791 and manages a collection
-- of buffers for reassembling datagrams.
-- Multiplexes this buffer to a single output to the transport layer,
-- which is responsible for handling the Wishbone payload based on the
-- non-Wishbone outputs of source/destination IP addresses, protocol, and id.

-------------------------------------------------------------------------------
network_receive_unit_([ip_receive],
[dnl -- GENERICS --------------------------------------------------------------
 ],
[dnl -- PORT ------------------------------------------------------
    src_ip_addr_out     : out    ip_address;
    dest_ip_addr_out    : out    ip_address;
    protocol_out        : out    ip_protocol;
    id_out              : out    ip_id;
    total_length_out    : out    ip_total_length;
    fragment_offset_out : out    ip_frag_offset;
    more_fragments_out  : out    std_logic;
],
[dnl -- DECLARATIONS ----------------------------------------------------------
    constant MAX_DATA_TOTAL_LENGTH : ip_total_length :=
      to_unsigned(MAX_FRAME_BYTE_COUNT - IP_MIN_HEADER_BYTE_LENGTH,
                  IP_TOTAL_LENGTH_WIDTH);

    constant IP_HEADER_FIRST_BYTE : nbyte :=
      IP_VERSION_FOUR & std_logic_vector(IP_MIN_HEADER_LENGTH);
],
[dnl -- BYTE COUNT RANGE ------------------------------------------------------
    IP_MIN_HEADER_BYTE_LENGTH],
[dnl -- RECEIVER HEADER ENTRIES -----------------------------------------------
  [dnl -- IP Version and Header Length
                if (wbs_dat_i /= IP_HEADER_FIRST_BYTE) then
                  state := pass_data;
                end if;
                checksum_word_in ( 0 to 7) <= IP_HEADER_FIRST_BYTE;         ],
  [dnl -- Service Type, ignored by our IP layer
                checksum_word_in ( 8 to 15) <= wbs_dat_i;                   ],
  [dnl -- Total IP Length
                total_length     ( 0 to  7) <= unsigned(wbs_dat_i);
                checksum_word_in ( 0 to  7) <= wbs_dat_i;                   ],
  [dnl 
                total_length     ( 8 to 15) <= unsigned(wbs_dat_i);
                checksum_word_in ( 8 to 15) <= wbs_dat_i;                   ],
  [dnl -- Identification
                total_length_out <= total_length - IP_MIN_HEADER_BYTE_LENGTH;
                id_out           ( 0 to  7) <= wbs_dat_i;
                checksum_word_in ( 0 to  7) <= wbs_dat_i;                   ],
  [dnl
                id_out           ( 8 to 15) <= wbs_dat_i;
                checksum_word_in ( 8 to 15) <= wbs_dat_i;                   ],
  [dnl -- Flags and Fragment Offset
                -- flags and fragment offset
                -- we don't care about the dont_fragment flag for receiving
--                 dont_fragment <= wbs_dat_i(1);
                more_fragments_out          <= wbs_dat_i(2);
                fragment_offset_out(0 to 4) <= unsigned(wbs_dat_i(3 to 7));
                checksum_word_in ( 0 to  7) <= wbs_dat_i;                   ],
  [dnl -- Fragment offset
                fragment_offset_out(5 to 12) <= unsigned(wbs_dat_i);
                checksum_word_in ( 8 to 15) <= wbs_dat_i;                   ],
  [dnl -- Time to Live
                checksum_word_in ( 0 to  7) <= wbs_dat_i;                   ],
  [dnl -- Protocol
                protocol_out <= wbs_dat_i;
                checksum_word_in ( 8 to 15) <= wbs_dat_i;                   ],
  [dnl -- Header Checksum
                received_checksum( 0 to  7) <= wbs_dat_i;
                -- checksum field is zero for purposes of its own calculation
                checksum_word_in ( 0 to  7) <= X"00";                       ],
  [dnl
                received_checksum( 8 to 15) <= wbs_dat_i;
                checksum_word_in ( 8 to 15) <= X"00";                       ],
  [dnl -- Source IP Address
                src_ip_addr_out  ( 0 to  7) <= wbs_dat_i;
                checksum_word_in ( 0 to  7) <= wbs_dat_i;                   ],
  [dnl
                src_ip_addr_out  ( 8 to 15) <= wbs_dat_i;
                checksum_word_in ( 8 to 15) <= wbs_dat_i;                   ],
  [dnl
                src_ip_addr_out  (16 to 23) <= wbs_dat_i;
                checksum_word_in ( 0 to  7) <= wbs_dat_i;                   ],
  [dnl
                src_ip_addr_out  (24 to 31) <= wbs_dat_i;
                checksum_word_in ( 8 to 15) <= wbs_dat_i;                   ],
  [dnl -- Destination IP Address
                dest_ip_addr_out ( 0 to  7) <= wbs_dat_i;
                checksum_word_in ( 0 to  7) <= wbs_dat_i;                   ],
  [dnl
                dest_ip_addr_out ( 8 to 15) <= wbs_dat_i;
                checksum_word_in ( 8 to 15) <= wbs_dat_i;                   ],
  [dnl
                dest_ip_addr_out (16 to 23) <= wbs_dat_i;
                checksum_word_in ( 0 to  7) <= wbs_dat_i;
  -- receive_architecture does this in the next cycle but we need to do it
  -- one cycle early to process the frame from Ethernet receive quickly enough
                wbm_cyc_o <= '1';                                           ],
  [dnl
                dest_ip_addr_out (24 to 31) <= wbs_dat_i;
                checksum_word_in ( 8 to 15) <= wbs_dat_i;                   ]])
