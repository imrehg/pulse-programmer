dnl-*-VHDL-*-
-- Controller for pcp2
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------
unit_([pcp2_controller], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
library pcplib;
use pcplib.instructions.all;
],[dnl -- Generics ------------------------------------------------------------
  STABLE_COUNT : positive := 2;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   core_reset    : in  std_logic;
   triggers_in   : in  trigger_source_type;
   pulse_out     : out pcp_pulse_type;
   halted_out    : out std_logic;
   -- Debugging outputs
   debug_led_out : out byte;
   -- Read port to memory
   wb_cyc_o      : out std_logic;
   wb_stb_o      : out std_logic;
   wb_adr_o      : out pcp32_address_type;
   wb_dat_i      : in  pcp32_instruction_type;
   wb_ack_i      : in  std_logic;
   -- Port to data memory
   wb_ptp_clk_i  : in  std_logic;
   wb_ptp_cyc_i  : in  std_logic;
   wb_ptp_stb_i  : in  std_logic;
   wb_ptp_we_i   : in  std_logic;
   wb_ptp_adr_i  : in  pcp2_data_address_type;
   wb_ptp_dat_i  : in  pcp32a_data_type;
   wb_ptp_dat_o  : out pcp32a_data_type;
],[dnl -- Declarations --------------------------------------------------------
pcp2_core_component_
  signal instruction    : pcp32_instruction_type;
  signal pc             : unsigned(PCP32_ADDRESS_WIDTH-1 downto 0);
  signal halted         : std_logic;
  signal internal_reset : std_logic;
  signal internal_wait  : std_logic;
  signal stable_counter : natural range 0 to STABLE_COUNT+1;
],[dnl -- Body ----------------------------------------------------------------

  halted_out <= halted;

  pcp2 : pcp2_core
    port map (
      -- Wishbone common signals
      wb_clk_i            => wb_clk_i,
      wb_rst_i            => wb_rst_i,
      sclr                => internal_reset,
      wait_in             => internal_wait,
      instruction_in      => instruction,
      triggers_in         => triggers_in,
      pc_out              => pc,
      halted_out          => halted,
      pulse_out           => pulse_out,
      wb_ptp_clk_i        => wb_ptp_clk_i,
      wb_ptp_cyc_i        => wb_ptp_cyc_i,
      wb_ptp_stb_i        => wb_ptp_stb_i,
      wb_ptp_we_i         => wb_ptp_we_i,
      wb_ptp_adr_i        => wb_ptp_adr_i,
      wb_ptp_dat_i        => wb_ptp_dat_i,
      wb_ptp_dat_o        => wb_ptp_dat_o,
      debug_led_out       => debug_led_out
      );

  instruction <= wb_dat_i;

  -- Process to synchronize core_reset (which is generated on a different
  -- clock) to our own wb_clk_i.
  process(wb_rst_i, wb_clk_i)

    type state_type is (
      idle,
      active
      );

    variable state : state_type;

  begin
    if (wb_rst_i = '1') then
      state := idle;
      internal_reset <= '1';
      stable_counter <= 0;
    elsif (rising_edge(wb_clk_i)) then

      internal_wait <= not wb_ack_i;
      
      case (state) is
        -----------------------------------------------------------------------
        when idle =>
          if (stable_counter > STABLE_COUNT) then
            state := active;
            stable_counter <= 0;
            internal_reset <= '0';
          elsif (core_reset = '0') then
            stable_counter <= stable_counter + 1;
          end if;
        -----------------------------------------------------------------------
        when active =>
          if (stable_counter > STABLE_COUNT) then
            state := idle;
            stable_counter <= 0;
            internal_reset <= '1';
          elsif (core_reset = '1') then
            stable_counter <= stable_counter + 1;
          end if;
        -----------------------------------------------------------------------
      end case;
    end if;

  end process;

  wb_adr_o <= std_logic_vector(pc);
  wb_cyc_o <= (not internal_reset);
  wb_stb_o <= (not internal_reset);

-------------------------------------------------------------------------------
])
