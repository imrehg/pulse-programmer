-- SignalTap test for controlling debugging LEDs through incoming PTP packets.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

sequencer_unit_([ptp_route_test],dnl
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

ptp_terminate_instance_

  ptp_clock <= network_clock;
  dhcp_status_load <= '1';

  ptp_route_xmit_opcode <= X"A5";
  ptp_route_xmit_dest_id <= X"01";
  ptp_route_xmit_length  <= X"0001";

  process(wb_rst_i, ptp_clock)

    type state_type is (
      idle,
      receive,
      receive_ack,
      receiving_led,
      receiving_done,
      transmit,
      transmit_ack,
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
              state := receive;
            end if;
          elsif (switch(2) = '1') then
            -- initiator/transmitter case
            ptp_route_xmit_wb_cyc <= '1';
            data_reg := switch;
            state := transmit;
          end if;
-------------------------------------------------------------------------------
       when receive =>
         if (ptp_route_recv_wb_cyc = '0') then
           debug_led_wb_dat <= data_reg;
           debug_led_wb_cyc <= '1';
           debug_led_wb_stb <= '1';
           state := receiving_led;
         elsif (ptp_route_recv_wb_stb = '1') then
           -- shift in LSB first (same direction as shifting out)
           data_reg := ptp_route_recv_wb_dat;
           ptp_route_recv_wb_ack <= '1';
           state := receive_ack;
         end if;
-------------------------------------------------------------------------------
       when receive_ack =>
         ptp_route_recv_wb_ack <= '0';
         state := receive;
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
       when transmit =>
         ptp_route_xmit_wb_stb <= '1';
         ptp_route_xmit_wb_dat <= switch;
         state := transmit_ack;
-------------------------------------------------------------------------------
       when transmit_ack =>
         if (ptp_route_xmit_wb_ack = '1') then
           ptp_route_xmit_wb_stb <= '0';
           ptp_route_xmit_wb_cyc <= '0';
           state := transmitting_led;
           debug_led_wb_cyc <= '1';
           debug_led_wb_stb <= '1';
           debug_led_wb_dat <= switch;
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

  daisy_router : ptp_daisy_router
    generic map (
      DATA_WIDTH           => NETWORK_DATA_WIDTH,
      ADDRESS_WIDTH        => PTP_BUFFER_ADDRESS_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i             => ptp_clock,
      wb_rst_i             => wb_rst_i,
      -- Wishbone slave transmit interface from top-level PTP
      xmit_wbs_cyc_i       => ptp_route_xmit_wb_cyc,
      xmit_wbs_stb_i       => ptp_route_xmit_wb_stb,
      xmit_wbs_dat_i       => ptp_route_xmit_wb_dat,
      xmit_wbs_ack_o       => ptp_route_xmit_wb_ack,
      xmit_dest_id_in      => ptp_route_xmit_dest_id,
      xmit_opcode_in       => ptp_route_xmit_opcode,
      xmit_length_in       => ptp_route_xmit_length,
      -- Wishbone master transmit interface to daisy-chain link layer or UDP
      xmit_wbm_cyc_o       => ptp_link_xmit_wb_cyc,
      xmit_wbm_stb_o       => ptp_link_xmit_wb_stb,
      xmit_wbm_dat_o       => ptp_link_xmit_wb_dat,
      xmit_wbm_ack_i       => ptp_link_xmit_wb_ack,
      xmit_interface_out   => ptp_link_xmit_interface,
      -- Wishbone master receive interface to top-level PTP
      recv_wbm_cyc_o       => ptp_route_recv_wb_cyc,
      recv_wbm_stb_o       => ptp_route_recv_wb_stb,
      recv_wbm_dat_o       => ptp_route_recv_wb_dat,
      recv_wbm_ack_i       => ptp_route_recv_wb_ack,
      recv_src_id_out      => ptp_route_recv_src_id,
      recv_dest_id_out     => ptp_route_recv_dest_id,
      recv_opcode_out      => ptp_route_recv_opcode,
      recv_length_out      => ptp_route_recv_length,
      -- Wishbone slave receive interface to daisy-chain link layer or UDP
      recv_wbs_cyc_i       => ptp_link_recv_wb_cyc,
      recv_wbs_stb_i       => ptp_link_recv_wb_stb,
      recv_wbs_dat_i       => ptp_link_recv_wb_dat,
      recv_wbs_ack_o       => ptp_link_recv_wb_ack,
      -- ID of this programmer
      self_id_in           => PTP_AUTO_SELF_ID
      );

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
      xmit_wbs_cyc_i             => ptp_link_xmit_wb_cyc,
      xmit_wbs_stb_i             => ptp_link_xmit_wb_stb,
      xmit_wbs_dat_i             => ptp_link_xmit_wb_dat,
      xmit_wbs_ack_o             => ptp_link_xmit_wb_ack,
      xmit_interface_in          => to_slave,
      -- Daisy-chain Wishbone receive interface
      recv_wbm_cyc_o             => ptp_link_recv_wb_cyc,
      recv_wbm_stb_o             => ptp_link_recv_wb_stb,
      recv_wbm_dat_o             => ptp_link_recv_wb_dat,
      recv_wbm_ack_i             => ptp_link_recv_wb_ack,
      -- Physical daisy chain pins to master
      master_xmit_stb_ack        => daisy_transmit(0),
      master_xmit_dat_cyc        => daisy_transmit(1),
      master_recv_stb_ack        => daisy_receive(0),
      master_recv_dat_cyc        => daisy_receive(1),
      -- Physical daisy chain pins to slave
      slave_xmit_stb_ack         => daisy_transmit(2),
      slave_xmit_dat_cyc         => daisy_transmit(3),
      slave_recv_stb_ack         => daisy_receive(2),
      slave_recv_dat_cyc         => daisy_receive(3)
      );

])