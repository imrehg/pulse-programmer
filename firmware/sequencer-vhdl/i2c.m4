divert(-1)dnl
# Macros for I2C instances and signals to include in top-level sequencer.
# ---------------------------------------------------------------------------
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
# ---------------------------------------------------------------------------

###############################################################################
# I2C Signals

define([i2c_signals_], [dnl
  signal i2c_clock              : std_logic;
  signal i2c_led_wbs_stb        : std_logic;
  signal i2c_led_wbs_dat        : byte;
  signal i2c_led_wbs_ack        : std_logic;
  signal i2c_led_decode         : std_logic;
  signal i2c_led_wbm_cyc        : std_logic;
  signal i2c_led_wbm_stb        : std_logic;
  signal i2c_led_wbm_adr        : i2c_slave_address_type;
  signal i2c_led_wbm_we         : std_logic;
  signal i2c_led_wbm_write_data : byte;
  signal i2c_led_wbm_read_data  : byte; -- not connected
  signal i2c_led_wbm_ack        : std_logic;
  signal i2c_wb_cyc             : std_logic;
  signal i2c_wb_stb             : std_logic;
  signal i2c_wb_we              : std_logic;
  signal i2c_wb_adr             : i2c_slave_address_type;
  signal i2c_wb_write_data      : byte;
  signal i2c_wb_read_data       : byte;
  signal i2c_wb_ack             : std_logic;

  -- I2C Controller Arbiter Signals
  constant I2C_MASTER_COUNT     : positive := 2;
  signal i2c_arbiter_read_data  : multibus_byte(0 to I2C_MASTER_COUNT-1);
  signal i2c_arbiter_gnt        : multibus_bit(0 to I2C_MASTER_COUNT-1);
  signal i2c_arbiter_ack        : multibus_bit(0 to I2C_MASTER_COUNT-1);
  -- I2C LED Controller Arbiter Signals
  constant I2C_LED_MASTER_COUNT : positive := 2;
  signal i2c_led_arbiter_gnt    : multibus_bit(0 to I2C_LED_MASTER_COUNT-1);
  signal i2c_led_arbiter_ack    : multibus_bit(0 to I2C_LED_MASTER_COUNT-1);

i2c_controller_component_
i2c_led_controller_component_
])

###############################################################################
# I2C Controller instance

define([i2c_controller_instance_], [dnl
  i2c_top : i2c_controller
    generic map (
      CLOCK_PRESCALE => X"0064"
      )
    port map (
      -- Wishbone common signals
      wb_clk_i    => i2c_clock,
      wb_rst_i    => wb_rst_i,
      -- Wishbone slave interface
      wb_cyc_i    => i2c_wb_cyc,
      wb_stb_i    => i2c_wb_stb,
      wb_we_i     => i2c_wb_we,
      wb_adr_i    => i2c_wb_adr,
      wb_dat_i    => i2c_wb_write_data,
      wb_dat_o    => i2c_wb_read_data,
      wb_ack_o    => i2c_wb_ack,
      -- Physical I2C pins
      sda         => sda,
      scl         => scl
      );
  i2c_clock <= network_clock;
])

###############################################################################
# I2C LED controller instance

define([i2c_led_controller_instance_], [dnl
  i2c_led : i2c_led_controller
    generic map (
      ENABLE_DEBUG_LEDS => ENABLE_DEBUG_LEDS
      )
    port map (
      -- Wishbone common signals
      wb_clk_i                           => i2c_clock,
      wb_rst_i                           => wb_rst_i,
      -- Wishbone slave inputs from LED master (top-level PTP)
      wbs_stb_i                          => i2c_led_wbs_stb,
      wbs_dat_i                          => i2c_led_wbs_dat,
      wbs_ack_o                          => i2c_led_wbs_ack,
      decode_in                          => i2c_led_decode,
      -- All the debugging LED inputs
      eth_xmit_debug_led_in              => eth_xmit_debug_led,
      eth_recv_debug_led_in              => eth_recv_debug_led,
      ip_eth_debug_led_in                => ip_eth_debug_led,
      ip_arp_debug_led_in                => ip_arp_debug_led,
      ip_arp_xmit_debug_led_in           => ip_arp_xmit_debug_led,
      ip_arp_recv_debug_led_in           => ip_arp_recv_debug_led,
      ip_xmit_debug_led_in               => ip_xmit_debug_led,
      ip_recv_debug_led_in               => ip_recv_debug_led,
      ip_debug_led_in                    => ip_debug_led,
      trans_xmit_debug_led_in            => trans_xmit_debug_led,
      icmp_xmit_debug_led_in             => icmp_xmit_debug_led,
      icmp_recv_debug_led_in             => icmp_recv_debug_led,
      icmp_debug_led_in                  => icmp_debug_led,
      udp_xmit_debug_led_in              => udp_xmit_debug_led,
      udp_recv_debug_led_in              => udp_recv_debug_led,
      dhcp_debug_led_in                  => dhcp_debug_led,
      ptp_link_master_xmit_debug_led_in  => ptp_link_master_xmit_debug_led,
      ptp_link_master_recv_debug_led_in  => ptp_link_master_recv_debug_led,
      ptp_link_slave_xmit_debug_led_in   => ptp_link_slave_xmit_debug_led,
      ptp_link_slave_recv_debug_led_in   => ptp_link_slave_recv_debug_led,
      ptp_link_state_debug_led_in        => ptp_link_state_debug_led,
      ptp_link_recv_arbiter_debug_led_in => ptp_link_recv_arbiter_debug_led,
      ptp_link_debug_led_in              => ptp_link_debug_led,
      ptp_route_debug_led_in             => ptp_route_debug_led,
      ptp_route_buffer_debug_led_in      => ptp_route_buffer_debug_led,
      ptp_route_xmit_debug_led_in        => ptp_route_xmit_debug_led,
      ptp_route_recv_debug_led_in        => ptp_route_recv_debug_led,
      ptp_top_debug_led_in               => ptp_top_debug_led,
      ptp_debug_led_in                   => ptp_debug_led,
      sequencer_debug_led_in             => sequencer_debug_led,
      -- Wishbone master outputs to I2C controller
      wbm_cyc_o                          => i2c_led_wbm_cyc,
      wbm_stb_o                          => i2c_led_wbm_stb,
      wbm_we_o                           => i2c_led_wbm_we,
      wbm_adr_o                          => i2c_led_wbm_adr,
      wbm_dat_o                          => i2c_led_wbm_write_data,
      wbm_ack_i                          => i2c_led_wbm_ack
      );
])

###############################################################################
# I2C Arbiter instance
define([i2c_arbiter_instance_], [dnl
  i2c_arbiter : wb_intercon
    generic map (
      MASTER_COUNT  => I2C_MASTER_COUNT
      )
    port map (
      wb_clk_i      => i2c_clock,
      wb_rst_i      => wb_rst_i,

      wbm_cyc_i     => (i2c_led_wbm_cyc, ptp_i2c_wb_cyc),
      wbm_stb_i     => (i2c_led_wbm_stb, ptp_i2c_wb_stb),
      wbm_adr_i     => (i2c_led_wbm_adr & B"0", ptp_i2c_wb_adr & B"0"),
      wbm_we_i      => (i2c_led_wbm_we,  ptp_i2c_wb_we),
      wbm_dat_i     => (i2c_led_wbm_write_data, ptp_i2c_wb_write_data),
      wbm_dat_o     => i2c_arbiter_read_data,
      wbm_ack_o     => i2c_arbiter_ack,
      wbm_gnt_o     => i2c_arbiter_gnt,

      wbs_cyc_o     => i2c_wb_cyc,
      wbs_stb_o     => i2c_wb_stb,
      wbs_adr_o(7 downto 1) => i2c_wb_adr,
      wbs_we_o      => i2c_wb_we,
      wbs_dat_i     => i2c_wb_read_data,
      wbs_dat_o     => i2c_wb_write_data,
      wbs_ack_i     => i2c_wb_ack
      );

    i2c_led_wbm_ack          <= i2c_arbiter_ack(0);
    ptp_i2c_wb_ack           <= i2c_arbiter_ack(1);
    i2c_led_wbm_read_data    <= i2c_arbiter_read_data(0);
    ptp_i2c_wb_read_data     <= i2c_arbiter_read_data(1);
--     i2c_arbiter_read_data(0) <= i2c_led_wbm_read_data;
--     i2c_arbiter_read_data(1) <= ptp_i2c_wb_read_data;

])

###############################################################################
# I2C LED Arbiter
define([i2c_led_arbiter_instance_], [dnl
  i2c_led_arbiter : wb_intercon
    generic map (
      MASTER_COUNT  => I2C_LED_MASTER_COUNT
      )
    port map (
      wb_clk_i      => i2c_clock,
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
    i2c_led_decode   <= i2c_led_arbiter_gnt(1);
])


###############################################################################
# All I2C instances
define([i2c_instances_], [dnl
i2c_controller_instance_
i2c_led_controller_instance_
i2c_arbiter_instance_
i2c_led_arbiter_instance_
])


# Renable output for processed file
divert(0)dnl