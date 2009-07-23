dnl--*-VHDL-*-
-- Test of I2C LED controller with arbiter.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([i2c_led_test],
  [dnl -- Libraries
sequencer_libraries_
],[dnl -- Generics
],[dnl -- Ports
wb_common_port_
    -- Wishbone slave inputs from LED master (top-level PTP)
    debug_led_wb_cyc     : in  std_logic;
    debug_led_wb_stb      : in  std_logic;
    debug_led_wb_dat      : in  byte;          -- the LED selector
    debug_led_wb_ack      : out std_logic;
    wbm_cyc_o      : out std_logic;
    wbm_stb_o      : out std_logic;
    wbm_we_o       : out std_logic;
    wbm_adr_o      : out i2c_slave_address_type;
    wbm_dat_o      : out byte;
    wbm_ack_i      : in  std_logic;
],[dnl -- Declarations
  signal boot_led_wb_cyc : std_logic;
  signal boot_led_wb_stb : std_logic;
  signal boot_led_wb_dat : byte;          -- the LED selector
  signal boot_led_wb_ack : std_logic;
  signal i2c_led_wbs_stb : std_logic;
  signal i2c_led_wbs_dat : byte;
  signal i2c_led_wbs_ack : std_logic;
  signal i2c_led_decode  : std_logic;
  -- I2C LED Controller Arbiter Signals
  constant I2C_LED_MASTER_COUNT : positive := 2;
  signal i2c_led_arbiter_gnt    : multibus_bit(0 to I2C_LED_MASTER_COUNT-1);
  signal i2c_led_arbiter_ack    : multibus_bit(0 to I2C_LED_MASTER_COUNT-1);
boot_led_component_
i2c_led_controller_component_
],[dnl -- Body

  boot_led_display : boot_led
    port map (
      -- Wishbone common signals
      wb_clk_i            => wb_clk_i,
      wb_rst_i            => wb_rst_i,
      user_reset_in       => '0',
      -- Outputs to I2C LED controllers
      wb_cyc_o            => boot_led_wb_cyc,
      wb_stb_o            => boot_led_wb_stb,
      wb_dat_o            => boot_led_wb_dat,
      wb_ack_i            => boot_led_wb_ack,
      -- inputs for debugging
      status_load         => '1',
      network_detected    => '1',
      dhcp_timed_out      => '0',
      chain_terminator    => false,
      clock_scale_quantum => B"001010",
      time_interval       => 10
      );

  i2c_led : i2c_led_controller
    port map (
      -- Wishbone common signals
      wb_clk_i                           => wb_clk_i,
      wb_rst_i                           => wb_rst_i,
      -- Wishbone slave inputs from LED master (top-level PTP)
      wbs_stb_i                          => i2c_led_wbs_stb,
      wbs_dat_i                          => i2c_led_wbs_dat,
      wbs_ack_o                          => i2c_led_wbs_ack,
      decode_in                          => i2c_led_decode,
      -- All the debugging LED inputs
      eth_xmit_debug_led_in              => X"01",
      eth_recv_debug_led_in              => X"02",
      ip_eth_debug_led_in                => X"03",
      ip_arp_debug_led_in                => X"04",
      ip_arp_xmit_debug_led_in           => X"05",
      ip_arp_recv_debug_led_in           => X"06",
      ip_xmit_debug_led_in               => X"07",
      ip_recv_debug_led_in               => X"08",
      ip_debug_led_in                    => X"09",
      trans_xmit_debug_led_in            => X"0a",
      icmp_xmit_debug_led_in             => X"0b",
      icmp_recv_debug_led_in             => X"0c",
      icmp_debug_led_in                  => X"0d",
      udp_xmit_debug_led_in              => X"0e",
      udp_recv_debug_led_in              => X"0f",
      dhcp_debug_led_in                  => X"10",
      ptp_link_master_xmit_debug_led_in  => X"11",
      ptp_link_master_recv_debug_led_in  => X"12",
      ptp_link_slave_xmit_debug_led_in   => X"13",
      ptp_link_slave_recv_debug_led_in   => X"14",
      ptp_link_state_debug_led_in        => X"15",
      ptp_link_recv_arbiter_debug_led_in => X"16",
      ptp_link_debug_led_in              => X"17",
      ptp_route_debug_led_in             => X"18",
      ptp_route_buffer_debug_led_in      => X"19",
      ptp_route_xmit_debug_led_in        => X"1a",
      ptp_route_recv_debug_led_in        => X"1b",
      ptp_top_debug_led_in               => X"1c",
      ptp_debug_led_in                   => X"1d",
      sequencer_debug_led_in             => X"1e",
      -- Wishbone master outputs to I2C controller
      wbm_cyc_o                          => wbm_cyc_o,
      wbm_stb_o                          => wbm_stb_o,
      wbm_we_o                           => wbm_we_o,
      wbm_adr_o                          => wbm_adr_o,
      wbm_dat_o                          => wbm_dat_o,
      wbm_ack_i                          => wbm_ack_i
      );

  i2c_led_arbiter : wb_intercon
    generic map (
      MASTER_COUNT  => I2C_LED_MASTER_COUNT
      )
    port map (
      wb_clk_i      => wb_clk_i,
      wb_rst_i      => wb_rst_i,

      wbm_cyc_i     => (boot_led_wb_cyc, debug_led_wb_cyc),
      wbm_stb_i     => (boot_led_wb_stb, debug_led_wb_stb),
      wbm_dat_i     => (boot_led_wb_dat, debug_led_wb_dat),
      wbm_ack_o     => i2c_led_arbiter_ack,
      wbm_gnt_o     => i2c_led_arbiter_gnt,

--      wbs_cyc_o     => i2c_led_wbs_cyc,
      wbs_stb_o     => i2c_led_wbs_stb,
      wbs_dat_o     => i2c_led_wbs_dat,
      wbs_ack_i     => i2c_led_wbs_ack
      );

    boot_led_wb_ack  <= i2c_led_arbiter_ack(0);
    debug_led_wb_ack <= i2c_led_arbiter_ack(1);
    i2c_led_decode   <= '0' when (i2c_led_arbiter_gnt(0) = '1') else '1';
])
