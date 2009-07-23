---*-VHDL-*-
-- UDP transmit module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Decodes an ICMP packet according to IETF RFC 768.

-------------------------------------------------------------------------------
transport_transmit_unit_([udp_transmit], dnl
  [dnl -- GENERICS ------------------------------------------------------------
    ADDRESS_WIDTH       : positive := 10;
],[dnl -- PORT ----------------------------------------------------------------
    -- Non-wishbone slave interface, synced to signals above
    src_port_in         : in  udp_port_type;
    dest_port_in        : in  udp_port_type;
    length_in           : in  udp_length_type;
    src_ip_addr_in      : in  ip_address;
    dest_ip_addr_in     : in  ip_address;
    length_out          : out udp_length_type;
],[dnl -- Byte Count Range ----------------------------------------------------
UDP_PSEUDO_HEADER_BYTE_LENGTH],
[dnl -- Checksum Address ----------------------------------------------------
6],
[dnl -- Transmit Header -------------------------------------------------------
  [dnl --- Source Port
                -- this is an abuse here to avoid polluting the transmit macros
                length_out <= length_in + UDP_HEADER_BYTE_LENGTH;
                mem_dat_i                  <= src_port_in(0 to 7);
                checksum_word_in           <= src_port_in;                 ],
  [dnl
                mem_dat_i                  <= src_port_in(8 to 15);        ],
  [dnl --- Destination Port
                mem_dat_i                  <= dest_port_in(0 to 7);
                checksum_word_in           <= dest_port_in;                ],
  [dnl
                mem_dat_i                  <= dest_port_in(8 to 15);       ],
  [dnl --- Length
                mem_dat_i <= std_logic_vector(total_length( 0 to  7));
                checksum_word_in <= std_logic_vector(total_length);        ],
  [dnl
                mem_dat_i <= std_logic_vector(total_length( 8 to 15));  ],
  [dnl --- Checksum Placeholder
                mem_dat_i                  <= X"00";
                checksum_word_in           <= X"0000";                     ],
  [dnl
                mem_dat_i                  <= X"00";                       ]
],[dnl -- Pseudo Header -------------------------------------------------------
  [dnl --- Source IP address
                                                                           ],
  [dnl
                checksum_word_in           <= src_ip_addr_in(0 to 15);     ],
  [dnl
                                                                           ],
  [dnl
                checksum_word_in           <= src_ip_addr_in(16 to 31);    ],
  [dnl --- Destination IP address
                                                                           ],
  [dnl
                checksum_word_in           <= dest_ip_addr_in(0 to 15);    ],
  [dnl
                                                                           ],
  [dnl
                checksum_word_in           <= dest_ip_addr_in(16 to 31);   ],
  [dnl --- Pseudo-header: Zero and Protocol
                                                                           ],
  [dnl
                checksum_word_in           <= X"00" & UDP_PROTOCOL_TYPE;   ],
  [dnl --- Pseudo-header: Length
                                                                           ],
  [dnl
                checksum_word_in  <= std_logic_vector(total_length);       ]
],[dnl --- Memory End
length_in + UDP_HEADER_BYTE_LENGTH])
