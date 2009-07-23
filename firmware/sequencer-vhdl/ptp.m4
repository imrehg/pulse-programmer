divert(-1)dnl
# Macros for pulse transfer to include in top-level sequencer.
# ---------------------------------------------------------------------------
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
# ---------------------------------------------------------------------------

define([ptp_debug_led_signals_], [dnl
  -- Debugging LED outputs
  signal ptp_link_master_xmit_debug_led  : byte;
  signal ptp_link_master_recv_debug_led  : byte;
  signal ptp_link_slave_xmit_debug_led   : byte;
  signal ptp_link_slave_recv_debug_led   : byte;
  signal ptp_link_state_debug_led        : byte;
  signal ptp_link_recv_arbiter_debug_led : byte;
  signal ptp_link_debug_led              : byte;
  signal ptp_route_debug_led             : byte;
  signal ptp_route_buffer_debug_led      : byte;
  signal ptp_route_xmit_debug_led        : byte;
  signal ptp_route_recv_debug_led        : byte;
  signal ptp_top_debug_led               : byte;
  signal ptp_debug_led                   : byte;
])

###############################################################################
# Signals for ptp router
define([ptp_router_signals_], [dnl
  -- PTP transmit signals
  signal ptp_udp_xmit_wb_cyc             : std_logic;
  signal ptp_udp_xmit_wb_stb             : std_logic;
  signal ptp_udp_xmit_wb_dat             : std_logic_vector(0 to
                                                       NETWORK_DATA_WIDTH-1);
  signal ptp_udp_xmit_wb_ack             : std_logic;
  signal ptp_udp_xmit_dest_ip_addr       : ip_address;
  signal ptp_udp_xmit_src_port           : udp_port_type;
  signal ptp_udp_xmit_dest_port          : udp_port_type;
  signal ptp_udp_xmit_length             : udp_length_type;
  signal ptp_udp_xmit_dont_fragment      : std_logic;
  -- PTP receive signals
  signal ptp_udp_recv_wb_cyc             : std_logic;
  signal ptp_udp_recv_wb_ack             : std_logic;
  signal ptp_server_port                 : udp_port_type;
])

###############################################################################
# Signals connecting the top-level PTP and router
# Use this one in tests.
define([ptp_top_router_signals_], [dnl
  -- Routing transmit signals
  signal ptp_route_xmit_wb_cyc           : std_logic;
  signal ptp_route_xmit_wb_stb           : std_logic;
  signal ptp_route_xmit_wb_dat           : std_logic_vector(0 to 7);
  signal ptp_route_xmit_wb_ack           : std_logic;
  signal ptp_route_xmit_dest_id          : ptp_id_type;
  signal ptp_route_xmit_opcode           : ptp_opcode_type;
  signal ptp_route_xmit_length           : ptp_length_type;
  -- Routing receive signals
  signal ptp_route_recv_wb_cyc           : std_logic;
  signal ptp_route_recv_wb_stb           : std_logic;
  signal ptp_route_recv_wb_dat           : std_logic_vector(0 to 7);
  signal ptp_route_recv_wb_ack           : std_logic;
  signal ptp_route_recv_src_id           : ptp_id_type;
  signal ptp_route_recv_dest_id          : ptp_id_type;
  signal ptp_route_recv_opcode           : ptp_opcode_type;
  signal ptp_route_recv_length           : ptp_length_type;
])

###############################################################################
# Signals for top-level PTP module
define([ptp_top_signals_], [dnl
  signal ptp_self_id                     : ptp_id_type;
  -- Non Wishbone PCP signals
  signal ptp_i2c_wb_cyc             : std_logic;
  signal ptp_i2c_wb_stb             : std_logic;
  signal ptp_i2c_wb_we              : std_logic;
  signal ptp_i2c_wb_adr             : i2c_slave_address_type;
  signal ptp_i2c_wb_write_data      : byte;
  signal ptp_i2c_wb_read_data       : byte;
  signal ptp_i2c_wb_ack             : std_logic;
  signal ptp_triggers               : trigger_source_type;
])

define([ptp_top_status_signals_], [dnl
  -- Chain status
  signal ptp_chain_initiator        : boolean;
  signal ptp_chain_terminator       : boolean;
])

define([ptp_top_start_signals_], [dnl
  signal avr_reset        : std_logic;
])

define([ptp_top_debug_signals_], [dnl
  signal debug_led_wb_cyc       : std_logic;
  signal debug_led_wb_stb       : std_logic;
  signal debug_led_wb_dat       : byte;
  signal debug_led_wb_ack       : std_logic;
])

define([ptp_top_sram_signals_], [dnl
  signal ptp_sram_wb_adr            : virtual8_address_type;
  signal ptp_sram_wb_read_data      : byte;
  signal ptp_sram_wb_write_data     : byte;
  signal ptp_sram_wb_we             : std_logic;
  signal ptp_sram_wb_stb            : std_logic;
  signal ptp_sram_wb_cyc            : std_logic;
  signal ptp_sram_wb_ack            : std_logic;
  signal ptp_sram_burst             : std_logic;
])

define([ptp_top_dmem_signals_], [dnl
  signal ptp_dmem_wb_adr            : virtual8_address_type;
  signal ptp_dmem_wb_read_data      : byte;
  signal ptp_dmem_wb_write_data     : byte;
  signal ptp_dmem_wb_we             : std_logic;
  signal ptp_dmem_wb_stb            : std_logic;
  signal ptp_dmem_wb_cyc            : std_logic;
  signal ptp_dmem_wb_ack            : std_logic;
  signal ptp_dmem_burst             : std_logic;
])

###############################################################################
# Top-level PTP instance

define([ptp_top_instance_], [dnl
  ptp : ptp_top
    generic map (
      DATA_WIDTH             => NETWORK_DATA_WIDTH,
      ENABLE_I2C             => PTP_I2C_ENABLE,
      ENABLE_TRIGGER         => PTP_TRIGGER_ENABLE
      )
    port map (
      -- Wishbone common signals
      wb_clk_i               => network_clock,
      wb_rst_i               => wb_rst_i,
      xmit_wbm_cyc_o         => ptp_route_xmit_wb_cyc,
      xmit_wbm_stb_o         => ptp_route_xmit_wb_stb,
      xmit_wbm_dat_o         => ptp_route_xmit_wb_dat,
      xmit_wbm_ack_i         => ptp_route_xmit_wb_ack,
      --xmit_debug_led_out  
      xmit_dest_id_out       => ptp_route_xmit_dest_id,
      xmit_opcode_out        => ptp_route_xmit_opcode,
      xmit_length_out        => ptp_route_xmit_length,
      recv_wbs_cyc_i         => ptp_route_recv_wb_cyc,
      recv_wbs_stb_i         => ptp_route_recv_wb_stb,
      recv_wbs_dat_i         => ptp_route_recv_wb_dat,
      recv_wbs_ack_o         => ptp_route_recv_wb_ack,
      --recv_debug_led_out
      recv_src_id_in         => ptp_route_recv_src_id,
      recv_dest_id_in        => ptp_route_recv_dest_id,
      recv_opcode_in         => ptp_route_recv_opcode,
      recv_length_in         => ptp_route_recv_length,
      -- Self ID
      self_id_out            => ptp_self_id,
      self_mac_byte_in       => self_mac_addr(47 downto 40),
      -- I2C ports
      i2c_wb_cyc_o           => ptp_i2c_wb_cyc,
      i2c_wb_stb_o           => ptp_i2c_wb_stb,
      i2c_wb_we_o            => ptp_i2c_wb_we,
      i2c_wb_adr_o           => ptp_i2c_wb_adr,
      i2c_wb_dat_o           => ptp_i2c_wb_write_data,
      i2c_wb_dat_i           => ptp_i2c_wb_read_data,
      i2c_wb_ack_i           => ptp_i2c_wb_ack,
      -- Status Ports
      chain_initiator_in     => ptp_chain_initiator,
      chain_terminator_in    => ptp_chain_terminator,
      pcp_halted_in          => pcp_halted,
      -- Debug Ports     
      led_wb_cyc_o           => debug_led_wb_cyc,
      led_wb_stb_o           => debug_led_wb_stb,
      led_wb_dat_o           => debug_led_wb_dat,
      led_wb_ack_i           => debug_led_wb_ack,
      -- Memory ports
      sram_wb_cyc_o          => ptp_sram_wb_cyc,
      sram_wb_stb_o          => ptp_sram_wb_stb,
      sram_wb_we_o           => ptp_sram_wb_we,
      sram_wb_adr_o          => ptp_sram_wb_adr,
      sram_wb_dat_o          => ptp_sram_wb_write_data,
      sram_wb_dat_i          => ptp_sram_wb_read_data,
      sram_wb_ack_i          => ptp_sram_wb_ack,
      sram_burst_out         => ptp_sram_burst,
      dmem_wb_cyc_o          => ptp_dmem_wb_cyc,
      dmem_wb_stb_o          => ptp_dmem_wb_stb,
      dmem_wb_we_o           => ptp_dmem_wb_we,
      dmem_wb_adr_o          => ptp_dmem_wb_adr,
      dmem_wb_dat_o          => ptp_dmem_wb_write_data,
      dmem_wb_dat_i          => ptp_dmem_wb_read_data,
      dmem_wb_ack_i          => ptp_dmem_wb_ack,
      dmem_burst_out         => ptp_dmem_burst,
      -- Start ports
--      avr_reset_out          => avr_reset,
      pcp_reset_out          => pcp_reset,
      triggers_in            => ptp_triggers,
      pcp_start_addr_out     => pcp_start_addr,
      debug_led_out          => ptp_top_debug_led
    );
])

###############################################################################
define([ptp_dma_router_signals_], [dnl
  -- Wishbone transmit interface to ptp_router
  signal ptp_dma_xmit_wb_cyc            : std_logic;
  signal ptp_dma_xmit_wb_stb            : std_logic;
  signal ptp_dma_xmit_wb_dat            : byte;
  signal ptp_dma_xmit_wb_ack            : std_logic;
  -- Wishbone receive interface to ptp_router
  signal ptp_dma_recv_wb_cyc            : std_logic;
  signal ptp_dma_recv_wb_stb            : std_logic;
  signal ptp_dma_recv_wb_dat            : byte;
  signal ptp_dma_recv_wb_ack            : std_logic;
])

define([ptp_dma_memory_signals_], [dnl
  -- Memory outputs to SRAM or sizer
  signal ptp_dma_sram_wb_cyc            : std_logic;
  signal ptp_dma_sram_wb_stb            : std_logic;
  signal ptp_dma_sram_wb_we             : std_logic;
  signal ptp_dma_sram_wb_adr            : virtual_address_type;
  signal ptp_dma_sram_wb_write_data     : virtual_data_type;
  signal ptp_dma_sram_wb_ack            : std_logic;
  signal ptp_dma_sram_burst             : std_logic;
])

define([ptp_dma_control_signals_], [dnl
  signal ptp_dma_xmit_sram_wb_stb       : std_logic;
  signal ptp_dma_xmit_sram_wb_ack       : std_logic;
  signal ptp_dma_xmit_sram_length       : ip_total_length;
  signal ptp_dma_recv_sram_wb_stb       : std_logic;
  signal ptp_dma_recv_sram_wb_ack       : std_logic;
  signal ptp_dma_recv_sram_length       : ip_total_length;
  signal ptp_dma_xmit_length            : ptp_length_type;
  signal ptp_dma_recv_length            : ptp_length_type;
  signal ptp_dma_xmit_sram_buffer_start : virtual_address_type;
  signal ptp_dma_recv_sram_buffer_start : virtual_address_type;
])

###############################################################################
# Top-level PCP router
define([ptp_router_instance_], [dnl
  router : ptp_router
    generic map (
      DATA_WIDTH         => NETWORK_DATA_WIDTH,
      ADDRESS_WIDTH      => PTP_BUFFER_ADDRESS_WIDTH,
      STABLE_COUNT       => DAISY_CHAIN_STABLE_COUNT,
      ABORT_TIMEOUT      => DAISY_CHAIN_ABORT_TIMEOUT,
      MAJOR_VERSION      => FIRMWARE_MAJOR_VERSION_NUMBER,
      MINOR_VERSION      => FIRMWARE_MINOR_VERSION_NUMBER
      )
    port map (
      -- Wishbone common signals
      wb_clk_i                        => network_clock,
      wb_rst_i                        => wb_rst_i,
      -- Transmit slave master interface from top-level PTP
      xmit_wbs_cyc_i                  => ptp_route_xmit_wb_cyc,
      xmit_wbs_stb_i                  => ptp_route_xmit_wb_stb,
      xmit_wbs_dat_i                  => ptp_route_xmit_wb_dat,
      xmit_wbs_ack_o                  => ptp_route_xmit_wb_ack,
      xmit_src_id_in                  => ptp_self_id,
      xmit_dest_id_in                 => ptp_route_xmit_dest_id,
      xmit_opcode_in                  => ptp_route_xmit_opcode,
      xmit_length_in                  => ptp_route_xmit_length,
      xmit_debug_led_out              => ptp_route_xmit_debug_led,
      -- Receive Wishbone master interface to top-level PTP
      recv_wbm_cyc_o                  => ptp_route_recv_wb_cyc,
      recv_wbm_stb_o                  => ptp_route_recv_wb_stb,
      recv_wbm_dat_o                  => ptp_route_recv_wb_dat,
      recv_wbm_ack_i                  => ptp_route_recv_wb_ack,
      recv_src_id_out                 => ptp_route_recv_src_id,
      recv_dest_id_out                => ptp_route_recv_dest_id,
      recv_opcode_out                 => ptp_route_recv_opcode,
      recv_length_out                 => ptp_route_recv_length,
      recv_debug_led_out              => ptp_route_recv_debug_led,
      -- Receive slave interface from AVR
      avr_recv_wbs_cyc_i              => ptp_dma_xmit_wb_cyc,
      avr_recv_wbs_stb_i              => ptp_dma_xmit_wb_stb,
      avr_recv_wbs_dat_i              => ptp_dma_xmit_wb_dat,
      avr_recv_wbs_ack_o              => ptp_dma_xmit_wb_ack,
      -- Transmit master inteface from AVR
      avr_xmit_wbm_cyc_o              => ptp_dma_recv_wb_cyc,
      avr_xmit_wbm_stb_o              => ptp_dma_recv_wb_stb,
      avr_xmit_wbm_dat_o              => ptp_dma_recv_wb_dat,
      avr_xmit_wbm_ack_i              => ptp_dma_recv_wb_ack,
      -- Transmit Wishbone master interface to UDP
      udp_xmit_wbm_cyc_o              => ptp_udp_xmit_wb_cyc,
      udp_xmit_wbm_stb_o              => ptp_udp_xmit_wb_stb,
      udp_xmit_wbm_dat_o              => ptp_udp_xmit_wb_dat,
      udp_xmit_wbm_ack_i              => ptp_udp_xmit_wb_ack,
      udp_xmit_dest_ip_addr_out       => ptp_udp_xmit_dest_ip_addr,
      udp_xmit_dest_port_out          => ptp_udp_xmit_dest_port,
      udp_xmit_length_out             => ptp_udp_xmit_length,
      udp_xmit_dont_fragment_out      => ptp_udp_xmit_dont_fragment,
      -- Receive Wishbone slave interface from UDP
      udp_recv_wbs_cyc_i              => ptp_udp_recv_wb_cyc,
      udp_recv_wbs_stb_i              => udp_recv_wb_stb,
      udp_recv_wbs_dat_i              => udp_recv_wb_dat,
      udp_recv_wbs_ack_o              => ptp_udp_recv_wb_ack,
      udp_recv_src_ip_addr_in         => udp_recv_src_ip_addr,
      udp_recv_src_port_in            => udp_recv_src_port,
      udp_recv_dest_port_in           => udp_recv_dest_port,
      udp_recv_length_in              => udp_recv_length,
      -- Physical daisy chain pins to master
      daisy_master_xmit_stb_ack       => daisy_transmit(0),
      daisy_master_xmit_dat_cyc       => daisy_transmit(1),
      daisy_master_recv_stb_ack       => daisy_receive(0),
      daisy_master_recv_dat_cyc       => daisy_receive(1),
      -- Physical daisy chain pins to slave
      daisy_slave_xmit_stb_ack        => daisy_transmit(2),
      daisy_slave_xmit_dat_cyc        => daisy_transmit(3),
      daisy_slave_recv_stb_ack        => daisy_receive(2),
      daisy_slave_recv_dat_cyc        => daisy_receive(3),
      -- Debugging LEDs outputs
      link_master_xmit_debug_led_out  => ptp_link_master_xmit_debug_led,
      link_master_recv_debug_led_out  => ptp_link_master_recv_debug_led,
      link_slave_xmit_debug_led_out   => ptp_link_slave_xmit_debug_led,
      link_slave_recv_debug_led_out   => ptp_link_slave_recv_debug_led,
      link_state_debug_led_out        => ptp_link_state_debug_led,
      link_recv_arbiter_debug_led_out => ptp_link_recv_arbiter_debug_led,
      link_debug_led_out              => ptp_link_debug_led,
      route_debug_led_out             => ptp_route_debug_led,
      route_buffer_debug_led_out      => ptp_route_buffer_debug_led,
      debug_led_out                   => ptp_debug_led,
      self_id_in                      => ptp_self_id,
      chain_initiator                 => ptp_chain_initiator,
      chain_terminator                => ptp_chain_terminator
      );

   ptp_chain_initiator   <= (network_detected = '1');
   ptp_udp_xmit_src_port <= ptp_server_port;
])

###############################################################################
# Chain termination detector
define([ptp_terminate_instance_], [dnl

  terminator_detector : process(wb_rst_i, network_clock)

    type terminate_state_type is (
      idle,
      detected
      );

    variable state : terminate_state_type;

    variable stable_count     : natural range 0 to
                                        TERMINATOR_DETECT_STABLE_COUNT+1;

  begin

    if (wb_rst_i = '1') then
      ptp_chain_terminator <= false;
      stable_count         := 0;
      state                := idle;

    elsif (rising_edge(network_clock)) then
      case (state) is
        when (idle) =>
          if ((daisy_receive(2) = '1') and (daisy_receive(3) = '1')) then
            if (stable_count >= TERMINATOR_DETECT_STABLE_COUNT-1) then
              ptp_chain_terminator <= true;
              state := detected;
            else
              stable_count := stable_count + 1;
            end if;
          else
            stable_count := 0;
            if (dhcp_status_load = '1') then
              state := detected;
            end if;
          end if;
        when others =>
          -- detected; get stuck here
          null;
      end case;
    end if;

  end process;
])

###############################################################################
# PTP signals
define([ptp_signals_], [dnl
ptp_top_signals_
ptp_top_status_signals_
ptp_top_debug_signals_
ptp_top_sram_signals_
ptp_top_dmem_signals_
ptp_router_signals_
ptp_debug_led_signals_
ptp_top_router_signals_
ptp_dma_router_signals_
ptp_dma_memory_signals_
ptp_dma_control_signals_

ptp_top_component_
ptp_router_component_
])

###############################################################################
# PTP instances
define([ptp_instances_], [dnl
ptp_top_instance_
ptp_router_instance_
ptp_terminate_instance_

  -- Disable AVR routing
  ptp_dma_xmit_wb_cyc <= '0';
  ptp_dma_xmit_wb_stb <= '0';
  ptp_dma_xmit_wb_dat <= (others => '0');
--  ptp_dma_xmit_wb_ack,
-- ptp_dma_recv_wb_cyc,
  ptp_dma_recv_wb_ack <= ptp_dma_recv_wb_stb;

  ptp_triggers(7 downto 0) <= lvds_receive;
  ptp_triggers(8) <= '0';
])

# Renable output for processed file
divert(0)dnl