divert(-1)dnl
# Macros for miscellaneous peripherals.
# ---------------------------------------------------------------------------
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
# ---------------------------------------------------------------------------

###############################################################################
# Power-on or user reset signals

define([reset_signals_], [dnl
  signal power_on_reset : std_logic;
  signal wb_rst_i       : std_logic;
])

###############################################################################
# Power-on or user reset instance

define([reset_instance_], [dnl
  power_on_reset_gen : pulse_generator
    port map (
      clock => network_clock,
      reset => '0',
      enable => '1',
      pulse_out => power_on_reset
      );

  -- User reset
  wb_rst_i <= power_on_reset or nswitch(0);
])

###############################################################################
# Boot LED signals
define([boot_led_signals_], [dnl
  signal boot_led_wb_cyc      : std_logic;
  signal boot_led_wb_stb      : std_logic;
  signal boot_led_wb_dat      : byte;
  signal boot_led_wb_ack      : std_logic;
  signal boot_led_status_load : std_logic;
])

###############################################################################
# Boot LED instance
define([boot_led_instance_], [dnl
  boot_led_display : boot_led
    port map (
      -- Wishbone common signals
      wb_clk_i            => i2c_clock,
      wb_rst_i            => power_on_reset,
      user_reset_in       => nswitch(0),
      time_interval       => BOOT_LED_INTERVAL,
      -- Outputs to I2C LED controllers
      wb_cyc_o            => boot_led_wb_cyc,
      wb_stb_o            => boot_led_wb_stb,
      wb_dat_o            => boot_led_wb_dat,
      wb_ack_i            => boot_led_wb_ack,
      -- inputs for debugging
      status_load         => dhcp_status_load,
      network_detected    => network_detected,
      dhcp_timed_out      => dhcp_timed_out,
      chain_terminator    => ptp_chain_terminator
      );
])

###############################################################################
# Clock divider instance
define([clock_divider_instance_], [dnl
  divider : clock_divider
    generic map (
      DIVIDER => 2
      )
    port map (
      areset => '0',
      inclk2 => clk2,
      pllena => '1',
      pfdena => '1',
      c2     => network_clock
      );
])

###############################################################################
# Clock buffer instance
define([clock_buffer_instance_], [dnl
  pcp_clock_buffer : clock_shifter
    port map (
      areset => power_on_reset,
      inclk0 => clk0,
      pllena => '1',
      pfdena => '1',
      c0     => pcp_clock
      );
])

###############################################################################
# All peripheral signals

define([peripheral_signals_], [dnl
reset_signals_
boot_led_signals_
boot_led_component_
signal sequencer_debug_led : byte;
signal debug_led_select    : byte;
signal nswitch             : byte;
pulse_generator_component_
])

###############################################################################
# All peripheral instances

define([peripheral_instances_], [dnl
reset_instance_
boot_led_instance_
clock_divider_instance_
clock_buffer_instance_
sequencer_debug_led(7) <= network_detected;
sequencer_debug_led(6) <= '1' when (ptp_chain_terminator) else '0';
sequencer_debug_led(5 downto 0) <= (others => '0');
    switch_gen: for i in 0 to 7 generate
      nswitch(i) <= not switch(i);
    end generate switch_gen;
])

# Renable output for processed file
divert(0)dnl
