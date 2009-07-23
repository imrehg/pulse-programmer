divert(-1)dnl
# Macros for SRAM signals and instances
# ---------------------------------------------------------------------------
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
# ---------------------------------------------------------------------------

###############################################################################
# SRAM instance

define([sram_instance_], [dnl
  sram : sram_controller
    generic map (
    DATA_WIDTH          => SRAM_DATA_WIDTH,
    ADDRESS_WIDTH       => SRAM_ADDRESS_WIDTH,
    READ_PIPELINE_DELAY => 3 -- b/c of extra data latching
    )
  port map (
    -- Physical SRAM device pins
    sram_data           => sram_data,
    sram_addr           => sram_addr,
    sram_nOE            => sram_nOE,
    sram_nGW            => sram_nGW,
--    sram_clk            => sram_clk,
    sram_nCE1           => sram_nCE1,

    wb_clk_i            => pcp_clock,
    wb_cyc_i            => sram_wb_cyc,
    wb_stb_i            => sram_wb_stb,
    wb_we_i             => sram_wb_we,
    wb_adr_i            => sram_wb_adr,
    wb_dat_i            => sram_wb_write_data,
    wb_dat_o            => sram_wb_read_data,
    wb_ack_o            => sram_wb_ack,
    burst_in            => sram_burst,
    addr_out            => sram_addr_out,
    one_shot_in         => '0'
    );
  sram_clk <= sram_clock;
])

###############################################################################
# Meta-macro for sizer signals
#   $1 = suffix to append to name
#   $2 = width of data word in bits
#   $3 = physical address width (if empty, uses sram_address_type)
#   $4 = physical data width (if empty, uses sram_data_type)
#   $5 = 
define([sram_sizer_signals_], [dnl
  -- Mux signals from arbiter to the SRAM sizer
  -- Before the sizer from client of virtual address space
  signal pre_sizer$1_wb_cyc         : std_logic;
  signal pre_sizer$1_wb_stb         : std_logic;
  signal pre_sizer$1_wb_we          : std_logic;
  signal pre_sizer$1_wb_adr         : virtual$1_address_type;
  signal pre_sizer$1_wb_write_data  : std_logic_vector($1-1 downto 0);
  signal pre_sizer$1_wb_read_data   : std_logic_vector($1-1 downto 0);
  signal pre_sizer$1_wb_ack         : std_logic;
  signal pre_sizer$1_burst          : std_logic;
  signal pre_sizer$1_burst_addr     : virtual$1_address_type;
  -- After the sizer itself a client of the physical address space
  signal post_sizer$1_wb_cyc        : std_logic;
  signal post_sizer$1_wb_gnt        : std_logic;
  signal post_sizer$1_wb_stb        : std_logic;
  signal post_sizer$1_wb_we         : std_logic;
  signal post_sizer$1_wb_adr        : sram_address_type;
  signal post_sizer$1_wb_write_data : sram_data_type;
  signal post_sizer$1_wb_ack        : std_logic;
  signal post_sizer$1_burst         : std_logic;
])

###############################################################################
# Meta-macro for SRAM sizer instance.
#  $1 = suffix to append to name
#  $2 = width of data word in bits
#  $3 = DATA_SCALE_TWO_POWER
#  $4 = PHYSICAL_ADDRESS_WIDTH (if empty, defaults to SRAM_ADDRESS_WIDTH)
#  $5 = PHYSICAL_DATA_WIDTH (if empty, defaults to SRAM_DATA_WIDTH)
#  $6 = VIRTUAL_ADDRESS_WIDTH (if empty, defaults to $4+$2)
#  $7 = ENDIANNESS
define([sram_sizer_instance_], [dnl
  define([p_addr_width], [ifelse([$4], , [SRAM_ADDRESS_WIDTH], [$4])])
  define([p_data_width], [ifelse([$5], , [SRAM_DATA_WIDTH], [$5])])
  define([v_addr_width], [ifelse([$6], , [p_addr_width+$3], [$6])])
  define([v_data_width], [$2])
  sizer$1 : memory_sizer
    generic map (
      VIRTUAL_ADDRESS_WIDTH  => v_addr_width,
      VIRTUAL_DATA_WIDTH     => v_data_width,
      PHYSICAL_ADDRESS_WIDTH => p_addr_width,
      DATA_SCALE_TWO_POWER   => $3,
      ifelse([$7], , , [ENDIANNESS => $7,])
      PHYSICAL_DATA_WIDTH    => p_data_width
      )
    port map (
      -- Wishbone common signals
      wb_clk_i          => pcp_clock,
      wb_rst_i          => wb_rst_i,
      -- Slave interface to client of virtual memory
      wbs_cyc_i         => pre_sizer$1_wb_cyc,
      wbs_stb_i         => pre_sizer$1_wb_stb,
      wbs_we_i          => pre_sizer$1_wb_we,
      wbs_adr_i         => pre_sizer$1_wb_adr(v_addr_width-1 downto 0),
      wbs_dat_i         => pre_sizer$1_wb_write_data(v_data_width-1 downto 0),
      wbs_dat_o         => pre_sizer$1_wb_read_data(v_data_width-1 downto 0),
      wbs_ack_o         => pre_sizer$1_wb_ack,
      burst_in          => pre_sizer$1_burst,
      burst_addr_out    => pre_sizer$1_burst_addr(v_addr_width-1 downto 0),
      -- Master interface to physical memory
      wbm_cyc_o         => post_sizer$1_wb_cyc,
      wbm_gnt_i         => post_sizer$1_wb_gnt,
      wbm_stb_o         => post_sizer$1_wb_stb,
      wbm_we_o          => post_sizer$1_wb_we,
      wbm_adr_o         => post_sizer$1_wb_adr(p_addr_width-1 downto 0),
      wbm_dat_o         => post_sizer$1_wb_write_data(p_data_width-1 downto 0),
      wbm_dat_i         => sram_latched_read_data(p_data_width-1 downto 0),
      wbm_ack_i         => post_sizer$1_wb_ack,
      burst_out         => post_sizer$1_burst,
      burst_addr_in     => ifelse([$4], , [sram_addr_out(p_addr_width-1 downto 0)], [(others => '0')])
    );
])

define([fifo8_signals_], [dnl
  signal fifo8_wrusedw : std_logic_vector(FIFO8_WORD_COUNT_WIDTH-1 downto 0);
])

###############################################################################
# Async fifo's for reading and writing between slow 8-bit and fast 32-bit
define([fifo8_instances_], [dnl
  fifo8 : async_read_write
    generic map (
      DATA_WIDTH       => NETWORK_DATA_WIDTH,
      ADDRESS_WIDTH    => VIRTUAL8_ADDRESS_WIDTH,
      WORD_COUNT_WIDTH => FIFO8_WORD_COUNT_WIDTH,
      STABLE_COUNT     => ASYNC_FIFO_STABLE_COUNT,
      HYSTERESIS       => ASYNC_FIFO_HYSTERESIS
      )
    port map (
      wb_rst_i         => wb_rst_i,
      wbs_clk_i        => network_clock,
      wbs_cyc_i        => ptp_sram_wb_cyc,
      wbs_stb_i        => ptp_sram_wb_stb,
      wbs_we_i         => ptp_sram_wb_we,
      wbs_adr_i        => ptp_sram_wb_adr,
      wbs_dat_i        => ptp_sram_wb_write_data,
      wbs_dat_o        => ptp_sram_wb_read_data,
      wbs_ack_o        => ptp_sram_wb_ack,
      wbm_clk_i        => pcp_clock,
      wbm_cyc_o        => pre_sizer8_wb_cyc,
      wbm_stb_o        => pre_sizer8_wb_stb,
      wbm_we_o         => pre_sizer8_wb_we,
      wbm_adr_o        => pre_sizer8_wb_adr,
      wbm_dat_i        => pre_sizer8_wb_read_data,
      wbm_dat_o        => pre_sizer8_wb_write_data,
      wbm_ack_i        => pre_sizer8_wb_ack,
      wrusedw_out      => fifo8_wrusedw
      );
  pre_sizer8_burst <= '1';
])

###############################################################################
# SRAM 8-bit sizer arbiter signals
define([sram_arbiter_signals_], [dnl
--  constant SRAM_MASTER_COUNT : positive := 2;
--  signal sram_arbiter_ack : multibus_bit(0 to SRAM_MASTER_COUNT-1);
--  signal sram_arbiter_gnt : multibus_bit(0 to SRAM_MASTER_COUNT-1);
  type winner_type is (
    pcp_winner,
    ptp_winner
    );

  signal winner : winner_type;
])

###############################################################################
# SRAM 32-bit sizer arbiter between 8-bit sizer/async FIFO and PCP32/pcp1
define([sram_arbiter_instance_], [dnl

  sram_arbiter : process(pcp_clock, wb_rst_i, winner, pcp_sram_wb_cyc,
                         pcp_sram_wb_stb, pcp_sram_wb_adr, sram_wb_ack,
                         pcp_sram_burst, post_sizer8_wb_stb, post_sizer8_burst,
                         post_sizer8_wb_cyc, post_sizer8_wb_we,
                         post_sizer8_wb_adr, mac_address_latched)

    type state_type is (
      idle,
      pcp_active,
      ptp_active
      );

    variable state  : state_type;

  begin
    if (wb_rst_i = '1') then
      winner      <= pcp_winner;
      state       := idle;
    elsif (rising_edge(pcp_clock)) then
      case (state) is
        when idle =>
          post_sizer8_wb_gnt <= '0';
          if (pcp_sram_wb_cyc = '1') then
            state  := pcp_active;
          elsif (post_sizer8_wb_cyc = '1') then
            winner <= ptp_winner;
            state  := ptp_active;
          end if;
        when pcp_active =>
          -- always "grant" to prevent ptp from hanging
          post_sizer8_wb_gnt <= '1';
          if (pcp_sram_wb_cyc = '0') then
            state := idle;
          end if;
        when ptp_active =>
          post_sizer8_wb_gnt <= '1';
          -- delay by one to allow from SRAM chip's select
          if (post_sizer8_wb_cyc = '0') then
            winner <= pcp_winner;
            state := idle;
          end if;
      end case;
      sram_latched_read_data <= sram_wb_read_data;
      sram_wb_write_data <= post_sizer8_wb_write_data;

      if (winner = pcp_winner) then
        sram_wb_cyc <= pcp_sram_wb_cyc;
        sram_wb_stb <= pcp_sram_wb_stb;
        sram_wb_we  <= '0'; -- PCP is read-only
        sram_wb_adr <= pcp_sram_wb_adr;
        pcp_sram_wb_ack <= sram_wb_ack;
        sram_burst <= pcp_sram_burst;
        post_sizer8_wb_ack <= post_sizer8_wb_stb;
      else -- PTP winner
        sram_wb_cyc <= post_sizer8_wb_cyc;
        -- Do not propagate strobes in the pipeline until acks have cleared
        sram_wb_stb <= post_sizer8_wb_stb and (not post_sizer8_wb_ack);
        sram_wb_we  <= post_sizer8_wb_we;
        sram_wb_adr <= post_sizer8_wb_adr;
        post_sizer8_wb_ack <= sram_wb_ack;
        sram_burst <= post_sizer8_burst;
        pcp_sram_wb_ack <= '0'; -- Do not ack to PCP b/c memory not ready
      end if;

    end if; -- rising_edge(pcp_clock)

  end process;

])

###############################################################################
# SRAM controller signals
define([sram_controller_signals_], [dnl
 signal sram_clock         : std_logic;
 signal sram_wb_cyc        : std_logic;
 signal sram_wb_stb        : std_logic;
 signal sram_wb_we         : std_logic;
 signal sram_wb_adr        : sram_address_type;
 signal sram_wb_write_data : sram_data_type;
 signal sram_wb_read_data  : sram_data_type;
 signal sram_latched_read_data  : sram_data_type;
 signal sram_wb_ack        : std_logic;
 signal sram_burst         : std_logic;
 signal sram_addr_out      : sram_address_type;
])

###############################################################################
# All SRAM signals
define([sram_signals_], [dnl
sram_controller_signals_
sram_arbiter_signals_
sram_sizer_signals_(8)

fifo8_signals_

async_read_write_component_
sram_controller_component_
])

###############################################################################
# All SRAM instances
define([sram_instances_], [dnl
sram_instance_
sram_sizer_instance_(8, 8, 2, , , , big_endian)

sram_arbiter_instance_

fifo8_instances_

])

# Renable output for processed file
divert(0)dnl