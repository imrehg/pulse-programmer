dnl-*-VHDL-*-
-- Pulse Transfer Protocol memory reading/writing module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

ptp_unit_([ptp_memory], dnl
  [dnl -- Generics ------------------------------------------------------------
],[dnl -- Ports ---------------------------------------------------------------
   sram_wb_cyc_o        : out std_logic;
   sram_wb_stb_o        : out std_logic;
   sram_wb_we_o         : out std_logic;
   sram_wb_adr_o        : out virtual8_address_type;
   sram_wb_dat_o        : out byte;
   sram_wb_dat_i        : in  byte;
   sram_wb_ack_i        : in  std_logic;
   sram_burst_out       : out std_logic;
   dmem_wb_cyc_o        : out std_logic;
   dmem_wb_stb_o        : out std_logic;
   dmem_wb_we_o         : out std_logic;
   dmem_wb_adr_o        : out virtual8_address_type;
   dmem_wb_dat_o        : out byte;
   dmem_wb_dat_i        : in  byte;
   dmem_wb_ack_i        : in  std_logic;
   dmem_burst_out       : out std_logic;
],[dnl -- Declarations --------------------------------------------------------
   signal subopcode      : ptp_opcode_type;
   signal length_counter : ptp_length_type;
],[dnl -- Additional State Names ----------------------------------------------
   extract_subopcode,
   extract_prefix,
   extract_address_high_byte,
   extract_address_low_byte,
   extract_suboperands,
   get_length_high_byte,
   get_length_low_byte,
   memory_sram_write_writing,
   memory_sram_write_reading,
   memory_sram_read_transmitting,
   memory_sram_read_receiving,
   memory_dmem_write_writing,
   memory_dmem_write_reading,
   memory_dmem_read_transmitting,
   memory_dmem_read_receiving,
   memory_clear,
   memory_table,
   wait_ack,
],[dnl -- Reset Behaviour -----------------------------------------------------
   sram_wb_cyc_o  <= '0';
   sram_wb_stb_o  <= '0';
   sram_wb_we_o   <= '0';
   sram_burst_out <= '0';
   sram_wb_adr_o  <= (others => '0');
   dmem_wb_cyc_o  <= '0';
   dmem_wb_stb_o  <= '0';
   dmem_wb_we_o   <= '0';
   dmem_burst_out <= '0';
   dmem_wb_adr_o  <= (others => '0');
],[dnl -- Cyc Behaviour -------------------------------------------------------
            xmit_dest_id_out <= recv_src_id_in;
            state            := extract_subopcode;
            ack_enable     <= '1';
],[dnl -- Additional State Behaviour ------------------------------------------
        when extract_subopcode =>
          if (recv_wbs_stb_i = '1') then
            subopcode <= recv_wbs_dat_i;
            state := extract_prefix;
          end if;
        -----------------------------------------------------------------------
        when extract_prefix =>
          if (recv_wbs_stb_i = '1') then
            sram_wb_adr_o(18 downto 16) <= recv_wbs_dat_i(5 to 7);
            dmem_wb_adr_o(18 downto 16) <= recv_wbs_dat_i(5 to 7);
            state := extract_address_high_byte;
          end if;
          debug_led_out <= recv_wbs_dat_i;
        -----------------------------------------------------------------------
        when extract_address_high_byte =>
          if (recv_wbs_stb_i = '1') then
            sram_wb_adr_o(15 downto 8) <= recv_wbs_dat_i;
            dmem_wb_adr_o(15 downto 8) <= recv_wbs_dat_i;
            state := extract_address_low_byte;
          end if;
          debug_led_out <= recv_wbs_dat_i;
        -----------------------------------------------------------------------
        when extract_address_low_byte =>
          if (recv_wbs_stb_i = '1') then
            sram_wb_adr_o(7 downto 0) <= recv_wbs_dat_i;
            dmem_wb_adr_o(7 downto 0) <= recv_wbs_dat_i;
            state := extract_suboperands;
            -- always stall acks here b/c not all subopcodes need suboperands
            ack_enable     <= '0';
          end if;
          debug_led_out <= recv_wbs_dat_i;
        -----------------------------------------------------------------------
        when extract_suboperands =>
          if (recv_wbs_stb_i = '1') then
            sram_wb_cyc_o <= '1';
            sram_burst_out <= '1';
            -- the first payload byte of reply is always same subopcode
            xmit_wbm_dat_o <= subopcode;
            case (subopcode) is
              when PTP_MEMORY_SRAM_WRITE_SUBOPCODE =>
                ack_enable     <= '1';
                sram_wb_we_o   <= '1';
                sram_wb_stb_o  <= '1';
                sram_wb_dat_o  <= recv_wbs_dat_i;
                state          := memory_sram_write_writing;
              when PTP_MEMORY_SRAM_READ_SUBOPCODE =>
                ack_enable     <= '1';
                state          := get_length_high_byte;
              when PTP_MEMORY_CLEAR_SUBOPCODE =>
                sram_wb_we_o   <= '1';
                state          := memory_clear;
              when PTP_MEMORY_TABLE_SUBOPCODE =>
                state          := memory_table;
              when PTP_MEMORY_DMEM_WRITE_SUBOPCODE =>
                ack_enable     <= '1';
                sram_wb_we_o   <= '1';
                sram_wb_stb_o  <= '1';
                sram_wb_dat_o  <= recv_wbs_dat_i;
                state          := memory_dmem_write_writing;
              when PTP_MEMORY_DMEM_READ_SUBOPCODE =>
                ack_enable     <= '1';
                state          := get_length_high_byte;
              when others =>
                -- invalid opcode; don't just let it get stuck here
               ack_enable <= '1';
               state := done_state;
            end case;
          end if;
          debug_led_out <= recv_wbs_dat_i;
          ---------------------------------------------------------------------
          when get_length_high_byte =>
            if (recv_wbs_stb_i = '1') then
              length_counter(0 to 7) <= unsigned(recv_wbs_dat_i);
              state := get_length_low_byte;
            end if;
          debug_led_out <= recv_wbs_dat_i;
          ---------------------------------------------------------------------
          when get_length_low_byte =>
            if (recv_wbs_stb_i = '1') then
              length_counter(8 to 15) <= unsigned(recv_wbs_dat_i);
              xmit_length_out <= (length_counter(0 to 7) & unsigned(recv_wbs_dat_i)) + 1;
              case (subopcode) is
                when PTP_MEMORY_SRAM_READ_SUBOPCODE =>
                  state := memory_sram_read_transmitting;
                when PTP_MEMORY_DMEM_READ_SUBOPCODE =>
                  state := memory_dmem_read_transmitting;
                when others => null;
              end case;
              xmit_wbm_cyc_o  <= '1';
              -- first strobe is for reply suboperand
              xmit_wbm_stb_o  <= '1';
            end if;
          debug_led_out <= recv_wbs_dat_i;
          ---------------------------------------------------------------------
ptp_memory_states_(sram)
ptp_memory_states_(dmem)
        -----------------------------------------------------------------------
        when memory_clear =>
        -----------------------------------------------------------------------
        when memory_table =>
        -----------------------------------------------------------------------
        when wait_ack =>
          -- lower here, b/c we won't latch data for next packet until
          -- after cyc is raised in a later cycle
          ack_enable <= '0';            
          if (xmit_wbm_ack_i = '1') then
            xmit_wbm_stb_o <= '0';
            state := done_state;
          end if;
],[dnl -- Async Assignments ---------------------------------------------------
  xmit_opcode_out <= PTP_MEMORY_REPLY_OPCODE;
])
