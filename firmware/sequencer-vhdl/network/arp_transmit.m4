dnl--*-VHDL-*-
-- ARP transmitter module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Based on inputs supplied to it from the top-level ARP module, this
-- transmitter constructs a valid payload and feeds it to the
-- ethernet_transmit module via a Wishbone interface.

-- This module latches inputs from the ARP in parallel and shifts out a
-- serial payload to ethernet_transmit.

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

-- Master Interface to Ethernet PHY:
-- no WB_CYC_I b/c all transfers are singular (not block).
-- no WB_WE_O or WB_DAT_I b/c this is strictly a write-only master.
-- no WB_ADR_O b/c destination MAC address is supplied by ARP.

-- Non-Wishbone "Slave" Interface to top-level ARP:
-- S_STB_I enables parallel loading and serial shifting; whenever it goes low,
-- the serial shifter is reset and this module releases its control of its
-- S_ACK_O goes high for one cycle after serial shifting has completed,
-- no matter how long S_STB_I remains high after that.

unit_([arp_transmit], dnl
  [dnl-- Libraries-------------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
    -- Wishbone master interface to ethernet_transmit
wb_lsb_master_port_
    -- Non-Wishbone "slave" interface (e.g. to top-level ARP)
    s_stb_i         : in     std_logic;
    s_ack_o         : buffer std_logic;
    dest_ip_addr    : in     ip_address;
    src_ip_addr     : in     ip_address;
    src_mac_addr    : in     mac_address;
    dest_mac_addr   : in     mac_address;
    opcode_in       : in     arp_opcode;
    debug_led_out   : out    byte;
],[dnl -- Declarations --------------------------------------------------------
byte_count_signals_(ARP_BYTE_LENGTH)
  signal src_protocol_addr  : protocol_address;
  signal dest_protocol_addr : protocol_address;
  signal first_data         : boolean;
],[dnl -- Body ----------------------------------------------------------------
  -- Both Ethernet and IP transmit most sig BYTE first, but
  -- Ethernet does least sig BIT first and IP does most sig BIT first.
  -- So do byte-wise reversal here.
  addr_reverse: for i in (IP_ADDRESS_WIDTH/BYTE_WIDTH)-1 downto 0 generate
    byte_reverse: for j in BYTE_WIDTH-1 downto 0 generate
      src_protocol_addr(i*8 + j)  <= src_ip_addr(i*8 + (BYTE_WIDTH-1-j));
      dest_protocol_addr(i*8 + j) <= dest_ip_addr(i*8 + (BYTE_WIDTH-1-j));
    end generate byte_reverse;
  end generate addr_reverse;
-------------------------------------------------------------------------------
  arp_process : process(wb_rst_i, wb_clk_i, wb_ack_i, s_stb_i)

  begin

    if ((wb_rst_i = '1') or (s_stb_i = '0')) then
      -- aysnchronous reset conditions
      first_data <= true;
      byte_count <= 0;
      -- cyc and stb should be low during reset, but we want them to
      -- jump to high immediately when reset is deasserted, synced to clock
      wb_stb_o   <= '0';
      wb_cyc_o   <= '0';
      s_ack_o    <= '0';

    elsif (rising_edge(wb_clk_i) and (s_stb_i = '1')) then
      wb_cyc_o <= '1';

      if (first_data or (wb_ack_i = '1')) then -- cases inside of slave's acks
        first_data <= false;

        case (byte_count) is
map_loop_([i], 0, [network_header_transform_], dnl
[[dnl -- Bootstrapping, hardware_type
            wb_stb_o <= '1';
            -- start the pipeline by holding the first payload chunk in reset
            wb_dat_o   <= ETHERNET_HARDWARE_TYPE(15 downto 8);
            -- frame is done; wait for strobe to go low       ],
 [dnl -- hardware_type
            wb_dat_o <= ETHERNET_HARDWARE_TYPE( 7 downto  0); ],
 [dnl -- protocol_type
            wb_dat_o <= INTERNET_PROTOCOL_TYPE(15 downto  8); ],
 [dnl
            wb_dat_o <= INTERNET_PROTOCOL_TYPE( 7 downto  0); ],
 [dnl -- hardware_size
            wb_dat_o <= ETHERNET_HARDWARE_SIZE;               ],
 [dnl -- protocol_size
            wb_dat_o <= INTERNET_PROTOCOL_SIZE;               ],
 [dnl -- opcode
            wb_dat_o <= opcode_in             (15 downto  8); ],
 [dnl
            wb_dat_o <= opcode_in             ( 7 downto  0); ],
 [dnl -- sender_hardware_addr
            wb_dat_o <= src_mac_addr          ( 7 downto  0); ],
 [dnl
            wb_dat_o <= src_mac_addr          (15 downto  8); ],
 [dnl
            wb_dat_o <= src_mac_addr          (23 downto 16); ],
 [dnl
            wb_dat_o <= src_mac_addr          (31 downto 24); ],
 [dnl
            wb_dat_o <= src_mac_addr          (39 downto 32); ],
 [dnl
            wb_dat_o <= src_mac_addr          (47 downto 40); ],
 [dnl -- sender_protocol_addr
            wb_dat_o <= src_protocol_addr     ( 7 downto  0); ],
 [dnl
            wb_dat_o <= src_protocol_addr     (15 downto  8); ],
 [dnl
            wb_dat_o <= src_protocol_addr     (23 downto 16); ],
 [dnl
            wb_dat_o <= src_protocol_addr     (31 downto 24); ],
 [dnl -- target_hardware_addr
            wb_dat_o <= dest_mac_addr         ( 7 downto  0); ],
 [dnl
            wb_dat_o <= dest_mac_addr         (15 downto  8); ],
 [dnl
            wb_dat_o <= dest_mac_addr         (23 downto 16); ],
 [dnl
            wb_dat_o <= dest_mac_addr         (31 downto 24); ],
 [dnl
            wb_dat_o <= dest_mac_addr         (39 downto 32); ],
 [dnl
            wb_dat_o <= dest_mac_addr         (47 downto 40); ],
 [dnl -- target_protocol_addr
            wb_dat_o <= dest_protocol_addr    ( 7 downto  0); ],
 [dnl
            wb_dat_o <= dest_protocol_addr    (15 downto  8); ],
 [dnl
            wb_dat_o <= dest_protocol_addr    (23 downto 16); ],
 [dnl
            wb_dat_o <= dest_protocol_addr    (31 downto 24); ],
 [dnl
          -- Boot-unstrapping
          wb_stb_o <= '0';                                    ]
])
            s_ack_o  <= '1';
-------------------------------------------------------------------------------
          when others =>
            s_ack_o <= '1';
        end case;

        if (byte_count <= COUNT_START + 27) then
          byte_count <= byte_count + 1;
        end if;
        
      end if;                           -- (wb_ack_i = '1')

    end if; -- rising_edge(wb_clk_i)

  end process;

  debug_led_out(7) <= s_stb_i;
  debug_led_out(6) <= s_ack_o;
  debug_led_out(5) <= wb_cyc_o;
  debug_led_out(4) <= wb_ack_i;
  debug_led_out(3 downto 0) <= std_logic_vector(to_unsigned(byte_count, 4));
])
