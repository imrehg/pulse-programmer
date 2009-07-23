dnl-*-VHDL-*-
-- Loopback test of PTP top-level.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([ptp_loopback_test], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.ptp.all;
],[dnl -- Generics ------------------------------------------------------------
data_generic_
  ADDRESS_WIDTH : positive := 10;
  STABLE_COUNT  : positive := 1;
  ABORT_TIMEOUT : positive := 10;
],[dnl -- Ports ---------------------------------------------------------------
   network_clock             : in std_logic;
   wb_rst_i                  : in std_logic;
ptp_loopback_test_ports_([one])
ptp_loopback_test_ports_([two])
],[dnl -- Declarations --------------------------------------------------------
  signal one_daisy_transmit   : nibble;
  signal one_daisy_receive    : nibble;
  signal two_daisy_transmit   : nibble;
  signal two_daisy_receive    : nibble;
  signal one_network_detected : std_logic;
  signal one_chain_initiator  : boolean;
  signal one_chain_terminator : boolean;
  signal two_network_detected : std_logic;
  signal two_chain_initiator  : boolean;
  signal two_chain_terminator : boolean;
  signal one_pcp_halted       : std_logic;
  signal two_pcp_halted       : std_logic;
  signal one_pcp_fifo_busy    : std_logic;
  signal two_pcp_fifo_busy    : std_logic;
ptp_top_test_component_
],[dnl -- Body ----------------------------------------------------------------

ptp_top_test_instance_([one])
ptp_top_test_instance_([two])

  one_daisy_receive(2) <= two_daisy_transmit(0);
  one_daisy_receive(3) <= two_daisy_transmit(1);
  two_daisy_receive(2) <= '1';   
  two_daisy_receive(3) <= '1';
  two_daisy_receive(0) <= one_daisy_transmit(2);
  two_daisy_receive(1) <= one_daisy_transmit(3);

  one_network_detected <= '1';
  one_chain_terminator <= false;
  two_network_detected <= '0';
  two_chain_terminator <= true;
  one_pcp_halted <= '1';
  two_pcp_halted <= '0';
  one_pcp_fifo_busy <= '0';
  two_pcp_fifo_busy <= '0';
])
