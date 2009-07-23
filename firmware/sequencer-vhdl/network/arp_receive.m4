dnl--*-VHDL-*-
-- ARP datagram parser (connects to ethernet_receive)
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Reads in the payload of an Ethernet frame of ARP type and
-- outputs the various fields to be handled by top-level ARP module.

-- This module is auto-reloading in that it can handle another frame after
-- its current frame is finished without any resets.

-- An ARP frame has 28 octets and has 9 parts:
-- 2 octets: hardware_type = Ethernet
-- 2 octets: protocol_type = Internet
-- 1 octets: hardware_size = 6
-- 1 octets: protocol_size = 4
-- 2 octets: opcode
-- 6 octets: sender_hardware_addr
-- 4 octets: sender_protocol_addr
-- 6 octets: target_hardware_addr
-- 4 octets: target_protocol_addr
-- See IETF RFC 826 for more details.

-- Slave Interface to Ethernet PHY:
-- no WB_WE_I, WB_ADR_I, WB_DAT_O b/c this is strictly a write-only slave.
-- note that when WB_CYC_I and WB_STB_I go low, WB_ACK_O remains high
-- as long as the device is busy, and cannot be used again until it goes low,
-- even if WB_CYC_I and WB_STB_I are asserted again.

-- Non-Wishbone "Master" Interface to top-level ARP:
-- M_STB_O goes high whenever ARP field outputs are valid,
-- and goes low again after ARP has raised M_ACK_I.
-- These are not technically Wishbone outputs, but they obey the same timing.

unit_([arp_receive], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
    -- Wishbone slave interface from ethernet_receive
wb_lsb_slave_port_
    -- Non-Wishbone "master" interface (e.g. to top-level ARP)
    m_stb_o       : buffer std_logic;
    m_ack_i       : in     std_logic;
    src_mac_addr  : out    mac_address;
    src_ip_addr   : out    ip_address;
    dest_mac_addr : out    mac_address;
    dest_ip_addr  : out    ip_address;
    opcode_out    : out    arp_opcode;
    debug_led_out : out    byte;
],[dnl -- Declarations --------------------------------------------------------
byte_count_signals_(ARP_BYTE_LENGTH)
  signal src_protocol_addr  : protocol_address;
  signal dest_protocol_addr : protocol_address;
],[dnl -- Body ----------------------------------------------------------------
  arp_process : process(wb_rst_i, wb_clk_i, wb_stb_i)

    type arp_states is (
      idle,
      receiving,
      done_state,
      wait_slave_ack,
      error_state
      );
  
  variable state       : arp_states;
  variable arp_counter : unsigned(2 downto 0);

  begin

    if (wb_rst_i = '1') then
      arp_counter := (others => '0');
      state    := idle;
      m_stb_o  <= '0';

    elsif (rising_edge(wb_clk_i)) then

      case (state) is

        when idle =>
          debug_led_out(2 downto 0) <= B"001";
          if ((wb_cyc_i = '1') and (wb_stb_i = '1')) then
            if (wb_dat_i = ETHERNET_HARDWARE_TYPE(15 downto 8)) then
              byte_count <= 0;          -- start pipeline here
              state := receiving;
            end if;
          end if;
-------------------------------------------------------------------------------
        when error_state =>
          debug_led_out(2 downto 0) <= B"100";
          if ((wb_cyc_i = '0') and (wb_stb_i = '0')) then
            -- if our master is done giving us info, and our slave has acked
            -- reload ourselves for next frame.
            state := idle;
          end if;
-------------------------------------------------------------------------------
        when done_state =>
          debug_led_out(2 downto 0) <= B"010";
          -- wait for master to release us
          if ((wb_cyc_i = '0') and (wb_stb_i = '0')) then
            state := wait_slave_ack;
          end if;
-------------------------------------------------------------------------------
        when wait_slave_ack =>
          debug_led_out(2 downto 0) <= "101";
          if (m_ack_i = '1') then
            m_stb_o <= '0';
            arp_counter := arp_counter + 1;
            state := idle;
          end if;
-------------------------------------------------------------------------------
        when receiving =>
          debug_led_out(2 downto 0) <= B"011";

          if (wb_cyc_i = '0') then
            state := idle;
          elsif (wb_stb_i = '1') then

            case (byte_count) is
map_loop_([i], 0, [network_header_transform_], dnl
[[dnl -- hardware_type
                if (wb_dat_i /= ETHERNET_HARDWARE_TYPE(7 downto 0)) then
                  state := error_state;
                end if;                                                   ],
 [dnl -- protocol_type
                if (wb_dat_i /= INTERNET_PROTOCOL_TYPE(15 downto 8)) then
                  state := error_state;
                end if;                                                   ],
 [dnl
                if (wb_dat_i /= INTERNET_PROTOCOL_TYPE(7 downto 0)) then
                  state := error_state;
                end if;                                                   ],
 [dnl -- hardware_size
                if (wb_dat_i /= ETHERNET_HARDWARE_SIZE) then
                  state := error_state;
                end if;                                                   ],
 [dnl -- protocol_size
                if (wb_dat_i /= INTERNET_PROTOCOL_SIZE) then
                  state := error_state;
                end if;                                                   ],
 [dnl -- opcode
                opcode_out        (15 downto  8) <= wb_dat_i;             ],
 [dnl
                opcode_out        ( 7 downto  0) <= wb_dat_i;             ],
 [dnl -- sender_hardware_addr
                src_mac_addr      ( 7 downto  0) <= wb_dat_i;             ],
 [dnl
                src_mac_addr      (15 downto  8) <= wb_dat_i;             ],
 [dnl
                src_mac_addr      (23 downto 16) <= wb_dat_i;             ],
 [dnl
                src_mac_addr      (31 downto 24) <= wb_dat_i;             ],
 [dnl
                src_mac_addr      (39 downto 32) <= wb_dat_i;             ],
 [dnl
                src_mac_addr      (47 downto 40) <= wb_dat_i;             ],
 [dnl -- sender_protocol_addr
                src_protocol_addr ( 7 downto  0) <= wb_dat_i;             ],
 [dnl
                src_protocol_addr (15 downto  8) <= wb_dat_i;             ],
 [dnl
                src_protocol_addr (23 downto 16) <= wb_dat_i;             ],
 [dnl
                src_protocol_addr (31 downto 24) <= wb_dat_i;             ],
 [dnl -- target_hardware_addr
                dest_mac_addr     ( 7 downto  0) <= wb_dat_i;             ],
 [dnl
                dest_mac_addr     (15 downto  8) <= wb_dat_i;             ],
 [dnl
                dest_mac_addr     (23 downto 16) <= wb_dat_i;             ],
 [dnl
                dest_mac_addr     (31 downto 24) <= wb_dat_i;             ],
 [dnl
                dest_mac_addr     (39 downto 32) <= wb_dat_i;             ],
 [dnl
                dest_mac_addr     (47 downto 40) <= wb_dat_i;             ],
 [dnl -- target_protocol_addr
                dest_protocol_addr( 7 downto  0) <= wb_dat_i;             ],
 [dnl
                dest_protocol_addr(15 downto  8) <= wb_dat_i;             ],
 [dnl
                dest_protocol_addr(23 downto 16) <= wb_dat_i;             ],
 [dnl
                dest_protocol_addr(31 downto 24) <= wb_dat_i;             ]])
-------------------------------------------------------------------------------
                m_stb_o <= '1';         -- notify ARP of finished, valid frame
                state := done_state;               
              when others =>
                m_stb_o <= '1';         -- notify ARP of finished, valid frame
                state := done_state;               
            end case;

            byte_count <= byte_count + 1;

          end if;
          
        when others =>
          m_stb_o <= '0';
          state := idle;
      end case;

    end if; -- rising_edge(wb_clk_i)

    debug_led_out(6 downto 4) <= std_logic_vector(arp_counter);
  end process;

  -- Both Ethernet and IP transmit most sig BYTE first, but
  -- Ethernet does least sig BIT first and IP does most sig BIT first.
  -- So do byte-wise reversal here.
  addr_reverse: for i in (IP_ADDRESS_WIDTH/BYTE_WIDTH)-1 downto 0 generate
    byte_reverse: for j in BYTE_WIDTH-1 downto 0 generate
      src_ip_addr(i*8 + j)  <= src_protocol_addr (i*8 + (BYTE_WIDTH-1-j));
      dest_ip_addr(i*8 + j) <= dest_protocol_addr(i*8 + (BYTE_WIDTH-1-j));
    end generate byte_reverse;
  end generate addr_reverse;

  wb_ack_o <= wb_stb_i;                 -- we never insert wait states
  debug_led_out(7) <= m_stb_o;
])
