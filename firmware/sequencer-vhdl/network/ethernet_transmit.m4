dnl--*-VHDL-*-
-- transmit frame to Ethernet PHY
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Latches onto address, length, and payload bytes in parallel from
-- network layer, calculates running CRC32 checksum, then
-- shifts out nibbles (LSB first, LSN first) to PHY via MII.

-- no WB_WE_I, WB_ADR_I, WB_DAT_O b/c this is strictly a write-only slave.
-- note that if the WB_CLK_I is faster than phy_clock (probably),
-- WB_ACK_O goes low to insert wait states until it is ready for another
-- payload chunk.

-- WARNING: If WB_STB_I ever goes low during a transfer, then
--          WB_DAT_O will still be latched into the frame.

-- Consult the IEEE 802.3 (2002) standard for details about the
-- Ethernet frame.

unit_([ethernet_transmit], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
],[dnl -- Ports ---------------------------------------------------------------
  wb_rst_i         : in  std_logic;
    -- Wishbone slave interface (e.g. to arp_transmit and ip_transmit)
  wb_cyc_o         : out std_logic;
  wb_stb_o         : out std_logic;
  wb_dat_i         : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  wb_ack_i         : in  std_logic;
    s_cyc_i        : in  std_logic;
    s_stb_i        : in  std_logic;
    s_ack_o        : out std_logic;
    -- MAC interface (non-wishbone)
    dest_addr_in   : in  mac_address;
    src_addr_in    : in  mac_address;
    type_length_in : in  ethernet_type_length;
    debug_led_out  : out byte;
    -- PHY interface
    phy_clock      : in  std_logic;
    nibble_out     : out nibble;
    phy_enable     : out std_logic;
],[dnl -- Declarations --------------------------------------------------------
  signal nibble_inter       : nibble;
  signal payload_in         : std_logic_vector(DATA_WIDTH-1 downto 0);
crc32_signals_
--  signal ack_sync           : std_logic;

  -- minFrameSize - checksum size, + preamble size, in nibbles = 136 = 0x88
  constant MIN_PAYLOAD_NIBBLE_COUNT : positive := (64 - 4 + 8) * 2;

  subtype nibble_count_type is natural range 0 to
    (MIN_PAYLOAD_NIBBLE_COUNT + 24 + 8);  -- 24 interframe gap, 8 checksum
  --MAX_FRAME_BYTE_COUNT*2;

  -- (0.96 us, or 12 octets = 24 nibbles)
  constant INTERFRAME_GAP    : nibble_count_type := 24;
  constant PAYLOAD_MULTIPLE  : positive := DATA_WIDTH / NIBBLE_WIDTH;

  constant NIBBLE_START      : nibble_count_type := 12;
  signal nibble_count        : nibble_count_type;
  signal is_minimum          : boolean;
  signal payload_counter     : natural range 0 to PAYLOAD_MULTIPLE;
  signal payload_latched     : std_logic_vector(DATA_WIDTH-1 downto 0);
],[dnl -- Body ----------------------------------------------------------------
  checksum_generator : crc32
    port map (
      wb_clk_i   => (not phy_clock),
      wb_rst_i   => checksum_reset,
      wb_stb_i   => checksum_enable,
      wb_dat_i   => nibble_inter,
      wb_dat_o   => checksum_out
      );

--    wb_ack_o <= wb_stb_i and ack_sync;      -- we always ack out at full speed
-------------------------------------------------------------------------------
  -- slow speed PHY interface to latch out nibbles to the MII
  process(phy_clock, wb_rst_i, s_stb_i)

    type frame_parts is (
      idle    ,
      preamble,
      header  ,
      payload_read ,
      payload_write,
      zero_pad,
      checksum,
      waiting ,
      waiting_fall,
      done
      );

    variable state           : frame_parts;
    variable reload          : boolean;
    
  begin

    if (wb_rst_i = '1') then
      debug_led_out(3 downto 0) <= B"0001";
      checksum_reset <= '1';
      phy_enable     <= '0';
      state          := idle;

    elsif (rising_edge(phy_clock)) then

      case (state) is
        -----------------------------------------------------------------------
        when idle =>
          debug_led_out(3 downto 0) <= B"0010";
          nibble_count    <= 0;
          s_ack_o         <= '0';
--          ack_sync        <= '0';
          checksum_enable <= '0';
          checksum_reset  <= '0';
          if ((s_cyc_i = '1') and (s_stb_i = '1')) then
            state        := preamble;
            phy_enable   <= '1';
            nibble_inter <= X"5";
          end if;
        -----------------------------------------------------------------------
        when preamble =>
          debug_led_out(3 downto 0) <= B"0011";
          if (nibble_count = NIBBLE_START+2) then
            nibble_inter <= X"D";
            state := header;
          else
            nibble_inter <= X"5";
          end if;
          nibble_count <= nibble_count + 1;
        -----------------------------------------------------------------------
        when header =>
          debug_led_out(3 downto 0) <= B"0100";
          checksum_enable <= '1';
          case (nibble_count) is
            when NIBBLE_START+3 =>
              -- enable the checksum here b/c first dest_addr nibble won't be
              -- active until next cycle
              nibble_inter <= dest_addr_in(3 downto 0);
            when NIBBLE_START+4 =>
              nibble_inter <= dest_addr_in(7 downto 4);
            when NIBBLE_START+5 =>
              nibble_inter <= dest_addr_in(11 downto 8);
            when NIBBLE_START+6 =>
              nibble_inter <= dest_addr_in(15 downto 12);
            when NIBBLE_START+7 =>
              nibble_inter <= dest_addr_in(19 downto 16);
            when NIBBLE_START+8 =>
              nibble_inter <= dest_addr_in(23 downto 20);
            when NIBBLE_START+9 =>
              nibble_inter <= dest_addr_in(27 downto 24);
            when NIBBLE_START+10 =>
              nibble_inter <= dest_addr_in(31 downto 28);
            when NIBBLE_START+11 =>
              nibble_inter <= dest_addr_in(35 downto 32);
            when NIBBLE_START+12 =>
              nibble_inter <= dest_addr_in(39 downto 36);
            when NIBBLE_START+13 =>
              nibble_inter <= dest_addr_in(43 downto 40);
            when NIBBLE_START+14 =>
              nibble_inter <= dest_addr_in(47 downto 44);
            when NIBBLE_START+15 =>
              nibble_inter <= src_addr_in(3 downto 0);
            when NIBBLE_START+16 =>
              nibble_inter <= src_addr_in(7 downto 4);
            when NIBBLE_START+17 =>
              nibble_inter <= src_addr_in(11 downto 8);
            when NIBBLE_START+18 =>
              nibble_inter <= src_addr_in(15 downto 12);
            when NIBBLE_START+19 =>
              nibble_inter <= src_addr_in(19 downto 16);
            when NIBBLE_START+20 =>
              nibble_inter <= src_addr_in(23 downto 20);
            when NIBBLE_START+21 =>
              nibble_inter <= src_addr_in(27 downto 24);
            when NIBBLE_START+22 =>
              nibble_inter <= src_addr_in(31 downto 28);
            when NIBBLE_START+23 =>
              nibble_inter <= src_addr_in(35 downto 32);
            when NIBBLE_START+24 =>
              nibble_inter <= src_addr_in(39 downto 36);
            when NIBBLE_START+25 =>
              nibble_inter <= src_addr_in(43 downto 40);
            when NIBBLE_START+26 =>
              nibble_inter <= src_addr_in(47 downto 44);
            when NIBBLE_START+27 =>
              nibble_inter <= type_length_in(11 downto 8);
            when NIBBLE_START+28 =>
              nibble_inter <= type_length_in(15 downto 12);
              wb_cyc_o <= '1';
              wb_stb_o <= '1';
--              ack_sync <= '1';
            when NIBBLE_START+29 =>
--              ack_sync <= '0';
              nibble_inter <= type_length_in(3 downto 0);
              wb_stb_o <= '0';
              -- Start filling pipeline
            when NIBBLE_START+30 =>
              nibble_inter <= type_length_in(7 downto 4);
--                ack_sync <= '1';
              wb_stb_o <= '1';
              payload_latched <= wb_dat_i;
              is_minimum <= false;
              state := payload_read;
              reload := true;
            when others => null;
          end case;
          nibble_count <= nibble_count + 1;
        -----------------------------------------------------------------------
        when payload_read =>
          if (s_stb_i = '0') then
            reload := false;
          end if;
          -- We can't wait for slackers
--           if (wb_ack_i = '1') then
          payload_in <= payload_latched;
          wb_stb_o <= '0';
          state := payload_write;
--           end if;
          nibble_inter <= payload_latched(3 downto 0);
          nibble_count <= nibble_count + 1;
        -----------------------------------------------------------------------
        when payload_write =>
          if (reload) then
            wb_stb_o <= '1';
            payload_latched <= wb_dat_i;
            state := payload_read;
            nibble_count <= nibble_count + 1;
          else
            wb_cyc_o <= '0';
            -- b/c of the one nibble pipeline, and b/c we need to check
            -- one byte early (on the odd/low nibble) if we need to zero pad
            -- (hence MIN_PAYLOAD_NIBBLE_COUNT - 2)
            if (is_minimum) then --(nibble_count < MIN_PAYLOAD_NIBBLE_COUNT-2) then
              nibble_count <= 0;
              state := checksum;
            else
              nibble_count <= nibble_count + 1;
              state := zero_pad;
            end if;
          end if;
          nibble_inter <= payload_latched(7 downto 4);
          if (nibble_count >= MIN_PAYLOAD_NIBBLE_COUNT-3) then
            is_minimum <= true;
          end if;
          -- output the current nibble (lowest order)
        -----------------------------------------------------------------------
        when zero_pad =>
--          debug_led_out(3 downto 0) <= B"1000";
          debug_led_out(3 downto 0) <= std_logic_vector(to_unsigned(nibble_count, 4));
          nibble_inter   <= X"0";
          if (nibble_count >= MIN_PAYLOAD_NIBBLE_COUNT-2) then
            -- we'll always end the pad on a high nibble
            -- (integral number of octets)
            nibble_count <= 0;
            state        := checksum;
          else
            nibble_count <= nibble_count + 1;
          end if;
        -----------------------------------------------------------------------
        when checksum =>
          debug_led_out(3 downto 0) <= B"1001";
          checksum_enable <= '0';
          case (nibble_count) is
            when 0 =>
              nibble_inter <= checksum_out(3 downto 0);
            when 1 =>
              nibble_inter <= checksum_out(7 downto 4);
            when 2 =>
              nibble_inter <= checksum_out(11 downto 8);
            when 3 =>
              nibble_inter <= checksum_out(15 downto 12);
            when 4 =>
              nibble_inter <= checksum_out(19 downto 16);
            when 5 =>
              nibble_inter <= checksum_out(23 downto 20);
            when 6 =>
              nibble_inter <= checksum_out(27 downto 24);
            when others => --8 =>
              nibble_inter <= checksum_out(31 downto 28);
              state := waiting;
          end case;
          if (nibble_count >= 7) then
            nibble_count <= 0;
          else
            nibble_count <= nibble_count + 1;
          end if;
        -----------------------------------------------------------------------
        when waiting =>
          phy_enable <= '0';
          checksum_reset <= '1';
          s_ack_o <= '1';
          state := waiting_fall;
        when waiting_fall =>
          if (s_cyc_i = '0') then
            s_ack_o <= '0';
            state := idle;
          end if;
--             s
--           debug_led_out(3 downto 0) <= B"1010";
--           if (nibble_count >= INTERFRAME_GAP-1) then
--             state := idle;
--           end if;
--           nibble_count <= nibble_count + 1;
          
        when others => null;
                       -- as a precaution against glitches
--          debug_led_out(3 downto 0) <= B"1011";
--          state := waiting;

      end case;

    end if;

--     debug_led_out(7) <= ack_sync;

  end process;

--   debug_led_out(4) <= wb_cyc_i;
--   debug_led_out(5) <= wb_stb_i;
--   debug_led_out(6) <= wb_ack_o;

  -- we use an intermediate nibble signal b/c checksum needs to read it in
  nibble_out <= nibble_inter;
])
