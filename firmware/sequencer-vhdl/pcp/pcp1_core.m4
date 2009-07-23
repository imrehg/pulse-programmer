dnl-*-VHDL-*-
-- Core for the Pulse Control Processor One (pcp1) machine
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([pcp1_core], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
library pcplib;
use pcplib.instructions.all;
],[dnl -- Generics ------------------------------------------------------------
  OPCODE_WIDTH        : positive := 4 ;
  TRIGGER_WIDTH       : positive := 9 ;
  TIMER_WIDTH         : positive := 28;
  ADDRESS_WIDTH       : positive := 19;
  INSTRUCTION_WIDTH   : positive := 32;
  IMMEDIATE_WIDTH     : positive := 16;
  OUTPUT_WIDTH        : positive := 64;
  REG_ADDRESS_WIDTH   : positive := 5 ;
  LOOP_REG_DATA_WIDTH : positive := 4 ;
  PHASE_WORD_WIDTH    : positive := 32;
  PHASE_ADDEND_WIDTH  : positive := 32;
  PHASE_ADJUST_WIDTH  : positive := 14;
  PHASE_ADDRESS_WIDTH : positive := 4;
  LOOP_ADDRESS_WIDTH  : positive := 4;
  STACK_ADDRESS_WIDTH : positive := 4;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   sclr                        : in  std_logic;
   wait_in                     : in  std_logic;
   instruction_in              : in  std_logic_vector(INSTRUCTION_WIDTH-1
                                                      downto 0);
   triggers_in                 : in  trigger_source_type;
   pc_out                      : out unsigned(ADDRESS_WIDTH-1 downto 0);
   halted_out                  : out std_logic;
   pulse_out                   : out std_logic_vector(OUTPUT_WIDTH-1 downto 0);
   debug_reg_addr              : out std_logic_vector(REG_ADDRESS_WIDTH-1
                                                      downto 0);
   -- Phase register file debug ports
   debug_phase_reg_addend      : out std_logic_vector(PHASE_ADDEND_WIDTH-1
                                                      downto 0);
   debug_phase_reg_word        : out std_logic_vector(PHASE_WORD_WIDTH-1
                                                    downto 0);
   debug_phase_reg_adjust      : out std_logic_vector(PHASE_ADJUST_WIDTH-1
                                                      downto 0);
   debug_phase_reg_wren        : out std_logic;
   debug_phase_reg_set_current : out std_logic;
   -- Loop register debug ports
   debug_loop_reg_count        : out std_logic_vector(LOOP_REG_DATA_WIDTH-1
                                                      downto 0);
   debug_loop_reg_data         : out std_logic_vector(LOOP_REG_DATA_WIDTH-1
                                                      downto 0);
   debug_loop_reg_wren         : out std_logic;
   debug_loop_reg_decrement    : out std_logic;
   debug_loop_reg_is_zero      : out std_logic;
   -- Address stack debug ports
   debug_sub_write_address     : out std_logic_vector(ADDRESS_WIDTH-1
                                                      downto 0);
   debug_sub_read_address      : out std_logic_vector(ADDRESS_WIDTH-1
                                                      downto 0);
   debug_sub_stack_push        : out std_logic;
   debug_sub_stack_pop         : out std_logic;
   -- Timer debug ports
   debug_timer_count           : out unsigned(TIMER_WIDTH-1 downto 0);
   debug_timer_clear           : out std_logic;
   debug_timer_load            : out std_logic;
   debug_timer_fired           : out std_logic;
   debug_led_out               : out byte;
],[dnl -- Declarations --------------------------------------------------------
pcp1_decoder_component_
pcp_phase_reg_file_component_
pcp_loop_reg_file_component_
pcp_address_stack_component_
timer_component_

  -- Register address for ldc, bdec, lp, and pp opcodes
  signal reg_addr : std_logic_vector(REG_ADDRESS_WIDTH-1 downto 0);
   
  -- Timer ports for wait opcode
   signal timer_count   : unsigned(TIMER_WIDTH-1 downto 0);
   signal timer_clear   : std_logic;
   signal timer_load    : std_logic;
   signal timer_fired   : std_logic;

   -- Phase register ports for lp and pp opcodes
   signal phase_reg_addr       : std_logic_vector(REG_ADDRESS_WIDTH-1
                                                   downto 0);
   signal phase_reg_addend      : std_logic_vector(PHASE_ADDEND_WIDTH-1
                                                   downto 0);
   signal phase_reg_word        : std_logic_vector(PHASE_WORD_WIDTH-1
                                                   downto 0);
   signal phase_reg_adjust      : std_logic_vector(PHASE_ADJUST_WIDTH-1
                                                   downto 0);
   signal phase_reg_wren        : std_logic;
   signal phase_reg_set_current : std_logic;
   
   -- Loop register ports for bdec and ldc opcodes
   signal loop_reg_data         : std_logic_vector(LOOP_REG_DATA_WIDTH-1
                                                   downto 0);
   signal loop_reg_wren         : std_logic;
   signal loop_reg_decrement    : std_logic;
   signal loop_reg_is_zero      : std_logic;

   -- Address stack ports for sub and ret opcodes
   signal sub_write_address     : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
   signal sub_read_address      : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
   signal sub_stack_push        : std_logic;
   signal sub_stack_pop         : std_logic;

],[dnl -- Body ----------------------------------------------------------------

   debug_reg_addr              <= reg_addr;
  -- Phase register file debug ports
   debug_phase_reg_addend      <= phase_reg_addend;
   debug_phase_reg_word        <= phase_reg_word;
   debug_phase_reg_adjust      <= phase_reg_adjust;
   debug_phase_reg_wren        <= phase_reg_wren;
   debug_phase_reg_set_current <= phase_reg_set_current;
   -- Loop register debug ports
   debug_loop_reg_data         <= loop_reg_data;
   debug_loop_reg_wren         <= loop_reg_wren;
   debug_loop_reg_decrement    <= loop_reg_decrement;
   debug_loop_reg_is_zero      <= loop_reg_is_zero;
   -- Address stack debug ports
   debug_sub_write_address     <= sub_write_address;
   debug_sub_read_address      <= sub_read_address;
   debug_sub_stack_push        <= sub_stack_push;
   debug_sub_stack_pop         <= sub_stack_pop;
   -- Timer debug ports
   debug_timer_count           <= timer_count;
   debug_timer_clear           <= timer_clear;
   debug_timer_load            <= timer_load;
   debug_timer_fired           <= timer_fired;
   
  decoder : pcp1_decoder
    generic map (
      OPCODE_WIDTH        => OPCODE_WIDTH        ,
      TRIGGER_WIDTH       => TRIGGER_WIDTH       ,
      TIMER_WIDTH         => TIMER_WIDTH         ,
      ADDRESS_WIDTH       => ADDRESS_WIDTH       ,
      INSTRUCTION_WIDTH   => INSTRUCTION_WIDTH   ,
      IMMEDIATE_WIDTH     => IMMEDIATE_WIDTH     ,
      OUTPUT_WIDTH        => OUTPUT_WIDTH        ,
      REG_ADDRESS_WIDTH   => REG_ADDRESS_WIDTH   ,
      LOOP_REG_DATA_WIDTH => LOOP_REG_DATA_WIDTH ,
      PHASE_WORD_WIDTH    => PHASE_WORD_WIDTH    ,
      PHASE_ADDEND_WIDTH  => PHASE_ADDEND_WIDTH  ,
      PHASE_ADJUST_WIDTH  => PHASE_ADJUST_WIDTH
      )
    port map (
      wb_clk_i               => wb_clk_i,
      wb_rst_i               => wb_rst_i,
      sclr                   => sclr,
      wait_in                => wait_in,
      instruction_in         => instruction_in,
      triggers_in            => triggers_in,
      pc_out                 => pc_out,
      -- Register address for ldc, bdec, lp, and pp opcodes
      reg_addr_out           => reg_addr,
      -- Timer ports for wait opcode
      timer_count_out        => timer_count,
      timer_clear_out        => timer_clear,
      timer_load_out         => timer_load,
      timer_fired_in         => timer_fired,
      -- Phase register ports for lp and pp opcodes
      phase_reg_addr_out     => phase_reg_addr,
      phase_reg_addend_out   => phase_reg_addend,
      phase_reg_word_out     => phase_reg_word,
      phase_reg_adjust_in    => phase_reg_adjust,
      phase_reg_wren_out     => phase_reg_wren,
      phase_reg_current_out  => phase_reg_set_current,
      -- Loop register ports for bdec and ldc opcodes
      loop_reg_data_out      => loop_reg_data,
      loop_reg_wren_out      => loop_reg_wren,
      loop_reg_decrement_out => loop_reg_decrement,
      loop_reg_is_zero_in    => loop_reg_is_zero,
      -- Address stack ports for sub and ret opcodes
      sub_address_out        => sub_write_address,
      sub_address_in         => sub_read_address,
      sub_stack_push_out     => sub_stack_push,
      sub_stack_pop_out      => sub_stack_pop,
      -- Status and debugging outputs
      pulse_out              => pulse_out,
      halted_out             => halted_out,
      debug_led_out          => debug_led_out
    );

  delay_timer : timer
    generic map (
      SUBCOUNTER_MULTIPLE    => 4,
      SUBCOUNTER_WIDTH       => 7
      )
    port map (
      clock      => wb_clk_i,
      clk_en     => '1',
      sclr       => timer_clear or sclr,
      load       => timer_load,
      count_in   => timer_count,
      fired_out  => timer_fired
      );

  phase_reg_file : pcp_phase_reg_file
    generic map (
      DATA_WIDTH         => PHASE_WORD_WIDTH,
      PHASE_ADJUST_WIDTH => PHASE_ADJUST_WIDTH,
      ADDRESS_WIDTH      => PHASE_ADDRESS_WIDTH,
      REGISTER_COUNT     => 2**PHASE_ADDRESS_WIDTH
      )
    port map (
      clk                => wb_clk_i,
      address_in         => phase_reg_addr(PHASE_ADDRESS_WIDTH-1 downto 0),
      phase_in           => phase_reg_word,
      addend_in          => phase_reg_addend,
      set_current_in     => phase_reg_set_current,
      phase_adjust_out   => phase_reg_adjust,
      wren_in            => phase_reg_wren
      );

  loop_reg_file : pcp_loop_reg_file
    generic map (
      DATA_WIDTH        => LOOP_REG_DATA_WIDTH,
      ADDRESS_WIDTH     => LOOP_ADDRESS_WIDTH,
      REGISTER_COUNT    => 2**LOOP_ADDRESS_WIDTH
      )
    port map (
      wb_clk_i          => wb_clk_i,
      wb_adr_i          => reg_addr(LOOP_ADDRESS_WIDTH-1 downto 0),
      wb_dat_i          => loop_reg_data,
      wb_we_i           => loop_reg_wren,
      decrement_in      => loop_reg_decrement,
      is_zero_out       => loop_reg_is_zero,
      debug_out         => debug_loop_reg_count
      );

  address_stack : pcp_address_stack
    generic map (
      DATA_WIDTH        => ADDRESS_WIDTH,
      ADDRESS_WIDTH     => STACK_ADDRESS_WIDTH,
      STACK_DEPTH       => 2**STACK_ADDRESS_WIDTH
      )
    port map (
      wb_clk_i          => wb_clk_i,
      sclr              => sclr,
      wb_dat_i          => sub_write_address,
      wb_dat_o          => sub_read_address,
      push_in           => sub_stack_push,
      pop_in            => sub_stack_pop
      );
  
-------------------------------------------------------------------------------
])
