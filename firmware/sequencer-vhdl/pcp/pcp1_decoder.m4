dnl-*-VHDL-*-
-- Instruction decoder for the Pulse Control Processor One (pcp1) machine.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([pcp1_decoder], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
library pcplib;
use pcplib.instructions.all;
],[dnl -- Generics ------------------------------------------------------------
  OPCODE_WIDTH           : positive := 4;
  TRIGGER_WIDTH          : positive := 9;
  TIMER_WIDTH            : positive := 28;
  ADDRESS_WIDTH          : positive := 19;
  INSTRUCTION_WIDTH      : positive := 32;
  IMMEDIATE_WIDTH        : positive := 16;
  OUTPUT_WIDTH           : positive := 64;
  REG_ADDRESS_WIDTH      : positive := 5;
  LOOP_REG_DATA_WIDTH    : positive := 4;
  PHASE_WORD_WIDTH       : positive := 32;
  PHASE_ADDEND_WIDTH     : positive := 32;
  PHASE_ADJUST_WIDTH     : positive := 14;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
  sclr                   : in  std_logic;
  wait_in                : in  std_logic;
  instruction_in         : in  std_logic_vector(INSTRUCTION_WIDTH-1
                                                   downto 0);
  triggers_in            : in  std_logic_vector(TRIGGER_WIDTH-1 downto 0);
  pc_out                 : out unsigned(ADDRESS_WIDTH-1 downto 0);
  -- Register address for ldc, bdec opcodes
  reg_addr_out           : out std_logic_vector(REG_ADDRESS_WIDTH-1
                                                   downto 0);
  -- Timer ports for wait opcode
  timer_count_out        : out unsigned(TIMER_WIDTH-1 downto 0);
  timer_clear_out        : out std_logic;
  timer_load_out         : out std_logic;
  timer_fired_in         : in  std_logic;
  -- Phase register ports for lp and pp opcodes
  phase_reg_addr_out     : out std_logic_vector(REG_ADDRESS_WIDTH-1 downto 0);
  phase_reg_addend_out   : out std_logic_vector(PHASE_ADDEND_WIDTH-1 downto 0);
  phase_reg_word_out     : out std_logic_vector(PHASE_WORD_WIDTH-1 downto 0);
  phase_reg_adjust_in    : in  std_logic_vector(PHASE_ADJUST_WIDTH-1 downto 0);
  phase_reg_wren_out     : out std_logic;
  phase_reg_current_out  : out std_logic;
  -- Loop register ports for bdec and ldc opcodes
  loop_reg_data_out      : out std_logic_vector(LOOP_REG_DATA_WIDTH-1
                                                downto 0);
  loop_reg_wren_out      : out std_logic;
  loop_reg_decrement_out : out std_logic;
  loop_reg_is_zero_in    : in  std_logic;
  -- Address stack ports for sub and ret opcodes
  sub_address_out        : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  sub_address_in         : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  sub_stack_push_out     : out std_logic;
  sub_stack_pop_out      : out std_logic;
  -- Status and debugging outputs
  pulse_out              : out std_logic_vector(OUTPUT_WIDTH-1 downto 0);
  halted_out             : out std_logic;
  debug_led_out          : out byte;
],[dnl -- Declarations --------------------------------------------------------
   alias opcode                is instruction_in(INSTRUCTION_WIDTH-1 downto
                                                 INSTRUCTION_WIDTH-
                                                 OPCODE_WIDTH);
   alias reg_addr              is instruction_in(23+REG_ADDRESS_WIDTH-1
                                                 downto 23);
   alias immediate_address     is instruction_in(ADDRESS_WIDTH-1 downto 0);
   alias data_constant         is instruction_in(IMMEDIATE_WIDTH-1 downto 0);
   alias loop_reg_constant     is instruction_in(LOOP_REG_DATA_WIDTH-1
                                                 downto 0);
   alias sel16                 is instruction_in(17 downto 16);
   alias output_constant       is instruction_in(IMMEDIATE_WIDTH-1 downto 0);
   alias upper_output_constant is instruction_in(IMMEDIATE_WIDTH-1 downto 8);
   alias lower_output_constant is instruction_in(7 downto 0);
   alias timer_constant        is instruction_in(TIMER_WIDTH-1 downto 0);
   alias trigger_source        is instruction_in(19+TRIGGER_WIDTH-1 downto 19);

   alias phase_wren_flag       is instruction_in(22);
   alias phase_addend_flag     is instruction_in(21);
   alias phase_current_flag    is instruction_in(20);
   alias phase_sel32           is instruction_in(16);

   signal pc                  : unsigned(ADDRESS_WIDTH-1 downto 0);
   signal halt_flag           : boolean;
   signal timer_done          : boolean;

   -- Looping decrement signals
   signal pc_bdec_flag        : boolean;
   signal trigger_branch_flag : boolean;

   -- Branch flags
   signal pc_branch_flag      : boolean;
   signal pc_branch_addr      : unsigned(ADDRESS_WIDTH-1 downto 0);
   signal pc_ret_flag         : boolean;
   signal pc_sub_flag         : boolean;
   signal pc_jump_flag        : boolean;

   -- Phase reg file signals
   signal phase_reg_wren      : std_logic;

   -- Abbreviations for decoding opcodes
   signal decoded_p16         : boolean;
   signal decoded_btr         : boolean;
   signal decoded_j           : boolean;
   signal decoded_sub         : boolean;
   signal decoded_ret         : boolean;
   signal decoded_halt        : boolean;
   signal decoded_wait        : boolean;
   signal decoded_bdec        : boolean;
   signal decoded_ldc         : boolean;
   signal decoded_pp          : boolean;
   signal decoded_lp          : boolean;
],[dnl -- Body ----------------------------------------------------------------

  debug_led_out(7) <= wait_in;

  -- port async. assignments
  pc_out     <= pc;
  halted_out <= '1' when halt_flag else '0';

  -- push return address of pc+2 to avoid infinite loops and
  -- overlaps with the 2 branch delay slots
  sub_address_out <= std_logic_vector(pc + 2);

  reg_addr_out  <= reg_addr;

  -- Asynchronous Decoding
  decoded_p16   <= (opcode = PCP1_P16_OPCODE);
  decoded_btr   <= (opcode = PCP1_BTR_OPCODE);
  decoded_j     <= (opcode = PCP1_J_OPCODE);
  decoded_sub   <= (opcode = PCP1_SUB_OPCODE);
  decoded_ret   <= (opcode = PCP1_RET_OPCODE);
  decoded_halt  <= (opcode = PCP1_HALT_OPCODE);
  decoded_wait  <= (opcode = PCP1_WAIT_OPCODE);
  decoded_bdec  <= (opcode = PCP1_BDEC_OPCODE);
  decoded_ldc   <= (opcode = PCP1_LDC_OPCODE);
  decoded_pp    <= (opcode = PCP1_PP_OPCODE);
  decoded_lp    <= (opcode = PCP1_LP_OPCODE);

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
      pc_bdec_flag <= decoded_bdec;
      pc_branch_addr <= unsigned(immediate_address);
      pc_ret_flag <= decoded_ret;
      pc_sub_flag <= decoded_sub;
      pc_jump_flag <= decoded_j;
      trigger_branch_flag <= decoded_btr and (triggers_in = trigger_source);
      if (decoded_bdec) then
        loop_reg_decrement_out <= '1';
      else
        loop_reg_decrement_out <= '0';
      end if;
    end if;                                 -- sclr = '0'

  end process;

  -- Unsynced to clock edge because the branch flags should already be synced
  pc_branch_flag <= trigger_branch_flag or
                    (pc_bdec_flag and loop_reg_is_zero_in = '0') or
                    pc_sub_flag or pc_jump_flag;

  -- Subroutine async assignments.
  sub_stack_push_out <= '1' when (decoded_sub) else '0';
  sub_stack_pop_out  <= '1' when (decoded_ret) else '0';
  
  -- Loop decrementing async assigments
  loop_reg_wren_out <= '1' when (decoded_ldc) else '0';
  loop_reg_data_out <= loop_reg_constant;

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
                phase_reg_addend_out(15 downto 0) <= data_constant;
              when '1' =>
                phase_reg_addend_out(31 downto 16) <= data_constant;
              when others => null;
            end case;
          else
            case phase_sel32 is
              when '0' =>
                phase_reg_word_out(15 downto 0) <= data_constant;
              when '1' =>
                phase_reg_word_out(31 downto 16) <= data_constant;
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

    if (wb_rst_i = '1') then
      pulse_out <= (others => '0');
    elsif (rising_edge(wb_clk_i)) then

      if (wait_in = '0') then
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
          pulse_out(23 downto 16) <= lower_output_constant;
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
-------------------------------------------------------------------------------
  begin

    if (rising_edge(wb_clk_i)) then
      if (sclr = '1') then
        timer_load_out  <= '0';
        timer_clear_out <= '1';
        state := timer_idle_state;
      elsif (wait_in = '0') then
        case (state) is
-------------------------------------------------------------------------------
          when timer_idle_state =>
            if (decoded_wait) then
              -- overhead of 3 cycles, so it is minimum
              timer_count_out <= unsigned(timer_constant) - 2;
              timer_load_out  <= '1';
              timer_clear_out <= '0';
              state := timer_wait_state;
            end if;
-------------------------------------------------------------------------------
          when timer_wait_state =>
            timer_load_out <= '0';
            -- wait for fired_in to go low after loading
            if (timer_fired_in = '0') then
              state := timer_out_state;
            end if;
-------------------------------------------------------------------------------
          when timer_out_state =>
            if (timer_fired_in = '1') then
              timer_clear_out <= '1';
              state := timer_idle_state;
            end if;
-------------------------------------------------------------------------------
          when others =>
            null;
        end case;
      end if;
    end if;

    timer_done <= ((timer_fired_in = '1') and (state = timer_out_state)) or
                  (state = timer_idle_state);

  end process;
])
