dnl--*-VHDL-*-
-- Single pulse generator
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Generates a positive (active high) pulse for one clock cycle then
-- stays low forever, either
-- IN_PHASE true : on first rising clock edge after enable sampled true.
-- IN_PHASE false : on first falling clock edge after enable sampled true.

-- Useful for generating power-on resets and
-- and loads for shift registers. For this reason, it starts on a
-- falling clock edge in order to meet the setup and hold times relative
-- to the rising clock edge, assuming tsu and th << clock_cycle / 2.

-- Clock this device faster than 20 ns (50 MHz) may introduce glitches
-- and single-cycle delays.

unit_([pulse_generator],
  [dnl -- Libraries
library altera;
use altera.maxplus2.all;
library lpm;
use lpm.lpm_components.all;
],[dnl -- Generics
],[dnl -- Ports
    clock     : in  std_logic;
    enable    : in  std_logic;
    reset     : in  std_logic;
    pulse_out : out std_logic;
],[dnl -- Declarations
  signal tff_delay : std_logic_vector(0 downto 0);
  signal tff_out : std_logic_vector(0 downto 0);
  signal not_tff_delay : std_logic_vector(0 downto 0);
],[dnl -- Body

  reset_toggle : lpm_ff
    generic map (
      LPM_FFTYPE  => "TFF",
      LPM_WIDTH => 1
      )
    port map (
      clock  => clock,
      enable => enable,
      aclr   => reset,
      q      => tff_out
      );

  not_tff_delay <= not tff_delay;

  reset_delay : lpm_ff
    generic map (
      LPM_FFTYPE  => "TFF",
      LPM_WIDTH => 1
      )
    port map (
      clock  => clock,
      enable => not_tff_delay(0),
      data   => tff_out,
      aclr   => reset,
      q      => tff_delay
      );

  pulse_out <= (not_tff_delay(0)) and tff_out(0);
])

