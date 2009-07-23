-- SignalTap test that wire protocol for a single byte is correct.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

sequencer_unit_([ptp_wire_test],dnl
  [dnl -- Declarations -------------------------------------------------------
    signal ptp_clock : std_logic;
ptp_daisy_link_component_
],[dnl -- Body ----------------------------------------------------------------
peripheral_instances_
sram_instance_
i2c_instances_
network_clockdiv_instance_

  ptp_clock <= network_clock;
  dhcp_status_load <= '1';

  process(wb_rst_i, ptp_clock)

    type state_type is (
      idle,
      receiving,
      receiving_led,
      receiving_done,
      transmitting,
      transmitting_led,
      transmitting_done
      );

    variable state : state_type;

  begin
    if (wb_rst_i = '1') then
      ptp_route_xmit_wb_cyc <= '0';
      ptp_route_xmit_wb_stb <= '0';
      ptp_route_xmit_wb_dat <= (others => '0');
      debug_led_wb_cyc      <= '0';
      debug_led_wb_stb      <= '0';
      debug_led_wb_dat      <= (others => '0');
      state                 := idle;
    elsif (rising_edge(ptp_clock)) then
      case (state) is
        when idle =>
          -- terminator/receiver case
          if (switch(1) = '0') then
            if (ptp_route_recv_wb_cyc = '1') then
              state := receiving;
            end if;
          elsif (switch(2) = '1') then
            -- initiator/transmitter case
            ptp_route_xmit_wb_cyc <= '1';
            ptp_route_xmit_wb_stb <= '1';
            ptp_route_xmit_wb_dat <= switch;
            state := transmitting;
          end if;
       when receiving =>
         if (ptp_route_recv_wb_stb = '1') then
           ptp_route_recv_wb_ack <= '1';
           debug_led_wb_dat <= ptp_route_recv_wb_dat;
           debug_led_wb_cyc <= '1';
           debug_led_wb_stb <= '1';
           state := receiving_led;
         end if;
       when receiving_led =>
         if (debug_led_wb_ack = '1') then
           debug_led_wb_cyc <= '0';
           debug_led_wb_stb <= '0';
           state := receiving_done;
         end if;
       when receiving_done =>
         if (ptp_route_recv_wb_cyc = '0') then
           ptp_route_recv_wb_ack <= '0';
           state := idle;
         end if;
       when transmitting =>
         if (ptp_route_xmit_wb_ack = '1') then
           ptp_route_xmit_wb_cyc <= '0';
           ptp_route_xmit_wb_stb <= '0';
           state := transmitting_led;
           debug_led_wb_cyc <= '1';
           debug_led_wb_stb <= '1';
           debug_led_wb_dat <= ptp_route_xmit_wb_dat;
         end if;
       when transmitting_led =>
         if (debug_led_wb_ack = '1') then
           debug_led_wb_cyc <= '0';
           debug_led_wb_stb <= '0';
           state := transmitting_done;
         end if;
       when transmitting_done =>
         if (switch(2) = '0') then
           state := idle;
         end if;
       when others =>
         state := idle;
     end case;
    end if;

  end process;

  daisy_link : ptp_daisy_link
    generic map (
      DATA_WIDTH                 => NETWORK_DATA_WIDTH,
      STABLE_COUNT               => DAISY_CHAIN_STABLE_COUNT,
      ABORT_TIMEOUT              => DAISY_CHAIN_ABORT_TIMEOUT
      )
    port map (
      -- Wishbone common signals
      wb_clk_i                   => ptp_clock,
      wb_rst_i                   => wb_rst_i,
     -- Daisy-chain Wishbone transmit interface
      xmit_wbs_cyc_i             => ptp_route_xmit_wb_cyc,
      xmit_wbs_stb_i             => ptp_route_xmit_wb_stb,
      xmit_wbs_dat_i             => ptp_route_xmit_wb_dat,
      xmit_wbs_ack_o             => ptp_route_xmit_wb_ack,
      xmit_interface_in          => to_slave,
      -- Daisy-chain Wishbone receive interface
      recv_wbm_cyc_o             => ptp_route_recv_wb_cyc,
      recv_wbm_stb_o             => ptp_route_recv_wb_stb,
      recv_wbm_dat_o             => ptp_route_recv_wb_dat,
      recv_wbm_ack_i             => ptp_route_recv_wb_ack,
      -- Physical daisy chain pins to master
      master_xmit_stb_ack        => daisy_transmit(0),
      master_xmit_dat_cyc        => daisy_transmit(1),
      master_recv_stb_ack        => daisy_receive(0),
      master_recv_dat_cyc        => daisy_receive(1),
      -- Physical daisy chain pins to slave
      slave_xmit_stb_ack         => daisy_transmit(2),
      slave_xmit_dat_cyc         => daisy_transmit(3),
      slave_recv_stb_ack         => daisy_receive(2),
      slave_recv_dat_cyc         => daisy_receive(3),
      debug_led_out              => ptp_link_debug_led,
      master_xmit_debug_led_out  => ptp_link_master_xmit_debug_led,
      master_recv_debug_led_out  => ptp_link_master_recv_debug_led,
      slave_xmit_debug_led_out   => ptp_link_slave_xmit_debug_led,
      slave_recv_debug_led_out   => ptp_link_slave_recv_debug_led,
      recv_arbiter_debug_led_out => ptp_link_recv_arbiter_debug_led,
      state_debug_led_out        => ptp_link_state_debug_led
      );

])