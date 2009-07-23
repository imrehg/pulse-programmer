dnl--*-VHDL-*-
-- Clock multiplier using Altera PLL (non-portable)
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([clock_multiplier],
  [dnl -- Libraries
sequencer_libraries_
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
],[dnl -- Generics
  MULTIPLIER : positive := 3;
],[dnl -- Ports
  inclk0  : in  std_logic  := '0';
  pllena  : in  std_logic  := '1';
  pfdena  : in  std_logic  := '1';
  areset  : in  std_logic  := '0';
  c0      : out std_logic;
  locked  : out std_logic; 
],[dnl -- Declarations
  signal sub_wire0	: std_logic_vector(5 downto 0);
  signal sub_wire1	: std_logic;
  signal sub_wire2	: std_logic;
  signal sub_wire3	: std_logic;
  signal sub_wire4	: std_logic_vector(1 downto 0);
  signal sub_wire5_bv	: bit_vector(0 downto 0);
  signal sub_wire5	: std_logic_vector(0 downto 0);

  component altpll
    generic (
      clk0_duty_cycle         : natural;
      lpm_type                : string;
      clk0_multiply_by        : natural;
      invalid_lock_multiplier : natural;
      inclk0_input_frequency  : natural;
      clk0_divide_by          : natural;
      pll_type                : string;
      valid_lock_multiplier   : natural;
      intended_device_family  : string;
      operation_mode          : string;
      compensate_clock        : string;
      clk0_phase_shift        : string
      );
    port (
      inclk   : in  std_logic_vector(1 downto 0);
      pllena  : in  std_logic ;
      locked  : out std_logic ;
      pfdena  : in  std_logic ;
      areset  : in  std_logic ;
      clk     : out std_logic_vector(5 downto 0)
      );
  end component;
],[dnl -- Body
  sub_wire5_bv(0 DOWNTO 0) <= "0";
  sub_wire5    <= To_stdlogicvector(sub_wire5_bv);
  sub_wire1    <= sub_wire0(0);
  c0    <= sub_wire1;
  locked    <= sub_wire2;
  sub_wire3    <= inclk0;
  sub_wire4    <= sub_wire5(0 DOWNTO 0) & sub_wire3;

  altpll_component : altpll
    generic map (
      clk0_duty_cycle         => 50,
      lpm_type                => "altpll",
      clk0_multiply_by        => MULTIPLIER,
      invalid_lock_multiplier => 5,
      inclk0_input_frequency  => 8000,
      clk0_divide_by          => 1,
      pll_type                => "AUTO",
      valid_lock_multiplier   => 1,
      intended_device_family  => "Cyclone",
      operation_mode          => "NORMAL",
      compensate_clock        => "CLK0",
      clk0_phase_shift        => "0"
      )
    port map (
      inclk  => sub_wire4,
      pllena => pllena,
      pfdena => pfdena,
      areset => areset,
      clk    => sub_wire0,
      locked => sub_wire2
  );

])
