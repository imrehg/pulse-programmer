dnl-*-VHDL-*-
-- Memory test of PTP memory.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([ptp_memory_memory_test], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.ptp.all;
],[dnl -- Generics ------------------------------------------------------------
data_generic_
  PHYSICAL_ADDRESS_WIDTH : positive := 17;
  PHYSICAL_DATA_WIDTH    : positive := 16;
  SRAM_ADDRESS_WIDTH : positive := 17;
  SRAM_DATA_WIDTH    : positive := 16;
ptp_top_test_generics_
],[dnl -- Ports ---------------------------------------------------------------
   clk0 : in std_logic;
   common_test_ports_
   ptp_top_test_ports_
   ptp_router_test_ports_
   ptp_router_daisy_test_ports_
   ptp_debug_led_test_ports_
   ptp_dma_control_test_ports_
   pre_sizer8_wb_cyc_out : out std_logic;
   pre_sizer8_wb_stb_out : out std_logic;
   pre_sizer8_wb_we_out  : out std_logic;
   pre_sizer8_wb_adr_out : out virtual8_address_type;
   pre_sizer8_wb_write_data_out  : out std_logic_vector(7 downto 0);
   pre_sizer8_wb_read_data_out : out std_logic_vector(7 downto 0);
   pre_sizer8_wb_ack_out     : out std_logic;
   pre_sizer8_burst_out      : out std_logic;
   pre_sizer8_burst_addr_out : out virtual8_address_type;
   post_sizer8_wb_cyc_out : buffer std_logic;
   post_sizer8_wb_stb_out : buffer std_logic;
   post_sizer8_wb_we_out  : buffer std_logic;
   post_sizer8_wb_adr_out : buffer std_logic_vector(PHYSICAL_ADDRESS_WIDTH-1 downto 0);
   post_sizer8_wb_write_data_out : buffer std_logic_vector(PHYSICAL_DATA_WIDTH-1 downto 0);
   sram_wb_read_data_out : buffer std_logic_vector(PHYSICAL_DATA_WIDTH-1 downto 0);
   post_sizer8_wb_ack_out : buffer std_logic;
   post_sizer8_burst_out : buffer std_logic;
   sram_addr_out_out : buffer std_logic_vector(PHYSICAL_ADDRESS_WIDTH-1 downto 0);
   
],[dnl -- Declarations --------------------------------------------------------
ptp_top_sram_signals_
ptp_top_router_signals_
ptp_dma_router_signals_
ptp_dma_memory_signals_
tcp_dma_control_signals_
tcp_dma_memory_signals_
dnl pcp_dma_memory_signals_
network_ip_signals_
pcp32_memory_signals_
dhcp_signals_
dnl pcp_common_signals_
   
sram_controller_signals_
sram_arbiter_signals_
sram_sizer_signals_(8)

fifo8_signals_

async_read_write_component_
ptp_top_component_
ptp_router_component_

],[dnl -- Body ----------------------------------------------------------------

   pre_sizer8_wb_cyc_out <= pre_sizer8_wb_cyc;
   pre_sizer8_wb_stb_out <= pre_sizer8_wb_stb;
   pre_sizer8_wb_we_out  <= pre_sizer8_wb_we;
   pre_sizer8_wb_adr_out <= pre_sizer8_wb_adr;
   pre_sizer8_wb_write_data_out <= pre_sizer8_wb_write_data;
   pre_sizer8_wb_read_data_out  <= pre_sizer8_wb_read_data;
   pre_sizer8_wb_ack_out <= pre_sizer8_wb_ack;
   pre_sizer8_burst_out  <= pre_sizer8_burst;
   pre_sizer8_burst_addr_out <= pre_sizer8_burst_addr;
   post_sizer8_wb_cyc_out <= post_sizer8_wb_cyc;
   post_sizer8_wb_stb_out <= post_sizer8_wb_stb;
   post_sizer8_wb_we_out  <= post_sizer8_wb_we;
   post_sizer8_wb_adr_out <= post_sizer8_wb_adr(PHYSICAL_ADDRESS_WIDTH-1 downto 0);
   post_sizer8_wb_write_data_out <= post_sizer8_wb_write_data(PHYSICAL_DATA_WIDTH-1 downto 0);
   sram_wb_read_data_out <= sram_wb_read_data(PHYSICAL_DATA_WIDTH-1 downto 0);
   post_sizer8_wb_ack_out <= post_sizer8_wb_ack;
   post_sizer8_burst_out <= post_sizer8_burst;
   sram_addr_out_out <= sram_addr_out(PHYSICAL_ADDRESS_WIDTH-1 downto 0);

ptp_top_instance_
ptp_router_instance_
dnl ptp_dma_instance_

dnl sram_instance_
sram_sizer_instance_(8, 8, 1, , , , big_endian)

sram_arbiter_instance_

fifo8_instances_

  storage : memory_controller
    generic map (
      ADDRESS_WIDTH => PHYSICAL_ADDRESS_WIDTH,
      DATA_WIDTH    => PHYSICAL_DATA_WIDTH,
      READ_PIPELINE_DELAY => 2
      )
    port map (
      wb_clk_i      => network_clock,
      wb_cyc_i      => sram_wb_cyc,
      wb_stb_i      => sram_wb_stb,
      wb_we_i       => sram_wb_we,
      wb_adr_i      => sram_wb_adr(PHYSICAL_ADDRESS_WIDTH-1 downto 0),
      wb_dat_i      => sram_wb_write_data(PHYSICAL_DATA_WIDTH-1 downto 0),
      wb_dat_o      => sram_wb_read_data(PHYSICAL_DATA_WIDTH-1 downto 0),
      wb_ack_o      => sram_wb_ack,
      burst_in      => sram_burst,
      addr_out      => sram_addr_out(PHYSICAL_ADDRESS_WIDTH-1 downto 0)
      );

--   post_sizer8_wb_gnt  <= '1';
--   ptp_sram_wb_read_data <= pre_sizer8_wb_read_data;
--   tcp_sram_wb_cyc <= '0';
--   avr_dmem_wb_cyc <= '0';
--   pcp_dma_sram_wb_cyc <= '0';
])
