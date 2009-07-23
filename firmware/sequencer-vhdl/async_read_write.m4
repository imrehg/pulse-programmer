dnl--*-VHDL-*-
-- Asynchronous unit for interclock reading and writing.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([async_read_write],
  [dnl -- Libraries
sequencer_libraries_
],[dnl -- Generics
  DATA_WIDTH       : positive := 8;
  ADDRESS_WIDTH    : positive := 16;
  WORD_COUNT_WIDTH : positive := 3;
  STABLE_COUNT     : positive := 2;
  HYSTERESIS       : positive := 2;
],[dnl -- Ports
  wb_rst_i        : in  std_logic;
  wbs_clk_i       : in  std_logic;
  wbs_cyc_i       : in  std_logic;
  wbs_stb_i       : in  std_logic;
  wbs_we_i        : in  std_logic;
  wbs_adr_i       : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  wbs_dat_i       : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  wbs_dat_o       : out std_logic_vector(DATA_WIDTH-1 downto 0);
  wbs_ack_o       : out std_logic;
  wbm_clk_i       : in  std_logic;
  wbm_cyc_o       : out std_logic;
  wbm_stb_o       : out std_logic;
  wbm_we_o        : out std_logic;
  wbm_adr_o       : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  wbm_dat_i       : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  wbm_dat_o       : out std_logic_vector(DATA_WIDTH-1 downto 0);
  wbm_ack_i       : in  std_logic;
  rdusedw_out     : out std_logic_vector(WORD_COUNT_WIDTH-1 downto 0);
  wrusedw_out     : out std_logic_vector(WORD_COUNT_WIDTH-1 downto 0);
  debug_led_out   : out byte;
],[dnl -- Declarations
async_fifo_component_
async_read_fifo_component_
  signal address_latched   : std_logic;
  signal read_ack          : std_logic;
  signal wbm_write_cyc     : std_logic;
  signal wbm_write_stb     : std_logic;
  signal wbm_write_ack     : std_logic;
  signal wbm_read_cyc      : std_logic;
  signal wbm_read_stb      : std_logic;
  signal wbm_read_ack      : std_logic;
  signal wbs_read_ack      : std_logic;
  signal wbs_write_ack     : std_logic;
  signal stable_counter    : natural range 0 to STABLE_COUNT+2;
  signal wbm_cyc           : std_logic;
  signal wbm_ack           : multibus_bit(0 to 1);
],[dnl -- Body

--  debug_led_out(7) <= address_read_stb;
  debug_led_out(6) <= wbm_read_cyc;
  debug_led_out(5) <= wbm_write_cyc;
  debug_led_out(4) <= wbm_write_stb;
  debug_led_out(3) <= wbm_write_ack;

  -----------------------------------------------------------------------------
  process(wb_rst_i, wbm_clk_i, wbm_cyc)

    type state_type is (
      idle,
      slave_fall,
      master_rise,
      master_fall
    );

    variable state : state_type;
    variable master_risen : boolean;
    variable slave_fallen : boolean;

  begin
    if (wb_rst_i = '1') then
      state := idle;
      address_latched <= '0';
      stable_counter <= 0;
    elsif (rising_edge(wbm_clk_i)) then
      case (state) is
        -----------------------------------------------------------------------
        when idle =>
          master_risen := false;
          slave_fallen := false;
          if (stable_counter >= STABLE_COUNT) then
            wbm_adr_o <= wbs_adr_i;
            address_latched <= '1';
            stable_counter  <= 0;
            state := slave_fall;
          elsif (wbs_cyc_i = '1') then
            stable_counter <= stable_counter + 1;
          end if;
        -----------------------------------------------------------------------
        when slave_fall =>
          if (wbm_cyc = '1') then
            master_risen := true;
          end if;
          if (stable_counter >= STABLE_COUNT) then
            address_latched <= '0';
            slave_fallen := true;
            stable_counter <= 0;
          elsif (wbs_cyc_i = '0') then
            stable_counter <= stable_counter + 1;
          end if;
          if (master_risen and slave_fallen) then
            state := master_fall;
          end if;
        -----------------------------------------------------------------------
        when master_fall =>
          if (wbm_cyc = '0') then
            state := idle;
          end if;
        -----------------------------------------------------------------------
        when others => null;
      end case;
    end if;          

  end process;

  -----------------------------------------------------------------------------
  reader : async_read_fifo
    generic map (
      DATA_WIDTH       => DATA_WIDTH,
      WORD_COUNT_WIDTH => WORD_COUNT_WIDTH,
      STABLE_COUNT     => STABLE_COUNT
      )
    port map (
      wb_rst_i        => wb_rst_i,
      wbs_clk_i       => wbs_clk_i,
      wbs_cyc_i       => (address_latched and (not wbs_we_i)),
      wbs_stb_i       => (wbs_stb_i and (not wbs_we_i)),
      wbs_dat_o       => wbs_dat_o,
      wbs_ack_o       => wbs_read_ack,
      wbm_clk_i       => wbm_clk_i,
      wbm_cyc_o       => wbm_read_cyc,
      wbm_stb_o       => wbm_read_stb,
      wbm_dat_i       => wbm_dat_i,
      wbm_ack_i       => wbm_read_ack,
      wrusedw_out     => wrusedw_out
      );

  -----------------------------------------------------------------------------
  writer : async_fifo
    generic map (
      DATA_WIDTH       => DATA_WIDTH,
      WORD_COUNT_WIDTH => WORD_COUNT_WIDTH,
      STABLE_COUNT     => STABLE_COUNT,
      HYSTERESIS       => HYSTERESIS
      )
    port map (
      wb_rst_i         => wb_rst_i,
      wb_read_clk_i    => wbm_clk_i,
      wb_read_cyc_o    => wbm_write_cyc,
      wb_read_stb_o    => wbm_write_stb,
      wb_read_dat_o    => wbm_dat_o,
      wb_read_ack_i    => wbm_write_ack,
      wb_write_clk_i   => wbs_clk_i,
      wb_write_cyc_i   => (address_latched and wbs_we_i),
      wb_write_stb_i   => (wbs_stb_i and wbs_we_i),
      wb_write_dat_i   => wbs_dat_i,
      wb_write_ack_o   => wbs_write_ack
      );

  wbs_ack_o <= (wbs_write_ack and wbs_we_i) or
        (wbs_read_ack and (not wbs_we_i));

  -----------------------------------------------------------------------------
  arbiter : wb_intercon
    generic map (
      MASTER_COUNT        => 2,
      ENABLE_TIMEOUT      => false
      )
    port map (
      -- Wishbone common signals
      wb_clk_i            => wbm_clk_i,
      wb_rst_i            => wb_rst_i,
      -- Master ports
      wbm_cyc_i           => (wbm_write_cyc, wbm_read_cyc),
      wbm_stb_i           => (wbm_write_stb, wbm_read_stb),
      wbm_we_i            => ('1', '0'),
      wbm_ack_o           => wbm_ack,
      -- Slave ports
      wbs_cyc_o           => wbm_cyc,
      wbs_stb_o           => wbm_stb_o,
      wbs_we_o            => wbm_we_o,
      wbs_ack_i           => wbm_ack_i
      );

  wbm_write_ack <= wbm_ack(0);
  wbm_read_ack  <= wbm_ack(1);
  wbm_cyc_o <= wbm_cyc;

])
