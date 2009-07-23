dnl-*-VHDL-*-
-- Loopback test of PTP daisy-chain link-level.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([ptp_daisy_link_test], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.ptp.all;
],[dnl -- Generics ------------------------------------------------------------
data_generic_
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   -- Wishbone slave transmit interface for first link
   one_xmit_wbs_cyc_i : in  std_logic;
   one_xmit_wbs_stb_i : in  std_logic;
   one_xmit_wbs_dat_i : in  std_logic_vector(0 to DATA_WIDTH-1);
   one_xmit_wbs_ack_o : out std_logic;
   one_xmit_interface : in  ptp_interface_type;
   one_recv_wbm_cyc_o : out std_logic;
   one_recv_wbm_stb_o : out std_logic;
   one_recv_wbm_dat_o : out std_logic_vector(0 to DATA_WIDTH-1);
   one_recv_wbm_ack_i : in  std_logic;
   one_master_xmit_stb_ack : out std_logic;
   one_master_xmit_dat_cyc : out std_logic;
   one_master_recv_stb_ack : in  std_logic;
   one_master_recv_dat_cyc : in  std_logic;
   -- Wishbone slave transmit interface for first link
   two_xmit_wbs_cyc_i : in  std_logic;
   two_xmit_wbs_stb_i : in  std_logic;
   two_xmit_wbs_dat_i : in  std_logic_vector(0 to DATA_WIDTH-1);
   two_xmit_wbs_ack_o : out std_logic;
   two_xmit_interface : in  ptp_interface_type;
   two_recv_wbm_cyc_o : out std_logic;
   two_recv_wbm_stb_o : out std_logic;
   two_recv_wbm_dat_o : out std_logic_vector(0 to DATA_WIDTH-1);
   two_recv_wbm_ack_i : in  std_logic;
   two_slave_xmit_stb_ack : out std_logic;
   two_slave_xmit_dat_cyc : out std_logic;
   two_slave_recv_stb_ack : in  std_logic;
   two_slave_recv_dat_cyc : in  std_logic;

],[dnl -- Declarations --------------------------------------------------------
  signal two2one_stb_ack : std_logic;
  signal two2one_dat_cyc : std_logic;
  signal one2two_stb_ack : std_logic;
  signal one2two_dat_cyc : std_logic;

  signal link_xmit_wbs_stb : std_logic;
  signal link_xmit_wbs_dat : std_logic_vector(0 to DATA_WIDTH-1);
  signal link_xmit_wbs_ack : std_logic;
  signal route_recv_wbm_cyc : std_logic;

  signal link_recv_wbm_cyc : std_logic;
  signal link_recv_wbm_stb : std_logic;
  signal link_recv_wbm_dat : std_logic_vector(0 to DATA_WIDTH-1);
  signal link_recv_wbm_ack : std_logic;
  signal link_recv_checksum_error : std_logic;

  signal link_recv_src_id_out : ptp_id_type;
  signal link_recv_dest_id_out : ptp_id_type;
  signal link_recv_major_version : std_logic_vector(0 to 7);
  signal link_recv_opcode_out : ptp_opcode_type;
  signal link_recv_length_out : ptp_length_type;

  signal buffer_wbm_cyc : std_logic;
  signal buffer_wbm_ack : std_logic;
  signal buffer_reload  : std_logic;
  signal buffer_match   : std_logic;

  signal link_xmit_src_id  : ptp_id_type;
  signal link_xmit_dest_id : ptp_id_type;
  signal link_xmit_opcode  : ptp_opcode_type;
  signal link_xmit_length  : ptp_length_type;

  signal router_forward : boolean;

  signal xmit_arbiter_gnt : multibus_bit(0 to 1);
  signal xmit_arbiter_ack : multibus_bit(0 to 1);

ptp_daisy_link_component_
],[dnl -- Body ----------------------------------------------------------------
  one_link : ptp_daisy_link
    generic map (
      DATA_WIDTH                => DATA_WIDTH,
      STABLE_COUNT              => 3,
      ABORT_TIMEOUT             => 15
      )
    port map (
      -- Wishbone common signals
      wb_clk_i                  => wb_clk_i,
      wb_rst_i                  => wb_rst_i,
     -- Daisy-chain Wishbone transmit interface
      xmit_wbs_cyc_i            => one_xmit_wbs_cyc_i,
      xmit_wbs_stb_i            => one_xmit_wbs_stb_i,
      xmit_wbs_dat_i            => one_xmit_wbs_dat_i,
      xmit_wbs_ack_o            => one_xmit_wbs_ack_o,
      xmit_interface_in         => one_xmit_interface,
      -- Daisy-chain Wishbone receive interface
      recv_wbm_cyc_o            => one_recv_wbm_cyc_o,
      recv_wbm_stb_o            => one_recv_wbm_stb_o,
      recv_wbm_dat_o            => one_recv_wbm_dat_o,
      recv_wbm_ack_i            => one_recv_wbm_ack_i,
      -- Physical daisy chain pins to master
      master_xmit_stb_ack => one_master_xmit_stb_ack,
      master_xmit_dat_cyc => one_master_xmit_dat_cyc,
      master_recv_stb_ack => one_master_recv_stb_ack,
      master_recv_dat_cyc => one_master_recv_dat_cyc,
      -- Physical daisy chain pins to slave
      slave_xmit_stb_ack  => one2two_stb_ack,
      slave_xmit_dat_cyc  => one2two_dat_cyc,
      slave_recv_stb_ack  => two2one_stb_ack,
      slave_recv_dat_cyc  => two2one_dat_cyc
      );

  two_link : ptp_daisy_link
    generic map (
      DATA_WIDTH                => DATA_WIDTH,
      STABLE_COUNT              => 3,
      ABORT_TIMEOUT             => 15
      )
    port map (
      -- Wishbone common signals
      wb_clk_i                  => wb_clk_i,
      wb_rst_i                  => wb_rst_i,
     -- Daisy-chain Wishbone transmit interface
      xmit_wbs_cyc_i            => two_xmit_wbs_cyc_i,
      xmit_wbs_stb_i            => two_xmit_wbs_stb_i,
      xmit_wbs_dat_i            => two_xmit_wbs_dat_i,
      xmit_wbs_ack_o            => two_xmit_wbs_ack_o,
      xmit_interface_in         => two_xmit_interface,
      -- Daisy-chain Wishbone receive interface
      recv_wbm_cyc_o            => two_recv_wbm_cyc_o,
      recv_wbm_stb_o            => two_recv_wbm_stb_o,
      recv_wbm_dat_o            => two_recv_wbm_dat_o,
      recv_wbm_ack_i            => two_recv_wbm_ack_i,
      -- Physical daisy chain pins to master
      master_xmit_stb_ack => two2one_stb_ack,
      master_xmit_dat_cyc => two2one_dat_cyc,
      master_recv_stb_ack => one2two_stb_ack,
      master_recv_dat_cyc => one2two_dat_cyc,
      -- Physical daisy chain pins to slave
      slave_xmit_stb_ack  => two_slave_xmit_stb_ack,
      slave_xmit_dat_cyc  => two_slave_xmit_dat_cyc,
      slave_recv_stb_ack  => two_slave_recv_stb_ack,
      slave_recv_dat_cyc  => two_slave_recv_dat_cyc
      );
    
])
