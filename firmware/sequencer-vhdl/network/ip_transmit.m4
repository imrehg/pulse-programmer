dnl-*-VHDL-*-
-- IP transmitter module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Based on inputs supplied to it from the top-level IP module, this
-- transmitter constructs a valid payload and feeds it to the
-- ethernet_transmit module via a Wishbone interface.

-- An IP datagram has a header in 32-bit chunks with a minimum of 20 octets
-- See IETF RFC 791 for more details.

-- no WB_WE_O or WB_DAT_I b/c this is strictly a write-only master.
-- no WB_ADR_O b/c destination MAC address is supplied by ARP.

network_transmit_unit_([ip_transmit], dnl
  [dnl -- Generics ------------------------------------------------------------
],[dnl -- Ports ---------------------------------------------------------------
    -- Non-wishbone slave interface, synced to signals above
    dest_ip_addr_in  : in  ip_address;
    src_ip_addr_in   : in  ip_address;
    dont_fragment_in : in  std_logic;
    id_in            : in  ip_id;
    protocol_in      : in  ip_protocol;
    total_length_in  : in  ip_total_length;
    total_length_out : out ip_total_length;
],[dnl -- Byte Count Range ----------------------------------------------------
IP_MIN_HEADER_BYTE_LENGTH[]dnl
],[dnl -- Declarations --------------------------------------------------------
  signal current_length         : ip_total_length;
  signal current_total_length   : ip_total_length;
  signal fragment_offset        : ip_frag_offset;
  signal more_fragments         : std_logic;
],[dnl -- Additional States ---------------------------------------------------
      fragment_test,
],[dnl -- Process Variables-------------------------------------------------
    -- Maximum total length of data (not including header) of IP datagram.
    -- Rounded down to nearest 8-octet chunk.
    -- Ethernet MTU - 2*mac_addresses - type_length - crc32 - IP min header
    -- 1500 - 6*2 - 2 - 4 - 5*4 = 1462 = 0x5b6
    -- / 8 = 182 = 0xB6
    -- in bytes, so it can be added/subtracted with total length
    -- 0xB6 = 0x1011_0110, << 3 = 0x101_1011_0000 = 0x5b0
    constant MAX_FRAGMENT_SIZE : ip_total_length :=
    to_unsigned(MAX_FRAME_BYTE_COUNT - ETHERNET_HEADER_BYTE_COUNT -
                IP_MIN_HEADER_BYTE_LENGTH,
                IP_TOTAL_LENGTH_WIDTH) and B"1111_1111_1111_1000";

    variable remaining_length : ip_total_length;
],[dnl -- Idle Behaviour ------------------------------------------------------
            remaining_length := total_length_in;
            fragment_offset <= (others => '0');
            state := fragment_test;
],[dnl -- Checksum Header Entries ---------------------------------------------
   [dnl --- IP version four, minimum header length, and service type
                checksum_word_in <= IP_VERSION_FOUR & 
                                    std_logic_vector(IP_MIN_HEADER_LENGTH) &
                                    X"00";                                   ],
   [dnl --- total length
                checksum_word_in <= std_logic_vector(current_total_length);  ],
   [dnl --- identification
                checksum_word_in <= id_in;                                   ],
   [dnl --- flags and fragment offset
                checksum_word_in <= B"0" & dont_fragment_in & more_fragments &
                                    std_logic_vector(fragment_offset);       ],
   [dnl --- time to live and protocol
                checksum_word_in <= IP_TIME_TO_LIVE & protocol_in;           ],
   [dnl --- checksum placeholder
                checksum_word_in <= X"0000";                                 ],
   [dnl --- source IP address
                checksum_word_in <= src_ip_addr_in(0 to 15);                 ],
   [dnl
                checksum_word_in <= src_ip_addr_in(16 to 31);                ],
   [dnl --- destination IP address
                checksum_word_in <= dest_ip_addr_in(0 to 15);                ],
   [dnl
                checksum_word_in <= dest_ip_addr_in(16 to 31);               ]
],[dnl -- Receive Data Behaviour ---------------------------------------------
          elsif (current_length = 0) then
            -- we are done with the promised data length (current fragment)
            -- (we stop at 1 and not at 0 b/c of the pipeline)
            -- release our slave
            wbm_stb_o <= '0';
            wbm_cyc_o <= '0';
            -- wait for master to go low and ack out any errant data
            --wbs_ack_o <= wbs_stb_i;
            if (remaining_length = 0) then
              -- if there are no more fragments, then wait for master to go low
              -- and ack out any errant data
              wbs_ack_o <= wbs_stb_i;
            else
              wbs_ack_o <= '0';
              -- otherwise increment the fragment offset
              fragment_offset <= fragment_offset + MAX_FRAGMENT_SIZE(0 to 12);
              -- then generate the header for next fragment
              -- then generate the header for next fragment
              state := fragment_test;
            end if;
],[dnl -- Transmit Header Entries ---------------------------------------------
   [dnl --- IP version four and minimum header length
                total_length_out <= total_length_in +
                                    IP_MIN_HEADER_BYTE_LENGTH;
                wbm_dat_o <= IP_VERSION_FOUR &
                             std_logic_vector(IP_MIN_HEADER_LENGTH);         ],
   [dnl --- service type
                wbm_dat_o <= X"00";                                          ],
   [dnl --- total length
                wbm_dat_o <= std_logic_vector(current_total_length(0 to  7));],
   [dnl
                wbm_dat_o <= std_logic_vector(current_total_length(8 to 15));],
   [dnl --- identification
                wbm_dat_o <= id_in(0 to 7);                                  ],
   [dnl
                wbm_dat_o <= id_in(8 to 15);                                 ],
   [dnl --- flags and fragment offset
                wbm_dat_o <= B"0" & dont_fragment_in & more_fragments &
                             std_logic_vector(fragment_offset(0 to 4));      ],
   [dnl
                wbm_dat_o <= std_logic_vector(fragment_offset(5 to 12));     ],
   [dnl --- time to live
                wbm_dat_o <= IP_TIME_TO_LIVE;                                ],
   [dnl --- protocol
                wbm_dat_o <= protocol_in;                                    ],
   [dnl --- checksum
                wbm_dat_o <= checksum(0 to 7);                               ],
   [dnl
                wbm_dat_o <= checksum(8 to 15);                              ],
   [dnl --- source IP address
                wbm_dat_o <= src_ip_addr_in(0 to 7);                         ],
   [dnl
                wbm_dat_o <= src_ip_addr_in(8 to 15);                        ],
   [dnl
                wbm_dat_o <= src_ip_addr_in(16 to 23);                       ],
   [dnl
                wbm_dat_o <= src_ip_addr_in(24 to 31);                       ],
   [dnl --- destination IP address
                wbm_dat_o <= dest_ip_addr_in(0 to 7);                        ],
   [dnl
                wbm_dat_o <= dest_ip_addr_in(8 to 15);                       ],
   [dnl
                wbm_dat_o <= dest_ip_addr_in(16 to 23);                      ],
   [dnl
                wbm_dat_o <= dest_ip_addr_in(24 to 31);                      ]
],[dnl -- Additional State Behaviour ------------------------------------------
      when fragment_test =>
          checksum_reset <= '0';
          if (remaining_length < MAX_FRAGMENT_SIZE) then
            -- fragment by creating a new header based on old header
            current_length <= remaining_length;
            more_fragments <= '0';
            remaining_length := (others => '0');
            state := generate_header;
          elsif (dont_fragment_in = '1') then
            -- discard this datagram; it is too long but not to be fragmented
            state := idle;
          else
            -- fragment this datagram
            current_length   <= MAX_FRAGMENT_SIZE;
            remaining_length := remaining_length - MAX_FRAGMENT_SIZE;
            more_fragments   <= '1';
            state            := generate_header;
          end if;
],[dnl -- Asynchronous Behaviour ----------------------------------------------
   -- the total length is the data length plus the header length
  current_total_length <= current_length + IP_MIN_HEADER_BYTE_LENGTH;
])
