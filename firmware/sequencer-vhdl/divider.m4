dnl--*-VHDL-*-
-- Binary divider with rounding up.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Pipelined circuit that shifts, compares, and subtracts the divisor from
-- the dividend. If there is a remainder, it adds one to the quotient.
-- Arguments are assumed to be unsigned.

unit_([divider],
  [dnl -- Libraries
use ieee.numeric_std.all;
],[dnl -- Generics
    -- the number of bits and stages in the pipeline
    WIDTH        : positive := 6;
],[dnl -- Ports
wb_common_port_
    wb_stb_i      : in     std_logic;
    dividend      : in     unsigned(WIDTH-1 downto 0);
    divisor       : in     unsigned(WIDTH-1 downto 0);
    quotient      : out    unsigned(WIDTH-1 downto 0);
    wb_ack_o      : out    std_logic;
],[dnl -- Declarations
  subtype twice_width_type is unsigned((2*WIDTH)-1 downto 0);
  signal remainder : twice_width_type;
  signal current_divisor : twice_width_type;
  signal bit_count : natural range 0 to WIDTH+1;
  signal result : unsigned(WIDTH-1 downto 0);
],[dnl -- Body

  process(wb_rst_i, wb_clk_i)

    type state_type is (
     idle,
     dividing,
     done_state
     );
    variable state : state_type;

-------------------------------------------------------------------------------
  begin

    if (wb_rst_i = '1') then
      result <= (others => '0');
      state := idle;

    elsif (rising_edge(wb_clk_i)) then
      case (state) is
-------------------------------------------------------------------------------
        when idle =>
          wb_ack_o <= '0';
          if (wb_stb_i = '1') then
            remainder((2*WIDTH)-1 downto 0) <= (others => '0');
            remainder(WIDTH-1 downto 0) <= dividend;
            current_divisor((2*WIDTH)-1 downto WIDTH) <= divisor;
            current_divisor(WIDTH-1 downto 0) <= (others => '0');
            bit_count <= 0;
            state := dividing;
          end if;
-------------------------------------------------------------------------------
        when dividing =>
          bit_count <= bit_count + 1;
          if (current_divisor <= remainder) then
            result <= result(WIDTH-2 downto 0) & '1';
            remainder <= remainder - current_divisor;
          else
            result <= result(WIDTH-2 downto 0) & '0';
          end if;
          current_divisor <= '0' & current_divisor((2*WIDTH)-1 downto 1);
          if (bit_count >= WIDTH) then
            state := done_state;
          end if;
-------------------------------------------------------------------------------
        when done_state =>
          wb_ack_o <= '1';
          if (remainder /= 0) then
            quotient <= result + 1;
          else
            quotient <= result;
          end if;
          if (wb_stb_i = '0') then
            state := idle;
          end if;
-------------------------------------------------------------------------------
        when others =>
          state := done_state;
      end case;
    end if;                             -- rising_edge(wb_clk_i)

  end process;
])
