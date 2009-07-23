dnl-*-VHDL-*-
divert(-1)
-------------------------------------------------------------------------------
-- Macros for network receive units
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

###############################################################################
# Receiver port, included automatically in receiver unit.
# Any additional ports are added after it.

define([receive_port_], [dnl
wb_common_port_()

wb_master_port_()
    checksum_error_out      : out    std_logic;
    debug_led_out           : out    byte;
wb_slave_port_()
    checksum_error_in       : in     std_logic := '0';
])

###############################################################################
# Network layer receive signals

define([network_receive_signals_], [dnl
  signal total_length : ip_total_length;
])                                    
  
###############################################################################
# Receiver archiecture
#    $1 = entity name
#    $2 = byte count range
#    $3 = additional declarations (signals, constants, subtypes)
#    $4 = quoted, comma-separated list of receive header entries
#    $5 = checksum behaviour
#         [header] computes the checksum for the header only
#         [data]   computs the checksum both the header and the data

define([receive_architecture_], [dnl
architecture_([$1], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Declarations --------------------------------------------------------
byte_count_signals_($2)
cksum_signals_()
network_transceiver_signals_
  -- receive values from parsed header
  signal received_checksum      : ip_checksum;
[$3]],
[dnl -- Body ------------------------------------------------------------------

cksum_instance_()

  process(wb_rst_i, wb_clk_i, wbs_cyc_i, wbs_stb_i, wbm_ack_i, wbm_cyc_o,
          wbs_ack_o, checksum_enable, header_ack, data_ack)

    type state_type is (
      idle,
      receive_header,
      checksum_stall,
      check_checksum,
      pass_data,
      done_state
      );
    
    variable state   : state_type;

-------------------------------------------------------------------------------
  begin

    if (wb_rst_i = '1') then
      checksum_reset       <= '1';
      checksum_word_toggle <= '1';
      checksum_word_ready  <= '0';
      wbm_cyc_o            <= '0';
      header_ack           <= '0';
      data_ack             <= '0';
      state                := idle;

    elsif (rising_edge(wb_clk_i)) then

      case (state) is
-------------------------------------------------------------------------------
        when idle =>
          debug_led_out(1 downto 0) <= B"00";
          if (wbs_cyc_i = '1') then
            byte_count             <= 0;
            -- ack early here, b/c registered inputs are sampled 1 cycle later
            header_ack             <= '1';
            checksum_enable        <= '1';
            checksum_reset         <= '0';
            checksum_error_out     <= '0';
            checksum_toggle_enable <= wbs_stb_i;
            state                  := receive_header;
          end if;
-------------------------------------------------------------------------------
        when receive_header =>
          debug_led_out(1 downto 0) <= B"01";          
          -- in case our master terminates us abnormally
          if (wbs_cyc_i = '0') then
            checksum_enable <= '0';
            state := done_state;
          elsif (wbs_stb_i = '1') then
            case (byte_count) is
map_loop_([i], 0, [network_header_transform_], [$4])
             -- Do not move the following two lines to the "others" case,
             -- otherwise, the slave won't be strobed in time to latch the
             -- first byte between ethernet_receive to ip_receive.
             -- And then nothing will work, and I will have to hurt you.
                header_ack <= '0';
                data_ack   <= '1';
                wbm_cyc_o  <= '1';
                state      := pass_data;
              when others => null;
            end case;

            byte_count <= byte_count + 1;
          elsif (byte_count >= count_args_($4)) then
            -- added this case outside of stb = '1' here for slow receive
            -- masters like ptp_daisy_receive who don't strobe quickly enough
            -- to go from header to data
            checksum_enable <= '0';
            data_ack        <= '1';
            state           := pass_data;
          end if; -- wb_stb_i = '1'
-------------------------------------------------------------------------------
        when pass_data =>
          debug_led_out(1 downto 0) <= B"10";          
          checksum_enable <= '0';
ifelse([network], [$5],
  [dnl -- Network layer checksums header only ---------------------------------
          if (wbs_cyc_i = '0') then
            data_ack        <= '0';
            state           := checksum_stall;
          end if;
],[dnl -- Transport layer checksums data and needs to handle zero padding -----
          -- wait for our master to release us
          if (wbs_cyc_i = '0') then
            -- allow one more state for checksum to propagate out
            if (checksum_word_toggle = '1') then
              -- cyc should fall after the last data byte,
              -- so checksum_word_ready = '1' afterwards means an even number
              checksum_word_ready <= '0';
              checksum_enable     <= '0';
              data_ack            <= '0';
              state               := checksum_stall;
            else
              -- pad with zero byte if there is an odd number
              checksum_word_toggle <= '1';
              checksum_word_ready  <= '1';
              checksum_word_in     <= checksum_word_in(8 to 15) & X"00";
            end if;
          else
            if (wbs_stb_i = '1') then
              checksum_enable <= '1';
              -- shift in new byte as low-order byte to checksum word
              checksum_word_in <= checksum_word_in(8 to 15) & wbs_dat_i;
            end if;
          end if;
])
-------------------------------------------------------------------------------
        when checksum_stall =>
          debug_led_out(1 downto 0) <= B"11";          
          checksum_toggle_enable <= '0';
          -- stall one cycle here for final checksum to propagate out
          state := check_checksum;
-------------------------------------------------------------------------------
        when check_checksum =>
          state := done_state;
          if (checksum /= received_checksum) then
            -- if the checksum was wrong after all, abort
            checksum_error_out <= '1';
          else
            checksum_error_out <= checksum_error_in;
          end if;
-------------------------------------------------------------------------------
        when done_state =>
          -- we need an end state to reset the checksum before next packet
          wbm_cyc_o            <= '0';
          header_ack           <= '0';
          data_ack             <= '0';
          checksum_reset       <= '1';
          checksum_word_toggle <= '1';
          checksum_word_ready  <= '0';
          state                := idle;
-------------------------------------------------------------------------------
        when others =>
          -- for safety's sake
          state                := done_state;
      end case;
-------------------------------------------------------------------------------
cksum_toggle_
    end if; -- rising_edge(wb_clk_i)

cksum_toggle_enable_    

  end process;

  debug_led_out(7) <= wbs_cyc_i;
  debug_led_out(6) <= wbs_stb_i;
  debug_led_out(5) <= wbs_ack_o;
  debug_led_out(4) <= wbm_cyc_o;
  debug_led_out(3) <= wbm_stb_o;
  debug_led_out(2) <= wbm_ack_i;

  wbm_stb_o <= wbs_stb_i when (data_ack = '1') else '0';
  wbm_dat_o <= wbs_dat_i;
])])

###############################################################################
# Network layer receiver design unit
#   $1 = design unit name (for entity/architecture pair)
#   $2 = additional generics
#   $3 = additional ports
#   $4 = additional declarations
#   $5 = byte count range
#   $6 = quoted, comma-separated list of receive header entries

define([network_receive_unit_],
[declare_([$1], [sequencer_libraries_], dnl
          [data_generic_[]$2], [receive_port_[]$3])]
$1[_entity_]

[receive_architecture_($1, $5, network_receive_signals_[]$4, [$6],
                      [network])])

###############################################################################
# Transport layer receiver design unit
#   $1 = design unit name (for entity/architecture pair)
#   $2 = additional generics
#   $3 = additional ports
#   $4 = byte count range
#   $5 = quoted, comma-separated list of receive header entries
#   $6 = declarations

define([transport_receive_unit_],
[declare_([$1], [sequencer_libraries_], dnl
          [data_generic_[]$2], [receive_port_[]$3])]
$1[_entity_]

[receive_architecture_([$1], [$4], [$6], [$5], [transport])])

# Renable output for processed file
divert(0)dnl
