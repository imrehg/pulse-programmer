dnl-*-VHDL-*-
-- Test of pcp1 controller connected to memory and PTP.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([pcp1_controller_test], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.ptp.all;
library pcplib;
use pcplib.instructions.all;
],[dnl -- Generics ------------------------------------------------------------
data_generic_
  AVR_ENABLE                    : boolean := false;
  TEST_SRAM_ADDRESS_WIDTH       : positive := 4;
  FIRMWARE_MAJOR_VERSION_NUMBER : std_logic_vector(0 to 7) := X"00";
  FIRMWARE_MINOR_VERSION_NUMBER : std_logic_vector(0 to 7) := X"01";
],[dnl -- Ports ---------------------------------------------------------------
  common_test_ports_
  ptp_router_test_ports_
  sequencer_clock_ports_
  sequencer_switch_ports_
  sequencer_lvds_ports_
  ptp_router_daisy_test_ports_
  ptp_debug_led_test_ports_
  sram_sizer_test_ports_(8, 8)
  ptp_self_id_out   : out byte;
  pcp_debug_led_out : out byte;
  instruction_out   : out pcp32_instruction_type;
  pcp_instruction   : out pcp32_instruction_type;
  pcp_wb_stb        : out std_logic;
  pcp_wb_ack        : out std_logic;
  pc_out            : out std_logic_vector(TEST_SRAM_ADDRESS_WIDTH-1 downto 0);
  -- Memory ports
  ptp_sram_wb_cyc_out        : out std_logic;
  ptp_sram_wb_stb_out        : out std_logic;
  ptp_sram_wb_we_out         : out std_logic;
  ptp_sram_wb_adr_out        : out virtual8_address_type;
  ptp_sram_wb_write_data_out : out byte;
  ptp_sram_wb_read_data_out  : out byte;
  ptp_sram_wb_ack_out        : out std_logic;
  ptp_sram_burst_out         : out std_logic;
  wrusedw_out                : out std_logic_vector(FIFO8_WORD_COUNT_WIDTH-1
                                                    downto 0);
],[dnl -- Declarations --------------------------------------------------------
ptp_top_signals_
ptp_top_status_signals_
ptp_top_debug_signals_
ptp_top_sram_signals_
ptp_top_router_signals_
dnl ptp_router_signals_
ptp_dma_router_signals_
clock_scaler_signals_
network_common_signals_
dhcp_signals_
  signal nswitch       : byte;
  signal self_mac_addr : mac_address;

fifo8_signals_
sram_controller_signals_
sram_arbiter_signals_

ptp_top_component_
ptp_router_component_
pcp_signals_

async_read_write_component_
  signal instruction : sram_data_type;
  signal delayed_instruction : sram_data_type;
],[dnl -- Body ----------------------------------------------------------------

pcp_instances_
ptp_top_instance_
ptp_router_instance_
sram_sizer_instance_(8, 8, 2, , , , big_endian)
sram_arbiter_instance_
fifo8_instances_

  ptp_self_id_out <= ptp_self_id;
  pcp_debug_led_out(7) <= sram_burst;
  pcp_debug_led_out(6) <= sram_wb_ack;
  pcp_debug_led_out(5) <= sram_wb_we;
  pcp_debug_led_out(4) <= pcp_reset;
  pc_out <= sram_wb_adr(TEST_SRAM_ADDRESS_WIDTH-1 downto 0);
--  pc_out <= sram_addr_out(TEST_SRAM_ADDRESS_WIDTH-1 downto 0);
  instruction_out <= instruction(PCP32_INSTRUCTION_WIDTH-1 downto 0);
  pcp_instruction <= sram_wb_read_data(PCP32_INSTRUCTION_WIDTH-1 downto 0);
  pcp_wb_stb     <= pcp_sram_wb_stb;
  pcp_wb_ack     <= pcp_sram_wb_ack;

  ptp_sram_wb_cyc_out        <= ptp_sram_wb_cyc;
  ptp_sram_wb_stb_out        <= ptp_sram_wb_stb;
  ptp_sram_wb_we_out         <= ptp_sram_wb_we;
  ptp_sram_wb_adr_out        <= ptp_sram_wb_adr;
  ptp_sram_wb_write_data_out <= ptp_sram_wb_write_data;
  ptp_sram_wb_read_data_out  <= ptp_sram_wb_read_data;
  ptp_sram_wb_ack_out        <= ptp_sram_wb_ack;
  ptp_sram_burst_out         <= ptp_sram_burst;

  wrusedw_out                <= fifo8_wrusedw;

  storage : memory_controller
    generic map (
      ADDRESS_WIDTH       => TEST_SRAM_ADDRESS_WIDTH,
      DATA_WIDTH          => SRAM_DATA_WIDTH,
      READ_PIPELINE_DELAY => 1
      )
    port map (
      wb_clk_i      => clk0,
      wb_cyc_i      => sram_wb_cyc,
      wb_stb_i      => sram_wb_stb,
      wb_we_i       => sram_wb_we,
      wb_adr_i      => sram_wb_adr(TEST_SRAM_ADDRESS_WIDTH-1 downto 0),
      wb_dat_i      => sram_wb_write_data,
      wb_dat_o      => instruction,
      wb_ack_o      => sram_wb_ack,
      burst_in      => sram_burst,
      one_shot_in   => '0',
      addr_out      => sram_addr_out(TEST_SRAM_ADDRESS_WIDTH-1 downto 0)
      );

  -- Delay instructions by one cycle to simulate 2-stage pipeline in SRAM
   process(clk0, wb_rst_i)

   begin
     if (wb_rst_i = '1') then
       delayed_instruction <= (others => '0');
     elsif (rising_edge(clk0)) then
       delayed_instruction <= instruction;
     end if;

   end process;

  sram_wb_read_data <= delayed_instruction;
--  when (sram_wb_ack = '1') else  (others => '0');
  
  -- Disable AVR routing
  ptp_dma_xmit_wb_cyc <= '0';
  ptp_dma_xmit_wb_stb <= '0';
  ptp_dma_xmit_wb_dat <= (others => '0');
  ptp_dma_recv_wb_ack <= ptp_dma_recv_wb_stb;
   
  ptp_chain_terminator <= true;
  network_detected <= '1';
  ptp_i2c_wb_ack <= ptp_i2c_wb_stb;
  ptp_i2c_wb_read_data <= (others => '0');
  debug_led_wb_ack <= debug_led_wb_stb;
])
