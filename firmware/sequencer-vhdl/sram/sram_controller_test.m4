sequencer_unit_([sram_controller_test],dnl
  [dnl -- Declarations -------------------------------------------------------
],[dnl -- Body ----------------------------------------------------------------
reset_instance_
sram_instances_
network_clock_instance_
tcp_dma_instance_

  pre_sizer16_wb_cyc <= '0';

  process(network_clock, wb_rst_i)

    type state_type is (
      idle,
      writing,
      writing_done,
      reading,
      receive_strobed,
      receive_acked,
      reading_done,
      done_state
      );

    variable state : state_type;
    constant MAX_BYTE_COUNT : positive := 64; --(2**16)-1;
    variable byte_count : unsigned(15 downto 0);

  begin

    if (wb_rst_i = '1') then
      state := idle;
      tcp_recv_wb_cyc <= '0';
      tcp_recv_wb_stb <= '0';
      byte_count := (others => '0');
      tcp_xmit_sram_buffer_start <= (others => '0');
      tcp_xmit_sram_length <= to_unsigned(MAX_BYTE_COUNT, 16);
      tcp_recv_length <= to_unsigned(MAX_BYTE_COUNT, 16);
    elsif (rising_edge(network_clock)) then
      case (state) is
        when idle =>
          if (switch(2) = '1') then
            byte_count := byte_count + 1;
            tcp_recv_wb_cyc <= '1';
            tcp_recv_wb_stb <= '1';
            tcp_recv_wb_dat <= X"00";
--            tcp_xmit_burst <= '1';
            state := writing;
          else
            byte_count := (others => '0');
          end if;
        when writing =>
          if (tcp_recv_wb_ack = '1') then
            tcp_recv_wb_dat <= std_logic_vector(byte_count(7 downto 0));
            byte_count := byte_count + 1;
            if (byte_count >= MAX_BYTE_COUNT-1) then
              tcp_recv_wb_cyc <= '0';
              tcp_recv_wb_stb <= '0';
--              tcp_xmit_wb_we <= '0';
--              tcp_xmit_burst <= '0';
              state := writing_done;
            end if;
          end if;
        when writing_done =>
          if (tcp_recv_wb_ack = '0') then
            tcp_xmit_sram_wb_stb <= '1';
--            tcp_xmit_wb_cyc <= '1';
--            tcp_xmit_wb_stb <= '1';
--            tcp_xmit_burst <= '1';
            byte_count := (others => '0');
            state := reading;
          end if;
        when reading =>
          if (tcp_recv_sram_wb_stb = '1') then
            tcp_recv_sram_wb_ack <= '1';
            state := receive_strobed;
          end if;
        when receive_strobed =>
          if (tcp_recv_sram_wb_stb = '0') then
            tcp_recv_sram_wb_ack <= '0';
            state := receive_acked;
          end if;
        when receive_acked =>
          if (tcp_xmit_sram_wb_ack = '1') then
            tcp_xmit_sram_wb_stb <= '0';
--          byte_count := byte_count + 1;
--          if (byte_count >= MAX_BYTE_COUNT-1) then
--            tcp_xmit_wb_cyc <= '0';
--            tcp_xmit_wb_stb <= '0';
--            tcp_xmit_burst <= '0';
            state := done_state;
          end if;
        when done_state =>
          if (tcp_xmit_sram_wb_ack = '0') then
            state := idle;
          end if;
        when others =>
          -- get stuck here
          null;
      end case;

      tcp_xmit_wb_ack <= tcp_xmit_wb_stb;

    end if; -- rising_edge(network-clock)

  end process;

])