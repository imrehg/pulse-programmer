dnl-*-VHDL-*-
divert(-1)
-------------------------------------------------------------------------------
-- Macros for network transmit units
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

###############################################################################
# Transmitter generic, included automatically in receiver unit.
# Any additional generics are added after it.

define([transmit_generic_], [dnl
    DATA_WIDTH          : positive := 8;
])

###############################################################################
# Transmitter port, included automatically in receiver unit.
# Any additional ports are added after it.

define([transmit_port_], [dnl
wb_common_port_()
wb_master_port_()
wb_slave_port_()
    debug_led_out : out byte;
])

###############################################################################
# Transmit architecture
#    $1 = entity name
#    $2 = byte count range
#    $3 = additional declarations (signals, constants, subtypes)
#    $4 = additional components
#    $5 = additional process states
#    $6 = additional process variables
#    $7 = reset behaviour
#    $8 = idle behaviour
#    $9 = generate header behaviour
#    $10 = receive data behaviour
#    $11 = additional state behaviours
#    $12 = synchronous behaviour
#    $13 = asynchronous behaviour
#    $14 = done behaviour (if blank, uses default)
#    $15 = make this non-empty do disable checksumming (to save gates)

define([transmit_architecture_], [dnl
architecture_([$1], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Declarations --------------------------------------------------------
byte_count_signals_($2)
ifelse($15, , [cksum_signals_()])
network_transceiver_signals_
$3
],[dnl -- Body ----------------------------------------------------------------
ifelse($15, , [cksum_instance_()])
$4
  process(wb_rst_i, wb_clk_i, wbs_cyc_i, wbs_stb_i, wbm_ack_i, wbm_cyc_o,
          wbm_stb_o, wbs_ack_o, wbs_dat_i, header_ack ifelse($15, , [, checksum_enable]))

    type state_type is (
      idle,
      generate_header,
      receive_data,
$5
      done_state
      );
    
    variable state                  : state_type;
    variable first_data             : boolean;
$6
-------------------------------------------------------------------------------
  begin

    if (wb_rst_i = '1') then
ifelse($15, , [dnl
      checksum_reset       <= '1';
      checksum_enable      <= '0';
      checksum_word_ready  <= '0';
      checksum_word_toggle <= '0';
])
      wbm_cyc_o            <= '0';
      wbm_stb_o            <= '0';
$7
      state                := idle;

    elsif (rising_edge(wb_clk_i)) then

      case (state) is
-------------------------------------------------------------------------------
        when idle =>
          debug_led_out(1 downto 0) <= B"00";
          if (wbs_cyc_i = '1') then
            overlap    <= false;
            byte_count <= 0;
$8
          end if;
-------------------------------------------------------------------------------
        when generate_header =>
$9
-------------------------------------------------------------------------------
        when receive_data =>
          debug_led_out(1 downto 0) <= B"10";
          byte_count <= 0;
$10
-------------------------------------------------------------------------------
$11
-------------------------------------------------------------------------------
        when done_state =>
          debug_led_out(1 downto 0) <= B"11";
          -- we need an end state to reset the checksum before next packet
ifelse($15, , [dnl          
          checksum_reset      <= '1';
          checksum_word_ready <= '0';
          -- after the first run, don't set to zero b/c of overlap
          -- sampling delay
          checksum_word_toggle <= '1';
])
ifelse($14, , [dnl
          -- wait for our slave to go low so it doesn't trip us again
          if ((wbm_ack_i = '0') and ((wbs_cyc_i = '0') or overlap)) then
            state         := idle;
          end if;
], $14)
        when others => null;

      end case;
-------------------------------------------------------------------------------
$12
    end if; -- rising_edge(wb_clk_i)
$13
    debug_led_out(7) <= wbs_cyc_i;
    debug_led_out(6) <= wbs_stb_i;
    debug_led_out(5) <= wbs_ack_o;
    debug_led_out(4) <= wbm_cyc_o;
    debug_led_out(3) <= wbm_stb_o;
    debug_led_out(2) <= wbm_ack_i;
  end process;
])])

###############################################################################
# Network layer transmit design unit
#   $1 = design unit name (for entity/architecture pair)
#   $2 = additional generics
#   $3 = additional ports
#   $4 = byte count range
#   $5 = additional declarations
#   $6 = additional states 
#   $7 = process variables
#   $8 = idle behaviour
#   $9 = quoted, comma-separated list of checksum header entries
#   $10 = receive data behaviour
#   $11 = quoted, comma-separated list of transmit header entries
#   $12 = additional state behaviour
#   $13 = asynchronous behaviour
                   
define([network_transmit_unit_],
[declare_([$1],
[sequencer_libraries_],
[transmit_generic_[]$2],
[transmit_port_[]$3])]dnl
$1[_entity_]

[transmit_architecture_($1, $4, dnl
[dnl --- Declarations (Constants, Subtypes, and Signals) ----------------------
$5
    signal overlap             : boolean;
],[dnl -- Components ----------------------------------------------------------
],[dnl -- Process States ------------------------------------------------------
       transmit_header,
       transmit_slave_data,
   $6
],[dnl -- Process Variables ---------------------------------------------------
$7
],[dnl -- Reset Behaviour -----------------------------------------------------
],[dnl -- Idle Behaviour ------------------------------------------------------
$8
],[dnl -- Generate Header Behaviour -------------------------------------------
            first_data := true;
ifelse(0, count_args_($9), [dnl
            state := transmit_header;
],[dnl

            case (byte_count) is
map_loop_([i], 0, [network_header_transform_], [$9])
              when others => null;
            end case;

            if (byte_count < $4/2) then
              checksum_enable <= '1';
              byte_count <= byte_count + 1;
            else
              checksum_enable <= '0';
              byte_count <= 0;
              state := transmit_header;
            end if;
])                                                  
],[dnl -- Receive Data Behaviour ----------------------------------------------
          checksum_reset <= '1';
          if (wbs_cyc_i = '0') then
            -- if our master has released us abnormally (before its promised
            -- length), release our slave
            wbm_cyc_o <= '0';
            wbm_stb_o <= '0';
            wbs_ack_o <= '0';
            overlap   <= true;
            state     := done_state;
$10
          else

            if ((wbs_stb_i = '1') and (wbm_ack_i = '0')) then
              -- If our master is strobing us, update our synchronous ack.
              -- if we are acking, set the flag as "producer ready".
                wbs_ack_o <= '1';
                wbm_stb_o <= '1';
                wbm_dat_o <= wbs_dat_i;
                state := transmit_slave_data;
            end if;
          
          end if;
],[dnl -- Additional State Behaviour ------------------------------------------
        when transmit_slave_data =>
          wbs_ack_o <= '0';
          if (wbm_ack_i = '1') then
            wbm_stb_o <= '0';
            current_length <= current_length - 1;
            state := receive_data;
          end if;
        when transmit_header =>
          wbm_cyc_o       <= '1';
          wbm_stb_o       <= '1';         -- start the pipeline here
          if ((wbm_ack_i = '1') or (first_data)) then
            first_data := false;
            -- 20 bytes (minus the initial one in the previous state)
            case (byte_count) is
map_loop_([i], 0, [network_header_transform_], [$11])
               when others =>
                if (wbs_stb_i = '1') then
                  -- start the pipeline from our master here (first data chunk)
                  wbs_ack_o <= '1';
                  wbm_dat_o <= wbs_dat_i;
                end if;
                state := transmit_slave_data;
            end case;

            byte_count <= byte_count + 1;
          end if;
-------------------------------------------------------------------------------
$12
],[dnl -- Synchronous Behaviour -----------------------------------------------
],[dnl -- Asynchronous Behaviour ----------------------------------------------
   -- we only checksum the header, and these are latched in parallel
   -- we should never insert wait states.
   checksum_word_ready <= '1';
$13
])])

###############################################################################
# Transport layer transmit design unit
#   $1 = design unit name (for entity/architecture pair)
#   $2 = additional generics
#   $3 = additional ports
#   $4 = byte count range
#   $5 = checksum address
#   $6 = quoted, comma-separated list of transmit header entries
#   $7 = quoted, comma-separated list of pseudo-header entries
#   $8 = end address
#   $9 = done behaviour
#   $10 = reset behaviour
#   $11 = cyc behaviour
#   $12 = declarations
#   $13 = make this non-empty to disable checksum generation and save gates

define([transport_transmit_unit_],
[declare_([$1],dnl
[sequencer_libraries_],dnl
[transmit_generic_[]$2],dnl
[transmit_port_[]$3])]dnl
$1[_entity_]

[transmit_architecture_([$1], [$4],
  [dnl -- Declarations (Constants, Subtypes, and Signals) ---------------------
memory_signals_
    signal total_length : ip_total_length;
$12
],[dnl -- Components ----------------------------------------------------------
memory_instance_
],[dnl -- Process States ------------------------------------------------------
      transmit_data,
ifelse($13, , [write_checksum,])
      transmit_precache,
      memory_stall,
ifelse(0, count_args_($7), ,[dnl
      generate_pseudo,])
],[dnl -- Process Variables ---------------------------------------------------
    constant CHECKSUM_ADDRESS : memory_address_unsigned_type :=
      to_unsigned($5, ADDRESS_WIDTH);
memory_variables_
],[dnl -- Reset Behaviour -----------------------------------------------------
memory_reset_
            header_ack <= '0';
            total_length <= (others => '0');
$10
],[dnl -- Idle Behaviour ------------------------------------------------------
ifelse($13, , [checksum_reset <= '0';])
            first_data     := true;
    if ($8 > (2**ADDRESS_WIDTH)-1) then
      total_length((IP_TOTAL_LENGTH_WIDTH - ADDRESS_WIDTH) to
                   IP_TOTAL_LENGTH_WIDTH-1) <= (others => '1');
      total_length(0 to (IP_TOTAL_LENGTH_WIDTH - ADDRESS_WIDTH)-1) <=
        (others => '0');
    else
      total_length <= $8;
    end if;
ifelse($11, , [dnl
ifelse(0, count_args_($7),[dnl
            state      := generate_header;],[dnl
            state      := generate_pseudo;])
], $11)
],[dnl -- Generate Header Behaviour -------------------------------------------
          mem_stb         <= '1';
memory_start_write_burst_([(others => '0')])
ifelse($13, , [checksum_enable <= '1';])
          if ((mem_ack = '1') or (first_data)) then
            first_data := false;

            case (byte_count) is
map_loop_([i], 0, [network_header_transform_], [$6])
                header_ack <= '1';
              when others =>
                state := receive_data;
                mem_dat_i <= wbs_dat_i;
ifelse($13, , [checksum_word_in(8 to 15) <= wbs_dat_i;])
            end case;

            byte_count <= byte_count + 1;

          end if;
],[dnl -- Receive Data Behaviour ----------------------------------------------
          mem_stb   <= wbs_stb_i;
          mem_dat_i <= wbs_dat_i;
          -- wait for our master to release us
          if ((wbs_cyc_i = '0') or overlap) then
            overlap <= true;
ifelse($13, , [dnl
            -- allow one more state for checksum to propagate out
            -- pad with zero byte if there is an odd number
            if (checksum_word_toggle = '1') then
              -- one stage stall so that last byte of data gets written
              checksum_word_ready <= '1';
memory_end_burst_
              header_ack <= '0';
              checksum_enable <= '0';
              state := write_checksum;
            else
              checksum_word_in <= checksum_word_in(8 to 15) & X"00";
              checksum_word_toggle <= '1';
              checksum_word_ready <= '1';
            end if;
          elsif (wbs_stb_i = '1') then
            checksum_word_in <= checksum_word_in(8 to 15) & wbs_dat_i;
], [dnl         
memory_end_burst_
            header_ack <= '0';
            state := transmit_precache;
            -- b/c we are skipping the checksum, start at 2
            byte_count <= 2;
])
          end if;
],
[dnl --- Additional State Behaviour -------------------------------------------
ifelse(0, count_args_($7), ,[dnl
        when generate_pseudo =>
ifelse($13, , [checksum_enable <= '1';])
          case (byte_count) is
map_loop_([i], 0, [network_header_transform_], [$7])
              state := generate_header;
            when others => null;
          end case;

          if (byte_count = count_args_($7)-1) then
            byte_count <= 0;
          else
            byte_count <= byte_count + 1;
          end if;
])
-------------------------------------------------------------------------------
ifelse($13, , [dnl
        when write_checksum =>
          case (byte_count) is
            when 0 =>
              mem_stb   <= '1';
              mem_dat_i <= checksum(0 to 7);
memory_start_write_burst_(CHECKSUM_ADDRESS)
            when 1 =>
              mem_dat_i <= checksum(8 to 15);
memory_end_burst_
              state := transmit_precache;
            when others => null;
          end case;
          byte_count <= byte_count + 1;
])
-------------------------------------------------------------------------------
        when transmit_precache =>
          case (byte_count) is
memory_precache_states_(2, (others => '0'))
          debug_led_out(7 downto 6) <= B"01";
            when others => null;
          end case;
          byte_count <= byte_count + 1;
-------------------------------------------------------------------------------
memory_master_state_(total_length)
],[dnl -- Synchronous Behaviour -----------------------------------------------
ifelse($13, , [cksum_toggle_])
],[dnl -- Asynchronous Behaviour ----------------------------------------------
ifelse($13, , [dnl
    if (overlap) then
      checksum_toggle_enable <= '0';
    else
      checksum_toggle_enable <= (wbs_stb_i and wbs_cyc_i) or
                                (checksum_enable and (not wbs_cyc_i));
    end if;
])
      -- we cannot tie ack to stb directly b/c it takes one cycle to
      -- jump from idle state to receive_header state.
    if (overlap) then
      -- don't answer a new master while we are still forwarding from old one
      wbs_ack_o <= '0';
    else
      wbs_ack_o <= header_ack and wbs_stb_i;
    end if;
memory_master_async_
],[dnl -- Done Behaviour ------------------------------------------------------
$9[]dnl
],[dnl -- Disable Checksum ---------------------------------------------------
[$13]dnl
])])

# Renable output for processed file
divert(0)dnl
