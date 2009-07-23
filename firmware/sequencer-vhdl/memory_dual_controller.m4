dnl--*-VHDL-*-
-- Generic burst controller to dual-port memory.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([memory_dual_controller],
  [dnl -- Libraries
library altera_mf;
use altera_mf.altera_mf_components.all;
use ieee.numeric_std.all;
sequencer_libraries_
],[dnl -- Generics
    DATA_WIDTH          : positive := 8;
    ADDRESS_WIDTH       : positive := 4;
    WORD_COUNT          : positive := 8;
],[dnl -- Ports ---------------------------------------------------------------
    wb_clk_i : in  std_logic;
    -- First port
    wb1_cyc_i : in  std_logic;
    wb1_stb_i : in  std_logic;
    wb1_we_i  : in  std_logic;
    wb1_adr_i : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    wb1_dat_i : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    wb1_dat_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
    wb1_ack_o : out std_logic;
    burst1_in : in  std_logic;
    addr1_out : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    -- Second port
    wb2_cyc_i : in  std_logic;
    wb2_stb_i : in  std_logic;
    wb2_adr_i : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    wb2_dat_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
    wb2_ack_o : out std_logic;
    burst2_in : in  std_logic;
    addr2_out : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
],[dnl -- Declarations --------------------------------------------------------
   signal first_port_wren : std_logic;
   signal first_port_write_data : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal first_port_read_data : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal first_port_address   : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
   -- left open
   signal second_port_wren : std_logic;
   signal second_port_write_data : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal second_port_read_data : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal second_port_address   : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
   
],[dnl -- Component Instantiation ---------------------------------------------

  first_port : memory_burst_controller
    generic map (
      DATA_WIDTH        => DATA_WIDTH,
      ADDRESS_WIDTH     => ADDRESS_WIDTH,
      READ_PIPELINE_DELAY => 1
      )
    port map (
      ext_wb_we_o  => first_port_wren,
      ext_wb_dat_o => first_port_write_data,
      ext_wb_dat_i => first_port_read_data,
      ext_wb_adr_o => first_port_address,
      wb_clk_i     => wb_clk_i,
      wb_cyc_i     => wb1_cyc_i,
      wb_stb_i     => wb1_stb_i,
      wb_we_i      => wb1_we_i,
      wb_adr_i     => wb1_adr_i,
      wb_dat_i     => wb1_dat_i,
      wb_dat_o     => wb1_dat_o,
      wb_ack_o     => wb1_ack_o,
      burst_in     => burst1_in,
      addr_out     => addr1_out
      );

   -- This is a read-only controller
  second_port : memory_burst_controller
    generic map (
      DATA_WIDTH        => DATA_WIDTH,
      ADDRESS_WIDTH     => ADDRESS_WIDTH,
      READ_PIPELINE_DELAY => 1
      )
    port map (
      ext_wb_we_o  => second_port_wren,
      ext_wb_dat_o => second_port_write_data,
      ext_wb_dat_i => second_port_read_data,
      ext_wb_adr_o => second_port_address,
      wb_clk_i     => wb_clk_i,
      wb_cyc_i     => wb2_cyc_i,
      wb_stb_i     => wb2_stb_i,
      wb_we_i      => '0',
      wb_adr_i     => wb2_adr_i,
      wb_dat_i     => (others => '0'),
      wb_dat_o     => wb2_dat_o,
      wb_ack_o     => wb2_ack_o,
      burst_in     => burst2_in,
      addr_out     => addr2_out
      );
   
  memory : altsyncram
    generic map (
      operation_mode => "BIDIR_DUAL_PORT",
      LPM_TYPE       => "altsyncram",
      WIDTH_A        => DATA_WIDTH,
      WIDTHAD_A      => ADDRESS_WIDTH,
      WIDTH_B        => DATA_WIDTH,
      WIDTHAD_B      => ADDRESS_WIDTH,
      NUMWORDS_A     => WORD_COUNT,
      NUMWORDS_B     => WORD_COUNT
      )
    port map (
      wren_a    => first_port_wren,
--       clocken0  => ,
      data_a    => first_port_write_data,
      address_a => first_port_address,
      clock0    => wb_clk_i,
      clock1    => wb_clk_i,
      q_a       => first_port_read_data,
      wren_b    => '0',
      data_b    => (others => '0'),
      address_b => second_port_address,
      q_b       => second_port_read_data
      );
])

