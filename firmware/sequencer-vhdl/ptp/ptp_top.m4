dnl-*-VHDL-*-
-- Top-level PTP application layer.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([ptp_top], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
   ENABLE_I2C           : boolean  := true;
   ENABLE_TRIGGER       : boolean  := true;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
wb_xmit_master_port_
   xmit_dest_id_out       : buffer ptp_id_type;
   xmit_opcode_out        : out    ptp_opcode_type;
   xmit_length_out        : out    ptp_length_type;
wb_recv_slave_port_
   recv_src_id_in         : in     ptp_id_type;
   recv_dest_id_in        : in     ptp_id_type;
   recv_opcode_in         : in     ptp_opcode_type;
   recv_length_in         : in     ptp_length_type;
   -- Self ID
   self_id_out            : buffer ptp_id_type;
   self_mac_byte_in       : in     byte;
   -- I2C ports
   i2c_wb_cyc_o           : out    std_logic;
   i2c_wb_stb_o           : out    std_logic;
   i2c_wb_we_o            : out    std_logic;
   i2c_wb_adr_o           : out    i2c_slave_address_type;
   i2c_wb_dat_o           : out    byte;
   i2c_wb_dat_i           : in     byte;
   i2c_wb_ack_i           : in     std_logic;
   -- Status ports
   chain_terminator_in    : in     boolean;
   chain_initiator_in     : in     boolean;
   pcp_halted_in          : in     std_logic;
   -- Debug ports
   led_wb_cyc_o           : out    std_logic;
   led_wb_stb_o           : out    std_logic;
   led_wb_dat_o           : out    byte;
   led_wb_ack_i           : in     std_logic;
   -- Memory ports (external SRAM)
   sram_wb_cyc_o          : out    std_logic;
   sram_wb_stb_o          : out    std_logic;
   sram_wb_we_o           : out    std_logic;
   sram_wb_adr_o          : out    virtual8_address_type;
   sram_wb_dat_o          : out    byte;
   sram_wb_dat_i          : in     byte;
   sram_wb_ack_i          : in     std_logic;
   sram_burst_out         : out    std_logic;
   -- Memory ports (PCP data memory)
   dmem_wb_cyc_o          : out    std_logic;
   dmem_wb_stb_o          : out    std_logic;
   dmem_wb_we_o           : out    std_logic;
   dmem_wb_adr_o          : out    virtual8_address_type;
   dmem_wb_dat_o          : out    byte;
   dmem_wb_dat_i          : in     byte;
   dmem_wb_ack_i          : in     std_logic;
   dmem_burst_out         : out    std_logic;
   -- Start ports
   avr_reset_out          : out    std_logic;
   pcp_reset_out          : out    std_logic;
   -- Trigger ports
   triggers_in            : in     trigger_source_type;
   pcp_start_addr_out     : out    sram_address_type;
   debug_led_out          : out    byte;
],[dnl -- Declarations --------------------------------------------------------
ptp_status_component_
ptp_debug_component_
ptp_discover_component_
ptp_memory_component_
ptp_start_component_
ptp_trigger_component_
ptp_i2c_component_

  constant MODULE_COUNT       : positive := 7;
  constant MODULE_COUNT_WIDTH : positive := 3;

  -- Arbiter arbiter signals
  signal xmit_arbiter_gnt : multibus_bit(0 to MODULE_COUNT-1);
  signal xmit_arbiter_ack : multibus_bit(0 to MODULE_COUNT-1);
  signal recv_arbiter_gnt : multibus_bit(0 to MODULE_COUNT);

  -- Status Module interconnection signals
  signal status_xmit_wb_cyc  : std_logic;
  signal status_xmit_wb_stb  : std_logic;
  signal status_xmit_wb_dat  : std_logic_vector(0 to DATA_WIDTH-1);
  signal status_xmit_wb_ack  : std_logic;
  signal status_xmit_dest_id : ptp_id_type;
  signal status_xmit_opcode  : ptp_opcode_type;
  signal status_xmit_length  : ptp_length_type;
  signal status_recv_wb_cyc  : std_logic;
  signal status_recv_wb_ack  : std_logic;
  signal avr_reset           : std_logic;
  signal pcp_reset           : std_logic;

  -- Debug Module interconnection signals
  signal debug_xmit_wb_cyc  : std_logic;
  signal debug_xmit_wb_stb  : std_logic;
  signal debug_xmit_wb_dat  : std_logic_vector(0 to DATA_WIDTH-1);
  signal debug_xmit_wb_ack  : std_logic;
  signal debug_xmit_dest_id : ptp_id_type;
  signal debug_xmit_opcode  : ptp_opcode_type;
  signal debug_xmit_length  : ptp_length_type;
  signal debug_recv_wb_cyc  : std_logic;
  signal debug_recv_wb_ack  : std_logic;

  -- Discover Module interconnection signals
  signal discover_xmit_wb_cyc  : std_logic;
  signal discover_xmit_wb_stb  : std_logic;
  signal discover_xmit_wb_dat  : std_logic_vector(0 to DATA_WIDTH-1);
  signal discover_xmit_wb_ack  : std_logic;
  signal discover_xmit_dest_id : ptp_id_type;
  signal discover_xmit_opcode  : ptp_opcode_type;
  signal discover_xmit_length  : ptp_length_type;
  signal discover_recv_wb_cyc  : std_logic;
  signal discover_recv_wb_ack  : std_logic;

  -- Memory Module interconnection signals
  signal memory_xmit_wb_cyc  : std_logic;
  signal memory_xmit_wb_stb  : std_logic;
  signal memory_xmit_wb_dat  : std_logic_vector(0 to DATA_WIDTH-1);
  signal memory_xmit_wb_ack  : std_logic;
  signal memory_xmit_dest_id : ptp_id_type;
  signal memory_xmit_opcode  : ptp_opcode_type;
  signal memory_xmit_length  : ptp_length_type;
  signal memory_recv_wb_cyc  : std_logic;
  signal memory_recv_wb_ack  : std_logic;

  -- Start Module interconnection signals
  signal start_xmit_wb_cyc  : std_logic;
  signal start_xmit_wb_stb  : std_logic;
  signal start_xmit_wb_dat  : std_logic_vector(0 to DATA_WIDTH-1);
  signal start_xmit_wb_ack  : std_logic;
  signal start_xmit_dest_id : ptp_id_type;
  signal start_xmit_opcode  : ptp_opcode_type;
  signal start_xmit_length  : ptp_length_type;
  signal start_recv_wb_cyc  : std_logic;
  signal start_recv_wb_ack  : std_logic;

  -- Trigger Module interconnection signals
  signal trigger_xmit_wb_cyc  : std_logic;
  signal trigger_xmit_wb_stb  : std_logic;
  signal trigger_xmit_wb_dat  : std_logic_vector(0 to DATA_WIDTH-1);
  signal trigger_xmit_wb_ack  : std_logic;
  signal trigger_xmit_dest_id : ptp_id_type;
  signal trigger_xmit_opcode  : ptp_opcode_type;
  signal trigger_xmit_length  : ptp_length_type;
  signal trigger_recv_wb_cyc  : std_logic;
  signal trigger_recv_wb_ack  : std_logic;
  signal current_trigger      : trigger_index_type;

    -- I2C Module interconnection signals
  signal i2c_xmit_wb_cyc  : std_logic;
  signal i2c_xmit_wb_stb  : std_logic;
  signal i2c_xmit_wb_dat  : std_logic_vector(0 to DATA_WIDTH-1);
  signal i2c_xmit_wb_ack  : std_logic;
  signal i2c_xmit_dest_id : ptp_id_type;
  signal i2c_xmit_opcode  : ptp_opcode_type;
  signal i2c_xmit_length  : ptp_length_type;
  signal i2c_recv_wb_cyc  : std_logic;
  signal i2c_recv_wb_ack  : std_logic;
],[dnl -- Body ----------------------------------------------------------------

   avr_reset_out <= avr_reset;
   pcp_reset_out <= pcp_reset;

-------------------------------------------------------------------------------
-- Status Module

  status_module : ptp_status
    generic map (
      DATA_WIDTH        => DATA_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i          => wb_clk_i,
      wb_rst_i          => wb_rst_i,
      -- Transmit master interface
      xmit_wbm_cyc_o    => status_xmit_wb_cyc,
      xmit_wbm_stb_o    => status_xmit_wb_stb,
      xmit_wbm_dat_o    => status_xmit_wb_dat,
      xmit_wbm_ack_i    => status_xmit_wb_ack,
      xmit_dest_id_out  => status_xmit_dest_id,
      xmit_opcode_out   => status_xmit_opcode,
      xmit_length_out   => status_xmit_length,
      -- xmit_debug_led_out
      -- Receive slave interface
      recv_wbs_cyc_i    => status_recv_wb_cyc,
      recv_wbs_stb_i    => recv_wbs_stb_i,
      recv_wbs_dat_i    => recv_wbs_dat_i,
      recv_wbs_ack_o    => status_recv_wb_ack,
      recv_src_id_in    => recv_src_id_in,
      recv_dest_id_in   => recv_dest_id_in,
      recv_length_in    => recv_length_in,
      -- recv_debug_led_out
      -- External ports passed-in from top-level PTP
      avr_reset_in      => avr_reset,
      pcp_reset_in      => pcp_reset,
      current_trigger_in => current_trigger,
      chain_initiator    => chain_initiator_in,
      chain_terminator   => chain_terminator_in,
      pcp_halted_in     => pcp_halted_in
      --debug_led_out
      );

-------------------------------------------------------------------------------
-- Debug Module

  debug_module : ptp_debug
    generic map (
      DATA_WIDTH        => DATA_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i          => wb_clk_i,
      wb_rst_i          => wb_rst_i,
      -- Transmit master interface
      xmit_wbm_cyc_o    => debug_xmit_wb_cyc,
      xmit_wbm_stb_o    => debug_xmit_wb_stb,
      xmit_wbm_dat_o    => debug_xmit_wb_dat,
      xmit_wbm_ack_i    => debug_xmit_wb_ack,
      xmit_dest_id_out  => debug_xmit_dest_id,
      xmit_opcode_out   => debug_xmit_opcode,
      xmit_length_out   => debug_xmit_length,
      -- xmit_debug_led_out
      -- Receive slave interface
      recv_wbs_cyc_i    => debug_recv_wb_cyc,
      recv_wbs_stb_i    => recv_wbs_stb_i,
      recv_wbs_dat_i    => recv_wbs_dat_i,
      recv_wbs_ack_o    => debug_recv_wb_ack,
      recv_src_id_in    => recv_src_id_in,
      recv_dest_id_in   => recv_dest_id_in,
      recv_length_in    => recv_length_in,
      -- recv_debug_led_out
      -- External ports passed-in from top-level PTP
      led_wb_cyc_o      => led_wb_cyc_o,
      led_wb_stb_o      => led_wb_stb_o,
      led_wb_dat_o      => led_wb_dat_o,
      led_wb_ack_i      => led_wb_ack_i,
      self_mac_byte     => self_mac_byte_in
      --debug_led_out
      );

-------------------------------------------------------------------------------
-- Discover Module

  discover_module : ptp_discover
    generic map (
      DATA_WIDTH        => DATA_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i          => wb_clk_i,
      wb_rst_i          => wb_rst_i,
      -- Transmit master interface
      xmit_wbm_cyc_o    => discover_xmit_wb_cyc,
      xmit_wbm_stb_o    => discover_xmit_wb_stb,
      xmit_wbm_dat_o    => discover_xmit_wb_dat,
      xmit_wbm_ack_i    => discover_xmit_wb_ack,
      xmit_dest_id_out  => discover_xmit_dest_id,
      xmit_opcode_out   => discover_xmit_opcode,
      xmit_length_out   => discover_xmit_length,
      -- xmit_debug_led_out
      -- Receive slave interface
      recv_wbs_cyc_i    => discover_recv_wb_cyc,
      recv_wbs_stb_i    => recv_wbs_stb_i,
      recv_wbs_dat_i    => recv_wbs_dat_i,
      recv_wbs_ack_o    => discover_recv_wb_ack,
      recv_src_id_in    => recv_src_id_in,
      recv_dest_id_in   => recv_dest_id_in,
      recv_length_in    => recv_length_in,
      -- recv_debug_led_out
      -- External ports passed-in from top-level PTP
      mac_byte_in       => self_mac_byte_in,
      self_id_out       => self_id_out
      --debug_led_out
      );

-------------------------------------------------------------------------------
-- Memory Module

  memory_module : ptp_memory
    generic map (
      DATA_WIDTH           => DATA_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i             => wb_clk_i,
      wb_rst_i             => wb_rst_i,
      -- Transmit master interface
      xmit_wbm_cyc_o       => memory_xmit_wb_cyc,
      xmit_wbm_stb_o       => memory_xmit_wb_stb,
      xmit_wbm_dat_o       => memory_xmit_wb_dat,
      xmit_wbm_ack_i       => memory_xmit_wb_ack,
      xmit_dest_id_out     => memory_xmit_dest_id,
      xmit_opcode_out      => memory_xmit_opcode,
      xmit_length_out      => memory_xmit_length,
      -- xmit_debug_led_out
      -- Receive slave interface
      recv_wbs_cyc_i       => memory_recv_wb_cyc,
      recv_wbs_stb_i       => recv_wbs_stb_i,
      recv_wbs_dat_i       => recv_wbs_dat_i,
      recv_wbs_ack_o       => memory_recv_wb_ack,
      recv_src_id_in       => recv_src_id_in,
      recv_dest_id_in      => recv_dest_id_in,
      recv_length_in       => recv_length_in,
      -- External ports passed-in from top-level PTP
      -- External SRAM ports
      sram_wb_cyc_o        => sram_wb_cyc_o,
      sram_wb_stb_o        => sram_wb_stb_o,
      sram_wb_we_o         => sram_wb_we_o,
      sram_wb_adr_o        => sram_wb_adr_o,
      sram_wb_dat_o        => sram_wb_dat_o,
      sram_wb_dat_i        => sram_wb_dat_i,
      sram_wb_ack_i        => sram_wb_ack_i,
      sram_burst_out       => sram_burst_out,
      -- PCP data memory ports
      dmem_wb_cyc_o        => dmem_wb_cyc_o,
      dmem_wb_stb_o        => dmem_wb_stb_o,
      dmem_wb_we_o         => dmem_wb_we_o,
      dmem_wb_adr_o        => dmem_wb_adr_o,
      dmem_wb_dat_o        => dmem_wb_dat_o,
      dmem_wb_dat_i        => dmem_wb_dat_i,
      dmem_wb_ack_i        => dmem_wb_ack_i,
      dmem_burst_out       => dmem_burst_out
      --debug_led_out        => debug_led_out
      );

-------------------------------------------------------------------------------
-- Start Module

  start_module : ptp_start
    generic map (
      DATA_WIDTH           => DATA_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i             => wb_clk_i,
      wb_rst_i             => wb_rst_i,
      -- Transmit master interface
      xmit_wbm_cyc_o       => start_xmit_wb_cyc,
      xmit_wbm_stb_o       => start_xmit_wb_stb,
      xmit_wbm_dat_o       => start_xmit_wb_dat,
      xmit_wbm_ack_i       => start_xmit_wb_ack,
      xmit_dest_id_out     => start_xmit_dest_id,
      xmit_opcode_out      => start_xmit_opcode,
      xmit_length_out      => start_xmit_length,
      -- xmit_debug_led_out
      -- Receive slave interface
      recv_wbs_cyc_i       => start_recv_wb_cyc,
      recv_wbs_stb_i       => recv_wbs_stb_i,
      recv_wbs_dat_i       => recv_wbs_dat_i,
      recv_wbs_ack_o       => start_recv_wb_ack,
      recv_src_id_in       => recv_src_id_in,
      recv_dest_id_in      => recv_dest_id_in,
      recv_length_in       => recv_length_in,
      -- External ports passed-in from top-level PTP
      avr_reset_out        => avr_reset,
      pcp_reset_out        => pcp_reset
      --debug_led_out
      );

-------------------------------------------------------------------------------
-- Trigger Module

  trigger_gen: if (ENABLE_TRIGGER) generate
    trigger_module : ptp_trigger
      generic map (
        DATA_WIDTH          => DATA_WIDTH
        )
      port map (
        -- Wishbone common signals
        wb_clk_i            => wb_clk_i,
        wb_rst_i            => wb_rst_i,
        xmit_wbm_cyc_o      => trigger_xmit_wb_cyc,
        xmit_wbm_stb_o      => trigger_xmit_wb_stb,
        xmit_wbm_dat_o      => trigger_xmit_wb_dat,
        xmit_wbm_ack_i      => trigger_xmit_wb_ack,
--      xmit_debug_led_out
        xmit_dest_id_out    => trigger_xmit_dest_id,
        xmit_opcode_out     => trigger_xmit_opcode,
        xmit_length_out     => trigger_xmit_length,
        recv_wbs_cyc_i      => trigger_recv_wb_cyc,
        recv_wbs_stb_i      => recv_wbs_stb_i,
        recv_wbs_dat_i      => recv_wbs_dat_i,
        recv_wbs_ack_o      => trigger_recv_wb_ack,
--      recv_debug_led_out
        recv_src_id_in      => recv_src_id_in,
        recv_dest_id_in     => recv_dest_id_in,
        recv_length_in      => recv_length_in,
        -- External ports passed-in from top-level PTP
        current_trigger_out => current_trigger,
        pcp_start_addr_out  => pcp_start_addr_out
--      debug_led_out
        );
  end generate trigger_gen;

  trigger_notgen: if (not ENABLE_TRIGGER) generate
    trigger_xmit_wb_cyc <= '0';
    trigger_recv_wb_ack <= '1';
    current_trigger <= TRIGGER_NULL;
    pcp_start_addr_out <= (others => '0');
  end generate trigger_notgen;

-------------------------------------------------------------------------------
-- I2C Module

  i2c_gen : if (ENABLE_I2C) generate  
    i2c_module : ptp_i2c
      generic map (
        DATA_WIDTH          => DATA_WIDTH
        )
      port map (
        -- Wishbone common signals
        wb_clk_i            => wb_clk_i,
        wb_rst_i            => wb_rst_i,
        xmit_wbm_cyc_o      => i2c_xmit_wb_cyc,
        xmit_wbm_stb_o      => i2c_xmit_wb_stb,
        xmit_wbm_dat_o      => i2c_xmit_wb_dat,
        xmit_wbm_ack_i      => i2c_xmit_wb_ack,
--      xmit_debug_led_out
        xmit_dest_id_out    => i2c_xmit_dest_id,
        xmit_opcode_out     => i2c_xmit_opcode,
        xmit_length_out     => i2c_xmit_length,
        recv_wbs_cyc_i      => i2c_recv_wb_cyc,
        recv_wbs_stb_i      => recv_wbs_stb_i,
        recv_wbs_dat_i      => recv_wbs_dat_i,
        recv_wbs_ack_o      => i2c_recv_wb_ack,
--    recv_debug_led_out
        recv_src_id_in      => recv_src_id_in,
        recv_dest_id_in     => recv_dest_id_in,
        recv_length_in      => recv_length_in,
        -- External ports passed-in from top-level PTP
        i2c_wb_cyc_o        => i2c_wb_cyc_o,
        i2c_wb_stb_o        => i2c_wb_stb_o,
        i2c_wb_we_o         => i2c_wb_we_o,
        i2c_wb_adr_o        => i2c_wb_adr_o,
        i2c_wb_dat_o        => i2c_wb_dat_o,
        i2c_wb_dat_i        => i2c_wb_dat_i,
        i2c_wb_ack_i        => i2c_wb_ack_i,
        debug_led_out       => debug_led_out
        );
  end generate i2c_gen;

  i2c_notgen: if (not ENABLE_I2C) generate
    i2c_xmit_wb_cyc <= '0';
    i2c_recv_wb_ack <= '1';
    i2c_wb_cyc_o <= '0';
    i2c_wb_stb_o <= '0';
    i2c_wb_we_o <= '0';
    i2c_wb_adr_o <= (others => '0');
    i2c_wb_dat_o <= (others => '0');
  end generate i2c_notgen;

------------------------------------------------------------------------------
-- Transmit arbiter from modules
    xmit_arbiter : wb_intercon
      generic map (
        MASTER_COUNT       => MODULE_COUNT,
        MASTER_COUNT_WIDTH => MODULE_COUNT_WIDTH
        )
      port map (
        wb_clk_i      => wb_clk_i,
        wb_rst_i      => wb_rst_i,

        wbm_cyc_i     => (status_xmit_wb_cyc, debug_xmit_wb_cyc,
                          discover_xmit_wb_cyc, memory_xmit_wb_cyc,
                          start_xmit_wb_cyc, trigger_xmit_wb_cyc,
                          i2c_xmit_wb_cyc),
        wbm_stb_i     => (status_xmit_wb_stb, debug_xmit_wb_stb,
                          discover_xmit_wb_stb, memory_xmit_wb_stb,
                          start_xmit_wb_stb, trigger_xmit_wb_stb,
                          i2c_xmit_wb_stb),
        wbm_dat_i     => (status_xmit_wb_dat, debug_xmit_wb_dat,
                          discover_xmit_wb_dat, memory_xmit_wb_dat,
                          start_xmit_wb_dat, trigger_xmit_wb_dat,
                          i2c_xmit_wb_dat),
        wbm_ack_o     => xmit_arbiter_ack,
        wbm_gnt_o     => xmit_arbiter_gnt,

        wbs_cyc_o     => xmit_wbm_cyc_o,
        wbs_stb_o     => xmit_wbm_stb_o,
        wbs_dat_o     => xmit_wbm_dat_o,
        wbs_ack_i     => xmit_wbm_ack_i
        );

    status_xmit_wb_ack   <= xmit_arbiter_ack(0);
    debug_xmit_wb_ack    <= xmit_arbiter_ack(1);
    discover_xmit_wb_ack <= xmit_arbiter_ack(2);
    memory_xmit_wb_ack   <= xmit_arbiter_ack(3);
    start_xmit_wb_ack    <= xmit_arbiter_ack(4);
    trigger_xmit_wb_ack  <= xmit_arbiter_ack(5);
    i2c_xmit_wb_ack      <= xmit_arbiter_ack(6);

    with xmit_arbiter_gnt select
      xmit_dest_id_out <=
      status_xmit_dest_id   when B"1000000",
      debug_xmit_dest_id    when B"0100000",
      discover_xmit_dest_id when B"0010000",
      memory_xmit_dest_id   when B"0001000",
      start_xmit_dest_id    when B"0000100",
      trigger_xmit_dest_id  when B"0000010",
      i2c_xmit_dest_id      when B"0000001",
      PTP_HOST_ID           when others;
    with xmit_arbiter_gnt select
      xmit_opcode_out <=
      status_xmit_opcode   when B"1000000",
      debug_xmit_opcode    when B"0100000",
      discover_xmit_opcode when B"0010000",
      memory_xmit_opcode   when B"0001000",
      start_xmit_opcode    when B"0000100",
      trigger_xmit_opcode  when B"0000010",
      i2c_xmit_opcode      when B"0000001",
      PTP_NULL_OPCODE      when others;
    with xmit_arbiter_gnt select
      xmit_length_out <=
      status_xmit_length   when B"1000000",
      debug_xmit_length    when B"0100000",
      discover_xmit_length when B"0010000",
      memory_xmit_length   when B"0001000",
      start_xmit_length    when B"0000100",
      trigger_xmit_length  when B"0000010",
      i2c_xmit_length      when B"0000001",
      (others => '0')      when others;
-------------------------------------------------------------------------------
-- Receive Arbitration
-------------------------------------------------------------------------------
  receive_process : process(wb_rst_i, wb_clk_i, recv_opcode_in,
                            recv_arbiter_gnt, recv_wbs_cyc_i, recv_wbs_stb_i,
                            status_recv_wb_ack, debug_recv_wb_ack,
                            discover_recv_wb_ack, start_recv_wb_ack,
                            i2c_recv_wb_ack, trigger_recv_wb_ack,
                            memory_recv_wb_ack)

   begin
     if (wb_rst_i = '1') then
       recv_arbiter_gnt <= B"00000000";

     elsif (rising_edge(wb_clk_i)) then
       if (recv_wbs_cyc_i = '1') then
         case (recv_opcode_in) is
           when PTP_STATUS_REQUEST_OPCODE =>
             recv_arbiter_gnt <= B"10000000";
           when PTP_DEBUG_REQUEST_OPCODE =>
             recv_arbiter_gnt <= B"01000000";
           when PTP_DISCOVER_REQUEST_OPCODE =>
             recv_arbiter_gnt <= B"00100000";
           when PTP_MEMORY_REQUEST_OPCODE =>
             recv_arbiter_gnt <= B"00010000";
           when PTP_START_REQUEST_OPCODE =>
             recv_arbiter_gnt <= B"00001000";
           when PTP_TRIGGER_REQUEST_OPCODE =>
             recv_arbiter_gnt <= B"00000100";
           when PTP_I2C_REQUEST_OPCODE =>
             recv_arbiter_gnt <= B"00000010";
           when others =>
             recv_arbiter_gnt <= B"00000001";
         end case;
       else
         recv_arbiter_gnt <= B"00000000";
       end if;
     end if;                            -- rising_edge(wb_clk_i)

     status_recv_wb_cyc   <= recv_wbs_cyc_i and recv_arbiter_gnt(0);
     debug_recv_wb_cyc    <= recv_wbs_cyc_i and recv_arbiter_gnt(1);
     discover_recv_wb_cyc <= recv_wbs_cyc_i and recv_arbiter_gnt(2);
     memory_recv_wb_cyc   <= recv_wbs_cyc_i and recv_arbiter_gnt(3);
     start_recv_wb_cyc    <= recv_wbs_cyc_i and recv_arbiter_gnt(4);
     trigger_recv_wb_cyc  <= recv_wbs_cyc_i and recv_arbiter_gnt(5);
     i2c_recv_wb_cyc      <= recv_wbs_cyc_i and recv_arbiter_gnt(6);

     case (recv_arbiter_gnt) is
       when B"10000000" =>
         recv_wbs_ack_o <= status_recv_wb_ack;
       when B"01000000" =>
         recv_wbs_ack_o <= debug_recv_wb_ack;
       when B"00100000" =>
         recv_wbs_ack_o <= discover_recv_wb_ack;
       when B"00010000" =>
         recv_wbs_ack_o <= memory_recv_wb_ack;
       when B"00001000" =>
         recv_wbs_ack_o <= start_recv_wb_ack;
       when B"00000100" =>
         recv_wbs_ack_o <= trigger_recv_wb_ack;
       when B"00000010" =>
         recv_wbs_ack_o <= i2c_recv_wb_ack;
       when B"00000001" =>
         recv_wbs_ack_o <= recv_wbs_stb_i;
       when others =>
         recv_wbs_ack_o <= '0';
     end case;

   end process;
-------------------------------------------------------------------------------
])
