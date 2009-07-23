dnl-*-VHDL-*-
divert(-1)dnl
# Macros for PTP application modules
# ---------------------------------------------------------------------------
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
# ---------------------------------------------------------------------------

###############################################################################
# Stable count and timeout macros
#  $1 = stable condition
#  $2 = stable actions
#  $3 = stable next state
#  $4 = timeout state
define([ptp_stable_timeout_], [dnl
          if ($1) then
            if (ack_stable_count >= STABLE_COUNT-1) then
              $2
              ack_stable_count <= 0;
              timeout_counter  <= 0;
              state            := $3;
            else
              ack_stable_count <= ack_stable_count + 1;
            end if;
          else
            ack_stable_count <= 0;
            if (timeout_counter >= ABORT_TIMEOUT-1) then
              state := ifelse($4, , timed_out, $4);
            else
              timeout_counter <= timeout_counter + 1;
            end if;
          end if;
])
  
###############################################################################
#  $1 = ptp module design unit name
#  $2 = generics
#  $3 = ports
#  $4 = declarations
#  $5 = additional state names
#  $6 = reset behaviour
#  $7 = cyc behaviour
#  $8 = additional state behaviour
#  $9 = asynchronous assignments
#  $10 = done behaviour
  
define([ptp_unit_], [dnl
unit_([$1], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
$2
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
wb_xmit_master_port_
   xmit_dest_id_out       : out ptp_id_type;
   xmit_opcode_out        : out ptp_opcode_type;
   xmit_length_out        : out ptp_length_type;
wb_recv_slave_port_
   recv_src_id_in         : in  ptp_id_type;
   recv_dest_id_in        : in  ptp_id_type;
   recv_length_in         : in  ptp_length_type;
   -- External ports passed-in from top-level PTP
$3
   debug_led_out          : out byte;
],[dnl -- Declarations --------------------------------------------------------
  signal overlap          : std_logic;
  signal ack_enable       : std_logic;
$4
],[dnl -- Body ----------------------------------------------------------------
$9

  recv_wbs_ack_o <= recv_wbs_stb_i and overlap and ack_enable;
   
  process(wb_rst_i, wb_clk_i)

    type ptp_states is (
      idle,
$5
      done_state,
      wait_slave_ack
      );

    variable state           : ptp_states;
    variable overlap_enable  : boolean;

  begin

    if (wb_rst_i = '1') then
      xmit_wbm_cyc_o <= '0';
      xmit_wbm_stb_o <= '0';
      ack_enable     <= '0';
      overlap        <= '0';
      overlap_enable := true;
$6
      state           := idle;

    elsif (rising_edge(wb_clk_i)) then

      if ((recv_wbs_stb_i = '0') and (not overlap_enable)) then
        overlap <= '0';
      elsif ((recv_wbs_stb_i = '1') and (overlap_enable)) then
        overlap <= '1';
      end if;

      case (state) is
-------------------------------------------------------------------------------
        when idle =>
          if (recv_wbs_cyc_i = '1') then
            overlap_enable := false;
--            overlap        <= '1';
$7
          end if;
-------------------------------------------------------------------------------
$8
-------------------------------------------------------------------------------
        when done_state =>
          xmit_wbm_cyc_o <= '0';
          if (recv_wbs_cyc_i = '0') then
            ack_enable <= '0';
            overlap_enable := true;
$10
            state := wait_slave_ack;
          else
            -- ack out any errant data
            ack_enable <= '1';
          end if;
-------------------------------------------------------------------------------
        when wait_slave_ack =>
          -- wait for our slave to go low so it doesn't trip us the next time
          if (xmit_wbm_ack_i = '0') then
            state := idle;
          end if;
-------------------------------------------------------------------------------
        when others =>
          state := done_state;
      end case;
    end if; -- rising_edge(wb_clk_i)

  end process;

])])

###############################################################################
# PTP top test component for loopback tests
#  $1 = prefix for signal names
define([ptp_top_test_instance_], [dnl
  $1[]_ptp_top_test : ptp_top_test
    generic map (
      DATA_WIDTH                 => DATA_WIDTH,
      ADDRESS_WIDTH              => ADDRESS_WIDTH,
      STABLE_COUNT               => STABLE_COUNT,
      ABORT_TIMEOUT              => ABORT_TIMEOUT
      )
    port map (
      network_clock              => network_clock,
      wb_rst_i                   => wb_rst_i,

      ptp_self_id                => $1[]_self_id_out,
      -- I2C ports
      ptp_i2c_wb_cyc             => $1[]_i2c_wb_cyc_o,
      ptp_i2c_wb_stb             => $1[]_i2c_wb_stb_o,
      ptp_i2c_wb_we              => $1[]_i2c_wb_we_o,
      ptp_i2c_wb_adr             => $1[]_i2c_wb_adr_o,
      ptp_i2c_wb_write_data      => $1[]_i2c_wb_dat_o,
      ptp_i2c_wb_read_data       => $1[]_i2c_wb_dat_i,
      ptp_i2c_wb_ack             => $1[]_i2c_wb_ack_i,
      -- Status ports
      clock_scale_quantum        => (0 => '1', others => '0'),
      network_detected           => $1[]_network_detected,
      ptp_chain_initiator        => $1[]_chain_initiator,
      ptp_chain_terminator       => $1[]_chain_terminator,
      pcp_halted                 => $1[]_pcp_halted,
      -- Debug ports
      debug_led_wb_cyc           => $1[]_debug_led_wb_cyc_o,
      debug_led_wb_stb           => $1[]_debug_led_wb_stb_o,
      debug_led_wb_dat           => $1[]_debug_led_wb_dat_o,
      debug_led_wb_ack           => $1[]_debug_led_wb_ack_i,
      -- Start ports
      avr_reset                  => $1[]_avr_reset_out,
      pcp_reset                  => $1[]_pcp_reset_out,
      -- Trigger ports
      ptp_triggers               => $1[]_triggers_in,
      pcp_fifo_busy              => $1[]_pcp_fifo_busy,
      -- Memory ports
      ptp_sram_wb_cyc            => $1[]_sram_wb_cyc_o,
      ptp_sram_wb_stb            => $1[]_sram_wb_stb_o,
      ptp_sram_wb_we             => $1[]_sram_wb_we_o,
      ptp_sram_wb_adr            => $1[]_sram_wb_adr_o,
      ptp_sram_wb_write_data     => $1[]_sram_wb_dat_o,
      ptp_sram_wb_read_data      => $1[]_sram_wb_dat_i,
      ptp_sram_wb_ack            => $1[]_sram_wb_ack_i,
      ptp_sram_burst             => $1[]_sram_burst_out,
      ptp_sram_addr              => $1[]_sram_addr_in,
      -- UDP interface
      ptp_udp_xmit_wb_cyc        => $1[]_udp_xmit_wb_cyc_o,
      ptp_udp_xmit_wb_stb        => $1[]_udp_xmit_wb_stb_o,
      ptp_udp_xmit_wb_dat        => $1[]_udp_xmit_wb_dat_o,
      ptp_udp_xmit_wb_ack        => $1[]_udp_xmit_wb_ack_i,
      ptp_udp_xmit_dest_ip_addr  => $1[]_udp_xmit_dest_ip_addr_out,
      ptp_udp_xmit_src_port      => $1[]_udp_xmit_src_port_out,
      ptp_udp_xmit_dest_port     => $1[]_udp_xmit_dest_port_out,
      ptp_udp_xmit_length        => $1[]_udp_xmit_length_out,
      ptp_udp_xmit_dont_fragment => $1[]_udp_xmit_dont_fragment_out,
      -- Receive Wishbone slave interface from UDP
      ptp_udp_recv_wb_cyc        => $1[]_udp_recv_wb_cyc_i,
      udp_recv_wb_stb            => $1[]_udp_recv_wb_stb_i,
      udp_recv_wb_dat            => $1[]_udp_recv_wb_dat_i,
      ptp_udp_recv_wb_ack        => $1[]_udp_recv_wb_ack_o,
      udp_recv_src_ip_addr       => $1[]_udp_recv_src_ip_addr_in,
      udp_recv_src_port          => $1[]_udp_recv_src_port_in,
      udp_recv_dest_port         => $1[]_udp_recv_dest_port_in,
      udp_recv_length            => $1[]_udp_recv_length_in,
      -- Receive slave interface from AVR
      ptp_dma_xmit_wb_cyc        => $1[]_dma_xmit_wb_cyc_i,
      ptp_dma_xmit_wb_stb        => $1[]_dma_xmit_wb_stb_i,
      ptp_dma_xmit_wb_dat        => $1[]_dma_xmit_wb_dat_i,
      ptp_dma_xmit_wb_ack        => $1[]_dma_xmit_wb_ack_o,
      -- Transmit master inteface from AVR
      ptp_dma_recv_wb_cyc        => $1[]_dma_recv_wb_cyc_o,
      ptp_dma_recv_wb_stb        => $1[]_dma_recv_wb_stb_o,
      ptp_dma_recv_wb_dat        => $1[]_dma_recv_wb_dat_o,
      ptp_dma_recv_wb_ack        => $1[]_dma_recv_wb_ack_i,
      -- Physical daisy chain pins to master
      daisy_transmit             => $1[]_daisy_transmit,
      daisy_receive              => $1[]_daisy_receive,
      -- Debugging LED outputs
      ptp_link_master_xmit_debug_led  => $1[]_link_master_xmit_debug_led_out,
      ptp_link_master_recv_debug_led  => $1[]_link_master_recv_debug_led_out,
      ptp_link_slave_xmit_debug_led   => $1[]_link_slave_xmit_debug_led_out,
      ptp_link_slave_recv_debug_led   => $1[]_link_slave_recv_debug_led_out,
      ptp_link_state_debug_led        => $1[]_link_state_debug_led_out,
      ptp_link_recv_arbiter_debug_led => $1[]_link_recv_arbiter_debug_led_out,
      ptp_link_debug_led              => $1[]_link_debug_led_out,
      ptp_route_recv_debug_led        => $1[]_route_recv_debug_led_out,
      ptp_route_xmit_debug_led        => $1[]_route_xmit_debug_led_out,
      ptp_route_debug_led             => $1[]_route_debug_led_out,
      ptp_route_buffer_debug_led      => $1[]_route_buffer_debug_led_out,
      ptp_debug_led                   => $1[]_debug_led_out,
      ptp_top_debug_led               => $1[]_top_debug_led_out
      );
])

###############################################################################
# PTP top test ports
#  $1 = port prefix names
define([ptp_loopback_test_ports_], [
      $1[]_self_id_out                : out ptp_id_type;
      -- I2C ports
      $1[]_i2c_wb_cyc_o               : out std_logic;
      $1[]_i2c_wb_stb_o               : out std_logic;
      $1[]_i2c_wb_we_o                : out std_logic;
      $1[]_i2c_wb_adr_o               : out i2c_slave_address_type;
      $1[]_i2c_wb_dat_o               : out byte;
      $1[]_i2c_wb_dat_i               : in  byte;
      $1[]_i2c_wb_ack_i               : in  std_logic;
      -- Debug ports
      $1[]_debug_led_wb_cyc_o         : out std_logic;
      $1[]_debug_led_wb_stb_o         : out std_logic;
      $1[]_debug_led_wb_dat_o         : out byte;
      $1[]_debug_led_wb_ack_i         : in  std_logic;
      -- Start ports
      $1[]_avr_reset_out              : out std_logic;
      $1[]_pcp_reset_out              : out std_logic;
      -- Trigger ports
      $1[]_triggers_in                : in  trigger_source_type;
      -- Memory ports
      $1[]_sram_wb_cyc_o              : out std_logic;
      $1[]_sram_wb_stb_o              : out std_logic;
      $1[]_sram_wb_we_o               : out std_logic;
      $1[]_sram_wb_adr_o              : out sram_address_type;
      $1[]_sram_wb_dat_o              : out byte;
      $1[]_sram_wb_dat_i              : in  byte;
      $1[]_sram_wb_ack_i              : in  std_logic;
      $1[]_sram_burst_out             : out std_logic;
      -- UDP interface
      $1[]_udp_xmit_wb_cyc_o          : out std_logic;
      $1[]_udp_xmit_wb_stb_o          : out std_logic;
      $1[]_udp_xmit_wb_dat_o          : out std_logic_vector(0 to 7);
      $1[]_udp_xmit_wb_ack_i          : in  std_logic;
      $1[]_udp_xmit_dest_ip_addr_out  : out ip_address;
      $1[]_udp_xmit_src_port_out      : out udp_port_type;
      $1[]_udp_xmit_dest_port_out     : out udp_port_type;
      $1[]_udp_xmit_length_out        : out udp_length_type;
      $1[]_udp_xmit_dont_fragment_out : out std_logic;
      -- Receive Wishbone slave interface from UDP
      $1[]_udp_recv_wb_cyc_i          : in  std_logic;
      $1[]_udp_recv_wb_stb_i          : in  std_logic;
      $1[]_udp_recv_wb_dat_i          : in  std_logic_vector(0 to 7);
      $1[]_udp_recv_wb_ack_o          : out std_logic;
      $1[]_udp_recv_src_ip_addr_in    : in  ip_address;
      $1[]_udp_recv_src_port_in       : in  udp_port_type;
      $1[]_udp_recv_dest_port_in      : in  udp_port_type;
      $1[]_udp_recv_length_in         : in  udp_length_type;
         -- Receive slave interface from AVR
      $1[]_dma_xmit_wb_cyc_i          : in  std_logic;
      $1[]_dma_xmit_wb_stb_i          : in  std_logic;
      $1[]_dma_xmit_wb_dat_i          : in  std_logic_vector(DATA_WIDTH-1
                                                              downto 0);
      $1[]_dma_xmit_wb_ack_o          : out std_logic;
      -- Transmit master inteface from AVR
      $1[]_dma_recv_wb_cyc_o          : out std_logic;
      $1[]_dma_recv_wb_stb_o          : out std_logic;
      $1[]_dma_recv_wb_dat_o          : out std_logic_vector(DATA_WIDTH-1
                                                             downto 0);
      $1[]_dma_recv_wb_ack_i          : in  std_logic;
      -- Debugging LED outputs
      $1[]_link_master_xmit_debug_led_out  : out byte;
      $1[]_link_master_recv_debug_led_out  : out byte;
      $1[]_link_slave_xmit_debug_led_out   : out byte;
      $1[]_link_slave_recv_debug_led_out   : out byte;
      $1[]_link_state_debug_led_out        : out byte;
      $1[]_link_recv_arbiter_debug_led_out : out byte;
      $1[]_link_debug_led_out              : out byte;
      $1[]_route_recv_debug_led_out        : out byte;
      $1[]_route_xmit_debug_led_out        : out byte;
      $1[]_route_debug_led_out             : out byte;
      $1[]_route_buffer_debug_led_out      : out byte;
      $1[]_debug_led_out                   : out byte;
      $1[]_top_debug_led_out               : out byte;
])

###############################################################################
# PTP memory operations
#  $1 = memory prefix name
define([ptp_memory_states_], [
          ---------------------------------------------------------------------
          when memory_$1_read_transmitting =>
            if (xmit_wbm_ack_i = '1') then
              xmit_wbm_stb_o <= '0';
              if (length_counter = 0) then
                $1_wb_cyc_o  <= '0';
                $1_burst_out <= '0';
                state          := done_state;
              else
                $1_wb_stb_o <= '1';
                state := memory_$1_read_receiving;
              end if;
            end if;
          ---------------------------------------------------------------------
          when memory_$1_read_receiving =>
            if ($1_wb_ack_i = '1') then
              xmit_wbm_dat_o <= $1_wb_dat_i;
              $1_wb_stb_o <= '0';
              length_counter <= length_counter - 1;
              -- the total length is one more than payload length
              -- b/c of suboperand
              xmit_wbm_stb_o <= '1';
              state := memory_$1_read_transmitting;
            end if;
            debug_led_out <= $1_wb_dat_i;
        -----------------------------------------------------------------------
        when memory_$1_write_writing =>
          ack_enable <= '0';
          if ($1_wb_ack_i = '1') then
            $1_wb_stb_o <= '0';
            state := memory_$1_write_reading;
          end if;
          debug_led_out <= recv_wbs_dat_i;
        -----------------------------------------------------------------------
        when memory_$1_write_reading =>
          if (recv_wbs_stb_i = '1') then
            ack_enable  <= '1';
            $1_wb_stb_o <= '1';
            $1_wb_dat_o <= recv_wbs_dat_i;
            state := memory_$1_write_writing;
          elsif (recv_wbs_cyc_i = '0') then
            $1_wb_cyc_o     <= '0';
            $1_wb_stb_o     <= '0';
            $1_wb_we_o      <= '0';
            $1_burst_out    <= '0';
            xmit_wbm_cyc_o  <= '1';
            xmit_wbm_stb_o  <= '1';
            xmit_length_out <= X"0001";
            state          := wait_ack;
          end if;
          debug_led_out <= recv_wbs_dat_i;
])

                             
# Renable output for processed file
divert(0)dnl
