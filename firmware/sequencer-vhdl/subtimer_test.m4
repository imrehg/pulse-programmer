dnl--*-VHDL-*-
-- Test for the subtimer.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([subtimer_test],
  [dnl -- Libraries
sequencer_libraries_
],[dnl -- Generics
    COUNTER_WIDTH  : positive := 4;
],[dnl -- Ports
    clock      : in  std_logic;
    enable     : in  std_logic;
    reset      : in  std_logic;
    sclr       : in  std_logic;
    load       : in  std_logic;
    count_in   : in  unsigned(COUNTER_WIDTH-1 downto 0);
    count_out  : out unsigned(COUNTER_WIDTH-1 downto 0);
    ripple_out : out std_logic;
    fired_out  : out std_logic;
    finish_out : out std_logic;
    debug_out  : out byte;
],[dnl -- Declarations
subtimer_component_
],[dnl -- Body
  test : subtimer
    generic map (
      COUNTER_WIDTH  => COUNTER_WIDTH,
      AUTO_RELOAD    => FALSE
      )
    port map (
      clock      => clock,
      enable     => enable,
      sclr       => sclr,
      load       => load,
      count_in   => count_in,
      count_out  => count_out,
      ripple_out => ripple_out,
      fired_out  => fired_out,
      finish_out => finish_out,
      debug_out  => debug_out
      );

])
