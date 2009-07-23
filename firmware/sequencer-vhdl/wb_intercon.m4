dnl--*-VHDL-*-
-- Wishbone multiplexed shared bus interconnection for one slave and multiple
-- masters.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Lower number masters always have priority over high numbered masters =>
-- The bus master is never switched
-- until the current master releases it.
-- Inserts a one cycle delay in between switching slave inputs from masters to
-- give slave a chance to register that cyc_i has gone low.
-- Master inputs from slaves is switched instantaneously.
-- wb_cyc_i is passed from the winning master to the slave.

unit_([wb_intercon],
  [dnl -- Libraries
sequencer_libraries_
],[dnl -- Generics
  MASTER_COUNT_WIDTH  : positive := 2;
  MASTER_COUNT        : positive := 2;
  -- 500,000 clock periods (enough to send 250,000 bytes)
  TIMEOUT             : positive := 500_000;
  ENABLE_TIMEOUT      : boolean  := false;
],[dnl -- Ports
wb_common_port_
   -- Master ports
    wbm_cyc_i     : in     multibus_bit(0 to MASTER_COUNT-1);
    wbm_stb_i     : in     multibus_bit(0 to MASTER_COUNT-1);
    wbm_we_i      : in     multibus_bit(0 to MASTER_COUNT-1)
                           := (others => '0');
    wbm_adr_i     : in     multibus_byte(0 to MASTER_COUNT-1)
                           := (others => (others => '0'));
    wbm_dat_i     : in     multibus_byte(0 to MASTER_COUNT-1)
                           := (others => (others => '0'));
    wbm_dat_o     : out    multibus_byte(0 to MASTER_COUNT-1);
    wbm_ack_o     : out    multibus_bit(0 to MASTER_COUNT-1);
    wbm_gnt_o     : out    multibus_bit(0 to MASTER_COUNT-1);
    -- Slave ports
    wbs_cyc_o     : buffer std_logic;
    wbs_stb_o     : buffer std_logic;
    wbs_we_o      : out    std_logic;
    wbs_adr_o     : out    byte;
    wbs_dat_o     : out    byte;
    wbs_dat_i     : in     byte := (others => '0');
    wbs_ack_i     : in     std_logic;
    debug_led_out : out    byte;
],[dnl -- Declarations
  constant ROUNDED_MASTER_COUNT : positive := (2**MASTER_COUNT_WIDTH)-1;
  signal current_winner      : natural range 0 to ROUNDED_MASTER_COUNT;
  signal next_winner         : natural range 0 to ROUNDED_MASTER_COUNT;
  signal master_request      : multibus_bit (0 to ROUNDED_MASTER_COUNT);
  signal master_grant        : multibus_bit (0 to ROUNDED_MASTER_COUNT);
  signal master_strobe       : multibus_bit (0 to ROUNDED_MASTER_COUNT);
  signal master_write_enable : multibus_bit (0 to ROUNDED_MASTER_COUNT);
  signal master_address      : multibus_byte(0 to ROUNDED_MASTER_COUNT);
  signal master_data_in      : multibus_byte(0 to ROUNDED_MASTER_COUNT);
  signal master_data_out     : multibus_byte(0 to ROUNDED_MASTER_COUNT);
  signal master_ack          : multibus_bit (0 to ROUNDED_MASTER_COUNT);
  signal timeout_expired     : boolean;
  subtype timeout_type is natural range 0 to TIMEOUT;
  signal counter             : timeout_type;

],[dnl -- Body
  -- augment Wishbone signals to include the null master at index MASTER_COUNT
  master_request(0 to MASTER_COUNT-1)      <= wbm_cyc_i;
  master_request(MASTER_COUNT to ROUNDED_MASTER_COUNT) <= (others => '0');

  master_strobe(0 to MASTER_COUNT-1)       <= wbm_stb_i;
  master_strobe(MASTER_COUNT to ROUNDED_MASTER_COUNT)  <= (others => '0');

  master_write_enable(0 to MASTER_COUNT-1) <= wbm_we_i;
  master_write_enable(MASTER_COUNT to ROUNDED_MASTER_COUNT) <= (others => '0');

  master_address(0 to MASTER_COUNT-1)      <= wbm_adr_i;
  master_address(MASTER_COUNT) <= (others => '0');

  master_data_in(0 to MASTER_COUNT-1)      <= wbm_dat_i;
  master_data_in(MASTER_COUNT) <= (others => '0');

  wbm_dat_o <= master_data_out(0 to MASTER_COUNT-1);
  wbm_ack_o <= master_ack(0 to MASTER_COUNT-1);

  wbm_gnt_o <= master_grant(0 to MASTER_COUNT-1);

  read_data_gen: for i in 0 to ROUNDED_MASTER_COUNT-1 generate
    master_data_out(i) <= wbs_dat_i;
  end generate read_data_gen;

  -- process to sync the grant signals on a clock edge
  process(wb_rst_i, wb_clk_i, current_winner, next_winner,
          master_grant, master_request, master_strobe,
          master_write_enable, master_address, master_data_in,
          wbs_dat_i, wbs_ack_i, timeout_expired, wbs_cyc_o, wbs_stb_o)

  begin

    if (wb_rst_i = '1') then
      current_winner  <= MASTER_COUNT;
      next_winner     <= MASTER_COUNT;
      master_grant    <= (others => '0');
      counter         <= 0;
      timeout_expired <= false;
      
    elsif (rising_edge(wb_clk_i)) then
      if (wbm_cyc_i(current_winner) = '0') then
        current_winner <= next_winner;
      end if;
      if ((wbm_cyc_i(current_winner) = '0') and
          (current_winner /= next_winner)) then
        -- insert one cycle delay between old master releasing bus and
        -- new master gaining bus.
        timeout_expired              <= false;
        counter                      <= 0;
        master_grant(next_winner)    <= '1';
        master_grant(current_winner) <= '0';

      elsif ((counter = TIMEOUT) and ENABLE_TIMEOUT) then
        if (master_request(current_winner) = '0') then
          timeout_expired <= false;
          counter <= 0;
        else
          timeout_expired <= true;
        end if;
        
      else
        -----------------------------------------------------------------------
        if (ENABLE_TIMEOUT) then
          if (master_request(current_winner) = '1') then
            counter <= counter + 1;
          else
            counter <= 0;
          end if;
        end if;
        -----------------------------------------------------------------------
        for i in 0 to ROUNDED_MASTER_COUNT loop
          if (master_request(i) = '1') then
            next_winner <= i;
            if (current_winner = MASTER_COUNT) then
              -- optimization to switch to new master from no master
              current_winner  <= i;
              master_grant(i) <= '1';
            end if;
            exit;
          end if;
        end loop;

      end if;
    end if;                             -- rising_edge(wb_clk_i)

    -- outside clock edge to reduce latency
    for i in 0 to ROUNDED_MASTER_COUNT loop
      if (current_winner = i) then
        wbs_we_o           <= master_write_enable(i) and master_request(i);
        wbs_adr_o          <= master_address(i);
        wbs_dat_o          <= master_data_in(i);
        if (timeout_expired and ENABLE_TIMEOUT) then
          -- if current winner has held us too long, release the slave
          -- and ack out any remaining data
          wbs_cyc_o        <= '0';
          wbs_stb_o        <= '0';
          master_ack(i)    <= master_strobe(i);
          debug_led_out(3) <= '1';
        else
          wbs_cyc_o        <= master_request(i);
          wbs_stb_o        <= master_strobe(i);
          master_ack(i)    <= wbs_ack_i;
          debug_led_out(3) <= '0';
        end if;
        debug_led_out(0)   <= master_request(i);
        debug_led_out(1)   <= master_strobe(i);
        debug_led_out(2)   <= wbs_ack_i;
        debug_led_out(4)   <= wbs_cyc_o;
        debug_led_out(5)   <= wbs_stb_o;
        debug_led_out(7 downto 6) <=
          std_logic_vector(to_unsigned(current_winner, 2));
      else
        master_ack(i)      <= '0';
      end if;
    end loop;  -- i

  end process;
])
