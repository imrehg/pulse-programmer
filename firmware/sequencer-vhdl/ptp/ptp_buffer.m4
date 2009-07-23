dnl-*-VHDL-*-
-- PTP receive buffer.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------
buffer_unit_([ptp_buffer], dnl
  [dnl -- Generics ------------------------------------------------------------
],[dnl -- Ports ---------------------------------------------------------------
    -- Non-wishbone slave inputs synced with above
    src_id_in         : in  ptp_id_type;
    dest_id_in        : in  ptp_id_type;
    opcode_in         : in  ptp_opcode_type;
    -- Non-wishbone master outputs synced with above
    src_id_out        : out ptp_id_type;
    dest_id_out       : out ptp_id_type;
    opcode_out        : out ptp_opcode_type;
    -- asset to replay last loaded buffer.
    reload            : in  std_logic;
],[dnl -- Declarations --------------------------------------------------------
  signal src_id       : ptp_id_type;
  signal dest_id      : ptp_id_type;
  signal opcode       : ptp_opcode_type;
],[dnl -- Latched Outputs -----------------------------------------------------
  src_id_out  <= src_id;
  dest_id_out <= dest_id;
  opcode_out  <= opcode;
],[dnl -- Reset Behaviour------------------------------------------------------
      src_id   <= (others => '0');
      dest_id  <= (others => '0');
      opcode   <= (others => '0');
      -- always begin at address 0 b/c we don't fragment
      memory_start_rev := (others => '0');
],[dnl -- Cyc Behaviour -------------------------------------------------------
            if ((load = '1') or (reload = '1')) then
--               ack_async <= '1';

              -- newly loaded values will always match themselves
              match_ack <= '1';

              if (load = '1') then
                -- load new header values
                src_id  <= src_id_in;
                dest_id <= dest_id_in;
                opcode  <= opcode_in;
                -- and calculate the length of entire datagram
                length(TOTAL_LENGTH_START_INDEX to IP_TOTAL_LENGTH_WIDTH-1) <=
                  length_in(TOTAL_LENGTH_START_INDEX to
                            IP_TOTAL_LENGTH_WIDTH-1);
                length(0 to TOTAL_LENGTH_START_INDEX-1) <=
                  (others => '0');
                memory_end_rev := memory_start_rev +
                              length_in(TOTAL_LENGTH_START_INDEX to
                                        IP_TOTAL_LENGTH_WIDTH-1);

                -- an extra stage to latch burst address
                state := receive_latch;
              end if;

              -- we are always complete b/c we don't fragment
              complete := true;
            end if;
])
