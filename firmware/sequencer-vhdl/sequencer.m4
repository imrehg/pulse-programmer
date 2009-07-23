divert(-1)dnl
# Macros for sequencer firmware
# ---------------------------------------------------------------------------
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
# ---------------------------------------------------------------------------

###############################################################################
# Sequencer libraries

define([sequencer_libraries_], [dnl
library seqlib;
use seqlib.constants.all;
use seqlib.util.all;
use seqlib.network.all;
use seqlib.ptp.all;
use seqlib.avr.all;
use ieee.numeric_std.all;
])

###############################################################################
# Data width generic

define([data_generic_], [dnl
    DATA_WIDTH          : positive := 8;])

##############################################################################
# Wishbone common ports

define([wb_common_port_], [dnl
    -- Wishbone common signals
    wb_clk_i            : in     std_logic;
    wb_rst_i            : in     std_logic;
])

###############################################################################
# Wishbone link level master ports (LSB)
define([wb_lsb_master_port_], [dnl
    wb_cyc_o           : buffer std_logic;
    wb_stb_o           : buffer std_logic;
    wb_dat_o           : out    std_logic_vector(DATA_WIDTH-1 downto 0);
    wb_ack_i           : in     std_logic;
])

###############################################################################
# Wishbone link level slave ports (LSB)
define([wb_lsb_slave_port_], [dnl
    wb_cyc_i       : in  std_logic;
    wb_stb_i       : in  std_logic;
    wb_dat_i       : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    wb_ack_o       : buffer std_logic;
])
###############################################################################
# Wishbone master ports

define([wb_master_port_], [dnl
    -- Wishbone master signals
    wbm_cyc_o           : buffer std_logic;
    wbm_stb_o           : buffer std_logic;
    wbm_dat_o           : out    std_logic_vector(0 to DATA_WIDTH-1);
    wbm_ack_i           : in     std_logic;
])

define([wb_xmit_master_port_], [dnl
    xmit_wbm_cyc_o        : buffer std_logic;
    xmit_wbm_stb_o        : buffer std_logic;
    xmit_wbm_dat_o        : buffer std_logic_vector(0 to DATA_WIDTH-1);
    xmit_wbm_ack_i        : in     std_logic;
    xmit_debug_led_out    : out    byte;
])

define([wb_xmit_slave_port_], [dnl
    xmit_wbs_cyc_i        : in     std_logic;
    xmit_wbs_stb_i        : in     std_logic;
    xmit_wbs_dat_i        : in     std_logic_vector(0 to DATA_WIDTH-1);
    xmit_wbs_ack_o        : buffer std_logic;
])
###############################################################################
# Wishbone slave ports

define([wb_slave_port_], [dnl
    -- Wishbone slave signals
    wbs_cyc_i           : in     std_logic;
    wbs_stb_i           : in     std_logic;
    wbs_dat_i           : in     std_logic_vector(0 to DATA_WIDTH-1);
    wbs_ack_o           : buffer std_logic;
])

define([wb_recv_slave_port_], [dnl
    recv_wbs_cyc_i        : in     std_logic;
    recv_wbs_stb_i        : in     std_logic;
    recv_wbs_dat_i        : in     std_logic_vector(0 to DATA_WIDTH-1);
    recv_wbs_ack_o        : buffer std_logic;
    recv_debug_led_out    : out    byte;
])

define([wb_recv_master_port_], [dnl
    recv_wbm_cyc_o        : out std_logic;
    recv_wbm_stb_o        : out std_logic;
    recv_wbm_dat_o        : out std_logic_vector(0 to DATA_WIDTH-1);
    recv_wbm_ack_i        : in  std_logic;
])

###############################################################################
# Transform macro for byte_count states
#   $1 = argument to transform

define([byte_count_transform_], [dnl
              when COUNT_START+i =>
                $1
])

###############################################################################
# Main sequencer ports

define([sequencer_clock_ports_], [dnl
    -- Clock pins
    clk0           : in    std_logic;
    clk2           : in    std_logic;
])

define([sequencer_sram_ports_], [dnl
    -- SRAM pins
    sram_data      : inout std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);
    sram_addr      : out   std_logic_vector(SRAM_ADDRESS_WIDTH-1 downto 0);
    sram_nOE       : out   std_logic;
    sram_nGW       : out   std_logic;
    sram_clk       : out   std_logic;
    sram_nCE1      : out   std_logic;
])

define([sequencer_i2c_ports_], [dnl
    -- I2C pins
    sda            : inout std_logic;
    scl            : inout std_logic;
])

define([sequencer_lvds_ports_], [dnl
    -- LVDS/Samtec connector pins
    lvds_receive   : in    std_logic_vector(7 downto 0);
    lvds_transmit  : out   std_logic_vector(63 downto 0);
])

define([sequencer_switch_ports_], [dnl
    -- DIP switch inputs
    switch         : in    std_logic_vector(7 downto 0);
])

define([sequencer_fo_ports_], [dnl
    -- Fiberoptic I/O
    fo_in          : in    std_logic;
    fo_out         : out   std_logic;
])

define([sequencer_daisy_ports_], [dnl
    -- Daisy chain pins
    daisy_transmit : buffer std_logic_vector(3 downto 0);
    daisy_receive  : in  std_logic_vector(3 downto 0);
])

define([sequencer_ethernet_ports_], [dnl
    -- Ethernet pins
    ether_rx_clk   : in    std_logic;
    ether_tx_clk   : in    std_logic;
    ether_rxd      : in    nibble;
    ether_txd      : out   nibble;
    ether_rx_dv    : in    std_logic;
    ether_tx_en    : out   std_logic;
    ether_mdio     : inout std_logic := '0'; -- currently unused
    ether_mdc      : out   std_logic
])

define([sequencer_ports_], [dnl
sequencer_clock_ports_
sequencer_sram_ports_
sequencer_lvds_ports_
sequencer_daisy_ports_
sequencer_i2c_ports_
sequencer_switch_ports_
sequencer_fo_ports_
dnl This must be last b/c it lacks the ending semi-colon
sequencer_ethernet_ports_
])

###############################################################################
# All peripheral signals

define([all_signals_], [dnl
network_signals_
peripheral_signals_
sram_signals_
i2c_signals_
ptp_signals_
dnl avr_signals_
pcp_signals_
])

###############################################################################
# All peripheral instances

define([all_instances_], [dnl
peripheral_instances_
sram_instances_
i2c_instances_
network_instances_
ptp_instances_
dnl avr_instances_
pcp_instances_

  ether_mdc <= '0';
  fo_out    <= '0';
])

###############################################################################
# Top-level sequencer unit
#   $1 = entity name
#   $2 = declarations
#   $3 = body
#   $4 = additional ports (for simulation only)
define([sequencer_unit_],dnl
generated_warning_
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
sequencer_libraries_
library pcplib;
use pcplib.instructions.all;

entity $1 is

  port (
sequencer_ports_
$4
    );

end $1;

[architecture_([$1],
sequencer_libraries_,
all_signals_[][$2],
[$3])])

# Renable output for processed file
divert(0)dnl
