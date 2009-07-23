dnl--*-VHDL-*-
-- Test for I2C controller and LED frontend.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([i2c_controller_test],
  [dnl -- Libraries
sequencer_libraries_
],[dnl -- Generics
],[dnl -- Ports
wb_common_port_
    i2c_led_wbs_stb_i      : in  std_logic;
    i2c_led_wbs_dat_i      : in  byte;          -- the LED selector
    i2c_led_wbs_ack_o      : out std_logic;
    
    -- Physical I2C pins
    sda            : inout std_logic;
    scl            : inout std_logic;
],[dnl -- Declarations
  constant I2C_MASTER_COUNT : positive := 2;
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
  signal i2c_arbiter_read_data  : multibus_byte(0 to I2C_MASTER_COUNT-1);
  signal i2c_arbiter_gnt        : multibus_bit(0 to I2C_MASTER_COUNT-1);
  signal i2c_arbiter_ack        : multibus_bit(0 to I2C_MASTER_COUNT-1);

i2c_controller_component_
i2c_led_controller_component_

],[dnl -- Body
  i2c_top : i2c_controller
    port map (
      -- Wishbone common signals
      wb_clk_i    => wb_clk_i,
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
      
  i2c_led : i2c_led_controller
    port map (
      -- Wishbone common signals
      wb_clk_i                           => wb_clk_i,
      wb_rst_i                           => wb_rst_i,
      -- Wishbone slave inputs from LED master (top-level PTP)
      wbs_stb_i                          => i2c_led_wbs_stb_i,
      wbs_dat_i                          => i2c_led_wbs_dat_i,
      wbs_ack_o                          => i2c_led_wbs_ack_o,
      -- All the debugging LED inputs
      eth_xmit_debug_led_in              => X"00",
      eth_recv_debug_led_in              => X"01",
      ip_eth_debug_led_in                => X"02",
      ip_arp_debug_led_in                => X"03",
      ip_arp_xmit_debug_led_in           => X"04",
      ip_arp_recv_debug_led_in           => X"05",
      ip_xmit_debug_led_in               => X"06",
      ip_recv_debug_led_in               => X"07",
      ip_debug_led_in                    => X"08",
      trans_xmit_debug_led_in            => X"09",
      icmp_xmit_debug_led_in             => X"0a",
      icmp_recv_debug_led_in             => X"0b",
      icmp_debug_led_in                  => X"0c",
      udp_xmit_debug_led_in              => X"0d",
      udp_recv_debug_led_in              => X"0e",
      dhcp_debug_led_in                  => X"0f",
      ptp_link_master_xmit_debug_led_in  => X"10",
      ptp_link_master_recv_debug_led_in  => X"11",
      ptp_link_slave_xmit_debug_led_in   => X"12",
      ptp_link_slave_recv_debug_led_in   => X"13",
      ptp_link_state_debug_led_in        => X"14",
      ptp_link_recv_arbiter_debug_led_in => X"15",
      ptp_link_debug_led_in              => X"16",
      ptp_route_debug_led_in             => X"17",
      ptp_route_buffer_debug_led_in      => X"18",
      ptp_route_xmit_debug_led_in        => X"19",
      ptp_route_recv_debug_led_in        => X"1a",
      ptp_top_debug_led_in               => X"1b",
      ptp_debug_led_in                   => X"1c",
      sequencer_debug_led_in             => X"1d",
      -- Wishbone master outputs to I2C controller
      wbm_cyc_o                          => i2c_led_wbm_cyc,
      wbm_stb_o                          => i2c_led_wbm_stb,
      wbm_we_o                           => i2c_led_wbm_we,
      wbm_adr_o                          => i2c_led_wbm_adr,
      wbm_dat_o                          => i2c_led_wbm_write_data,
      wbm_ack_i                          => i2c_led_wbm_ack
      );

  i2c_arbiter : wb_intercon
    generic map (
      MASTER_COUNT  => I2C_MASTER_COUNT
      )
    port map (
      wb_clk_i      => wb_clk_i,
      wb_rst_i      => wb_rst_i,

      wbm_cyc_i     => (i2c_led_wbm_cyc, '0'),
      wbm_stb_i     => (i2c_led_wbm_stb, '0'),
      wbm_adr_i     => (i2c_led_wbm_adr & B"0", (others => '0')),
      wbm_we_i      => (i2c_led_wbm_we,  '0'),
      wbm_dat_i     => (i2c_led_wbm_write_data, (others => '0')),
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

    i2c_led_wbm_ack <= i2c_arbiter_ack(0);
    i2c_arbiter_read_data(0) <= i2c_led_wbm_read_data;
])
