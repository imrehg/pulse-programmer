dnl--*-VHDL-*-
-- Asynchronous FIFO for interclock reading.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([async_read_fifo],
  [dnl -- Libraries
sequencer_libraries_
library lpm;
use lpm.lpm_components.all;
],[dnl -- Generics
  DATA_WIDTH       : positive := 8;
  WORD_COUNT_WIDTH : positive := 3;
  STABLE_COUNT     : positive := 2;
  HYSTERESIS       : positive := 4;
],[dnl -- Ports
  wb_rst_i        : in  std_logic;
  wbs_clk_i       : in  std_logic;
  wbs_cyc_i       : in  std_logic;
  wbs_stb_i       : in  std_logic;
  wbs_dat_o       : out std_logic_vector(DATA_WIDTH-1 downto 0);
  wbs_ack_o       : out std_logic;
  wbm_clk_i       : in  std_logic;
  wbm_cyc_o       : out std_logic;
  wbm_stb_o       : out std_logic;
  wbm_dat_i       : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  wbm_ack_i       : in  std_logic;
  rdusedw_out     : out std_logic_vector(WORD_COUNT_WIDTH-1 downto 0);
  wrusedw_out     : out std_logic_vector(WORD_COUNT_WIDTH-1 downto 0);
  debug_led_out   : out byte;
],[dnl -- Declarations
  constant WORD_COUNT   : positive := 2**WORD_COUNT_WIDTH;
  signal write_enable   : std_logic;
  signal read_enable    : std_logic;
  signal read_req       : std_logic;
  signal write_full     : std_logic;
  signal read_empty     : std_logic;
  signal write_empty    : std_logic;
  signal write_req      : std_logic;
  signal rdusedw        : std_logic_vector(WORD_COUNT_WIDTH-1 downto 0);
  signal wrusedw        : std_logic_vector(WORD_COUNT_WIDTH-1 downto 0);
  signal stable_counter : natural range 0 to STABLE_COUNT+1;
  signal read_counter   : natural range 0 to STABLE_COUNT+1;
],[dnl -- Body

  -----------------------------------------------------------------------------
  transfer_fifo : lpm_fifo_dc
    generic map (
      LPM_WIDTH    => DATA_WIDTH,
      LPM_WIDTHU   => WORD_COUNT_WIDTH,
      LPM_NUMWORDS => WORD_COUNT
      )
    port map (
      aclr    => wb_rst_i,
      rdclock => wbs_clk_i,
      wrclock => wbm_clk_i,
      rdreq   => read_req, -- or (not read_enable), -- ack out dregs
      wrreq   => wbm_ack_i and write_enable,
      data    => wbm_dat_i,
      q       => wbs_dat_o,
      rdempty => read_empty,
      wrempty => write_empty,
      wrfull  => write_full,
      rdusedw => rdusedw,
      wrusedw => wrusedw
      );

  -----------------------------------------------------------------------------
  -- Read master process
  reader : process(wbm_clk_i, wb_rst_i)

    type state_type is (
      idle,
      reading,
      writing,
      emptying
      );

    variable state : state_type;

  begin
    if (wb_rst_i = '1') then
      state          := idle;
      write_enable   <= '0';
      wbm_stb_o      <= '0';
      stable_counter <= 0;
    --------------------------------------------------------------------------
    elsif (rising_edge(wbm_clk_i)) then
      case (state) is
        ----------------------------------------------------------------------
        when idle =>
          if (stable_counter >= STABLE_COUNT) then
            stable_counter <= 0;
            write_enable <= '1';
            state := reading;
          elsif (wbs_cyc_i = '1') then
            stable_counter <= stable_counter + 1;
          end if;
        ----------------------------------------------------------------------
        when reading =>
          if (stable_counter >= STABLE_COUNT) then
            stable_counter <= 0;
            write_enable <= '0';
            state := emptying;
          elsif (wbs_cyc_i = '0') then
            stable_counter <= stable_counter + 1;
          end if;
        -----------------------------------------------------------------------
        when writing =>
          if (wbm_ack_i = '1') then
            wbm_stb_o <= '0';
            state := reading;
          end if;
        ----------------------------------------------------------------------
        when emptying =>
          if (stable_counter >= STABLE_COUNT) then
            stable_counter <= 0;
            state := idle;
          elsif (write_empty = '1') then
            stable_counter <= stable_counter + 1;
          end if;
        ----------------------------------------------------------------------
        when others =>
          null;
        ----------------------------------------------------------------------
      end case;

    end if;

    if (to_integer(unsigned(wrusedw)) < (WORD_COUNT-HYSTERESIS)) then
      write_req <= write_enable;
    else
      write_req <= '0';
    end if;

    wbm_stb_o <= write_req;
    
       
  end process;

  -----------------------------------------------------------------------------
  write : process(wbs_clk_i, wb_rst_i)

    type state_type is (
      idle,
      reading,
      reading_ack,
      emptying
      );

    variable state : state_type;


  begin
    if (wb_rst_i = '1') then
      read_enable    <= '1';
      read_req       <= '0';
      read_counter   <= 0;
      wbs_ack_o      <= '0';
      state          := idle;
    elsif (rising_edge(wbs_clk_i)) then
      case (state) is
        -----------------------------------------------------------------------
        when idle =>
          if (wbs_cyc_i = '1') then
            state := reading;
            read_enable <= '1';
          end if;
        -----------------------------------------------------------------------
        when reading =>
          wbs_ack_o <= '0';
          if (wbs_cyc_i = '0') then
            state := emptying;
            read_req <= '1';
            read_enable <= '0';
          elsif ((wbs_stb_i = '1') and (read_empty = '0')) then
            state := reading_ack;
            read_req <= '1';
          end if;
        -----------------------------------------------------------------------
        when reading_ack =>
          read_req <= '0';
          wbs_ack_o <= wbs_cyc_i;       -- to avoid acking after cyc falls
          state := reading;
        -----------------------------------------------------------------------
        when emptying =>
          if (read_counter >= STABLE_COUNT) then
            read_req <= '0';
            read_enable <= '1';
            read_counter <= 0;
            state := idle;
          elsif (to_integer(unsigned(wrusedw)) = 0) then
            read_counter <= read_counter + 1;
          end if;
        when others => null;
      end case;

    end if;
  end process;

  wbm_cyc_o <= write_enable;

  rdusedw_out <= rdusedw;
  wrusedw_out <= wrusedw;

])
