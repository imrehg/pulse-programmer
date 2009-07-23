dnl-*-VHDL-*-
-- Pulse Control Processor register file for DDS phase accumulators.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://pulse-sequencer.sf.net
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([pcp_phase_reg_file], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
  DATA_WIDTH         : positive := 32;
  PHASE_ADJUST_WIDTH : positive := 14;
  ADDRESS_WIDTH      : positive := 4;
  REGISTER_COUNT     : positive := 16;
],[dnl -- Ports ---------------------------------------------------------------
  clk                 : in  std_logic;
  address_in          : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  phase_in            : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  addend_in           : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  set_current_in      : in  std_logic;
  phase_adjust_out    : out std_logic_vector(PHASE_ADJUST_WIDTH-1 downto 0);
  wren_in             : in  std_logic;
],[dnl -- Declarations --------------------------------------------------------
  subtype index_type is natural range 0 to REGISTER_COUNT-1;
  subtype reg is unsigned(DATA_WIDTH-1 downto 0);
  type reg_file_type is array(0 to REGISTER_COUNT-1) of reg;

  signal current_index      : index_type;
  signal address_index      : index_type;
  signal total_phase_adjust : reg;

  signal phase_accumulators : reg_file_type;
  signal addends            : reg_file_type;
  signal current_phase      : reg;
  signal addressed_phase    : reg;
  signal addend             : reg;
  signal set_current_delay  : boolean;

  -- Don't get any smart ideas about changing this to a RAM.
  -- All phase accumulators need to be updated in parallel, ya hoser.
],[dnl -- Body ----------------------------------------------------------------

  address_index <= to_integer(unsigned(address_in));

  process(clk)

  begin
    if (rising_edge(clk)) then
      if (wren_in = '1') then
          addends(address_index) <= unsigned(addend_in);
      end if;

      if (set_current_in = '1') then
        current_index <= address_index;
        -- only start the phase adjust pipeline on set current so we can access
        -- both halves of the word
        addend        <= unsigned(addend_in);
        set_current_delay <= true;
      else
        set_current_delay <= false;
      end if;

    -- Update all phase accumulators
      for i in 0 to REGISTER_COUNT-1 loop
        if ((wren_in = '1') and (i = address_index)) then
          phase_accumulators(i) <= unsigned(phase_in);
        else
          phase_accumulators(i) <=
            phase_accumulators(i) + addends(i);
        end if;
      end loop;

      if (set_current_delay) then
        current_phase <= phase_accumulators(current_index);
      end if;
      
      total_phase_adjust <= current_phase + addend;
      phase_adjust_out <=
        std_logic_vector(total_phase_adjust(DATA_WIDTH-1 downto
                                            DATA_WIDTH-PHASE_ADJUST_WIDTH));
    end if;

  end process;

-------------------------------------------------------------------------------
])
