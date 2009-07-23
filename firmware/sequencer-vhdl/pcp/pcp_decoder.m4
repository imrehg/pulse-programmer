dnl-*-VHDL-*-
-- Pulse Control Processor instruction decoder.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([pcp_decoder], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
library pcplib;
use pcplib.instructions.all;
],[dnl -- Generics ------------------------------------------------------------
  TRIGGER_COUNT          : positive := 9;
  TIMER_WIDTH            : positive := 40;
  ADDRESS_WIDTH          : positive := 10;
  DATA_WIDTH             : positive := 64;
  REGISTER_ADDRESS_WIDTH : positive := 5;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   sclr                    : in     std_logic;
   instruction_in          : in     std_logic_vector(63 downto 0);
   triggers_in             : in     std_logic_vector(TRIGGER_COUNT-1 downto 0);
   pc_out                  : out    unsigned(ADDRESS_WIDTH-1 downto 0);
   timer_count_out         : out    unsigned(TIMER_WIDTH-1 downto 0);
   timer_clear_out         : out    std_logic;
   timer_load_out          : buffer std_logic;
   timer_fired_in          : in     std_logic;
   ram_adr_o               : out    std_logic_vector(ADDRESS_WIDTH-1 downto 0);
   ram_dat_i               : in     std_logic_vector(DATA_WIDTH-1 downto 0);
   rd_adr_o                : out    std_logic_vector(REGISTER_ADDRESS_WIDTH-1
                                                     downto 0);
   rd_we_o                 : buffer std_logic;
   rd_dat_o                : out    std_logic_vector(DATA_WIDTH-1 downto 0);
   rs1_adr_o               : out    std_logic_vector(REGISTER_ADDRESS_WIDTH-1
                                                     downto 0);
   rs1_dat_i               : in     std_logic_vector(DATA_WIDTH-1 downto 0);
   rs2_adr_o               : out    std_logic_vector(REGISTER_ADDRESS_WIDTH-1
                                                     downto 0);
   rs2_dat_i               : in     std_logic_vector(DATA_WIDTH-1 downto 0);
   pulse_out               : out    std_logic_vector(DATA_WIDTH-1 downto 0);
   halted_out              : out    std_logic;
   debug_led_out           : out    byte;
],[dnl -- Declarations --------------------------------------------------------
   alias opcode               is instruction_in(63 downto 58);
   alias immediate_flag       is instruction_in(57);
   alias unsigned_flag        is instruction_in(56);
   alias rd_adr               is instruction_in(51+REGISTER_ADDRESS_WIDTH-1
                                                downto 51);
   alias rs1_adr              is instruction_in(46+REGISTER_ADDRESS_WIDTH-1
                                                downto 46);
   alias rs2_adr              is instruction_in(41+REGISTER_ADDRESS_WIDTH-1
                                                downto 41);
   alias immediate_address    is instruction_in(ADDRESS_WIDTH-1 downto 0);
   alias sel32                is instruction_in(32);
   alias output_constant      is instruction_in(31 downto 0);
   alias short_delay_constant is instruction_in(55 downto 33);
   alias long_delay_constant  is instruction_in(PCP_TIMER_LONG_CONSTANT_WIDTH-1
                                                downto 0);
   alias trigger_source       is instruction_in(40 downto 32);

   signal pc                  : unsigned(ADDRESS_WIDTH-1 downto 0);
   signal pulse_pc_stall      : boolean;
   signal trigger_equal_flag  : boolean;
   signal pc_branch_flag      : boolean;
   signal pc_branch_addr      : unsigned(ADDRESS_WIDTH-1 downto 0);
   signal halt_flag           : boolean;
   signal timer_done          : boolean;
   signal pulse_decoded       : boolean;
   signal decoded_ld64i       : boolean;
   signal decoded_p           : boolean;
   signal decoded_pr          : boolean;
   signal decoded_j           : boolean;
   signal decoded_halt        : boolean;
   signal decoded_btr         : boolean;
   signal pulse_wait          : boolean;
   signal pulse_one_off       : boolean;
   signal pulse_two_off       : boolean;
   signal pulse_one_decoded   : boolean;
   signal pulse_two_decoded   : boolean;
   signal pulse_short_decoded : boolean;
   signal pulse_long_active   : boolean;
   signal pulse_one_zero      : boolean;
   signal short_delay_reg     : unsigned(PCP_TIMER_SHORT_CONSTANT_WIDTH-1
                                         downto 0);
   signal pulse_halt_flag     : boolean;
],[dnl -- Body ----------------------------------------------------------------

  -- port async. assignments
  ram_adr_o <= immediate_address;
  rd_dat_o  <= ram_dat_i;
  rs1_adr_o <= rs1_adr;
  rs2_adr_o <= rs2_adr;
  pc_out <= pc;
  halted_out <= '1' when halt_flag else '0';

  pulse_decoded <= decoded_p or decoded_pr;

  trigger_equal_flag <=
    ((triggers_in and trigger_source) /= PCP_NULL_TRIGGER) and decoded_btr;

  -- Asynchronous Decoding
  decoded_ld64i <= (opcode = PCP_LD64I_OPCODE);
  decoded_p     <= (opcode = PCP_P_OPCODE);
  decoded_pr    <= (opcode = PCP_PR_OPCODE);
  decoded_btr   <= (opcode = PCP_BTR_OPCODE);
  decoded_j     <= (opcode = PCP_J_OPCODE);
  decoded_halt  <= (opcode = PCP_HALT_OPCODE);

  -----------------------------------------------------------------------------
  -- Main Process (Instruction Fetching/Decoding and PC Updating)
  main_process : process(wb_rst_i, sclr, wb_clk_i, halt_flag)

    type state_type is (
      fetching,
      decoding
      );

    variable state : state_type;
    variable pc_continue : boolean;
    variable pc_branch_async : boolean;

  begin
--     if (wb_rst_i = '1') then
--       state         := fetching;
--       halt_flag     <= false;
--       pc            <= (others => '0');
    if (rising_edge(wb_clk_i)) then
      if (sclr = '1') then
        state         := fetching;
        halt_flag     <= false;
        pc            <= (others => '0');
      elsif (not halt_flag) then

        case (state) is
-------------------------------------------------------------------------------
          when fetching =>
            halt_flag <= decoded_halt;
            if (not pulse_pc_stall) then
              if (pc_branch_flag) then
                pc <= pc_branch_addr;
              elsif (pc_continue or timer_done) then
                pc <= (pc + 1);
              end if;
              state := decoding;
            end if;
-------------------------------------------------------------------------------
          when decoding =>
            state := fetching;
-------------------------------------------------------------------------------
          when others => null;
        end case;

      end if;                                 -- sclr = '0'

      if (not pulse_pc_stall) then
        pc_branch_flag <= decoded_j or trigger_equal_flag;
        pc_branch_addr <= unsigned(immediate_address);
      end if;
    end if;                             -- rising_edge(wb_clk_i)

    pc_continue := true;

  end process;

  -----------------------------------------------------------------------------
  -- Load Process
  load_process : process(wb_rst_i, sclr, wb_clk_i)

  begin
--     if (wb_rst_i = '1') then
--       rd_we_o <= '0';
    if (rising_edge(wb_clk_i)) then
      if (sclr = '1') then
        rd_we_o <= '0';
      else
        if (decoded_ld64i and (rd_we_o = '0')) then
          rd_adr_o  <= rd_adr;
          rd_we_o <= '1';
        else
          rd_we_o <= '0';
        end if;
      end if;
    end if;

  end process;

  -----------------------------------------------------------------------------
  -- Pulse Process
  pulse_process : process(wb_rst_i, sclr, wb_clk_i, halt_flag)

    type pulse_state_type is (
      pulse_idle_state,
      pulse_p_load_state,
      pulse_pr_load_state,
      pulse_stall_state,
      pulse_out_state,
      pulse_halt_state
      );

    variable pulse_state : pulse_state_type;
    variable pulse_timer_reg : unsigned(TIMER_WIDTH-1 downto 0);
    variable pulse_short_flag  : boolean;
    variable pulse_one_high : boolean;
-------------------------------------------------------------------------------
    procedure pulse_pr_out is

    begin
      -- subtract 2 b/c of additional register load delay
      timer_clear_out <= '0';
      timer_count_out <= pulse_timer_reg - 2;
      pulse_long_active <= true;
      timer_load_out <= '1';
    end procedure;
-------------------------------------------------------------------------------
-- Decide how to load timer and which state to go to based on pulse type
    procedure pulse_decode is

    begin
      if (halt_flag) then
        pulse_halt_flag <= true;
      end if;
      if (decoded_p) then
        -- Decide how to load the timer.
        if (pulse_short_flag) then
          if (pulse_one_off) then
            pulse_one_high := not pulse_one_high;
            pulse_one_zero <= not pulse_one_zero;
          end if;
          timer_load_out <= '0';
          pulse_long_active <= false;
          -- don't stall if delaying for 1 (special case)
          timer_clear_out <= '1';
        else
          pulse_long_active <= true;
        end if;
      elsif (decoded_pr) then
        if (pulse_long_active) then
          -- Load timer
          pulse_pr_out;
          pulse_out   <= rs2_dat_i;
          pulse_state := pulse_stall_state;
        else
--         if (pulse_state = pulse_idle_state) then
          -- if the previous insn wasn't a pulse, stall for loading registers
          pulse_long_active <= true;
          pulse_state := pulse_pr_load_state;
        end if;
      else
        pulse_long_active <= false;
        timer_clear_out <= '1';
        -- I comment this out b/c it took up more than 100 gates
        -- and I am short on space for the final build.
        -- Just make sure you end all pulses with a zero pulse and you'll
        -- be fine.
--        pulse_out       <= (others => '0');     -- safety first kids
        pulse_state := pulse_idle_state;
      end if;
    end procedure;
-------------------------------------------------------------------------------
  begin
--     if (wb_rst_i = '1') then
--       pulse_long_active <= false;
--       pulse_halt_flag <= false;
--       pulse_one_zero <= false;
--       pulse_one_high := false;
--       timer_load_out  <= '0';
--       timer_clear_out <= '1';
--       pulse_state := pulse_idle_state;
    if (rising_edge(wb_clk_i)) then
      if (sclr = '1') then
        pulse_long_active <= false;
        pulse_halt_flag <= false;
        pulse_one_zero <= false;
        pulse_one_high := false;
        timer_load_out  <= '0';
        timer_clear_out <= '1';
        pulse_out       <= (others => '0');     -- safety first kids
        pulse_state := pulse_idle_state;
      else

        case (pulse_state) is
-------------------------------------------------------------------------------
          when pulse_idle_state =>
            pulse_decode;
            -- Decide how to pulse.
            if (pulse_halt_flag) then
              pulse_state := pulse_halt_state;
            elsif (decoded_p) then
              -- Decide which state to go to next
              if (pulse_short_flag) then
                pulse_state := pulse_out_state;
              else
                pulse_state := pulse_p_load_state;
              end if;
            end if;
-------------------------------------------------------------------------------
          when pulse_p_load_state =>
            timer_count_out(PCP_TIMER_SHORT_CONSTANT_WIDTH-1 downto 0) <=
              short_delay_reg;
            timer_count_out(TIMER_WIDTH-1 downto
                            PCP_TIMER_SHORT_CONSTANT_WIDTH) <=
              (others => '0');
            timer_load_out  <= '1';
            timer_clear_out <= '0';
            pulse_state := pulse_stall_state;
-------------------------------------------------------------------------------
          when pulse_pr_load_state =>
            -- wait for loading register before pulsing out
            pulse_pr_out;
            pulse_out   <= rs2_dat_i;
            pulse_state := pulse_stall_state;
-------------------------------------------------------------------------------
          when pulse_stall_state =>
            timer_load_out <= '0';
            -- wait for fired_in to go low after loading
            pulse_state := pulse_out_state;
-------------------------------------------------------------------------------
          when pulse_out_state =>
            if (timer_fired_in = '1') then
              pulse_decode;
              if (decoded_p) then
                if (pulse_short_flag) then
                  if (pulse_two_off or (not pulse_one_zero)) then
                    pulse_state := pulse_idle_state;
                  end if;
                else
                  pulse_state := pulse_p_load_state;
                end if;
              end if;
            end if;
-------------------------------------------------------------------------------
          when others =>
            -- pulse_halt_state
            null;
        end case;

        -- Load pulse_out for decoded_p here, otherwise we consume too many
        -- gates repeating it in the cases above
        if (pulse_one_zero) then
          pulse_out <= (others => '0');
        elsif (decoded_p and (timer_done or pulse_one_high or 
                              (pulse_state = pulse_p_load_state))) then
          if (sel32 = '1') then
            pulse_out(63 downto 32) <= output_constant;
          else
            pulse_out(31 downto 0) <= output_constant;
          end if;
        end if;
        
      end if;                           -- sclr = '0'

      short_delay_reg <= unsigned(short_delay_constant) - 3;
      
    end if;                             -- rising_edge(wb_clk_i)

    pulse_one_off <= (unsigned_flag = '1');
    pulse_one_decoded <= pulse_one_off and pulse_decoded;

    pulse_two_off <= (immediate_flag = '1');
    pulse_two_decoded <= pulse_two_off and pulse_decoded;
    
    pulse_pc_stall <= (pulse_long_active and pulse_decoded and
                       (not timer_done));
    pulse_short_flag := (pulse_one_off or pulse_two_off);
    pulse_short_decoded <= pulse_short_flag and pulse_decoded;

    pulse_timer_reg := unsigned(rs1_dat_i(TIMER_WIDTH-1 downto 0));
    timer_done <= (((timer_fired_in = '1') and
                    (timer_load_out = '0') and
                    (pulse_state = pulse_out_state)));

  end process;
])
