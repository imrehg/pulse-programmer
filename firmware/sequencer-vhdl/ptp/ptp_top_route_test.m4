sequencer_unit_([ptp_top_route_test],dnl
  [dnl -- Declarations -------------------------------------------------------
    signal ptp_clock : std_logic;
ptp_daisy_link_component_
ptp_daisy_router_component_
      signal ptp_link_xmit_wb_cyc : std_logic;
      signal ptp_link_xmit_wb_stb : std_logic;
      signal ptp_link_xmit_wb_dat : nbyte;
      signal ptp_link_xmit_wb_ack : std_logic;
      signal ptp_link_xmit_interface : ptp_interface_type;
      signal ptp_link_recv_wb_cyc : std_logic;
      signal ptp_link_recv_wb_stb : std_logic;
      signal ptp_link_recv_wb_dat : nbyte;
      signal ptp_link_recv_wb_ack : std_logic;
],[dnl -- Body ----------------------------------------------------------------
peripheral_instances_
sram_instance_
i2c_instances_
network_clockdiv_instance_
network_instance_
udp_xmit_arbiter_instance_
dhcp_instance_
ptp_instances_

    sequencer_debug_led(7) <= network_detected;
    sequencer_debug_led(6) <= ptp_chain_terminator;

])