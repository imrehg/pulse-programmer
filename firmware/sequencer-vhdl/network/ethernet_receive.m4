dnl--*-VHDL-*-
-- Ethernet receive module
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Shifts in a frame from the PHY via MII at slow clock (25 MHz),
-- strips out the type-length
-- and source MAC address to see if we are the recipient, and
-- generates/compares running checksum to verify data integrity.

-- Shifts out payload at fast clock (100 MHz) via Wishbone interface
-- in chunks as configured by the generic PAYLOAD_WIDTH,
-- but doesn't listen to slave acks; slave is responsible for always being
-- able to latch in data when strobed.

-- Consult the IEEE 802.3 (2002) standard for details about the
-- Ethernet frame.

unit_([ethernet_receive], dnl
[dnl -- Libraries -------------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
],[dnl -- Ports ---------------------------------------------------------------
  wb_rst_i        : in  std_logic;
  -- Wishbone Master interface
wb_lsb_master_port_
  -- MAC INTERFACE
  src_addr_in      : in  mac_address;
  type_length_out  : out ethernet_type_length;
  src_addr_out     : out mac_address;
  checksum_error   : out std_logic;
  length_error     : out std_logic;
  header_valid_out : out std_logic;
  debug_led_out    : out byte;
  -- PHY INTERFACE
  phy_clock        : in  std_logic;
  nibble_in        : in  nibble;
  phy_data_valid   : in std_logic;
],[dnl -- Declarations --------------------------------------------------------
  -- this is the reflected XOR of the published CRC32 magic number, 0xc704dd7b
  constant CRC32_MAGIC_NUMBER : std_logic_vector(CRC32_WIDTH-1 downto 0) :=
    X"2144df1c";
  constant PAYLOAD_MULTIPLE   : positive := DATA_WIDTH / NIBBLE_WIDTH;
crc32_signals_
  signal payload                : std_logic_vector(DATA_WIDTH-1 downto 0);

  constant MAX_FRAME_NIBBLE_COUNT : positive := MAX_FRAME_BYTE_COUNT*2;
  subtype nibble_count_type is natural range 0 to MAX_FRAME_NIBBLE_COUNT+1;

  constant COUNT_START         : nibble_count_type := 0;
  signal   nibble_count        : nibble_count_type;
  signal   payload_counter     : natural range 0 to PAYLOAD_MULTIPLE;
],[dnl -- Body ----------------------------------------------------------------
  checksum : crc32
    port map (
      wb_clk_i   => phy_clock,
      wb_rst_i   => wb_rst_i or (not checksum_enable), 
      wb_stb_i   => checksum_enable,
      wb_dat_i   => nibble_in,
      wb_dat_o   => checksum_out
      );
-------------------------------------------------------------------------------

   wb_dat_o <= payload;
   
  process(phy_clock, wb_rst_i, phy_data_valid)

    type frame_parts is (
      disabled,
      preamble,
      sfd,
      dest_addr,
      src_addr,
      type_length,
      receive_payload,
      disabled_wait
      );

    variable state               : frame_parts;

    variable current_mac_addr    : mac_address;
    variable receive_counter     : unsigned(7 downto 0);

    type nibble_state is (
      high_nibble,
      low_nibble
    );

    variable which_nibble      : nibble_state;
    
  begin

    if (wb_rst_i = '1') then
      state    := disabled_wait;
      wb_cyc_o <= '0';
      wb_stb_o <= '0';
      payload  <= (others => '0');

    elsif (rising_edge(phy_clock)) then
      case (state) is
        -----------------------------------------------------------------------
        when preamble =>
          if (nibble_in = X"D") then
            state := dest_addr;
            checksum_enable <= '1';
            nibble_count <= 0;
          elsif (nibble_in /= X"5") then
            state := disabled_wait;
          end if;
        -----------------------------------------------------------------------
        when disabled_wait =>
          -- we've detected some error if we're in this state
          -- wait here for the (invalid) frame to end
          checksum_enable <= '0';
          header_valid_out <= '0';
          if (phy_data_valid = '0') then
            wb_cyc_o <= '0';
            state := disabled;
          end if;
        -----------------------------------------------------------------------
        when disabled =>
          -- initial conditions between frames
          wb_stb_o <= '0';
          if (phy_data_valid = '1') then
            receive_counter := receive_counter + 1;
            state := preamble;
            checksum_error <= '1';
            length_error <= '0';
          end if;
        -----------------------------------------------------------------------
        when receive_payload =>
          -- shift in a nibble as the high nibble
          payload <= nibble_in &
                             payload(DATA_WIDTH-1 downto NIBBLE_WIDTH);

          -- ensures an integral number of octets (even nibbles) 
          if (checksum_out = CRC32_MAGIC_NUMBER) then
            checksum_error <= '0';
          end if;
          if (nibble_count >= MAX_FRAME_NIBBLE_COUNT) then
            length_error <= '1';
            state := disabled_wait;
          elsif (phy_data_valid = '0') then
            state := disabled_wait;
          end if;
          
          payload_counter <= payload_counter - 1;

          if (payload_counter <= 1) then
            payload_counter <= PAYLOAD_MULTIPLE;
            wb_stb_o <= '1';
          else
            if (wb_ack_i = '1') then
              wb_stb_o <= '0';
            end if;
          end if;

          if (which_nibble = low_nibble) then
            which_nibble := high_nibble;
          else
            which_nibble := low_nibble;
          end if;
          nibble_count <= nibble_count + 1;
        -----------------------------------------------------------------------
        when others =>

          case (state) is
            -------------------------------------------------------------------
            when dest_addr =>
 
              -- shift in nibble to received destination MAC address
              current_mac_addr := nibble_in & current_mac_addr(
                MAC_ADDRESS_WIDTH-1 downto NIBBLE_WIDTH);

              if (nibble_count >= 11) then
                if ((current_mac_addr = src_addr_in) or
                    (current_mac_addr = BROADCAST_MAC_ADDRESS)) then
                  state := src_addr;
                else
                  state := disabled_wait;
                end if;
              end if;
            -------------------------------------------------------------------
            when src_addr =>

              current_mac_addr := nibble_in & current_mac_addr(
                MAC_ADDRESS_WIDTH-1 downto NIBBLE_WIDTH);
              
              if (nibble_count >= 23) then
                src_addr_out      <= current_mac_addr;
                state             := type_length;
              end if;
            -------------------------------------------------------------------
            when type_length =>
              -- raise it early for async_fifo stable counting
              wb_cyc_o <= '1';

              case (nibble_count) is
                when 24 =>
                  type_length_out(11 downto  8) <= nibble_in;
                when 25 =>
                  type_length_out(15 downto 12) <= nibble_in;
                when 26 =>
                  type_length_out( 3 downto  0) <= nibble_in;
                when 27 =>
                  type_length_out( 7 downto  4) <= nibble_in;
                  which_nibble    := low_nibble;
                  payload_counter <= PAYLOAD_MULTIPLE;
                  header_valid_out <= '1';
                  state           := receive_payload;
                when others => null;
              end case;
            -------------------------------------------------------------------
            when others => null;
--              debug_led_out(3 downto 0) <= B"1010";
              -- safety first kids. arbitrary safety, but still safety
--              state := type_length;
          end case;

          nibble_count <= nibble_count + 1;

      end case;

    end if;
    
  end process;
])
