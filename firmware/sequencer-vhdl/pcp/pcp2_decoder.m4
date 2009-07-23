dnl-*-VHDL-*-
-- Instruction decoder for the Pulse Control Processor One (pcp2) machine.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([pcp2_decoder], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
library pcplib;
use pcplib.instructions.all;
],[dnl -- Generics ------------------------------------------------------------
],[dnl -- Ports ---------------------------------------------------------------
  wb_clk_i               : in  std_logic;
  sclr                   : in  std_logic;
  wait_in                : in  std_logic;
  instruction_in         : in  pcp32_instruction_type;
  triggers_in            : in  pcp2_trigger_type;
  pc_out                 : out pcp32_address_type;
  -- Timer ports for wait opcode
  timer_count_out        : out pcp32_timer_constant_type;
  timer_clear_out        : out std_logic;
  timer_load_out         : out std_logic;
  timer_fired_in         : in  std_logic;
  -- Phase register ports for lp and pp opcodes
  phase_reg_addr_out     : out pcp2_phase_address_type;
  phase_reg_addend_out   : out pcp32_phase_addend_type;
  phase_reg_word_out     : out pcp32_phase_word_type;
  phase_reg_adjust_in    : in  pcp32_phase_adjust_type;
  phase_reg_wren_out     : out std_logic;
  phase_reg_current_out  : out std_logic;
  -- Data memory ports for ldr, str opcodes
  dmem_address_out       : out pcp2_data_address_type;
  dmem_wren_out          : out std_logic;
  dmem_write_data_out    : out pcp32a_data_type;
  dmem_read_data_in      : in  pcp32a_data_type;
  -- Register ports for ldr, str, cmp, and ldc opcodes
  r1_adr_out             : out pcp2_register_address_type;
  r1_wren_out            : out std_logic;
  r1_write_data_out      : out pcp32a_data_type;
  r1_read_data_in        : in  pcp32a_data_type;
  r2_adr_out             : out pcp2_register_address_type;
  r2_read_data_in        : in  pcp32a_data_type;
  -- Address stack ports for sub and ret opcodes
  sub_address_out        : out pcp32_address_type;
  sub_address_in         : in  pcp32_address_type;
  sub_stack_push_out     : out std_logic;
  sub_stack_pop_out      : out std_logic;
  -- Status and debugging outputs
  pulse_out              : out pcp_pulse_type;
  halted_out             : out std_logic;
  debug_led_out          : out byte;
],[dnl -- Declarations --------------------------------------------------------
   alias opcode             is instruction_in(PCP32_INSTRUCTION_WIDTH-1 downto
                                              PCP32_INSTRUCTION_WIDTH-
                                              PCP32_OPCODE_WIDTH);
   alias reg_addr           is instruction_in(23+PCP2_REGISTER_ADDRESS_WIDTH-1
                                              downto 23);
   alias immediate_address  is instruction_in(PCP32_ADDRESS_WIDTH-1 downto 0);
   alias data_constant      is instruction_in(PCP32A_DATA_WIDTH-1 downto 0);
   alias sel16              is instruction_in(17 downto 16);
   alias output_constant    is instruction_in(PCP32_OUTPUT_CONSTANT_WIDTH-1
                                              downto 0);
   alias upper_out_const    is instruction_in(PCP32_OUTPUT_CONSTANT_WIDTH-1
                                              downto 8);
   alias lower_out_const    is instruction_in(7 downto 0);
   alias timer_constant     is instruction_in(PCP32_TIMER_WIDTH-1 downto 0);
   alias trigger_source     is instruction_in(19+PCP2_TRIGGER_WIDTH-1
                                              downto 19);

   alias phase_wren_flag    is instruction_in(22);
   alias phase_addend_flag  is instruction_in(21);
   alias phase_current_flag is instruction_in(20);
   alias phase_sel32        is instruction_in(16);

   signal pc                  : pcp32_address_type;
   signal halt_flag           : boolean;
   signal timer_done          : boolean;

   -- Looping decrement signals
   signal pc_beq_flag         : boolean;
   signal trigger_branch_flag : boolean;

   -- Branch flags
   signal pc_branch_flag      : boolean;
   signal pc_branch_addr      : pcp32_address_type;
   signal pc_ret_flag         : boolean;
   signal pc_sub_flag         : boolean;
   signal pc_jump_flag        : boolean;

   -- Phase reg file signals
   signal phase_reg_wren      : std_logic;

   signal dec_value           : pcp32a_data_type;

   -- Abbreviations for decoding opcodes
   signal decoded_ldr         : boolean;
   signal decoded_str         : boolean;
   signal decoded_btr         : boolean;
   signal decoded_j           : boolean;
   signal decoded_sub         : boolean;
   signal decoded_ret         : boolean;
   signal decoded_beq         : boolean;
   signal decoded_halt        : boolean;
   signal decoded_wait        : boolean;
   signal decoded_dec         : boolean;
   signal decoded_ldc         : boolean;
   signal decoded_p16         : boolean;
   signal decoded_pp          : boolean;
   signal decoded_lp          : boolean;

],[dnl -- Body ----------------------------------------------------------------

  debug_led_out(7) <= wait_in;

  -- port async. assignments
  pc_out    <= pc;
  halted_out <= '1' when halt_flag else '0';

  -- push return address of pc+2 to avoid infinite loops and
  -- overlaps with the 2 branch delay slots
  sub_address_out <= (pc + 2);

  -- Asynchronous Decoding
  decoded_ldr   <= (opcode = PCP2_LDR_OPCODE);
  decoded_str   <= (opcode = PCP2_STR_OPCODE);
  decoded_btr   <= (opcode = PCP2_BTR_OPCODE);
  decoded_j     <= (opcode = PCP2_J_OPCODE);
  decoded_sub   <= (opcode = PCP2_SUB_OPCODE);
  decoded_ret   <= (opcode = PCP2_RET_OPCODE);
  decoded_beq   <= (opcode = PCP2_BEQ_OPCODE);
  decoded_halt  <= (opcode = PCP2_HALT_OPCODE);
  decoded_wait  <= (opcode = PCP2_WAIT_OPCODE);
  decoded_dec   <= (opcode = PCP2_DEC_OPCODE);
  decoded_ldc   <= (opcode = PCP2_LDC_OPCODE);
  decoded_p16   <= (opcode = PCP2_P16_OPCODE);
  decoded_pp    <= (opcode = PCP2_PP_OPCODE);
  decoded_lp    <= (opcode = PCP2_LP_OPCODE);

  -----------------------------------------------------------------------------
  -- Main Process (Instruction Fetching/Decoding and PC Updating)
  main_process : process(sclr, wb_clk_i, halt_flag, wait_in)

  begin
    if (rising_edge(wb_clk_i)) then
      if (sclr = '1') then
        halt_flag     <= false;
        pc            <= (others => '0');
      elsif ((timer_done) and (wait_in = '0')) then
        if (not halt_flag) then
          halt_flag <= decoded_halt;
        end if;
        if (pc_ret_flag) then
          pc <= unsigned(sub_address_in);
        elsif (pc_branch_flag) then
          -- branching is the only way out of a halt
          halt_flag <= false;
          pc <= pc_branch_addr;
        elsif (not halt_flag) then
          pc <= (pc + 1);
        end if;
      end if;
      -- Synced, because bdec requires a cycle for loop_reg_file memory to
      -- latch out is_zero_out
      pc_beq_flag <= decoded_beq and (r1_read_data_in = r2_read_data_in);
      pc_branch_addr <= unsigned(immediate_address);
      pc_ret_flag <= decoded_ret;
      pc_sub_flag <= decoded_sub;
      pc_jump_flag <= decoded_j;
      trigger_branch_flag <= decoded_btr and (triggers_in = trigger_source);
    end if;                                 -- sclr = '0'

  end process;

  -- Unsynced to clock edge because the branch flags should already be synced
  pc_branch_flag <= trigger_branch_flag or
                    pc_beq_flag or pc_sub_flag or pc_jump_flag;

  -- Subroutine async assignments.
  sub_stack_push_out <= '1' when (decoded_sub) else '0';
  sub_stack_pop_out  <= '1' when (decoded_ret) else '0';
  
  -- Register file async assignments
  r1_wren_out <= '1' when (decoded_ldc or decoded_ldr or decoded_dec) else '0';
  dec_value <= std_logic_vector(unsigned(r1_read_data_in) - 1);
  r1_write_data_out <= data_constant when (decoded_ldc) else
                       dec_value     when (decoded_dec) else
                       dmem_read_data_in;

  -- Data memory async assignments
  dmem_wren_out <= '1' when (decoded_str) else '0';
  dmem_write_data_out <= r2_read_data_in;

  -----------------------------------------------------------------------------
  -- Load Process for phase word and addend
  phase_process : process(sclr, wb_clk_i, wait_in)

  begin
    if (rising_edge(wb_clk_i)) then
      if (sclr = '1') then
        phase_reg_wren <= '0';
        phase_reg_current_out <= '0';
      elsif (wait_in = '0') then
        if (decoded_lp) then
          if (phase_addend_flag = '1') then
            case phase_sel32 is
              when '0' =>
                phase_reg_addend_out(15 downto 0) <= output_constant;
              when '1' =>
                phase_reg_addend_out(31 downto 16) <= output_constant;
              when others => null;
            end case;
          else
            case phase_sel32 is
              when '0' =>
                phase_reg_word_out(15 downto 0) <= output_constant;
              when '1' =>
                phase_reg_word_out(31 downto 16) <= output_constant;
              when others => null;
            end case;
          end if;
          -- Sync the wren and set_current to the same clock edge as above.
          phase_reg_wren        <= phase_wren_flag;
          phase_reg_current_out <= phase_current_flag;
          phase_reg_addr_out    <= reg_addr;
        else
          -- so that non-phase-pulse instructions don't keep writing
          phase_reg_wren <= '0';
          phase_reg_current_out <= '0';
        end if;
      end if;
    end if;

    phase_reg_wren_out <= phase_reg_wren;

  end process;

  -----------------------------------------------------------------------------
  -- Pulse Process (Opcodes: p16, pp)
  -- The only need for this process is to sync pulse writes to a clock edge.
  pulse_process : process(sclr, wb_clk_i, halt_flag, wait_in)

  begin

    if (rising_edge(wb_clk_i)) then

      if (sclr = '1') then
        pulse_out <= (others => '0');
      elsif (wait_in = '0') then
        if (decoded_p16) then
          case (sel16) is
            when B"00" =>
              pulse_out(15 downto 0) <= output_constant;
            when B"01" =>
              pulse_out(31 downto 16) <= output_constant;
            when B"10" =>
              pulse_out(47 downto 32) <= output_constant;
            when B"11" =>
              pulse_out(63 downto 48) <= output_constant;
            when others => null;
          end case;
        elsif (decoded_pp) then
          pulse_out(23 downto 16) <= lower_out_const;
          case (phase_sel32) is
            when '0' =>
              pulse_out(31 downto 24) <= phase_reg_adjust_in(7 downto 0);
            when '1' =>
              pulse_out(31 downto 24) <= B"00" &
                                         phase_reg_adjust_in(13 downto 8);
            when others => null;
          end case;
        end if;
      end if;
    end if;

  end process;
  
  -----------------------------------------------------------------------------
  -- Timer Process (Opcodes: wait)
  timer_process : process(sclr, wb_clk_i, halt_flag, timer_fired_in,
                          wait_in)

    type timer_state_type is (
      timer_idle_state,
      timer_wait_state,
      timer_out_state
      );

    variable state : timer_state_type;
  -----------------------------------------------------------------------------
  begin

    if (rising_edge(wb_clk_i)) then
      if (sclr = '1') then
        timer_load_out  <= '0';
        timer_clear_out <= '1';
        state := timer_idle_state;
      elsif (wait_in = '0') then
        case (state) is
          ---------------------------------------------------------------------
          when timer_idle_state =>
            if (decoded_wait) then
              -- overhead of 3 cycles, so it is minimum
              timer_count_out <= unsigned(timer_constant) - 2;
              timer_load_out  <= '1';
              timer_clear_out <= '0';
              state := timer_wait_state;
            end if;
          ---------------------------------------------------------------------
          when timer_wait_state =>
            timer_load_out <= '0';
            -- wait for fired_in to go low after loading
            if (timer_fired_in = '0') then
              state := timer_out_state;
            end if;
          ---------------------------------------------------------------------
          when timer_out_state =>
            if (timer_fired_in = '1') then
              timer_clear_out <= '1';
              state := timer_idle_state;
            end if;
          ---------------------------------------------------------------------
          when others =>
            null;
        end case;
      end if;
    end if;

    timer_done <= ((timer_fired_in = '1') and (state = timer_out_state)) or
                  (state = timer_idle_state);

  end process;
])
