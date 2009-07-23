dnl-*-VHDL-*-
-- IP receive buffer (previously used for matching and reassembly)
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

buffer_unit_([ip_buffer], dnl
  [dnl -- Generics ------------------------------------------------------------
],[dnl -- Ports ---------------------------------------------------------------
    -- Non-wishbone slave inputs synced with above
    self_ip_addr_in  : in     ip_address;
    src_ip_addr_in   : in     ip_address;
    dest_ip_addr_in  : in     ip_address;
    protocol_in      : in     ip_protocol;
    id_in            : in     ip_id;
    fragment_offset  : in     ip_frag_offset;
    more_fragments   : in     std_logic;
    -- Non-wishbone master outputs synced with above
    src_ip_addr_out  : out    ip_address;
    dest_ip_addr_out : out    ip_address;
    protocol_out     : out    ip_protocol;
    id_out           : out    ip_id;
],[dnl -- Declarations --------------------------------------------------------
  signal src_ip_addr      : ip_address;
  signal dest_ip_addr     : ip_address;
  signal protocol         : ip_protocol;
  signal id               : ip_id;
],[dnl -- Latched Outputs -----------------------------------------------------
  src_ip_addr_out  <= src_ip_addr;
  dest_ip_addr_out <= dest_ip_addr;
  protocol_out     <= protocol;
  id_out           <= id;
],[dnl -- Reset Behaviour------------------------------------------------------
      src_ip_addr   <= (others => '0');
      dest_ip_addr  <= (others => '0');
      protocol      <= (others => '0');
      id            <= (others => '0');
],[dnl -- Cyc Behaviour -------------------------------------------------------
            memory_start_rev :=
              unsigned(fragment_offset(FRAGMENT_OFFSET_START_INDEX to
                                       IP_FRAG_OFFSET_WIDTH-1) & B"000");
            memory_end_rev := memory_start_rev +
                          length_in(TOTAL_LENGTH_START_INDEX to
                                    IP_TOTAL_LENGTH_WIDTH-1);

            if (load = '1') then
--                and
--                  ((dest_ip_addr = self_ip_addr_in) or
--                   (dest_ip_addr = BROADCAST_IP_ADDRESS))) then
                -- load new header values
              src_ip_addr  <= src_ip_addr_in;
              dest_ip_addr <= dest_ip_addr_in;
              protocol     <= protocol_in;
              id           <= id_in;

            end if;

            -- newly loaded values will always match themselves
            match_ack <= '1';
                
            -- an extra stage to latch burst address
            state := receive_latch;
--             ack_async := '1';
              
            -- check if this is a last fragment or an unfragmented datagram
            if (more_fragments = '0') then
              -- this is the last fragment, mark ourselves as complete
              complete := true;
              -- and calculate the length of entire datagram
              length(TOTAL_LENGTH_START_INDEX to
                     IP_TOTAL_LENGTH_WIDTH-1) <= memory_end_rev;
              length(0 to TOTAL_LENGTH_START_INDEX-1) <=
                (others => '0');
            end if;
])
