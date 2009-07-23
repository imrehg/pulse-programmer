dnl--*-VHDL-*-
-- Run-time clock speed detector and scaler.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Counts the number of clock cycles of a given clock with respect to
-- the cycle of a known clock (usually the Ethernet transmit/receive clocks).

unit_([timer],
  [dnl -- Libraries
use ieee.numeric_std.all;
sequencer_libraries_
],[dnl -- Generics
    SUBCOUNTER_MULTIPLE       : positive := 16;
    SUBCOUNTER_WIDTH          : positive := 4;
],[dnl -- Ports
    clock      : in  std_logic;
    clk_en     : in  std_logic;
    sclr       : in  std_logic;
    load       : in  std_logic;
    count_in   : in  unsigned((SUBCOUNTER_MULTIPLE*
                               SUBCOUNTER_WIDTH)-1 downto 0);
    count_out  : out unsigned((SUBCOUNTER_MULTIPLE*
                               SUBCOUNTER_WIDTH)-1 downto 0);
    fired_out  : out std_logic;
    debug_out  : out byte;
],[dnl -- Declarations
  constant COUNTER_WIDTH : positive := SUBCOUNTER_WIDTH*SUBCOUNTER_MULTIPLE;

  signal subclock     : std_logic_vector(SUBCOUNTER_MULTIPLE downto 0);
  signal subfired_out : std_logic_vector(SUBCOUNTER_MULTIPLE downto 0);
  signal subripple_out: std_logic_vector(SUBCOUNTER_MULTIPLE downto 0);
  signal subfinish_in : std_logic_vector(SUBCOUNTER_MULTIPLE downto 0);
  signal subfinish_out: std_logic_vector(SUBCOUNTER_MULTIPLE downto 0);
  signal subfired_all : std_logic_vector(SUBCOUNTER_MULTIPLE downto 0);
  signal subdebug     : multibus_byte(SUBCOUNTER_MULTIPLE-1 downto 0);

subtimer_component_
],[dnl -- Body
  -- Subcounter generation (+1 for rounding)
  subcounter_gen: for i in SUBCOUNTER_MULTIPLE-1 downto 0 generate
    subcounter : subtimer
      generic map (
        COUNTER_WIDTH => SUBCOUNTER_WIDTH,
        -- the high order subcounter does not need to be reloading
        AUTO_RELOAD   => (i /= SUBCOUNTER_MULTIPLE-1)
        )
      port map (
        clock      => clock,
        enable     => subclock(i) and clk_en,
        sclr       => sclr,
        load       => load,
        count_in   => count_in(((i+1)*SUBCOUNTER_WIDTH)-1 downto
                               (i*SUBCOUNTER_WIDTH)),
        count_out  => count_out(((i+1)*SUBCOUNTER_WIDTH)-1 downto
                                   (i*SUBCOUNTER_WIDTH)),
        finish_out => subfinish_out(i),
        fired_out  => subfired_out(i),
        ripple_out => subripple_out(i),
        debug_out  => subdebug(i)
        );
    subfired_all(i+1) <= subfinish_out(i) and subfired_all(i);
    subclock(i+1) <= subripple_out(i);
    
  end generate subcounter_gen;

  debug_out(6) <= subfired_out(3);
  debug_out(5) <= subfired_out(2);
  debug_out(4) <= subfired_out(1);
  debug_out(3) <= subfired_out(0);
  debug_out(2) <= subclock(SUBCOUNTER_MULTIPLE-1);
  debug_out(1) <= subclock(1);
  debug_out(0) <= subfired_all(SUBCOUNTER_MULTIPLE-1);
  subclock(0) <= '1';
  fired_out <= subfired_all(SUBCOUNTER_MULTIPLE);
  subfired_all(0) <= '1';
])

