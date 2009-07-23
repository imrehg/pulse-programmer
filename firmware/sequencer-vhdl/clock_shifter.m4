dnl--*-VHDL-*-
-- Clock sync/buffer using Altera PLL (non-portable)
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([clock_shifter],
  [dnl -- Libraries
sequencer_libraries_
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
],[dnl -- Generics
  SHIFT_NS : natural := 5;
],[dnl -- Ports
  inclk0  : in  std_logic  := '0';
  pllena  : in  std_logic  := '1';
  pfdena  : in  std_logic  := '1';
  areset  : in  std_logic  := '0';
  c0      : out std_logic;
  c1      : out std_logic;
  locked  : out std_logic; 
],[dnl -- Declarations
	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC ;
	SIGNAL sub_wire2	: STD_LOGIC ;
	SIGNAL sub_wire3	: STD_LOGIC ;
	SIGNAL sub_wire4	: STD_LOGIC ;
	SIGNAL sub_wire5	: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL sub_wire6_bv	: BIT_VECTOR (0 DOWNTO 0);
	SIGNAL sub_wire6	: STD_LOGIC_VECTOR (0 DOWNTO 0);

	COMPONENT altpll
	GENERIC (
		clk1_divide_by		: NATURAL;
		clk1_phase_shift		: STRING;
		clk0_duty_cycle		: NATURAL;
		lpm_type		: STRING;
		clk0_multiply_by		: NATURAL;
		invalid_lock_multiplier		: NATURAL;
		inclk0_input_frequency		: NATURAL;
		clk0_divide_by		: NATURAL;
		clk1_duty_cycle		: NATURAL;
		pll_type		: STRING;
		valid_lock_multiplier		: NATURAL;
		clk1_multiply_by		: NATURAL;
		intended_device_family		: STRING;
		operation_mode		: STRING;
		compensate_clock		: STRING;
		clk0_phase_shift		: STRING
	);
	PORT (
			inclk	: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			pllena	: IN STD_LOGIC ;
			locked	: OUT STD_LOGIC ;
			pfdena	: IN STD_LOGIC ;
			areset	: IN STD_LOGIC ;
			clk	: OUT STD_LOGIC_VECTOR (5 DOWNTO 0)
	);
	END COMPONENT;
],[dnl -- Body
	sub_wire6_bv(0 DOWNTO 0) <= "0";
	sub_wire6    <= To_stdlogicvector(sub_wire6_bv);
	sub_wire2    <= sub_wire0(1);
	sub_wire1    <= sub_wire0(0);
	c0    <= sub_wire1;
	c1    <= sub_wire2;
	locked    <= sub_wire3;
	sub_wire4    <= inclk0;
	sub_wire5    <= sub_wire6(0 DOWNTO 0) & sub_wire4;

	altpll_component : altpll
	GENERIC MAP (
		clk1_divide_by => 1,
		clk1_phase_shift => "7000",
		clk0_duty_cycle => 50,
		lpm_type => "altpll",
		clk0_multiply_by => 1,
		invalid_lock_multiplier => 5,
		inclk0_input_frequency => 8000,
		clk0_divide_by => 1,
		clk1_duty_cycle => 50,
		pll_type => "AUTO",
		valid_lock_multiplier => 1,
		clk1_multiply_by => 1,
		intended_device_family => "Cyclone",
		operation_mode => "NORMAL",
		compensate_clock => "CLK1",
		clk0_phase_shift => "0"
	)
	PORT MAP (
		inclk => sub_wire5,
		pllena => pllena,
		pfdena => pfdena,
		areset => areset,
		clk => sub_wire0,
		locked => sub_wire3
	);
])
