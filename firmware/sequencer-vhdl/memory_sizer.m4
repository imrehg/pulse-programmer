dnl--*-VHDL-*-
-- Wishbone memory-size for converting between a virtual address/data width
-- and a physical address/data width.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- WARNING:
-- Writing partial physical words in a burst write is currently not supported.
-- It is not difficult, but tedious to add more states to first read back the
-- unwritten parts of a partially written word.
-- Big-endian reading is not currently supported, but big-endian writing is.

unit_([memory_sizer],
  [dnl -- Libraries
sequencer_libraries_
],[dnl -- Generics
    -- should be less than PHYSICAL_ADDRESS_WIDTH
    VIRTUAL_ADDRESS_WIDTH  : positive := 16;
    VIRTUAL_DATA_WIDTH     : positive := 16;
    PHYSICAL_ADDRESS_WIDTH : positive := SRAM_ADDRESS_WIDTH;
    -- Effective PHYSICAL_DATA_WIDTH is VIRTUAL_ADDRESS_WIDTH*(2**SCALE_POWER)
    DATA_SCALE_TWO_POWER   : positive := 1;
    PHYSICAL_DATA_WIDTH    : positive := SRAM_DATA_WIDTH;
    ENDIANNESS             : endian_type := little_endian;
],[dnl -- Ports
wb_common_port_
   -- Slave interface to client of virtual memory
    wbs_cyc_i      : in     std_logic;
    wbs_stb_i      : in     std_logic;
    wbs_we_i       : in     std_logic;
    wbs_adr_i      : in     std_logic_vector(VIRTUAL_ADDRESS_WIDTH-1
                                             downto 0);
    wbs_dat_i      : in     std_logic_vector(VIRTUAL_DATA_WIDTH-1 downto 0);
    wbs_dat_o      : out    std_logic_vector(VIRTUAL_DATA_WIDTH-1 downto 0);
    wbs_ack_o      : out    std_logic;
    burst_in       : in     std_logic;
   -- Master interface to physical memory
    wbm_cyc_o      : out    std_logic;
    wbm_gnt_i      : in     std_logic;
    wbm_stb_o      : buffer std_logic;
    wbm_we_o       : out    std_logic;
    wbm_adr_o      : out    std_logic_vector(PHYSICAL_ADDRESS_WIDTH-1
                                             downto 0);
--  wbm_sel_o     : out std_logic_vector((2**DATA_SCALE_TWO_POWER)-1 downto 0);
    wbm_dat_o      : out    std_logic_vector(PHYSICAL_DATA_WIDTH-1 downto 0);
    wbm_dat_i      : in     std_logic_vector(PHYSICAL_DATA_WIDTH-1 downto 0);
    wbm_ack_i      : in     std_logic;
    burst_out      : buffer std_logic;
    burst_addr_in  : in     std_logic_vector(PHYSICAL_ADDRESS_WIDTH-1
                                             downto 0);
    burst_addr_out : out    std_logic_vector(VIRTUAL_ADDRESS_WIDTH-1 downto 0);
    phy_start_addr : in     std_logic_vector((PHYSICAL_ADDRESS_WIDTH+
                                              DATA_SCALE_TWO_POWER)-1
                                             downto VIRTUAL_ADDRESS_WIDTH) :=
                            (others => '0');
],[dnl -- Declarations
  constant DATA_SCALE     : positive := 2**DATA_SCALE_TWO_POWER;
  signal burst_offset     : natural range 0 to DATA_SCALE+1;
  signal burst_offset_out : natural range 0 to DATA_SCALE+1;
],[dnl -- Body

   -- Process to allow easy looping, b/c sll doesn't seem to work
  process (wb_clk_i, wb_rst_i, wbs_we_i, wbs_adr_i, wbs_dat_i, wbm_dat_i,
           phy_start_addr, burst_addr_in, burst_offset_out)
    
    variable select_offset        : unsigned(DATA_SCALE_TWO_POWER-1 downto 0);
    variable select_address_start : natural range 0 to PHYSICAL_DATA_WIDTH-1;
    variable select_address_end   : natural range 0 to PHYSICAL_DATA_WIDTH-1;

    type state_type is (
      idle,
      read_reading,
      read_burst_reading,
      read_burst_reading_ack,
      read_burst_load_stall,
      read_burst_load,
      read_done,
      write_reading,
      write_burst_reading,
      write_burst_reading_ack,
      write_writing,
      write_burst_writing,
      write_done,
      write_burst_done
      );

    variable state       : state_type;
    
    variable read_data   : std_logic_vector(PHYSICAL_DATA_WIDTH-1 downto 0);
    variable overlap      : boolean;
    type burst_word_type is array(0 to DATA_SCALE) of
      std_logic_vector(VIRTUAL_DATA_WIDTH-1 downto 0);
    variable burst_words  : burst_word_type;
    variable latched_addr : std_logic_vector(VIRTUAL_ADDRESS_WIDTH-1 downto 0);
   
  begin
-------------------------------------------------------------------------------
-- Encoding the select bit for the physical address from the virtual address.

-- We don't use the sel signal b/c the physical word is not byte addressable
-- in hardware.
--     for i in (2**DATA_SCALE_TWO_POWER)-1 downto 0 loop
--       if (i = select_offset) then
--         wbm_sel_o(i) <= '1';
--       else
--         wbm_sel_o(i) <= '0';
--       end if;
--     end loop;

    select_address_start :=
      ((to_integer(select_offset)+1)*VIRTUAL_DATA_WIDTH)-1;
    select_address_end   := to_integer(select_offset)*VIRTUAL_DATA_WIDTH;

    -- Physical address is the same for reading and writing;
    -- we just select which parts of the physical word
    -- handle two cases of VIRTUAL_ADDRESS_WIDTH rel. to PHYSICAL_ADDRESS_WIDTH
    if (VIRTUAL_ADDRESS_WIDTH > PHYSICAL_ADDRESS_WIDTH) then
      -- if VIRTUAL > PHYSICAL, ignore prefix
      wbm_adr_o((PHYSICAL_ADDRESS_WIDTH-DATA_SCALE_TWO_POWER)-1 downto 0) <=
        std_logic_vector(signed(latched_addr(PHYSICAL_ADDRESS_WIDTH-1 downto
                                             DATA_SCALE_TWO_POWER)));
      -- Convert physical burst address to virtual burst address so that our
      -- virtual client knows when to stop the burst.
      burst_addr_out(VIRTUAL_ADDRESS_WIDTH-1 downto PHYSICAL_ADDRESS_WIDTH) <=
        (others => '0');
      if (wbs_we_i = '1') then
        burst_addr_out(PHYSICAL_ADDRESS_WIDTH-1 downto DATA_SCALE_TWO_POWER) <=
          std_logic_vector(unsigned(burst_addr_in(PHYSICAL_ADDRESS_WIDTH-
                                                  DATA_SCALE_TWO_POWER-1
                                                  downto 0)));
      else
        -- subtract 1 if reading b/c the burst address is one physical address
        -- ahead; we want to be one virtual address ahead
        burst_addr_out(PHYSICAL_ADDRESS_WIDTH-1 downto DATA_SCALE_TWO_POWER) <=
          std_logic_vector(unsigned(burst_addr_in(PHYSICAL_ADDRESS_WIDTH-
                                                  DATA_SCALE_TWO_POWER-1 downto
                                                  0)-1));
      end if;

    else
      wbm_adr_o(PHYSICAL_ADDRESS_WIDTH-1 downto
                (VIRTUAL_ADDRESS_WIDTH-DATA_SCALE_TWO_POWER)) <=
        phy_start_addr;
      wbm_adr_o((VIRTUAL_ADDRESS_WIDTH-DATA_SCALE_TWO_POWER)-1 downto 0) <=
        std_logic_vector(signed(latched_addr(VIRTUAL_ADDRESS_WIDTH-1 downto
                                             DATA_SCALE_TWO_POWER)));
      -- Convert physical burst address to virtual burst address so that our
      -- virtual client knows when to stop the burst.
      if (wbs_we_i = '1') then
        burst_addr_out(VIRTUAL_ADDRESS_WIDTH-1 downto DATA_SCALE_TWO_POWER) <=
          std_logic_vector(unsigned(burst_addr_in(VIRTUAL_ADDRESS_WIDTH-
                                                  DATA_SCALE_TWO_POWER-1 downto
                                                  0)));
      else
        -- subtract 1 if reading b/c the burst address is one physical address
        -- ahead; we want to be one virtual address ahead
        burst_addr_out(VIRTUAL_ADDRESS_WIDTH-1 downto DATA_SCALE_TWO_POWER) <=
          std_logic_vector(unsigned(burst_addr_in(VIRTUAL_ADDRESS_WIDTH-
                                                  DATA_SCALE_TWO_POWER-1 downto
                                                  0)-1));
      end if;

    end if;

    burst_addr_out(DATA_SCALE_TWO_POWER-1 downto 0) <=
      std_logic_vector(to_unsigned(burst_offset_out, DATA_SCALE_TWO_POWER));

-------------------------------------------------------------------------------
-- Reading/Writing Process
    if (wb_rst_i = '1') then
      wbm_cyc_o    <= '0';
      wbm_stb_o    <= '0';
      wbs_ack_o    <= '0';
      burst_out    <= '0';
      state        := idle;

    elsif (rising_edge(wb_clk_i)) then
      case (state) is
-------------------------------------------------------------------------------
        when idle =>
          overlap := false;
          wbs_ack_o <= '0';
          if (wbs_cyc_i = '1') then
            latched_addr := wbs_adr_i;
            wbm_cyc_o    <= '1';
            burst_offset <= 0;
            burst_offset_out <= 0;
            if (wbs_we_i = '1') then
              if (burst_in = '1') then
                -- burst writing
                state := write_burst_reading;
              else
                burst_out    <= '0';
                -- single write
                select_offset :=
                  unsigned(wbs_adr_i(DATA_SCALE_TWO_POWER-1 downto 0));
                state        := write_reading;
              end if;
            else
              if (burst_in = '1') then
                -- burst reading
                state := read_burst_load;
              else
                burst_out    <= '0';
                -- single read
                wbm_stb_o <= wbs_stb_i;
                wbm_we_o    <= '0';
                select_offset :=
                  unsigned(wbs_adr_i(DATA_SCALE_TWO_POWER-1 downto 0));
                state        := read_reading;
              end if;
            end if;
          end if;
-------------------------------------------------------------------------------
-- WRITING
-------------------------------------------------------------------------------
-- Burst writes are slightly easier in that we only have to do the above for
-- any remainder of the last virtual word in the last physical word.
        when write_burst_reading =>
          if (wbs_cyc_i = '0') then
            overlap      := true;
          end if;

          if ((burst_offset >= DATA_SCALE) or overlap) then
            -- test for overlap so we can handle partial writes
            wbs_ack_o <= '0';
            for j in DATA_SCALE-1 downto 0 loop
              if (ENDIANNESS = little_endian) then
                wbm_dat_o((VIRTUAL_DATA_WIDTH*(j+1))-1 downto
                          (VIRTUAL_DATA_WIDTH*j)) <= burst_words(j);
              else
                wbm_dat_o((VIRTUAL_DATA_WIDTH*(j+1))-1 downto
                          (VIRTUAL_DATA_WIDTH*j)) <=
                  burst_words((DATA_SCALE-1)-j);
              end if;
            end loop;  -- j
            burst_offset <= 0;
            burst_out    <= '1';
            wbm_stb_o    <= '1';
            wbm_we_o     <= '1';
            state        := write_burst_writing;
          elsif (wbs_stb_i = '1') then
            latched_addr              := wbs_adr_i;
            wbs_ack_o                 <= '1';
            burst_words(burst_offset) := wbs_dat_i;
            state := write_burst_reading_ack;
          else
            wbs_ack_o <= '0';
          end if;
-------------------------------------------------------------------------------
        when write_burst_reading_ack =>
          wbs_ack_o    <= '0';
          burst_offset <= burst_offset + 1;
          if (burst_offset <= DATA_SCALE-2) then
            burst_offset_out <= burst_offset + 1;
          end if;
          state        := write_burst_reading;
-------------------------------------------------------------------------------
        when write_burst_writing =>
          burst_out <= '0';             -- only increment address by one
          if (overlap or (wbs_cyc_i = '0')) then
            overlap := true;
            wbm_cyc_o <= '0';
            wbm_we_o  <= '0';
            wbm_stb_o <= '0';
            state := idle;
          elsif (wbm_ack_i = '1') then
            wbm_stb_o <= '0';
            burst_offset_out <= 0;
            state := write_burst_done;
          end if;
-------------------------------------------------------------------------------
        when write_burst_done =>
          if ((wbm_ack_i = '0') and (overlap or (wbs_cyc_i = '0'))) then
            wbm_cyc_o <= '0';
            wbm_stb_o <= '0';
            wbm_we_o <= '0';
            state := idle;
          else
            state := write_burst_reading;
          end if;
-------------------------------------------------------------------------------
-- This is harder for non-burst writes b/c we have to read first and then write
-- back the unselected parts of the physical word with the new selected virtual
-- word.
        when write_reading =>
          wbm_we_o  <= '0';
          if (wbm_ack_i = '1') then
            wbm_cyc_o <= '0';
            wbm_stb_o <= '0';

            -- Fill the virtual write word into the physical write word,
            -- leaving the remainder the same
            for j in PHYSICAL_DATA_WIDTH-1 downto 0 loop
              if ((j <= select_address_start) and
                  (j >= select_address_end)) then
                wbm_dat_o(j) <= wbs_dat_i(j - select_address_end);
              else
                wbm_dat_o(j) <= wbm_dat_i(j);
              end if;
            end loop;
            state := write_writing;
          else
            wbm_stb_o <= '1';
          end if;
-------------------------------------------------------------------------------
        when write_writing =>
          wbs_ack_o <= wbm_ack_i;
          if (wbm_ack_i = '1') then
            wbm_cyc_o <= '0';
            wbm_stb_o <= '0';
            wbm_we_o  <= '0';
            state := write_done;
          else
            wbm_cyc_o   <= '1';
            wbm_stb_o   <= '1';
            wbm_we_o    <= '1';
          end if;
-------------------------------------------------------------------------------
        when write_done =>
          wbs_ack_o <= '0';
          if (wbs_cyc_i = '0') then
            overlap := true;
          end if;
          if (overlap and (wbm_ack_i = '0')) then
            state := idle;
          end if;
-------------------------------------------------------------------------------
-- READING
-- Non-burst reading is easy and just involves select the right read data
        when read_reading =>
          wbs_ack_o <= wbm_ack_i;
          if (wbm_ack_i = '1') then
            wbm_stb_o <= '0';
            wbm_cyc_o <= '0';
            state := read_done;
          end if;
          for j in PHYSICAL_DATA_WIDTH-1 downto 0 loop
            -- Select physical read data to return as virtual read data
            if ((j <= select_address_start) and (j >= select_address_end)) then
              wbs_dat_o(j - select_address_end) <= wbm_dat_i(j);
            end if;
          end loop;
-------------------------------------------------------------------------------
        when read_done =>
          wbs_ack_o   <= '0';
          if (wbs_cyc_i = '0') then
            overlap := true;
          end if;
          if (overlap and (wbm_ack_i = '0')) then
            state := idle;
          end if;
-------------------------------------------------------------------------------
        when read_burst_reading =>
          if (overlap or (wbs_cyc_i = '0')) then
            wbm_cyc_o <= '0';
            state := idle;
          elsif (wbs_stb_i = '1') then
            wbs_ack_o    <= '1';
            for j in PHYSICAL_DATA_WIDTH-1 downto 0 loop
              -- Select which virtual word of the current burst to return
              if ((j <= select_address_start) and
                  (j >= select_address_end)) then
                wbs_dat_o(j - select_address_end) <= read_data(j);
              end if;
            end loop;
            if (ENDIANNESS = little_endian) then
              if ((to_integer(select_offset) = (DATA_SCALE-1)) and
                  (wbm_ack_i = '0')) then
                state  := read_burst_load_stall;
              else
                state := read_burst_reading_ack;
              end if;
            else
              if ((to_integer(select_offset) = 0) and
                  (wbm_ack_i = '0')) then
                state  := read_burst_load_stall;
              else
                state := read_burst_reading_ack;
              end if;
            end if;
          else
            wbs_ack_o <= '0';
          end if;
-------------------------------------------------------------------------------
        when read_burst_load_stall =>
          if (wbs_cyc_i = '0') then
            wbm_cyc_o <= '0';
            overlap := true;
          end if;
          wbs_ack_o <= '0';
          state := read_burst_load;
-------------------------------------------------------------------------------
        when read_burst_load =>
          if (ENDIANNESS = little_endian) then
            select_offset := (others => '0');
          else
            select_offset := to_unsigned(DATA_SCALE-1, DATA_SCALE_TWO_POWER);
          end if;
          burst_offset <= 0;
          wbm_we_o     <= '0';
          if (overlap or (wbs_cyc_i = '0')) then
            wbm_cyc_o <= '0';
            wbm_stb_o <= '0';
            overlap := true;
            state := idle;
          elsif (wbm_ack_i = '1') then
            wbm_stb_o <= '0';
            read_data := wbm_dat_i;
            state := read_burst_reading;
          elsif (wbm_gnt_i = '1') then
            -- b/c burst is only one-off, wait for grant before continuing
            -- (bootstrap problem)
            wbm_stb_o    <= '1';
            if (wbm_stb_o = '0') then
              -- burst to increment address only once per strobe
              burst_out <= '1';
            else
              burst_offset_out <= 0;
            end if;
          end if;
          -- check this outside other if to lower the burst in case the
          -- first two branches are taken.
          if (wbm_stb_o = '1') then
            burst_out <= '0';
          else
            burst_out    <= '1';
          end if;
-------------------------------------------------------------------------------
        when read_burst_reading_ack =>
          if (wbs_cyc_i = '0') then
            wbm_cyc_o <= '0';
            overlap := true;
          end if;
          wbs_ack_o     <= '0';
          if (ENDIANNESS = little_endian) then
            select_offset := select_offset + 1;
          else
            select_offset := select_offset - 1;
          end if;
          burst_offset  <= burst_offset + 1;
          burst_offset_out <= burst_offset + 1;
          state         := read_burst_reading;
-------------------------------------------------------------------------------
        when others =>
          wbs_ack_o <= '0';
          state := idle;
      end case;
    end if;                             -- rising_edge(wb_clk_i)

  end process;

])
