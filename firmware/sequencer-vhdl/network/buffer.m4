dnl-*-VHDL-*-
divert(-1)dnl
# Macros for network buffer modules
dnl ---------------------------------------------------------------------------
dnl MIT-NIST-ARDA Pulse Sequencer
dnl http://qubit.media.mit.edu/sequencer
dnl Paul Pham
dnl MIT Center for Bits and Atoms
dnl ---------------------------------------------------------------------------

###############################################################################
#  $1 = buffer design unit name
#  $2 = generics
#  $3 = ports
#  $4 = declarations
#  $5 = latched outputs
#  $6 = reset behaviour
#  $7 = cyc behaviour
#  $8 = additional state names
#  $9 = additional state behaviours
#  $10 = alternate memory start address

define([buffer_unit_], [dnl
unit_([$1], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
    ADDRESS_WIDTH    : positive := 10;
$2
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
ifelse($11, , [dnl
    -- Wishbone master interface to transport layer
wb_master_port_
])
    -- Wishbone slave interface from ip_receive
wb_slave_port_
    -- Wishbone header slave interface, with same cyc_i as above.
    load              : in     std_logic;
    match_ack         : buffer std_logic;
    checksum_error_in : in     std_logic;
    length_in         : in     ip_total_length;
    length_out        : out    ip_total_length;
    debug_led_out     : out    byte;
$3
],[dnl -- Declarations --------------------------------------------------------
byte_count_signals_(3)
memory_signals_
    signal length : ip_total_length;
$4
],[dnl -- Body ----------------------------------------------------------------
ifelse($11, , memory_instance_, [$11])

  debug_led_out(7) <= load;
--  debug_led_out(7) <= wbs_cyc_i;
  debug_led_out(6) <= wbs_stb_i;
  debug_led_out(5) <= wbs_ack_o;
  debug_led_out(4) <= wbm_cyc_o;
  debug_led_out(3) <= wbm_stb_o;
  debug_led_out(2) <= wbm_ack_i;

$5
  length_out <= length;
  process(wb_rst_i, wb_clk_i, wbs_cyc_i, wbs_stb_i, wbm_ack_i,
          mem_ack, match_ack, mem_addr_out, length)

    constant FRAGMENT_OFFSET_START_INDEX : natural :=
      IP_FRAG_OFFSET_WIDTH - ADDRESS_WIDTH + 3;

    constant TOTAL_LENGTH_START_INDEX : natural :=
      IP_TOTAL_LENGTH_WIDTH - ADDRESS_WIDTH;

    type reassembly_states is (
      idle,
      receive_latch,
      receive_data,
      receive_ack,
      precache_data,
      transmit_data,
      memory_stall,
$8
      done_state,
      wait_slave_ack
      );
    
    variable state            : reassembly_states;
    variable complete         : boolean;
--     variable ack_async        : std_logic;
    variable mem_addr_out_rev : memory_address_reversed_type;
    variable memory_start_rev : memory_address_reversed_type;
    variable memory_end_rev   : memory_address_reversed_type;
    variable memory_start     : memory_address_unsigned_type;
    variable memory_end       : memory_address_unsigned_type;
    variable length_rev       : memory_address_reversed_type;
memory_variables_

  begin

    if (wb_rst_i = '1') then
      complete   := false;
      state      := idle;
      length     <= (others => '0');
      wbm_stb_o  <= '0';
      wbm_cyc_o  <= '0';
      wbs_ack_o  <= '0';
memory_reset_
      match_ack  <= '0';
$6

    elsif (rising_edge(wb_clk_i)) then

      case (state) is

        when idle =>
          debug_led_out(1 downto 0) <= B"00";
          overlap <= false;
          mem_stb <= '0';

          if (complete) then
            -- if we are complete, then send the datagram to next layer
            -- strobe memory one cycle to load burst start address.
            byte_count       <= 0;
ifelse($10, , [memory_start_rev := (others => '0');])
            state            := precache_data;

          elsif (wbs_cyc_i = '1') then
            -- otherwise if our master has a new fragment, go fetch it
$7            
          end if;                       -- wbs_cyc_i = '1'
        -----------------------------------------------------------------------
        when receive_latch =>
          -- this extra stage makes sure memory_start has the right address
          -- before starting a memory write burst.
memory_start_write_burst_(memory_start)
          state := receive_data;
        -----------------------------------------------------------------------
        when receive_data =>
          if ((wbs_cyc_i = '0') or
              (mem_addr_out >= std_logic_vector(memory_end))) then
memory_end_burst_
            mem_we    <= '0';
            state := done_state;
          elsif (wbs_stb_i = '1') then
            mem_dat_i <= wbs_dat_i;
            mem_stb <= '1';
            wbs_ack_o <= '1';
            state := receive_ack;
          end if;
        -----------------------------------------------------------------------
        when receive_ack =>
          wbs_ack_o <= '0';
          if (mem_ack = '1') then
            mem_stb <= '0';
            state := receive_data;
          end if;
        -----------------------------------------------------------------------
        when precache_data =>
          case (byte_count) is
memory_precache_states_(0)
            when others => null;
          end case;
          byte_count <= byte_count + 1;
          complete := false;
        -----------------------------------------------------------------------
memory_master_state_([memory_end])
-------------------------------------------------------------------------------
$9
        -----------------------------------------------------------------------
        when done_state =>
          debug_led_out(1 downto 0) <= B"11";
memory_end_burst_
          mem_we    <= '0';
          match_ack <= '0';
          if (checksum_error_in = '1') then
            -- if we thought we were complete before, we were wrong
            complete := false;
          end if;
          if (overlap or (wbs_cyc_i = '0')) then
            state := wait_slave_ack;
            wbs_ack_o <= '0';
          else
            wbs_ack_o <= wbs_stb_i;       -- ack out any errant data
          end if;
       ------------------------------------------------------------------------
       when wait_slave_ack =>
          debug_led_out(1 downto 0) <= B"01";
          if (wbm_ack_i = '0') then
            state := idle;
          end if;
        -----------------------------------------------------------------------
        when others =>
          state := done_state;

      end case;

    end if; -- rising_edge(wb_clk_i)
memory_master_async_

  -- allow memory address to change asynchronously to avoid pipeline delay
  -- perform memory address conversions
  for i in 0 to ADDRESS_WIDTH-1 loop
    memory_start(ADDRESS_WIDTH-1 - i) := memory_start_rev(i);
    memory_end(ADDRESS_WIDTH-1 - i) := memory_end_rev(i);
    mem_addr_out_rev(i) := mem_addr_out(ADDRESS_WIDTH-1 - i);
    length_rev(i) := length(ADDRESS_WIDTH-1 - i);
  end loop;

  end process;
])
])

###############################################################################
# Buffer-multiplexer manager macro
#   $1 = design unit name
#   $2 = ports
#   $3 = multiplexed subtypes and signals
#   $4 = buffer design unit name
#   $5 = buffer instance assignments
#   $6 = arbiter assignments for winner
#   $7 = arbiter assignments for losers
  
define([buffer_mux_unit_], [dnl
unit_([$1], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
    BUFFER_ADDRESS_WIDTH : positive := 11;  -- 2**11 = 2 k buffer by default
    BUFFER_COUNT_WIDTH   : natural  := 1;  -- two buffers by default
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
    -- Wishbone master interface to transport layer
wb_master_port_
    length_out         : out ip_total_length;
    debug_led_out      : out byte;
    buffer_debug_led_out : out multibus_byte(0 to 2**BUFFER_COUNT_WIDTH-1);
    -- Wishbone slave interface from ip_receive
wb_slave_port_
    length_in          : in  ip_total_length;
    checksum_error_in  : in  std_logic;
$2
],[dnl -- Declarations --------------------------------------------------------
$4_component_
  -----------------------------------------------------------------------------
  -- Constants and global signals

  constant BUFFER_COUNT : positive := 2**BUFFER_COUNT_WIDTH;

  subtype buffer_index_type is natural range 0 to BUFFER_COUNT-1;
  signal current_buffer   : buffer_index_type;
  signal next_buffer      : buffer_index_type;

  -----------------------------------------------------------------------------
  -- IP buffer signals and subtypes

  -- Master interface to transport layer arbiter
  signal buffer_wbm_gnt         : multibus_bit (0 to BUFFER_COUNT-1);
  signal buffer_wbm_cyc_o       : multibus_bit (0 to BUFFER_COUNT-1);
  signal buffer_wbm_stb_o       : multibus_bit (0 to BUFFER_COUNT-1);
  signal buffer_wbm_dat_o       : multibus_byte(0 to BUFFER_COUNT-1);
  signal buffer_wbm_ack_i       : multibus_bit (0 to BUFFER_COUNT-1);

  -- Slave interface to ip_transport
  signal buffer_wbs_cyc_i       : multibus_bit (0 to BUFFER_COUNT-1);
  signal buffer_wbs_stb_i       : multibus_bit (0 to BUFFER_COUNT-1);
  signal buffer_wbs_dat_i       : multibus_byte(0 to BUFFER_COUNT-1);
  signal buffer_wbs_ack_o       : multibus_bit (0 to BUFFER_COUNT-1);

  -- Multiplexec subtypes and signals
  type multibus_ip_total_length is array (natural range <>) of
    ip_total_length;
  signal buffer_total_length    : multibus_ip_total_length(0 to
                                                           BUFFER_COUNT-1);
$3

  signal buffer_load            : multibus_bit(0 to BUFFER_COUNT-1);
  signal buffer_match           : multibus_bit(0 to BUFFER_COUNT-1);
],[dnl -- Body ----------------------------------------------------------------
  -----------------------------------------------------------------------------
  -- IP RECEIVE SLAVE INTERFACE

  -- Generate all the IP buffers for receiving datagram fragments
  buffer_gen: for i in 0 to BUFFER_COUNT-1 generate
    ip_buffer_inst : $4
      generic map (
        DATA_WIDTH       => DATA_WIDTH,
        ADDRESS_WIDTH    => BUFFER_ADDRESS_WIDTH
        )
      port map (
        -- Wishbone common signals
        wb_clk_i         => wb_clk_i,
        wb_rst_i         => wb_rst_i,
        -- Wishbone master interface (e.g. to a transport protocol)
        wbm_cyc_o        => buffer_wbm_cyc_o(i),
        wbm_stb_o        => buffer_wbm_stb_o(i),
        wbm_dat_o        => buffer_wbm_dat_o(i),
        wbm_ack_i        => buffer_wbm_ack_i(i),
        -- Wishbone payload slave interface (e.g. from ip_transport)
        wbs_cyc_i        => buffer_wbs_cyc_i(i),
        wbs_stb_i        => buffer_wbs_stb_i(i),
        wbs_dat_i        => buffer_wbs_dat_i(i),
        wbs_ack_o        => buffer_wbs_ack_o(i),
        -- Wishbone header slave interface, with same cyc_i as above.
        load             => buffer_load(i),
        match_ack        => buffer_match(i),
        -- Non Wishbone ports synced to above
$5
        length_in         => length_in,
        length_out        => buffer_total_length(i),
        checksum_error_in => checksum_error_in,
        debug_led_out     => buffer_debug_led_out(i)
        );

  end generate buffer_gen;

  -----------------------------------------------------------------------------
  -- Reassembles IP datagram fragments from Wishbone slave interface
  -- using buffers and round-robin scheme.
  buffer_process : process(wb_rst_i, wb_clk_i, wbs_cyc_i, wbs_stb_i,
                           wbs_dat_i, current_buffer, buffer_match,
                           buffer_wbs_ack_o)

    variable buffer_matched   : boolean;

    type buffer_states is (
      idle,
      load_wait,
      fill_buffer,
      wait_master_release
      );
    
    variable state                  : buffer_states;
    variable buffer_discard         : boolean;

  begin

    if (wb_rst_i = '1') then

      -- buffer signals initially low
      for i in 0 to BUFFER_COUNT-1 loop
        buffer_load(i) <= '0';
      end loop;  -- i

      -- initial buffer to use is 0
      current_buffer <= 0;
      next_buffer    <= 0;
      state          := idle;

    elsif (rising_edge(wb_clk_i)) then

      case (state) is
-------------------------------------------------------------------------------
        when idle =>
          buffer_discard := false;
          -- load this new buffer if wbs_cyc_i goes high
          buffer_load(next_buffer)      <= wbs_cyc_i;
          buffer_wbs_cyc_i(next_buffer) <= wbs_cyc_i;
          if (wbs_cyc_i = '1') then
            current_buffer <= next_buffer;
            if (next_buffer >= BUFFER_COUNT - 1) then
              next_buffer <= 0;
            else
              next_buffer <= next_buffer + 1;
            end if;
            state := fill_buffer;
          end if;
-------------------------------------------------------------------------------
        when fill_buffer =>
          -- lower cyc for non-matching buffers
--          for i in 0 to BUFFER_COUNT-1 loop
--            if (i /= current_buffer) then
--              buffer_wbs_cyc_i(i) <= '0';
--            end if;
--          end loop;  -- i
          if (buffer_match(current_buffer) = '1') then
            buffer_load(current_buffer) <= '0';
          end if;

          -- while our master (ethernet_receive) still has data
          -- and our buffer slave is still matching
          if (((buffer_load(current_buffer) = '0') and
               (buffer_match(current_buffer) = '0')) or (wbs_cyc_i = '0')) then
            buffer_wbs_cyc_i(current_buffer) <= '0';
            state := wait_master_release;
          end if;
-------------------------------------------------------------------------------
        when wait_master_release =>
          if (wbs_cyc_i = '0') then
            state := idle;
          else
            buffer_discard := true;
          end if;
-------------------------------------------------------------------------------
        when others =>
          state := fill_buffer;

      end case;

    end if; -- rising_edge(wb_clk_i)

    for i in 0 to BUFFER_COUNT-1 loop

      buffer_wbs_stb_i(i) <= wbs_stb_i;
      buffer_wbs_dat_i(i) <= wbs_dat_i;

      if (i = current_buffer) then
        if (buffer_match(i) = '1') then
          -- while our ip_buffer slave is still accepting data, pass ack/stb
          wbs_ack_o <= buffer_wbs_ack_o(i);
        else
          -- otherwise, raise ack high permanently until our master runs out.
          if (buffer_discard) then
            wbs_ack_o <= wbs_stb_i;
          else
            wbs_ack_o <= '0';
          end if;
        end if;
      end if;
    end loop;  -- i

  end process;

-------------------------------------------------------------------------------
-- TRANSPORT LAYER MASTER INTERFACE

  arbiter : wb_intercon
    generic map (
      MASTER_COUNT  => BUFFER_COUNT
      )
    port map (
      -- Wishbone common signals
      wb_clk_i      => wb_clk_i,
      wb_rst_i      => wb_rst_i,
      -- Wishbone masters
      wbm_cyc_i     => buffer_wbm_cyc_o,
      wbm_stb_i     => buffer_wbm_stb_o,
      wbm_dat_i     => buffer_wbm_dat_o,
      wbm_ack_o     => buffer_wbm_ack_i,
      wbm_gnt_o     => buffer_wbm_gnt,
      -- Wishbone slaves
      wbs_cyc_o     => wbm_cyc_o,
      wbs_stb_o     => wbm_stb_o,
      wbs_dat_o     => wbm_dat_o,
      wbs_ack_i     => wbm_ack_i,
      -- Debugging LED output
      debug_led_out => debug_led_out
      );

  -- this process multiplexes non-Wishbone outputs to
  -- the transport layer based on the grant signals of the arbiter
  multiplex_process : process(buffer_total_length, buffer_wbm_gnt)
  begin

    for i in 0 to BUFFER_COUNT-1 loop
      if (buffer_wbm_gnt(i) = '1') then
$6
        length_out <= buffer_total_length(i);
        exit;
      else
$7
        length_out <= (others => '0');
      end if;
    end loop;  -- i

  end process;
])])                            
  
# Renable output for processed file
divert(0)dnl
