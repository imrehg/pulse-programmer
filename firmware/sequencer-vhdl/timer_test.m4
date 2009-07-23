dnl--*-VHDL-*-
-- Test for the composite timer
-- Fixed quantum of one for performance comparison.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([timer_test],
  [dnl -- Libraries
sequencer_libraries_
],[dnl -- Generics
    COUNTER_WIDTH  : positive := 8;
],[dnl -- Ports
    clock      : in     std_logic;
    sclr       : in     std_logic;
    load       : in     std_logic;
    count_in   : in     unsigned(COUNTER_WIDTH-1 downto 0);
    count_out  : out    unsigned(COUNTER_WIDTH-1 downto 0);
    fired_out  : out    std_logic;
    debug_out  : out    byte;
],[dnl -- Declarations
timer_component_
],[dnl -- Body
  test : timer
    generic map (
      SUBCOUNTER_MULTIPLE     => 4,
      SUBCOUNTER_WIDTH        => 2
      )
    port map (
      clock                   => clock,
      clk_en                  => '1',
      sclr                    => sclr,
      load                    => load,
      count_in                => count_in,
      count_out               => count_out,
      fired_out               => fired_out,
      debug_out               => debug_out,
      unused_port             => '0'
    );

])
