dnl--*-VHDL-*-
-- Atomic timer limited to 31 bits (VHDL integer limit).
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- This module can be cascaded with itself to create arbitrarily large
-- composite timers by connecting its fired_out as the clock to the next
-- higher order subtimer.
-- It can be reloadable for cascaded use or non-reloadable to create a
-- one-off timer.

-- It depends on the quantum_in being latched and constant during its
-- operation, which is usually the case, to save keeping another register
-- internally.

unit_([subtimer],
  [dnl -- Libraries
sequencer_libraries_
],[dnl -- Generics
    COUNTER_WIDTH  : positive := 4;
    -- useful if cascading to make composite timer
    AUTO_RELOAD    : boolean  := true;
],[dnl -- Ports
    clock         : in  std_logic;
    enable        : in  std_logic;
    sclr          : in  std_logic;
    load          : in  std_logic;
    count_in      : in  unsigned(COUNTER_WIDTH-1 downto 0);
    count_out     : out unsigned(COUNTER_WIDTH-1 downto 0);
    finish_out    : out std_logic;
    ripple_out    : out std_logic;
    fired_out     : out std_logic;
    debug_out     : out byte;
],[dnl -- Declarations
  constant MAX_COUNT_VALUE : positive := (2**COUNTER_WIDTH)-1;

  subtype counter_type is natural range 0 to MAX_COUNT_VALUE;

  -- these are made signals so that the whole module can be clocked faster
  signal count       : counter_type;
  signal count_reg   : counter_type;
  signal fired_sync  : std_logic;
  signal ripple_sync : std_logic;
  signal next_count  : counter_type;
  signal is_last     : boolean;
],[dnl -- Body
  process(clock, load, count_in, count, enable)

  begin

    if (rising_edge(clock)) then
      debug_out(0) <= enable;

      if (sclr = '1') then
        count       <= 0;
        fired_sync  <= '1';
        ripple_sync <= '0';
        count_reg   <= 0;
        is_last     <= false;
        finish_out <= '1';
        
      elsif (load = '1') then
        -- this case can't be moved outside rising edge of clock b/c
        -- then it is async and slows down our max setup and hold times
        
        -- don't subtract a quantum here b/c there is a one-stage overhead
        -- for the initial load, but not for auto-reloading
        -- special case to handle count of 1 (kludge?)
         if (count_in = 0) then
          -- speed up by taking in inputs directly rather than wait for reg
           count <= 0;
           count_reg <= 0;
           ripple_sync <= '1';
           if (not AUTO_RELOAD) then
             is_last <= true;
             fired_sync <= '1';
           else
             fired_sync <= '0';
           end if;
           finish_out <= '1';
         else
          -- speed up by taking in inputs directly rather than wait for reg
          -- subtract a quantum here to allow for pipeline
          count <= to_integer(count_in);
          count_reg   <= to_integer(count_in);
          fired_sync <= '0';
          ripple_sync <= '0';
          finish_out <= '0';
         end if;

      elsif ((enable = '1') and (not is_last)) then
        -- only switch on for one cycle b/c we need to act as a clock enable
        -- for next cascaded subtimer
        if (count = 0) then
            -- else load our max count
            -- statically determined reloadable behaviour
            if (AUTO_RELOAD) then -- or (fired_sync = '0')) then
              count <= MAX_COUNT_VALUE;
              fired_sync <= '0';
              finish_out <= '0';
            end if;                           -- AUTO_RELOAD
          -- if count_reg is 0, we don't know whether we are beyond
          -- the count_in of the whole timer or a zero in the middle.
          -- Thus, raise fired_sync to let our faster cascaded timer know
          -- we are ready
--           if (count_reg = 0) then
--             fired_sync <= '1';
--           else
--             fired_sync <= '0';
--           end if;
          ripple_sync <= '0';
        elsif (count <= 1) then
          count <= next_count;
          ripple_sync <= '1';
          fired_sync <= '1';
          finish_out <= '1';
        else
          count <= next_count;
          fired_sync <= '0';
        end if;

      end if;

    end if;                             -- rising_edge(clock)

    next_count <= count - 1;
    ripple_out <= ripple_sync and enable;
    fired_out <= fired_sync;
    count_out <= to_unsigned(count, COUNTER_WIDTH);
--       if ((finish_in = '1') and (count = 0)) then
--         finish_out <= '1';
--       else
--         finish_out <= '0';
--       end if;
  end process;

  debug_out(1) <= '1' when is_last else '0';
])
