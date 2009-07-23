dnl--*-VHDL-*-
-- Asynchronous FIFO for simple one-shot interclock writes.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([async_simple_fifo],
  [dnl -- Libraries
sequencer_libraries_
library lpm;
use lpm.lpm_components.all;
],[dnl -- Generics
    DATA_WIDTH       : positive := 8;
    WORD_COUNT_WIDTH : positive := 3;
],[dnl -- Ports
  wb_rst_i        : in  std_logic;
  wbs_clk_i       : in  std_logic;
  wbs_cyc_i       : in  std_logic;
  wbs_stb_i       : in  std_logic;
  wbs_dat_i       : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  wbs_ack_o       : out std_logic;
  wbm_clk_i       : in  std_logic;
  wbm_cyc_o       : out std_logic;
  wbm_stb_o       : out std_logic;
  wbm_dat_o       : out std_logic_vector(DATA_WIDTH-1 downto 0);
  wbm_ack_i       : in  std_logic;
  rdusedw_out     : out std_logic_vector(WORD_COUNT_WIDTH-1 downto 0);
  wrusedw_out     : out std_logic_vector(WORD_COUNT_WIDTH-1 downto 0);
],[dnl -- Declarations
  signal read_req       : std_logic;
  signal write_full     : std_logic;
  signal read_empty     : std_logic;
],[dnl -- Body

  transfer_fifo : lpm_fifo_dc
    generic map (
      LPM_WIDTH    => DATA_WIDTH,
      LPM_WIDTHU   => WORD_COUNT_WIDTH,
      LPM_NUMWORDS => 2**WORD_COUNT_WIDTH
      )
    port map (
      aclr    => wb_rst_i,
      rdclock => wbm_clk_i,
      wrclock => wbs_clk_i,
      rdreq   => read_req,
      wrreq   => wbs_cyc_i and wbs_stb_i,
      data    => wbs_dat_i,
      q       => wbm_dat_o,
      rdempty => read_empty,
      wrfull  => write_full,
      rdusedw => rdusedw_out,
      wrusedw => wrusedw_out
      );

   process(wbm_clk_i, wb_rst_i)

     type state_type is (
       idle,
       reading,
       reading_stall
       );

     variable state : state_type;

   begin
     if (wb_rst_i = '1') then
       state          := idle;
       read_req       <= '0';
       wbm_cyc_o      <= '0';
       wbm_stb_o      <= '0';
     --------------------------------------------------------------------------
     elsif (rising_edge(wbm_clk_i)) then
       case (state) is
         ----------------------------------------------------------------------
         when idle =>
           if (read_empty = '0') then
             read_req <= '1';
             state := reading;
           end if;
         ----------------------------------------------------------------------
         when reading =>
           read_req <= '0';
           wbm_cyc_o <= '1';
           wbm_stb_o <= '1';
           state := reading_stall;
         ----------------------------------------------------------------------
         when reading_stall =>
           if (wbm_ack_i = '1') then
             wbm_cyc_o <= '0';
             wbm_stb_o <= '0';
             state := idle;
           end if;
         ----------------------------------------------------------------------
         when others => null;
       end case;
     end if;
       
   end process;

   wbs_ack_o <= wbs_cyc_i and wbs_stb_i and (not write_full);

])
