dnl-*-VHDL-*-
-- PCP Controller
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------
unit_([pcp_controller], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
library pcplib;
use pcplib.instructions.all;
],[dnl -- Generics ------------------------------------------------------------
  DATA_WIDTH             : positive := 64;
  ADDRESS_WIDTH          : positive := 11;
  TRIGGER_COUNT          : positive := 9;
  TIMER_WIDTH            : positive := 40;
  REGISTER_ADDRESS_WIDTH : positive := 3;  -- 8 registers
  FIFO_COUNT_WIDTH       : positive := 3;  -- 8 words deep
  STABLE_COUNT           : positive := 2;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   core_reset             : in  std_logic;
   triggers_in            : in  trigger_source_type;
   pulse_out              : out std_logic_vector(DATA_WIDTH-1 downto 0);
   halted_out             : out std_logic;
   -- Debugging outputs
   rdusedw_out            : out std_logic_vector(FIFO_COUNT_WIDTH-1 downto 0);
   debug_led_out          : out byte;
   -- Write port to memory
   wb_write_clk_i         : in  std_logic;
   wb_write_cyc_i         : in  std_logic;
   wb_write_stb_i         : in  std_logic;
   wb_write_dat_i         : in  std_logic_vector(DATA_WIDTH-1 downto 0);
   wb_write_ack_o         : out std_logic;
   write_busy_out         : out std_logic;
],[dnl -- Declarations --------------------------------------------------------
  -- Core signals
  signal wb_read_clk    : std_logic;
  signal instruction    : pcp_instruction_type;
  signal pc             : unsigned(ADDRESS_WIDTH-1 downto 0);
  signal internal_reset : std_logic;
  signal delay_reset    : std_logic;
  signal ram_adr        : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal ram_dat        : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal wb_read_cyc    : std_logic;
  signal wb_read_stb    : std_logic;
  signal wb_read_dat    : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal wb_read_ack    : std_logic;
  -- Memory signals
  signal mem_cyc        : std_logic;
  signal mem_stb        : std_logic;
  signal mem_we         : std_logic;
  signal mem_addr_in    : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal mem_dat_i      : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal mem_dat_o      : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal mem_ack        : std_logic;
  signal mem_burst      : std_logic;
  signal core_debug_led : byte;
  signal write_counter : natural range 0 to STABLE_COUNT+1;
  signal reset_counter : natural range 0 to STABLE_COUNT+1;
pcp_core_component_
],[dnl -- Body ----------------------------------------------------------------

   core : pcp_core
    generic map (
      DATA_WIDTH             => DATA_WIDTH,
      ADDRESS_WIDTH          => ADDRESS_WIDTH,
      TRIGGER_COUNT          => TRIGGER_COUNT,
      TIMER_WIDTH            => TIMER_WIDTH,
      REGISTER_ADDRESS_WIDTH => REGISTER_ADDRESS_WIDTH,
      REGISTER_COUNT         => 2**REGISTER_ADDRESS_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i               => wb_read_clk,
      wb_rst_i               => wb_rst_i,
      sclr                   => internal_reset,
      instruction_in         => instruction,
      triggers_in            => triggers_in,
      pc_out                 => pc,
      ram_adr_o              => ram_adr,
      ram_dat_i              => ram_dat,
      pulse_out              => pulse_out,
      halted_out             => halted_out,
      debug_led_out          => core_debug_led
      );

  interclock : async_fifo
    generic map (
      DATA_WIDTH            => DATA_WIDTH,
      WORD_COUNT_WIDTH      => FIFO_COUNT_WIDTH
      )
    port map (
      wb_rst_i              => wb_rst_i,
      wb_read_clk_i         => wb_read_clk,
      wb_read_cyc_o         => wb_read_cyc,
      wb_read_stb_o         => wb_read_stb,
      wb_read_dat_o         => wb_read_dat,
      wb_read_ack_i         => wb_read_ack,
      wb_write_clk_i        => wb_write_clk_i,
      wb_write_cyc_i        => wb_write_cyc_i,
      wb_write_stb_i        => wb_write_stb_i,
      wb_write_dat_i        => wb_write_dat_i,
      wb_write_ack_o        => wb_write_ack_o,
      rdusedw_out           => rdusedw_out
      );

  wb_read_clk <= wb_clk_i;

  -- Arbiter between program writing and reading
  process(wb_read_clk, wb_rst_i)

    type state_type is (
      idle,
      writing,
      reading
      );

    variable state : state_type;

  begin
    if (wb_rst_i = '1') then
      delay_reset    <= '0';
      internal_reset <= '1';
      write_busy_out <= '0';
      write_counter <= 0;
      reset_counter <= 0;
      state := idle;
    elsif (rising_edge(wb_read_clk)) then
      case (state) is
-------------------------------------------------------------------------------
        when idle =>
          if (write_counter >= STABLE_COUNT) then
            write_busy_out <= '1';
            -- a program is being written to our local memory
            write_counter <= 0;
            state := writing;
          elsif (reset_counter >= STABLE_COUNT) then
            -- stall one state before releasing internal reset so that
            -- pcp_decoder can latch onto address 0
            reset_counter <= 0;
            state := reading;
          elsif (wb_write_cyc_i = '1') then
            write_counter <= write_counter + 1;
          elsif (core_reset = '0') then
            reset_counter <= reset_counter + 1;  
          end if;
-------------------------------------------------------------------------------
        when writing =>
          if (write_counter >= STABLE_COUNT) then
            write_counter <= 0;
            -- only return to idle if we are done writing the program
            write_busy_out <= '0';
            state := idle;
          elsif ((wb_write_cyc_i = '0') and
                 (wb_read_cyc = '0') and (wb_read_stb = '0')) then
            write_counter <= write_counter + 1;
          end if;
-------------------------------------------------------------------------------
        when reading =>
          if (reset_counter >= STABLE_COUNT) then
            -- core is being reset; return to idle
            internal_reset <= '1';
            reset_counter <= 0;
            state := idle;
          else
            -- program is being executed
            internal_reset <= '0';
            if (core_reset = '1') then
              reset_counter <= reset_counter + 1;
            end if;
          end if;
-------------------------------------------------------------------------------
        when others =>
          state := idle;
      end case;

      delay_reset <= internal_reset;
    end if;                             -- rising_edge(wb_read_clk_i)

    -- asynchronous assignments
    if ((state = writing) or (state = reading)) then
      mem_cyc <= '1';
    else
      mem_cyc <= '0';
    end if;

    if (state = writing) then
      mem_stb     <= wb_read_stb;
      mem_we      <= '1';
      wb_read_ack <= mem_ack;
      mem_burst   <= '1';               -- b/c FIFO needs linear address burst
    else
      mem_stb     <= '1';
      mem_we      <= '0';
      wb_read_ack <= wb_read_stb;
      mem_burst   <= '0';
    end if;

    if (state = reading) then
      mem_addr_in <= std_logic_vector(pc);
    else
      mem_addr_in <= (others => '0');
    end if;

  end process;

  mem_dat_i   <= wb_read_dat;
  instruction <= mem_dat_o when (delay_reset = '0') else (others => '0');
    
  debug_led_out <= core_debug_led;
  
  pcp_memory : memory_dual_controller
    generic map (
      DATA_WIDTH        => DATA_WIDTH,
      ADDRESS_WIDTH     => ADDRESS_WIDTH,
      WORD_COUNT        => 2**ADDRESS_WIDTH
      )
    port map (
      wb_clk_i          => wb_read_clk,
      -- First port
      wb1_cyc_i         => mem_cyc,
      wb1_stb_i         => mem_stb,
      wb1_we_i          => mem_we,
      wb1_adr_i         => mem_addr_in,
      wb1_dat_i         => mem_dat_i,
      wb1_dat_o         => mem_dat_o,
      wb1_ack_o         => mem_ack,
      burst1_in         => mem_burst,
      -- Second port
      wb2_cyc_i         => mem_cyc,
      wb2_stb_i         => '1',
      wb2_adr_i         => ram_adr,
      wb2_dat_o         => ram_dat,
      burst2_in         => '0'
      );

-------------------------------------------------------------------------------
])
