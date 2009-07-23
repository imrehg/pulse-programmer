dnl--*-VHDL-*-
-- Bootstrap LED display for user feedback.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([boot_led],
  [dnl -- Libraries
sequencer_libraries_
],[dnl -- Generics
],[dnl -- Ports
wb_common_port_
    user_reset_in        : in  std_logic;
    time_interval       : in  positive;
    -- Outputs to I2C LED controllers
    wb_cyc_o            : out std_logic;
    wb_stb_o            : out std_logic;
    wb_dat_o            : out byte;
    wb_ack_i            : in  std_logic;
    -- inputs for debugging
    status_load         : in  std_logic;
    network_detected    : in  std_logic;
    chain_terminator    : in  boolean;
    dhcp_timed_out      : in  std_logic;
],[dnl -- Declarations
  
  signal interval_counter : natural range 0 to BOOT_LED_INTERVAL;
  signal bit_counter      : natural range 0 to 8;
  signal display_reg : byte;

],[dnl -- Body

   wb_dat_o <= display_reg;
      
  process(wb_rst_i, status_load, network_detected, dhcp_timed_out,
          wb_clk_i)

    type boot_state_type is (
      reset_state,
      interval,
      interval_ack,
      interval_ack_fall,
      display_status,
      display_status_ack,
      display_status_ack_fall
      );

    variable state         : boot_state_type;

  begin

    if (wb_rst_i = '1') then
      wb_cyc_o         <= '0';
      wb_stb_o         <= '0';
      state            := reset_state;

    elsif (rising_edge(wb_clk_i)) then
      case (state) is
        when reset_state =>
          -- give visual feedback that user has asserted reset
          display_reg      <= X"01";
          interval_counter <= 0;
          bit_counter      <= 0;
          state := interval;
-------------------------------------------------------------------------------
        when interval =>
          if (interval_counter >= time_interval-2) then
            interval_counter <= 0;
            wb_cyc_o         <= '1';
            wb_stb_o         <= '1';
            state            := interval_ack;
          elsif (user_reset_in = '1') then
            state := reset_state;
          else
            interval_counter <= interval_counter + 1;
          end if;
-------------------------------------------------------------------------------
        when interval_ack =>
          if (wb_ack_i = '1') then
            wb_stb_o <= '0';
            state    := interval_ack_fall;
          end if;
-------------------------------------------------------------------------------
        when interval_ack_fall =>
          if (wb_ack_i = '0') then
            wb_cyc_o      <= '0';
            if (bit_counter >= 7) then
              bit_counter <= 0;
              display_reg <= X"01";
              state       := display_status;
            elsif (user_reset_in = '1') then
              state := reset_state;
            else
              bit_counter <= bit_counter + 1;
              display_reg <= display_reg(6 downto 0) & '0'; -- leftshift one
              state       := interval;
            end if;
          end if;
-------------------------------------------------------------------------------
        when display_status =>
          if (status_load = '1') then
            wb_cyc_o                <= '1';
            wb_stb_o                <= '1';
            display_reg(7 downto 3) <= (3 => '1', others => '0');
            if (chain_terminator) then
              display_reg(2)          <= '1';
            else
              display_reg(2)          <= '0';
            end if;
            display_reg(1)          <= dhcp_timed_out;
            display_reg(0)          <= network_detected;
            state                   := display_status_ack;
          else
            state                   := interval;
          end if;
-------------------------------------------------------------------------------
        when display_status_ack =>
          if (wb_ack_i = '1') then
            wb_stb_o <= '0';
            state    := display_status_ack_fall;
          end if;
-------------------------------------------------------------------------------
        when display_status_ack_fall =>
          -- Get stuck here at the end.
           if (wb_ack_i = '0') then
             wb_cyc_o <= '0';
           end if;
           if (user_reset_in = '1') then
             state := reset_state;
           end if;
-------------------------------------------------------------------------------
         when others =>
          state := reset_state;
        end case;
    end if;
  end process;
])
