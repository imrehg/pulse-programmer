dnl-*-VHDL-*-
-- Pulse Control Processor trigger sampler for feedback operation.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://pulse-sequencer.sf.net
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([pcp_trigger], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
  TRIGGER_WIDTH  : positive := 8;
  STABLE_COUNT   : positive := 3;
],[dnl -- Ports ---------------------------------------------------------------
   wb_clk_i                 : in  std_logic;
   sclr                     : in  std_logic;
   triggers_in              : in  std_logic_vector(TRIGGER_WIDTH-1 downto 0);
   triggers_out             : out std_logic_vector(TRIGGER_WIDTH-1 downto 0);
],[dnl -- Declarations --------------------------------------------------------
   subtype counter_type is natural range 0 to STABLE_COUNT+1;
   type counter_array_type is array(0 to TRIGGER_WIDTH-1) of counter_type;
   signal stable_counters : counter_array_type;
   signal sample_clock   : std_logic;
   signal triggers       : std_logic_vector(TRIGGER_WIDTH-1 downto 0);
clock_multiplier_component_
],[dnl -- Body ----------------------------------------------------------------

  sampling_clock : clock_multiplier
    generic map (
      MULTIPLIER => 3
    )
    port map (
      inclk0 => wb_clk_i,
      c0    => sample_clock
    );

  process(sample_clock, sclr)

  begin
    if (rising_edge(sample_clock)) then
      if (sclr = '1') then
        for i in 0 to TRIGGER_WIDTH-1 loop
          stable_counters(i) <= 0;
        end loop;
        triggers <= (others => '0');
        triggers_out <= (others => '0');
      else
        for i in 0 to TRIGGER_WIDTH-1 loop
          if (stable_counters(i) >= STABLE_COUNT) then
            triggers_out(i) <= triggers(i);
            stable_counters(i) <= 0;
          elsif (triggers_in(i) = triggers(i)) then
            stable_counters(i) <= stable_counters(i) + 1;
          end if;
        end loop;
      end if;

    end if;

  end process;

-------------------------------------------------------------------------------
])
