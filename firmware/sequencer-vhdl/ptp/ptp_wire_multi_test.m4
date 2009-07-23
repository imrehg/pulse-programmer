-- SignalTap test that wire protocol for multiple bytes is correct.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

sequencer_unit_([ptp_wire_multi_test],dnl
  [dnl -- Declarations -------------------------------------------------------
    signal ptp_clock : std_logic;
ptp_daisy_link_component_
],[dnl -- Body ----------------------------------------------------------------
peripheral_instances_
sram_instance_
i2c_instances_
network_clockdiv_instance_

ptp_terminate_instance_

  ptp_clock <= network_clock;
  dhcp_status_load <= '1';

  process(wb_rst_i, ptp_clock)

    type state_type is (
      idle,
      receive_bit,
      receive_bit_ack,
      receiving_led,
      receiving_done,
      transmit_bit,
      transmit_bit_ack,
      transmit_bit_ack_fall,
      transmitting_led,
      transmitting_done
      );

    variable state : state_type;
    variable bit_count : natural range 0 to 10;
    variable data_reg : std_logic_vector(0 to 7);

  begin
    if (wb_rst_i = '1') then
      ptp_route_xmit_wb_cyc <= '0';
      ptp_route_xmit_wb_stb <= '0';
      ptp_route_xmit_wb_dat <= (others => '0');
      ptp_route_recv_wb_ack <= '0';
      debug_led_wb_cyc      <= '0';
      debug_led_wb_stb      <= '0';
      debug_led_wb_dat      <= (others => '0');
      state                 := idle;
    elsif (rising_edge(ptp_clock)) then
      case (state) is
-------------------------------------------------------------------------------
        when idle =>
          bit_count := 0;
          -- terminator/receiver case
          if (switch(1) = '0') then
            if (ptp_route_recv_wb_cyc = '1') then
              state := receive_bit;
            end if;
          elsif (switch(2) = '1') then
            -- initiator/transmitter case
            ptp_route_xmit_wb_cyc <= '1';
            data_reg := switch;
            state := transmit_bit;
          end if;
-------------------------------------------------------------------------------
       when receive_bit =>
         if (ptp_route_recv_wb_stb = '1') then
           -- shift in LSB first (same direction as shifting out)
           data_reg := ptp_route_recv_wb_dat(7) & data_reg(0 to 6);
           ptp_route_recv_wb_ack <= '1';
           state := receive_bit_ack;
         end if;
-------------------------------------------------------------------------------
       when receive_bit_ack =>
         ptp_route_recv_wb_ack <= '0';
         if ((bit_count >= 7) or (ptp_route_recv_wb_cyc = '0')) then
           debug_led_wb_dat <= data_reg;
           debug_led_wb_cyc <= '1';
           debug_led_wb_stb <= '1';
           state := receiving_led;
         else
           bit_count := bit_count + 1;
           state := receive_bit;
         end if;
-------------------------------------------------------------------------------
       when receiving_led =>
         if (debug_led_wb_ack = '1') then
           debug_led_wb_cyc <= '0';
           debug_led_wb_stb <= '0';
           state := receiving_done;
         end if;
-------------------------------------------------------------------------------
       when receiving_done =>
         if ((ptp_route_recv_wb_cyc = '0') and (debug_led_wb_ack = '0')) then
           ptp_route_recv_wb_ack <= '0';
           state := idle;
         end if;
-------------------------------------------------------------------------------
       when transmit_bit =>
         ptp_route_xmit_wb_stb <= '1';
         ptp_route_xmit_wb_dat <= B"0000000" & data_reg(7);
         state := transmit_bit_ack;
-------------------------------------------------------------------------------
       when transmit_bit_ack =>
         if (ptp_route_xmit_wb_ack = '1') then
           ptp_route_xmit_wb_stb <= '0';
           if (bit_count >= 7) then
             ptp_route_xmit_wb_cyc <= '0';
             state := transmitting_led;
             debug_led_wb_cyc <= '1';
             debug_led_wb_stb <= '1';
             debug_led_wb_dat <= switch;
           else
             bit_count := bit_count + 1;
             data_reg := B"0" & data_reg(0 to 6);
             state := transmit_bit_ack_fall;
           end if;
        end if;
-------------------------------------------------------------------------------
       when transmit_bit_ack_fall =>
         if (ptp_route_xmit_wb_ack = '0') then
           state := transmit_bit;
         end if;
-------------------------------------------------------------------------------
       when transmitting_led =>
         if (debug_led_wb_ack = '1') then
           debug_led_wb_cyc <= '0';
           debug_led_wb_stb <= '0';
           state := transmitting_done;
         end if;
-------------------------------------------------------------------------------
       when transmitting_done =>
         if ((switch(2) = '0') and (ptp_route_xmit_wb_ack = '0') and
             (debug_led_wb_ack = '0')) then
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