dnl-*-VHDL-*-
-- Core for the Pulse Control Processor One (pcp2) machine
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([pcp2_core], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
library pcplib;
use pcplib.instructions.all;
],[dnl -- Generics ------------------------------------------------------------
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   sclr                        : in  std_logic;
   wait_in                     : in  std_logic;
   instruction_in              : in  pcp32_instruction_type;
   triggers_in                 : in  trigger_source_type;
   pc_out                      : out pcp32_address_type;
   halted_out                  : out std_logic;
   pulse_out                   : out pcp_pulse_type;

   wb_ptp_clk_i                : in  std_logic;
   wb_ptp_cyc_i                : in  std_logic;
   wb_ptp_stb_i                : in  std_logic;
   wb_ptp_we_i                 : in  std_logic;
   wb_ptp_adr_i                : in  pcp2_data_address_type;
   wb_ptp_dat_i                : in  pcp32a_data_type;
   wb_ptp_dat_o                : out pcp32a_data_type;
   
   -- Phase register file debug ports
   debug_phase_reg_addend      : out pcp32_phase_addend_type;
   debug_phase_reg_word        : out pcp32_phase_word_type;
   debug_phase_reg_adjust      : out pcp32_phase_adjust_type;
   debug_phase_reg_wren        : out std_logic;
   debug_phase_reg_set_current : out std_logic;
   -- Data memory debug ports
   debug_dmem_address          : out pcp2_data_address_type;
   debug_dmem_wren             : out std_logic;
   debug_dmem_read_data        : out pcp32a_data_type;
   debug_dmem_write_data       : out pcp32a_data_type;
   -- Loop register debug ports
   debug_r1_address            : out pcp2_register_address_type;
   debug_r1_wren               : out std_logic;
   debug_r1_write_data         : out pcp32a_data_type;
   debug_r1_read_data          : out pcp32a_data_type;
   debug_r2_address            : out pcp2_register_address_type;
   debug_r2_read_data          : out pcp32a_data_type;
   -- Address stack debug ports
   debug_sub_write_address     : out pcp32_address_type;
   debug_sub_read_address      : out pcp32_address_type;
   debug_sub_stack_push        : out std_logic;
   debug_sub_stack_pop         : out std_logic;
   -- Timer debug ports
   debug_timer_count           : out pcp32_timer_constant_type;
   debug_timer_clear           : out std_logic;
   debug_timer_load            : out std_logic;
   debug_timer_fired           : out std_logic;
   debug_led_out               : out byte;
],[dnl -- Declarations --------------------------------------------------------
pcp2_decoder_component_
pcp_phase_reg_file_component_
pcp_reg_file_component_
pcp_address_stack_component_
memory_dual_dc_component_
timer_component_

  -- Timer ports for wait opcode
   signal timer_count   : pcp32_timer_constant_type;
   signal timer_clear   : std_logic;
   signal timer_load    : std_logic;
   signal timer_fired   : std_logic;

   -- Phase register ports for lp and pp opcodes
   signal phase_reg_addr        : pcp2_phase_address_type;
   signal phase_reg_addend      : pcp32_phase_addend_type;
   signal phase_reg_word        : pcp32_phase_word_type;
   signal phase_reg_adjust      : pcp32_phase_adjust_type;
   signal phase_reg_wren        : std_logic;
   signal phase_reg_set_current : std_logic;

   -- Data memory ports for ldr, str
   signal dmem_address          : pcp2_data_address_type;
   signal dmem_wren             : std_logic;
   signal dmem_write_data       : pcp32a_data_type;
   signal dmem_read_data        : pcp32a_data_type;
   
   -- Register file ports for ldr, str, cmp, and ldc opcodes
   signal r1_address            : pcp2_register_address_type;
   signal r1_wren               : std_logic;
   signal r1_write_data         : pcp32a_data_type;
   signal r1_read_data          : pcp32a_data_type;
   signal r2_address            : pcp2_register_address_type;
   signal r2_read_data          : pcp32a_data_type;

   -- Address stack ports for sub and ret opcodes
   signal sub_write_address     : pcp32_address_type;
   signal sub_read_address      : pcp32_address_type;
   signal sub_stack_push        : std_logic;
   signal sub_stack_pop         : std_logic;

],[dnl -- Body ----------------------------------------------------------------
   -- Phase register file debug ports
   debug_phase_reg_addend      <= phase_reg_addend;
   debug_phase_reg_word        <= phase_reg_word;
   debug_phase_reg_adjust      <= phase_reg_adjust;
   debug_phase_reg_wren        <= phase_reg_wren;
   debug_phase_reg_set_current <= phase_reg_set_current;
   -- Data memory debug ports
   debug_dmem_address          <= dmem_address;
   debug_dmem_wren             <= dmem_wren;
   debug_dmem_write_data       <= dmem_write_data;
   debug_dmem_read_data        <= dmem_read_data;
   -- Register file debug ports
   debug_r1_address            <= r1_address;
   debug_r1_wren               <= r1_wren;
   debug_r1_write_data         <= r1_write_data;
   debug_r1_read_data          <= r1_read_data;
   debug_r2_address            <= r2_address;
   debug_r2_read_data          <= r2_read_data;
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
  -----------------------------------------------------------------------------
  decoder : pcp2_decoder
    port map (
      wb_clk_i               => wb_clk_i,
      sclr                   => sclr,
      wait_in                => wait_in,
      instruction_in         => instruction_in,
      triggers_in            => triggers_in,
      pc_out                 => pc_out,
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
      -- Data memory ports for ldr, str opcodes
      dmem_address_out       => dmem_address,
      dmem_wren_out          => dmem_wren,
      dmem_write_data_out    => dmem_write_data,
      dmem_read_data_in      => dmem_read_data,
      -- Register ports for ldr, str, cmp, and ldc opcodes
      r1_adr_out             => r1_address,
      r1_wren_out            => r1_wren,
      r1_write_data_out      => r1_write_data,
      r1_read_data_in        => r1_read_data,
      r2_adr_out             => r2_address,
      r2_read_data_in        => r2_read_data,
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
  -----------------------------------------------------------------------------
  delay_timer : timer
    generic map (
      SUBCOUNTER_MULTIPLE    => 4,
      SUBCOUNTER_WIDTH       => 7
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
  -----------------------------------------------------------------------------
  phase_reg_file : pcp_phase_reg_file
    generic map (
      DATA_WIDTH         => PCP32_PHASE_WORD_WIDTH,
      PHASE_ADJUST_WIDTH => PCP32_PHASE_ADJUST_WIDTH,
      ADDRESS_WIDTH      => PCP2_PHASE_ADDRESS_WIDTH,
      REGISTER_COUNT     => 2**PCP2_PHASE_ADDRESS_WIDTH
      )
    port map (
      clk                => wb_clk_i,
      address_in         => phase_reg_addr,
      phase_in           => phase_reg_word,
      addend_in          => phase_reg_addend,
      set_current_in     => phase_reg_set_current,
      phase_adjust_out   => phase_reg_adjust,
      wren_in            => phase_reg_wren
      );
  -----------------------------------------------------------------------------
  data_memory : memory_dual_dc
    generic map (
      DATA_WIDTH        => PCP32A_DATA_WIDTH,
      ADDRESS_WIDTH     => PCP2_DATA_ADDRESS_WIDTH
      )
    port map (
      -- First port
      wb1_clk_i         => wb_clk_i,
      wb1_cyc_i         => '1',
      wb1_stb_i         => '1',
      wb1_we_i          => dmem_wren,
      wb1_adr_i         => dmem_address,
      wb1_dat_o         => dmem_read_data,      
      wb1_dat_i         => dmem_write_data,
      burst1_in         => '0',
      -- Second port
      wb2_clk_i         => wb_ptp_clk_i,
      wb2_cyc_i         => wb_ptp_cyc_i,
      wb2_stb_i         => wb_ptp_stb_i,
      wb2_we_i          => wb_ptp_we_i,
      wb2_adr_i         => wb_ptp_adr_i,
      wb2_dat_i         => wb_ptp_dat_i,
      wb2_dat_o         => wb_ptp_dat_o,
      burst2_in         => '0'
      );
  -----------------------------------------------------------------------------
  reg_file : pcp_reg_file
    generic map (
      DATA_WIDTH     => PCP32A_DATA_WIDTH,
      ADDRESS_WIDTH  => PCP2_REGISTER_ADDRESS_WIDTH,
      REGISTER_COUNT => 2**PCP2_REGISTER_ADDRESS_WIDTH
      )
    port map (
      wb_clk_i       => wb_clk_i,
      wb1_adr_i      => r1_address,
      wb1_dat_o      => r1_read_data,
      wb1_dat_i      => r1_write_data,
      wb1_we_i       => r1_wren,
      wb2_adr_i      => r2_address,
      wb2_dat_o      => r2_read_data
      );
  -----------------------------------------------------------------------------
  address_stack : pcp_address_stack
    generic map (
      DATA_WIDTH        => PCP32_ADDRESS_WIDTH,
      ADDRESS_WIDTH     => PCP2_STACK_ADDRESS_WIDTH,
      STACK_DEPTH       => 2**PCP2_STACK_ADDRESS_WIDTH
      )
    port map (
      wb_clk_i          => wb_clk_i,
      sclr              => sclr,
      wb_dat_i          => std_logic_vector(sub_write_address),
      std_logic_vector(wb_dat_o)          => sub_read_address,
      push_in           => sub_stack_push,
      pop_in            => sub_stack_pop
      );
  
-------------------------------------------------------------------------------
])
