divert(-1)dnl
dnl--*-VHDL-*-
# -----------------------------------------------------------------------------
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
# -----------------------------------------------------------------------------

###############################################################################
# Memory controller unit
#   $1 = entity name
#   $2 = libraries
#   $3 = ports
#   $4 = declarations
#   $5 = component instantiation

define([memory_unit_], [dnl

unit_([$1],
  [dnl -- Libraries
$2
],[dnl -- Generics
    DATA_WIDTH          : positive := 8;
    ADDRESS_WIDTH       : positive := 4;
    READ_PIPELINE_DELAY : positive := 1;
],[dnl -- Ports
$3
    wb_clk_i    : in  std_logic;
    wb_cyc_i    : in  std_logic;
    wb_stb_i    : in  std_logic;
    wb_we_i     : in  std_logic;
    wb_adr_i    : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    wb_dat_i    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    wb_dat_o    : out std_logic_vector(DATA_WIDTH-1 downto 0);
    wb_ack_o    : out std_logic;
    burst_in    : in  std_logic;
    one_shot_in : in  std_logic := '1';
    addr_out    : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
],[dnl -- Declarations
memory_subtypes_
  signal memory_addr       : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  signal read_ack_delay    : std_logic_vector(0 to READ_PIPELINE_DELAY-1);
  signal loaded            : boolean;
  signal memory_addr_burst : memory_address_unsigned_type;
  signal ack_inter         : std_logic;
  signal ack_fired         : boolean;
$4
],[dnl -- Body
$5

  process(wb_clk_i, wb_cyc_i, wb_stb_i, wb_adr_i, loaded, burst_in,
          memory_addr_burst)

  begin

    if (rising_edge(wb_clk_i)) then

      if (wb_cyc_i = '1') then
-------------------------------------------------------------------------------
        if (wb_stb_i = '1') then
          if (burst_in = '1') then
            if (not loaded) then
              loaded <= true;
              memory_addr_burst <= unsigned(wb_adr_i) + 1;
            else
              memory_addr_burst <= memory_addr_burst + 1;
            end if;
            for i in 0 to READ_PIPELINE_DELAY-2 loop
              read_ack_delay(i) <= read_ack_delay(i+1);
            end loop;
            read_ack_delay(READ_PIPELINE_DELAY-1) <= '1';
          else
            if (one_shot_in = '1') then
              if (not ack_fired) then
                read_ack_delay(READ_PIPELINE_DELAY-1) <= '1';
                ack_fired <= true;
              else
                read_ack_delay(READ_PIPELINE_DELAY-1) <= '0';
                ack_fired <= false;
              end if;
            else
              read_ack_delay(READ_PIPELINE_DELAY-1) <= '1';
            end if;
            for i in 0 to READ_PIPELINE_DELAY-2 loop
              read_ack_delay(i) <= read_ack_delay(i+1);
            end loop;
          end if;

-------------------------------------------------------------------------------
        else -- wb_stb_i = '0'
          for i in 0 to READ_PIPELINE_DELAY-1 loop
            read_ack_delay(i) <= '0';
          end loop;
          ack_fired <= false;
        end if; -- wb_stb_i = '1'
-------------------------------------------------------------------------------

      else
        for i in 0 to READ_PIPELINE_DELAY-1 loop
          read_ack_delay(i) <= '0';
        end loop;
        ack_fired <= false;
        loaded <= false;
      end if; -- wb_cyc_i = '1'

    end if; -- rising_edge(wb_clk_i);

    -- load the starting address by raising burst/cyc and keeping stb low
    -- for one cycle
    if (loaded) then
      memory_addr <= std_logic_vector(memory_addr_burst);
    else
      memory_addr <= wb_adr_i;
    end if;

  end process;

  -- Ack is immediate when writing, delayed by one cycle when reading
  ack_inter <= wb_stb_i when (wb_we_i = '1')  else read_ack_delay(0);
  wb_ack_o <= ack_inter and wb_cyc_i;

  addr_out <= memory_addr;
])
])

###############################################################################
# Memory subtype
define([memory_subtypes_], [dnl
  subtype memory_address_type is std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  subtype memory_address_unsigned_type is unsigned(ADDRESS_WIDTH-1 downto 0);
  subtype memory_address_reversed_type is unsigned(0 to ADDRESS_WIDTH-1);])

###############################################################################
# Memory signals

define([memory_signals_], [dnl
memory_subtypes_
  signal overlap          : boolean;
  signal mem_we           : std_logic;
  signal mem_cyc          : std_logic;
  signal mem_stb          : std_logic;
  signal mem_addr_in      : memory_address_type;
  signal mem_ack          : std_logic;
  signal mem_burst        : std_logic;
  signal mem_dat_i        : std_logic_vector(0 to DATA_WIDTH-1);
  signal mem_precache     : std_logic_vector(0 to DATA_WIDTH-1);
  signal mem_switch       : boolean;
  signal mem_dat_o        : std_logic_vector(0 to DATA_WIDTH-1);
  signal mem_addr_out     : memory_address_type;
])

###############################################################################
# Memory reset behaviour

define([memory_reset_], [dnl
      mem_we              <= '0';
      mem_burst           <= '0';
      mem_cyc             <= '0';
])

###############################################################################
# Memory start write burst
#  $1 = start address

define([memory_start_write_burst_], [dnl
            mem_cyc         <= '1';
            mem_burst       <= '1';
            mem_we          <= '1';
            memory_addr_async := $1;
])

###############################################################################
# Memory start read burst
#  $1 = start address

define([memory_start_read_burst_], [dnl
            mem_cyc         <= '1';
            mem_burst       <= '1';
            mem_we          <= '0';
            memory_addr_async := $1;
])

###############################################################################
# Memory end burst

define([memory_end_burst_], [dnl
            mem_cyc         <= '0';
            mem_burst       <= '0';
])

###############################################################################
# Memory variables

define([memory_variables_], [dnl
    variable memory_addr_async : memory_address_unsigned_type;
--    variable overlap           : boolean;
])

###############################################################################
# Memory instance

define([memory_instance_], [dnl
  storage : memory_controller
    generic map (
      ADDRESS_WIDTH => ADDRESS_WIDTH,
      DATA_WIDTH    => DATA_WIDTH
      )
    port map (
      wb_clk_i      => wb_clk_i,
      wb_cyc_i      => mem_cyc,
      wb_stb_i      => mem_stb,
      wb_we_i       => mem_we,
      wb_adr_i      => mem_addr_in,
      wb_dat_i      => mem_dat_i,
      wb_dat_o      => mem_dat_o,
      wb_ack_o      => mem_ack,
      burst_in      => mem_burst,
      one_shot_in   => '1',
      addr_out      => mem_addr_out
      );])

###############################################################################
# Memory sizer instance

define([memory_sizer_instance_], [dnl
  sizer : memory_sizer
    generic map (
      VIRTUAL_ADDRESS_WIDTH  => ADDRESS_WIDTH,
      VIRTUAL_DATA_WIDTH     => DATA_WIDTH,
      PHYSICAL_ADDRESS_WIDTH => PHYSICAL_ADDRESS_WIDTH,
      DATA_SCALE_TWO_POWER   => DATA_SCALE_TWO_POWER,
      PHYSICAL_DATA_WIDTH    => PHYSICAL_DATA_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i            => wb_clk_i,
      wb_rst_i            => wb_rst_i,
      -- Slave interface to client of virtual memory
      wbs_cyc_i           => mem_cyc,
      wbs_stb_i           => mem_stb,
      wbs_we_i            => mem_we,
      wbs_adr_i           => mem_addr_in,
      wbs_dat_i           => mem_dat_i,
      wbs_dat_o           => mem_dat_o,
      wbs_ack_o           => mem_ack,
      burst_in            => mem_burst,
      burst_addr_out      => mem_addr_out,
      -- Master interface to physical memory
      wbm_cyc_o           => sram_wbm_cyc_o,
      wbm_stb_o           => sram_wbm_stb_o,
      wbm_we_o            => sram_wbm_we_o,
      wbm_adr_o           => sram_wbm_adr_o,
      wbm_dat_o           => sram_wbm_dat_o,
      wbm_dat_i           => sram_wbm_dat_i,
      wbm_ack_i           => sram_wbm_ack_i,
      burst_out           => sram_burst,
      burst_addr_in       => sram_burst_addr_in,
      phy_start_addr      => phy_start_prefix
    );
])

###############################################################################
# Start the memory precache pipeline (3 stages)
#   $1 = start index of state handlers
#   $2 = start address

define([memory_precache_states_], [dnl
map_loop_([i], $1, [byte_count_transform_], [dnl
[dnl -- start pipeline by raising cyc and stb (3 cycles early)
              mem_stb <= '1';
              mem_switch <= false;
memory_start_read_burst_(ifelse($2, , [memory_start], [$2]))         ],
[dnl -- memory latches onto address "0"
                                                     ],
[dnl -- memory data at address "0" now on mem_dat_o
              mem_precache <= mem_dat_o;             
              mem_stb <= '0';                        ],
[dnl -- memory data at address "1" now on mem_dat_o
 dnl -- memory data at address "0" now on mem_precache
              mem_precache <= mem_dat_o;
              wbm_dat_o    <= mem_precache;
              wbm_cyc_o <= '1';
              wbm_stb_o <= '1';
              state := transmit_data;                ]
])])

###############################################################################
# Memory master state (sending starting from address 0)
#   $1 = ending value

define([memory_master_state_], [dnl
        when transmit_data =>

          -- this allows our master to release us while we are writing to slave
          if (wbs_cyc_i = '0') then
            overlap <= true;
          end if;

          if ((wbm_ack_i = '1') or (mem_ack = '1')) then
            mem_precache <= mem_dat_o;
          end if;

          -- sending data to our slave, transport layer

          if (wbm_ack_i = '1') then
            if (mem_switch) then
              wbm_dat_o <= mem_dat_o;
            else 
              mem_switch <= true;
              wbm_dat_o <= mem_precache;
            end if;

            if (unsigned(mem_addr_out) >= $1) then
              mem_stb <= '0';
memory_end_burst_
              -- special case: for length of one, don't stall b/c pipeline
              -- didn't need to be filled (hack).
              if (to_integer($1) <= 1) then
                wbm_cyc_o <= '0';
                wbm_stb_o <= '0';
                state := done_state;
              else
                state := memory_stall;
              end if;
            end if;

          else
            mem_switch <= false;
          end if;
-------------------------------------------------------------------------------
        when memory_stall =>
          -- stall for one more stage for ack of last data.
          if (wbm_ack_i = '1') then
            wbm_cyc_o <= '0';
            wbm_stb_o <= '0';
            state     := done_state;
          end if;
])

###############################################################################
# Memory master asynchronous behaviour; use with memory_master_state_ above

define([memory_master_async_], [dnl
    case (state) is
      when transmit_data =>
        mem_stb <= wbm_ack_i;
      when others => null;
    end case;

    -- allow memory address to change asynchronously to avoid pipeline delay
    mem_addr_in <= std_logic_vector(memory_addr_async);
])

# Renable output for processed file
divert(0)dnl
