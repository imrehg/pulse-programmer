dnl-*-VHDL-*-
-- Instruction decoder for the Pulse Control Processor One (pcp2) machine.
-------------------------------------------------------------------------------
-- pulse sequencer
-- Philipp Schindler
-- http://pulse-sequencer.sf.net
-------------------------------------------------------------------------------

unit_([pcp3_decoder], dnl
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
  hard_triggers_in       : in  pcp3_hard_trigger_type;
  firm_triggers_in       : in  pcp3_firm_trigger_type;
  pc_out                 : out pcp32_address_type;
  -- Timer ports for wait opcode
  timer_count_out        : out pcp3_timer_constant_type;
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
  r1_adr_out             : out pcp3_register_address_type;
  r1_wren_out            : out std_logic;
  r1_write_data_out      : out std_logic_vector(PCP3_DATA_WIDTH-1 downto 0); --pcp3_data_type;
  r1_read_data_in        : in  std_logic_vector(PCP3_DATA_WIDTH-1 downto 0); --pcp3_data_type;
  r2_adr_out             : out pcp3_register_address_type;
  r2_read_data_in        : in  std_logic_vector(PCP3_DATA_WIDTH-1 downto 0); --pcp3_data_type;

  -- Address stack ports for sub and ret opcodes
  sub_address_out        : out pcp32_address_type;
  sub_address_in         : in  pcp32_address_type;
  sub_stack_push_out     : out std_logic;
  sub_stack_pop_out      : out std_logic;
  -- Status and debugging outputs
  pulse_out              : buffer pcp_pulse_type;
  halted_out             : out std_logic;
  debug_led_out          : out byte;
  -- command ports for the arithmetic unit
  is_add                 : out std_logic;
  is_mult                : out std_logic;
  is_div                 : out std_logic;
  is_inc                 : out std_logic;
],[dnl -- Declarations --------------------------------------------------------
-------------------------------------------------------------------------------
-- The parts of the pulse out
-------------------------------------------------------------------------------
   alias ttl_out_low  is pulse_out(47 downto 32);
   alias ttl_out_high is pulse_out(59 downto 55);

   alias dac_data     is pulse_out(15 downto 2);
   alias dac_wrb      is pulse_out(1);

   alias dds_data     is pulse_out(31 downto 24);
   alias dds_addr     is pulse_out(23 downto 28);
   alias dds_psen     is pulse_out(16);
   alias dds_wrb_out  is pulse_out(17);
   alias dds_io_out   is pulse_out(48);
   alias dds_profile  is pulse_out(50 downto 49);

   alias dac_chain    is pulse_out(63 downto 60);
   alias dds_chain    is pulse_out(47 downto 32);
-------------------------------------------------------------------------------
-- The parts of the instruction word we gonna need:
-------------------------------------------------------------------------------

   alias opcode             is instruction_in(PCP32_INSTRUCTION_WIDTH-1 downto
                                              PCP32_INSTRUCTION_WIDTH-
                                              PCP3_OPCODE_WIDTH);
   alias reg_addr           is instruction_in(20+PCP3_REGISTER_ADDRESS_WIDTH-1
                                              downto 20);

   alias reg2_addr          is instruction_in(16+PCP3_REGISTER_ADDRESS_WIDTH-1
                                              downto 16);
   alias upper_ram_address  is instruction_in(24+PCP3_UPPER_RAM_ADDRESS_WIDTH-1
                                              downto 24);

   alias timer_constant     is instruction_in(PCP3_TIMER_WIDTH-1 downto 0);

   alias data_16            is instruction_in(PCP3_DATA_WIDTH-1
                                              downto 0);

   alias branch_eq          is instruction_in(26);

   alias sel16              is instruction_in(17 downto 16);

   alias trigger_source_hard is instruction_in(16+PCP3_HARD_TRIGGER_WIDTH-1
                                              downto 16);

   alias trigger_source_firm is instruction_in(16+PCP3_FIRM_TRIGGER_WIDTH+PCP3_HARD_TRIGGER_WIDTH-1
                                              downto 16+PCP3_HARD_TRIGGER_WIDTH);

   alias dac_wrb_in          is instruction_in(25);  -- set wrb bit of dac
   alias pulse_ttl_mode      is instruction_in(24);  -- if set or clear bits !!!

   alias dds_address_in      is instruction_in(16+DDS_ADDRESS_WIDTH-1
                                              downto 16);
   alias dds_wrb_in         is instruction_in(24);
   alias dds_update_in      is instruction_in(25);


 -- for the phase loader

   alias phase_wren_flag    is instruction_in(25);
   alias phase_current_flag is instruction_in(24);
   alias phase_sel32        is instruction_in(26);

-------------------------------------------------------------------------------
-- The flags and some additional stuff I'll remove
-------------------------------------------------------------------------------
   signal pc                  : pcp32_address_type;
   signal halt_flag           : boolean;
   signal timer_done          : boolean;

   -- some signals for comparing and branching
   signal eq_flag             : std_logic;
   signal gt_flag             : std_logic;

   -- Looping decrement signals
   signal pc_beq_flag         : boolean;
   signal pc_bgt_flag         : boolean;
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
-------------------------------------------------------------------------------
-- The Booleans we need to decode
-------------------------------------------------------------------------------

   -- Abbreviations for decoding opcodes
   signal decoded_nop         : boolean;
   signal decoded_halt        : boolean;
   signal decoded_wait        : boolean;
   signal decoded_btr         : boolean;
   signal decoded_j           : boolean;
   signal decoded_mv          : boolean;
   signal decoded_call        : boolean;
   signal decoded_ret         : boolean;
   signal decoded_cmp         : boolean;
   signal decoded_bf          : boolean;
   signal decoded_lcr         : boolean;
   signal decoded_scr         : boolean;
   signal decoded_ldr         : boolean;
   signal decoded_str         : boolean;
   signal decoded_rd          : boolean;
   signal decoded_wr          : boolean;
   signal decoded_add         : boolean;
   signal decoded_mul         : boolean;
   signal decoded_div         : boolean;
   signal decoded_pp          : boolean;
   signal decoded_lp          : boolean;
   signal decoded_pdac        : boolean;
   signal decoded_pdds        : boolean;
   signal decoded_pttlh       : boolean;
   signal decoded_pttll       : boolean;
   signal decoded_pchain      : boolean;
   signal decoded_inc         : boolean;
   signal decoded_ldc         : boolean;


],[dnl -- Body ----------------------------------------------------------------

  debug_led_out(7) <= wait_in;

  -- port async. assignments
  pc_out    <= pc;
  halted_out <= '1' when halt_flag else '0';

  -- push return address of pc+2 to avoid infinite loops and
  -- overlaps with the 2 branch delay slots
  sub_address_out <= (pc + 2);

  -- Asynchronous Decoding

  decoded_nop    <= (opcode = PCP3_NOP_OPCODE);
  decoded_halt   <= (opcode = PCP3_HALT_OPCODE);
  decoded_wait   <= (opcode = PCP3_WAIT_OPCODE);
  decoded_btr    <= (opcode = PCP3_BTR_OPCODE);
  decoded_j      <= (opcode = PCP3_J_OPCODE);
  decoded_mv     <= (opcode = PCP3_MV_OPCODE);
  decoded_call   <= (opcode = PCP3_CALL_OPCODE);
  decoded_ret    <= (opcode = PCP3_RET_OPCODE);
  decoded_cmp    <= (opcode = PCP3_CMP_OPCODE);
  decoded_bf     <= (opcode = PCP3_BF_OPCODE);
  decoded_lcr    <= (opcode = PCP3_LCR_OPCODE);
  decoded_scr    <= (opcode = PCP3_SCR_OPCODE);
  decoded_ldr    <= (opcode = PCP3_LDR_OPCODE);
  decoded_str    <= (opcode = PCP3_STR_OPCODE);
  decoded_rd     <= (opcode = PCP3_RD_OPCODE);
  decoded_wr     <= (opcode = PCP3_WR_OPCODE);
  decoded_add    <= (opcode = PCP3_ADD_OPCODE);
  decoded_mul    <= (opcode = PCP3_MUL_OPCODE);
  decoded_div    <= (opcode = PCP3_DIV_OPCODE);
  decoded_pp     <= (opcode = PCP3_PP_OPCODE);
  decoded_lp     <= (opcode = PCP3_LP_OPCODE);
  decoded_pdac   <= (opcode = PCP3_PDAC_OPCODE);
  decoded_pdds   <= (opcode = PCP3_PDDS_OPCODE);
  decoded_pttlh  <= (opcode = PCP3_PTTLH_OPCODE);
  decoded_pttll  <= (opcode = PCP3_PTTLL_OPCODE);
  decoded_pchain <= (opcode = PCP3_PCHAIN_OPCODE);
  decoded_inc    <= (opcode = PCP3_INC_OPCODE);
  decoded_ldc    <= (opcode = PCP3_LDC_OPCODE);

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
      pc_beq_flag <= decoded_bf and (eq_flag='1') and (branch_eq = '1');
      pc_bgt_flag <= decoded_bf and (gt_flag='1') and (not (branch_eq='1'));
      pc_branch_addr(15 downto 0) <= unsigned(data_16);  --changed to data_16 PHS
      pc_ret_flag <= decoded_ret;
      pc_sub_flag <= decoded_call;      --sub is now call
      pc_jump_flag <= decoded_j;
      trigger_branch_flag <= decoded_btr and ((hard_triggers_in = trigger_source_hard)
                                              or (firm_triggers_in = trigger_source_firm));
    end if;                                 -- sclr = '0'

  end process;

  -- Unsynced to clock edge because the branch flags should already be synced
  pc_branch_flag <= trigger_branch_flag or pc_bgt_flag or
                    pc_beq_flag or pc_jump_flag or pc_sub_flag;

  -- Subroutine async assignments.
  sub_stack_push_out <= '1' when (decoded_call) else '0';
  sub_stack_pop_out  <= '1' when (decoded_ret) else '0';


  -- arithmetic flag unsync assignment:
  -- The arithmetic unit should take care of being synced
  -- I don't know what's the best way to get the register addresses out ??
  is_add  <= '1' when (decoded_add) else '0';
  is_div  <= '1' when (decoded_div) else '0';
  is_mult <= '1' when (decoded_mul) else '0';
  is_inc  <= '1' when (decoded_inc) else '0';

  -- write the register address even if it's totally crap ??
  r1_adr_out <= reg_addr;
  r2_adr_out <= reg2_addr;

  -----------------------------------------------------------------------------
  -- Compare Process for 2 registers: sets the eq or gt flag
  -----------------------------------------------------------------------------
  compare_process : process(sclr, wb_clk_i, wait_in)

  begin
   if (rising_edge(wb_clk_i)) then
      if (sclr = '1') then
        eq_flag<='0';
        gt_flag<='0';
      elsif (wait_in = '0') then
        if (decoded_cmp) then
          if (r1_read_data_in = r2_read_data_in) then
			eq_flag<='1';
		  else
		    eq_flag<='0';
     	  end if;
          if (r1_read_data_in > r2_read_data_in) then
			gt_flag<='1';
		  else
		    gt_flag<='0';
		  end if;
        end if;
      end if;
   end if;
  end process;
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
            case phase_sel32 is
              when '0' =>
                phase_reg_word_out(15 downto 0) <= data_16;
              when '1' =>
                phase_reg_word_out(31 downto 16) <= data_16;
              when others => null;
	     end case;
--          end if;
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
        -- The dac pulse
        if (decoded_pdac) then
          dac_data <= data_16(DAC_WIDTH-1 downto 0);
          dac_wrb  <= dac_wrb_in;
        -- The TTL lower pulse
        elsif (decoded_pttll) then
            if (pulse_ttl_mode ='1') then
              ttl_out_low<=ttl_out_low or data_16;
            else
              ttl_out_low<=ttl_out_low and (not(data_16));
            end if;

        -- The TTL upper pulse
        elsif (decoded_pttlh) then
            if (pulse_ttl_mode ='1') then
              ttl_out_high<=ttl_out_high or data_16(UPPER_TTL_WIDTH-1 downto 0);
            else
              ttl_out_high<=ttl_out_high and (not(data_16(UPPER_TTL_WIDTH-1 downto 0)));
            end if;
        elsif (decoded_pdds) then
          dds_data    <= data_16(DDS_DATA_WIDTH-1 downto 0);
          dds_addr    <= dds_address_in;
          dds_io_out  <= dds_update_in;
          dds_wrb_out <= dds_wrb_in;

        elsif (decoded_pp) then
          dds_addr    <= data_16(DDS_ADDRESS_WIDTH-1 downto 0);
          dds_io_out  <= dds_update_in;
          dds_wrb_out <= dds_wrb_in;
          case (phase_sel32) is
            when '0' =>
              dds_data <= phase_reg_adjust_in(7 downto 0);
            when '1' =>
              dds_data(31 downto 24) <= B"00" &
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
