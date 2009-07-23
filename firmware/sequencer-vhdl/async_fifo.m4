dnl--*-VHDL-*-
-- Asynchronous FIFO for interclock transfers.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([async_fifo],
  [dnl -- Libraries
sequencer_libraries_
library lpm;
use lpm.lpm_components.all;
],[dnl -- Generics
  DATA_WIDTH       : positive := 64;
  WORD_COUNT_WIDTH : positive := 3;
  STABLE_COUNT     : positive := 2;
  HYSTERESIS       : positive := 3;
],[dnl -- Ports
  wb_rst_i        : in  std_logic;
  wb_read_clk_i   : in  std_logic;
  wb_read_cyc_o   : out std_logic;
  wb_read_stb_o   : buffer std_logic;
  wb_read_dat_o   : out std_logic_vector(DATA_WIDTH-1 downto 0);
  wb_read_ack_i   : in  std_logic;
  wb_write_clk_i  : in  std_logic;
  wb_write_cyc_i  : in  std_logic;
  wb_write_stb_i  : in  std_logic;
  wb_write_dat_i  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  wb_write_ack_o  : out std_logic;
  writing_cyc_out : out std_logic;
  rdusedw_out     : out std_logic_vector(WORD_COUNT_WIDTH-1 downto 0);
  wrusedw_out     : out std_logic_vector(WORD_COUNT_WIDTH-1 downto 0);
  debug_led_out   : out byte;
],[dnl -- Declarations
  constant WORD_COUNT   : positive := 2**WORD_COUNT_WIDTH;
  signal write_full     : std_logic;
  signal read_empty     : std_logic;
  signal write_req      : std_logic;
  signal write_empty    : std_logic;
  signal read_req       : std_logic;
  signal rdusedw        : std_logic_vector(WORD_COUNT_WIDTH-1 downto 0);
  signal wrusedw        : std_logic_vector(WORD_COUNT_WIDTH-1 downto 0);
  signal stable_counter : natural range 0 to STABLE_COUNT+1;
  signal write_enable   : std_logic;
--  signal writing_cyc    : std_logic;
],[dnl -- Body

  transfer_fifo : lpm_fifo_dc
    generic map (
      LPM_WIDTH    => DATA_WIDTH,
      LPM_WIDTHU   => WORD_COUNT_WIDTH,
      LPM_NUMWORDS => 2**WORD_COUNT_WIDTH
      )
    port map (
      aclr    => wb_rst_i,
      rdclock => wb_read_clk_i,
      wrclock => wb_write_clk_i,
      rdreq   => read_req,
      wrreq   => write_req,
      data    => wb_write_dat_i,
      q       => wb_read_dat_o,
      rdempty => read_empty,
      wrfull  => write_full,
      wrempty => write_empty,
      rdusedw => rdusedw,
      wrusedw => wrusedw
      );

   debug_led_out(7) <= read_empty;
   debug_led_out(6) <= write_req;
   debug_led_out(5) <= write_empty;
   debug_led_out(4) <= write_full;

   write_req <= wb_write_stb_i and write_enable and (not write_full);

   -- Write slave process
   ----------------------------------------------------------------------------
   writer : process(wb_write_clk_i, wb_rst_i)

     type state_type is (
       idle,
       writing,
       emptying
       );

     variable state : state_type;

   begin
     if (wb_rst_i = '1') then
       write_enable <= '0';
       state := idle;
     elsif (rising_edge(wb_write_clk_i)) then
       case (state) is
         ----------------------------------------------------------------------
         when idle =>
           if (wb_write_cyc_i = '1') then
             write_enable <= '1';
             state := writing;
           end if;
         ----------------------------------------------------------------------
         when writing =>
           if (wb_write_cyc_i = '0') then
             write_enable <= '0';
             state := emptying;
           end if;
         ----------------------------------------------------------------------
         when emptying =>
           if (write_empty = '1') then
             state := idle;
           end if;
         ----------------------------------------------------------------------
         when others => null;
       end case;
     end if;

   end process;
     
   ----------------------------------------------------------------------------
   -- Read master process
   reader : process(wb_read_clk_i, wb_rst_i)

     type state_type is (
       idle,
       reading,
       reading_prefetch,
       writing_prefetch,
       writing_prefetch_stall,
       writing,
       writing_stall,
       reading_stall,
       reading_stall_ack
       );

     variable state : state_type;

   begin
     if (wb_rst_i = '1') then
       state          := idle;
       read_req       <= '0';
       wb_read_stb_o  <= '0';
       wb_read_cyc_o  <= '0';
       stable_counter <= 0;
     --------------------------------------------------------------------------
     elsif (rising_edge(wb_read_clk_i)) then
       case (state) is
         ----------------------------------------------------------------------
         when idle =>
           debug_led_out(3 downto 0) <= X"0";
           if (stable_counter >= STABLE_COUNT) then
             stable_counter <= 0;
             writing_cyc_out <= '1';
             state := writing_prefetch;
           elsif (wb_write_cyc_i = '1') then
             stable_counter <= stable_counter + 1;
           end if;
         ----------------------------------------------------------------------
         when writing_prefetch =>
           debug_led_out(3 downto 0) <= X"1";
           if (to_integer(unsigned(rdusedw)) >= HYSTERESIS) then
             if (stable_counter >= STABLE_COUNT) then
               stable_counter <= 0;
               wb_read_cyc_o <= '1';
               read_req <= '1';
               state := writing_prefetch_stall;
             elsif (wb_write_cyc_i = '1') then
               stable_counter <= stable_counter + 1;
             end if;
           end if;
         ----------------------------------------------------------------------
         when writing_prefetch_stall =>
           debug_led_out(3 downto 0) <= X"2";
           wb_read_stb_o <= '1';
           read_req <= '0';
           state := reading;
         ----------------------------------------------------------------------
         when writing =>
           debug_led_out(3 downto 0) <= X"3";
           if ((read_empty = '0') and (wb_read_ack_i = '0')) then
             if (stable_counter >= STABLE_COUNT) then
               stable_counter <= 0;
               writing_cyc_out <= '0';
               state := writing_stall;
             elsif (wb_write_cyc_i = '0') then
               stable_counter <= stable_counter + 1;
             elsif (to_integer(unsigned(rdusedw)) >= HYSTERESIS) then
               stable_counter <= 0;
               read_req <= '1';
               state := reading_prefetch;
             end if;
           end if;
         ----------------------------------------------------------------------
         when reading_prefetch =>
           debug_led_out(3 downto 0) <= X"4";
           wb_read_stb_o <= '1';
           read_req <= '0';
           state := reading;
         ----------------------------------------------------------------------
         when reading =>
           debug_led_out(3 downto 0) <= X"5";
           if (wb_read_ack_i = '1') then
             wb_read_stb_o <= '0';
             state         := writing;
           end if;
         ----------------------------------------------------------------------
         when writing_stall =>
           debug_led_out(3 downto 0) <= X"6";
           wb_read_stb_o <= '0';
           -- right after writing is done, wait for fifo count to go up to 2
           -- before reading out to avoid false zeros
           if (read_empty = '0') then
             if (wb_read_ack_i = '0') then
               read_req      <= '1';
               state         := reading_stall;
             end if;
           else
             wb_read_cyc_o <= '0';
             state         := idle;
           end if;
         ----------------------------------------------------------------------
         when reading_stall =>
           debug_led_out(3 downto 0) <= X"7";
           wb_read_stb_o <= '1';
           read_req <= '0';
           state := reading_stall_ack;
         ----------------------------------------------------------------------
         when reading_stall_ack =>
           if (wb_read_ack_i = '1') then
             wb_read_stb_o <= '0';
             state         := writing_stall;
           end if;
         ----------------------------------------------------------------------
         when others =>
           debug_led_out(3 downto 0) <= X"8";
           state := idle;
         ----------------------------------------------------------------------
       end case;

     end if;
       
   end process;

   wb_write_ack_o <= write_req;

   rdusedw_out <= rdusedw;
   wrusedw_out <= wrusedw;
])
