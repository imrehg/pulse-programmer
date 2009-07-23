---*-VHDL-*-
-- Pulse Transfer Protocol transmit module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

transport_transmit_unit_([ptp_transmit], dnl
  [dnl -- GENERICS ------------------------------------------------------------
    ADDRESS_WIDTH : positive := 10;
    -- for testing (to remain constant across future versions)
    MAJOR_VERSION : std_logic_vector(0 to 7) := X"00";
    MINOR_VERSION : std_logic_vector(0 to 7) := X"01";
],[dnl -- PORT ----------------------------------------------------------------
    src_id_in          : in  ptp_id_type;
    dest_id_in         : in  ptp_id_type;
    opcode_in          : in  ptp_opcode_type;
    length_in          : in  ptp_length_type;
    length_out         : out ptp_length_type;
    interface_out      : out ptp_interface_type;
    self_id_in         : in  ptp_id_type;
    chain_initiator_in : in  boolean;
],[dnl -- Byte Count Range ----------------------------------------------------
PTP_HEADER_BYTE_LENGTH],
[dnl -- Checksum Address ----------------------------------------------------
8],
[dnl -- Transmit Header -------------------------------------------------------
  [dnl --- Source ID
                mem_dat_i                  <= src_id_in;
    -- this is not part of the header but I am sneaking it in here to avoid
    -- polluting transport_transmit_unit
                length_out <= length_in;
                if ((dest_id_in = PTP_AVR_ID) and (chain_initiator_in)) then
                  interface_out <= to_avr;
                elsif (unsigned(dest_id_in) >= unsigned(self_id_in)) then
                -- this is >= instead of > to handle bootstrapping case when
                -- all programmers have the same ID.
                  interface_out <= to_slave;
                else
                  interface_out <= to_master;
                end if;                                                      ],
  [dnl --- Destination ID
                mem_dat_i                  <= dest_id_in;                    ],
  [dnl --- Firmware Version
                mem_dat_i                  <= MAJOR_VERSION;                 ],
  [dnl
                mem_dat_i                  <= MINOR_VERSION;                 ],
  [dnl --- Opcode
                mem_dat_i                  <= opcode_in ;                    ],
  [dnl --- Zero
                mem_dat_i                  <= X"00";                         ],
  [dnl --- Length
                mem_dat_i <= std_logic_vector(total_length(0 to 7));         ],
  [dnl
                mem_dat_i <= std_logic_vector(total_length(8 to 15));        ],
  [dnl --- Checksum Placeholder
                mem_dat_i                  <= X"00";                         ],
  [dnl
                mem_dat_i                  <= X"00";                         ]
],[dnl -- Pseudo Header -------------------------------------------------------
],[dnl --- Memory End
length_in + PTP_HEADER_BYTE_LENGTH[]dnl
],[dnl -- Done Behaviour ------------------------------------------------------
],[dnl -- Reset Behaviour -----------------------------------------------------
],[dnl -- Cyc Behaviour -------------------------------------------------------
],[dnl -- Declarations --------------------------------------------------------
],[dnl -- Disable Checksum ----------------------------------------------------
  -- blah
])
