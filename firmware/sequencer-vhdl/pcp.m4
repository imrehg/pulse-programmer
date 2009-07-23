divert(-1)dnl
# Macros for Pulse Control Processor to include in top-level sequencer.
# ---------------------------------------------------------------------------
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
# ---------------------------------------------------------------------------

###############################################################################
define([pcp32_memory_signals_], [dnl
  signal pcp_sram_wb_cyc : std_logic;
  signal pcp_sram_wb_stb : std_logic;
  signal pcp_sram_wb_we  : std_logic;
  signal pcp_sram_wb_adr : sram_address_type;
  signal pcp_sram_wb_ack : std_logic;
  signal pcp_sram_burst  : std_logic;
])

###############################################################################
define([pcp_dma_memory_signals_], [dnl
  signal pcp_dma_sram_wb_cyc        : std_logic;
  signal pcp_dma_sram_wb_stb        : std_logic;
  signal pcp_dma_sram_wb_we         : std_logic;
  signal pcp_dma_sram_wb_adr        : virtual_address_type;
  signal pcp_dma_sram_wb_write_data : virtual_data_type;
  signal pcp_dma_sram_wb_ack        : std_logic;
  signal pcp_dma_sram_burst         : std_logic;
])

###############################################################################
define([pcp_dma_control_signals_], [dnl
  signal pcp_dma_xmit_sram_stb    : std_logic;
  signal pcp_dma_xmit_sram_ack    : std_logic;
  signal pcp_dma_xmit_sram_length : ptp_length_type;
  signal pcp_dma_start_addr       : virtual_address_type;
  signal pcp_sram_addr_prefix     : virtual8_address_prefix_type;
])

###############################################################################
define([pcp_common_signals_], [dnl
  signal pcp_clock        : std_logic;
  signal pcp_reset        : std_logic;
  signal pcp_halted       : std_logic;
  signal pcp_fifo_busy    : std_logic;
  signal pcp_start_addr   : sram_address_type;
])

###############################################################################
define([pcp_memory_signals_], [dnl
pcp32_memory_signals_
])

define([pcp_signals_], [dnl
pcp_common_signals_
pcp_memory_signals_
pcp1_controller_component_
  signal pcp_debug_led : byte;
  signal pcp_sram_wb_adr_int : pcp32_address_type;
])

###############################################################################
define([pcp1_controller_instance_], [dnl
  pcp1 : pcp1_controller
    port map (
      -- Wishbone common signals
      wb_clk_i      => pcp_clock,
      wb_rst_i      => wb_rst_i,
      core_reset    => pcp_reset,
      triggers_in   => ptp_triggers,
      pulse_out     => lvds_transmit,
      halted_out    => pcp_halted,
      -- Debugging outputs
   --   debug_led_out    : out byte;
      -- Read port to memory
      wb_cyc_o      => pcp_sram_wb_cyc,
      wb_stb_o      => pcp_sram_wb_stb,
      wb_adr_o      => pcp_sram_wb_adr_int,
      wb_dat_i      => sram_latched_read_data(31 downto 0),
      wb_ack_i      => pcp_sram_wb_ack,
      debug_led_out => pcp_debug_led
      );
  pcp_sram_wb_adr <= std_logic_vector(pcp_sram_wb_adr_int(SRAM_ADDRESS_WIDTH-1 downto 0));
  pcp_sram_burst <= '0'; -- We do not burst b/c pc must be able to branch.
])

###############################################################################
# PCP instances
define([pcp_instances_], [dnl

pcp1_controller_instance_

--  ptp_triggers(7 downto 0) <= lvds_receive;
--  ptp_triggers(8) <= nswitch(5);
])

# Renable output for processed file
divert(0)dnl