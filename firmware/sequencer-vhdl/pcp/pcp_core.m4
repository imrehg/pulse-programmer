dnl-*-VHDL-*-
-- Pulse Control Processor Core
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([pcp_core], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
library pcplib;
use pcplib.instructions.all;
],[dnl -- Generics ------------------------------------------------------------
  DATA_WIDTH    : positive := 64;
  ADDRESS_WIDTH : positive := 10;
  TRIGGER_COUNT : positive := 9;
  TIMER_WIDTH   : positive := 40;
  REGISTER_ADDRESS_WIDTH : positive := 2;
  REGISTER_COUNT : positive := 4;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   sclr                   : in  std_logic;
   instruction_in         : in  pcp_instruction_type;
   triggers_in            : in  trigger_source_type;
   pc_out                 : out unsigned(ADDRESS_WIDTH-1 downto 0);
   halted_out             : out std_logic;
   ram_adr_o              : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
   ram_dat_i              : in  std_logic_vector(DATA_WIDTH-1 downto 0);
   pulse_out              : out std_logic_vector(DATA_WIDTH-1 downto 0);
   -- Debugging ports
   debug_rd_we_o          : out std_logic;
   debug_reg1_adr_o       : out pcp_register_address_type;
   debug_rd_write_data_o  : out pcp_register_type;
   debug_rs1_adr_o        : out pcp_register_address_type;
   debug_rs1_read_data_o  : out pcp_register_type;
   debug_rs2_adr_o        : out pcp_register_address_type;
   debug_rs2_read_data_o  : out pcp_register_type;
   debug_led_out          : out byte;
   debug_timer_count      : out unsigned(TIMER_WIDTH-1 downto 0);
   debug_timer_load       : out std_logic;
   debug_timer_fired      : out std_logic;
],[dnl -- Declarations --------------------------------------------------------
pcp_decoder_component_
pcp_reg_file_component_
timer_component_
   signal rd_we         : std_logic;
   signal reg1_adr      : pcp_register_address_type;
   signal rd_adr        : pcp_register_address_type;
   signal rd_write_data : pcp_register_type;
   signal rs1_adr       : pcp_register_address_type;
   signal rs1_read_data : pcp_register_type;
   signal rs2_adr       : pcp_register_address_type;
   signal rs2_read_data : pcp_register_type;
   signal timer_count   : unsigned(TIMER_WIDTH-1 downto 0);
   signal timer_clear   : std_logic;
   signal timer_load    : std_logic;
   signal timer_fired   : std_logic;
   signal timer_enable  : std_logic;
   signal decoder_debug_led : byte;
],[dnl -- Body ----------------------------------------------------------------

   debug_rd_we_o <= rd_we;
   debug_rd_write_data_o <= rd_write_data;
   debug_reg1_adr_o <= reg1_adr;
   debug_rs1_adr_o <= rs1_adr;
   debug_rs1_read_data_o <= rs1_read_data;
   debug_rs2_adr_o <= rs2_adr;
   debug_rs2_read_data_o <= rs2_read_data;
   debug_timer_count <= timer_count;
   debug_timer_load <= timer_load;
   debug_timer_fired <= timer_fired;
   
  reg_file : pcp_reg_file
    generic map (
      DATA_WIDTH     => DATA_WIDTH,
      ADDRESS_WIDTH  => REGISTER_ADDRESS_WIDTH,
      REGISTER_COUNT => REGISTER_COUNT
      ) 
    port map (
      -- Wishbone common signals
      wb_clk_i            => wb_clk_i,
      wb1_adr_i           => reg1_adr(REGISTER_ADDRESS_WIDTH-1 downto 0),
      wb1_dat_o           => rs1_read_data,
      wb1_dat_i           => rd_write_data,
      wb1_we_i            => rd_we,
      wb2_adr_i           => rs2_adr(REGISTER_ADDRESS_WIDTH-1 downto 0),
      wb2_dat_o           => rs2_read_data
      );

  reg1_adr <= rd_adr when (rd_we = '1') else rs1_adr;

  debug_led_out(7 downto 3) <= decoder_debug_led(7 downto 3);
  debug_led_out(0) <= timer_load;
  debug_led_out(1) <= timer_clear;
  debug_led_out(2) <= timer_fired;

  decoder : pcp_decoder
    generic map (
      TRIGGER_COUNT          => TRIGGER_COUNT,
      TIMER_WIDTH            => TIMER_WIDTH,
      ADDRESS_WIDTH          => ADDRESS_WIDTH,
      DATA_WIDTH             => DATA_WIDTH,
      REGISTER_ADDRESS_WIDTH => REGISTER_ADDRESS_WIDTH
      )
    port map (
      -- Wishbone common signals
     wb_clk_i        => wb_clk_i,
     wb_rst_i        => wb_rst_i,
     sclr            => sclr,
     instruction_in  => instruction_in,
     triggers_in     => triggers_in,
     pc_out          => pc_out,
     timer_count_out => timer_count,
     timer_clear_out => timer_clear,
     timer_load_out  => timer_load,
     timer_fired_in  => timer_fired,
     ram_adr_o       => ram_adr_o,
     ram_dat_i       => ram_dat_i,
     rd_adr_o        => rd_adr(REGISTER_ADDRESS_WIDTH-1 downto 0),
     rd_we_o         => rd_we,
     rd_dat_o        => rd_write_data,
     rs1_adr_o       => rs1_adr(REGISTER_ADDRESS_WIDTH-1 downto 0),
     rs1_dat_i       => rs1_read_data,
     rs2_adr_o       => rs2_adr(REGISTER_ADDRESS_WIDTH-1 downto 0),
     rs2_dat_i       => rs2_read_data,
     pulse_out       => pulse_out,
     halted_out      => halted_out,
     debug_led_out   => decoder_debug_led
    );

  delay_timer : timer
    generic map (
      SUBCOUNTER_MULTIPLE    => 5,
      SUBCOUNTER_WIDTH       => 8
      )
    port map (
      clock      => wb_clk_i,
      clk_en     => '1',
      reset      => wb_rst_i,
      sclr       => timer_clear or sclr,
      load       => timer_load,
      count_in   => timer_count,
      quantum_in => (0 => '1', others => '0'),
      fired_out  => timer_fired
      );
-------------------------------------------------------------------------------
])
