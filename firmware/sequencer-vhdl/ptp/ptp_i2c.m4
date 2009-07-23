dnl-*-VHDL-*-
-- Pulse Transfer Protocol I2C reading/writing module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

ptp_unit_([ptp_i2c], dnl
  [dnl -- Generics ------------------------------------------------------------
],[dnl -- Ports ---------------------------------------------------------------
   i2c_wb_cyc_o           : out    std_logic;
   i2c_wb_stb_o           : out    std_logic;
   i2c_wb_we_o            : out    std_logic;
   i2c_wb_adr_o           : out    i2c_slave_address_type;
   i2c_wb_dat_o           : out    byte;
   i2c_wb_dat_i           : in     byte;
   i2c_wb_ack_i           : in     std_logic;
],[dnl -- Declarations --------------------------------------------------------
   signal read_length : ptp_length_type;
   signal slave_addr  : i2c_slave_address_type;
],[dnl -- Additional State Names ----------------------------------------------
   extract_address,
   extract_read_length_high_byte,
   extract_read_length_low_byte,
   writing_read,
   writing_write,
   writing_stall,
   test_write,
   reading_load,
   reading_write,
   reading_read,
],[dnl -- Reset Behaviour -----------------------------------------------------
   i2c_wb_cyc_o <= '0';
   i2c_wb_stb_o <= '0';
   i2c_wb_we_o  <= '0';
],[dnl -- Cyc Behaviour -------------------------------------------------------
    xmit_dest_id_out <= recv_src_id_in;
    state := extract_address;
    ack_enable <= '1';
],[dnl -- Additional State Behaviour ------------------------------------------
        when extract_address =>
          if (recv_wbs_stb_i = '1') then
            slave_addr <= recv_wbs_dat_i(1 to 7);
            state := extract_read_length_high_byte;
          end if;
-------------------------------------------------------------------------------
        when extract_read_length_high_byte =>
          if (recv_wbs_stb_i = '1') then
            read_length(0 to 7) <= unsigned(recv_wbs_dat_i);
            state := extract_read_length_low_byte;
          end if;
-------------------------------------------------------------------------------
        when extract_read_length_low_byte =>
          if (recv_wbs_stb_i = '1') then
            read_length(8 to 15) <= unsigned(recv_wbs_dat_i);
            state := test_write;
            -- lower b/c we don't know whether our master wants to write or not
            ack_enable <= '0';
          end if;
-------------------------------------------------------------------------------
        when test_write =>
          if (recv_wbs_cyc_i = '1') then
            -- if there is more data, we assume it is for writing
            i2c_wb_cyc_o <= '1';
            i2c_wb_we_o <= '1';
            state := writing_read;
          else
            -- otherwise, go straight to reading
            state := reading_load;
          end if;
-------------------------------------------------------------------------------
        when writing_read =>
          if (recv_wbs_cyc_i = '0') then
            i2c_wb_cyc_o <= '0';
            i2c_wb_stb_o <= '0';
            i2c_wb_we_o <= '0';
            state := reading_load;
          elsif (recv_wbs_stb_i = '1') then
            i2c_wb_dat_o <= recv_wbs_dat_i;
            i2c_wb_stb_o <= '1';
            state := writing_write;
          end if;
-------------------------------------------------------------------------------
        when writing_write =>
          if (i2c_wb_ack_i = '1') then
            i2c_wb_stb_o <= '0';
            ack_enable <= '1';
            state := writing_stall;
          end if;
-------------------------------------------------------------------------------
        when writing_stall =>
          -- b/c of synchronous ack, we must stall
          ack_enable <= '0';
          state := writing_read;
-------------------------------------------------------------------------------
        when reading_load =>
          -- we always respond with at least the slave address
          -- and additionally any read data
          -- latch out length here before decrementing; +1 b/c of slave addr
          xmit_length_out <= read_length + 1;
          xmit_wbm_cyc_o <= '1';
          xmit_wbm_stb_o <= '1';
          xmit_wbm_dat_o <= B"0" & slave_addr;
          i2c_wb_cyc_o <= '1';
          i2c_wb_we_o <= '0';
          state := reading_write;
-------------------------------------------------------------------------------
        when reading_read =>
          if (i2c_wb_ack_i = '1') then
            read_length <= read_length - 1;
            i2c_wb_stb_o <= '0';
            xmit_wbm_stb_o <= '1';
            xmit_wbm_dat_o <= i2c_wb_dat_i;
            state := reading_write;
          end if;
-------------------------------------------------------------------------------
        when reading_write =>
          if (xmit_wbm_ack_i = '1') then
            xmit_wbm_stb_o <= '0';
            if (to_integer(read_length) = 0) then
              xmit_wbm_cyc_o <= '0';
              i2c_wb_cyc_o <= '0';
              state := done_state;
            else
              i2c_wb_stb_o <= '1';
              state := reading_read;
            end if;
          end if;
],[dnl -- Async Assignments ---------------------------------------------------
  xmit_opcode_out      <= PTP_I2C_REPLY_OPCODE;
  i2c_wb_adr_o         <= slave_addr;
  debug_led_out <= i2c_wb_dat_i;
])
