dnl-*-VHDL-*-
-- IP interface to transport layer.
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

buffer_mux_unit_([ip_transport], dnl
 [dnl -- Ports--------------------------------------------------------------
    -- Wishbone master interface to transport layer
    self_ip_addr_in    : in  ip_address;
    src_ip_addr_out    : out ip_address;
    dest_ip_addr_out   : out ip_address;
    protocol_out       : out ip_protocol;
    id_out             : out ip_id;
    -- Wishbone slave interface from ip_receive
    src_ip_addr_in     : in  ip_address;
    dest_ip_addr_in    : in  ip_address;
    protocol_in        : in  ip_protocol;
    id_in              : in  ip_id;
    fragment_offset_in : in  ip_frag_offset;
    more_fragments_in  : in  std_logic;
],[dnl -- Multiplexed Subtypes and Signals ------------------------------------
  type multibus_ip_address      is array (natural range <>) of ip_address;
  type multibus_ip_protocol     is array (natural range <>) of ip_protocol;
  type multibus_ip_id           is array (natural range <>) of ip_id;

  signal buffer_src_ip_addr     : multibus_ip_address (0 to BUFFER_COUNT-1);
  signal buffer_dest_ip_addr    : multibus_ip_address (0 to BUFFER_COUNT-1);
  signal buffer_protocol        : multibus_ip_protocol(0 to BUFFER_COUNT-1);
  signal buffer_id              : multibus_ip_id      (0 to BUFFER_COUNT-1);
],[dnl -- Buffer Design Unit Name ---------------------------------------------
ip_buffer],
  [dnl -- Buffer Instance Assignments -----------------------------------------
        self_ip_addr_in  => self_ip_addr_in,
        src_ip_addr_in   => src_ip_addr_in,
        dest_ip_addr_in  => dest_ip_addr_in,
        protocol_in      => protocol_in,
        id_in            => id_in,
        fragment_offset  => fragment_offset_in,
        more_fragments   => more_fragments_in,
        src_ip_addr_out  => buffer_src_ip_addr(i),
        dest_ip_addr_out => buffer_dest_ip_addr(i),
        protocol_out     => buffer_protocol(i),
        id_out           => buffer_id(i),
],[dnl -- Arbiter Winner Assignments ------------------------------------------
        src_ip_addr_out  <= buffer_src_ip_addr(i);
        dest_ip_addr_out <= buffer_dest_ip_addr(i);
        protocol_out     <= buffer_protocol(i);
        id_out           <= buffer_id(i);
],[dnl -- Arbiter Loser Assignments -------------------------------------------
        src_ip_addr_out  <= (others => '0');
        dest_ip_addr_out <= (others => '0');
        protocol_out     <= (others => '0');
        id_out           <= (others => '0');
])
