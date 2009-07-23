dnl-*-VHDL-*-
-- DHCP receiver module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Based on inputs supplied to it from the top-level IP module, this
-- transmitter constructs a valid payload and feeds it to the
-- ethernet_transmit module via a Wishbone interface.

-- An IP datagram has a header in 32-bit chunks with a minimum of 20 octets
-- See IETF RFC 791 for more details.

-- no WB_WE_O or WB_DAT_I b/c this is strictly a write-only master.
-- no WB_ADR_O b/c destination MAC address is supplied by ARP.

unit_([dhcp_receive], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
wb_slave_port_
    m_cyc_o         : out std_logic;
    m_ack_i         : in  std_logic;
    -- Non-wishbone slave interface, synced to signals above
    message_type_out    : out dhcp_messagetype_type;
    server_ip_addr_out  : out ip_address;
    router_ip_addr_out  : out ip_address;
    self_ip_addr_out    : out ip_address;
    self_mac_addr_in    : in  mac_address;
],[dnl -- Declarations --------------------------------------------------------
byte_count_signals_(DHCP_FILE_BYTE_LENGTH)
   signal header_ack : std_logic;
],[dnl -- Body ----------------------------------------------------------------

  process(wb_rst_i, wb_clk_i)

    type dhcp_states is (
      idle,
      receive_header,
      receive_sname_file,
      receive_magic_cookie,
      receive_option,
      receive_messagetype,
      receive_serverid,
      receive_router,
      receive_optionlength,
      receive_discard,
      done_state,
      wait_state
      );

    variable state      : dhcp_states;

  begin

    if (wb_rst_i = '1') then
      m_cyc_o <= '0';
      header_ack <= '0';
      state := idle;

    elsif (rising_edge(wb_clk_i)) then

      case (state) is

        when idle =>
          if (wbs_cyc_i = '1') then
            state := receive_header;
            byte_count <= 0;
            header_ack <= '1';
          end if;
-------------------------------------------------------------------------------
        when receive_header =>
          if (wbs_stb_i = '1') then

            case (byte_count) is
map_loop_([i], 0, [network_header_transform_], [dnl
   [dnl --- op
                if (wbs_dat_i /= DHCP_BOOTREPLY_OPCODE) then
                  state := wait_state;
                end if;                                                      ],
   [dnl --- htype
                if (wbs_dat_i /= DHCP_ETHERNET_HTYPE) then
                  state := wait_state;
                end if;                                                      ],
   [dnl --- hlen
                if (wbs_dat_i /= ETHERNET_HARDWARE_SIZE) then
                  state := wait_state;
                end if;                                                      ],
   [dnl --- hops
                                                                             ],
   [dnl --- xid
                if (wbs_dat_i /= DHCP_DEFAULT_XID(0 to 7)) then
                  state := wait_state;
                end if;                                                      ],
   [dnl
                if (wbs_dat_i /= DHCP_DEFAULT_XID(0 to 7)) then
                  state := wait_state;
                end if;                                                      ],
   [dnl
                if (wbs_dat_i /= DHCP_DEFAULT_XID(0 to 7)) then
                  state := wait_state;
                end if;                                                      ],
   [dnl
                if (wbs_dat_i /= DHCP_DEFAULT_XID(0 to 7)) then
                  state := wait_state;
                end if;                                                      ],
   [dnl --- secs (unused)
                                                                             ],
   [dnl
                                                                             ],
   [dnl --- flags (broadcast/unicast) (unused)
                                                                             ],
   [dnl
                                                                             ],
   [dnl --- ciaddr (unused)
                                                                             ],
   [dnl
                                                                             ],
   [dnl
                                                                             ],
   [dnl
                                                                             ],
   [dnl --- yiaddr
                self_ip_addr_out( 0 to  7) <= wbs_dat_i;                     ],
   [dnl
                self_ip_addr_out( 8 to 15) <= wbs_dat_i;                     ],
   [dnl
                self_ip_addr_out(16 to 23) <= wbs_dat_i;                     ],
   [dnl
                self_ip_addr_out(24 to 31) <= wbs_dat_i;                     ],
   [dnl --- siaddr (unused)
                                                                             ],
   [dnl
                                                                             ],
   [dnl
                                                                             ],
   [dnl
                                                                             ],
   [dnl --- giaddr (unused)
                                                                             ],
   [dnl
                                                                             ],
   [dnl
                                                                             ],
   [dnl
                                                                             ],
   [dnl --- chaddr
                if (wbs_dat_i /= self_mac_addr_in(7 downto 0)) then
                  state := wait_state;
                end if;                                                      ],
   [dnl
                if (wbs_dat_i /= self_mac_addr_in(15 downto 8)) then
                  state := wait_state;
                end if;                                                      ],
   [dnl
                if (wbs_dat_i /= self_mac_addr_in(23 downto 16)) then
                  state := wait_state;
                end if;                                                      ],
   [dnl
                if (wbs_dat_i /= self_mac_addr_in(31 downto 24)) then
                  state := wait_state;
                end if;                                                      ],
   [dnl
                if (wbs_dat_i /= self_mac_addr_in(39 downto 32)) then
                  state := wait_state;
                end if;                                                      ],
   [dnl
                if (wbs_dat_i /= self_mac_addr_in(47 downto 40)) then
                  state := wait_state;
                end if;                                                      ],
   [dnl
                -- discard                                                   ],
   [dnl
                -- discard                                                   ],
   [dnl
                -- discard                                                   ],
   [dnl
                -- discard                                                   ],
   [dnl
                -- discard                                                   ],
   [dnl
                -- discard                                                   ],
   [dnl
                -- discard                                                   ],
   [dnl
                -- discard                                                   ],
   [dnl
                -- discard                                                   ],
   [dnl
                -- discard                                                   ]
])
                state := receive_sname_file;
              when others => null;
              
            end case;

            if (byte_count = DHCP_HEADER_BYTE_LENGTH-1) then
              byte_count <= 0;
            else
              byte_count <= byte_count + 1;
            end if;

          end if;                       -- wbs_stb_i = '1'
-------------------------------------------------------------------------------
        when receive_sname_file =>
          if (wbs_stb_i = '1') then
            if (byte_count = (DHCP_SNAME_BYTE_LENGTH+
                              DHCP_FILE_BYTE_LENGTH-1)) then
              byte_count <= 0;
              state := receive_magic_cookie;
            else
              byte_count <= byte_count + 1;
            end if;
          end if;
-------------------------------------------------------------------------------
        when receive_magic_cookie =>
          if (wbs_stb_i = '1') then
            case (byte_count) is
map_loop_([i], 0, [network_header_transform_], [dnl
   [dnl --- magic cookie
                if (wbs_dat_i /= DHCP_MAGIC_COOKIE(0 to 7)) then
                  state := wait_state;
                end if;                                                      ],
   [dnl
                if (wbs_dat_i /= DHCP_MAGIC_COOKIE(8 to 15)) then
                  state := wait_state;
                end if;                                                      ],
   [dnl
                if (wbs_dat_i /= DHCP_MAGIC_COOKIE(16 to 23)) then
                  state := wait_state;
                end if;                                                      ],
   [dnl
                if (wbs_dat_i /= DHCP_MAGIC_COOKIE(24 to 31)) then
                  state := wait_state;
                else
                  state := receive_option;
                end if;                                                      ]
])

              when others => null;
            end case;

            byte_count <= byte_count + 1;
          end if;
-------------------------------------------------------------------------------
        when receive_option =>
          byte_count <= 0;
          if (wbs_stb_i = '1') then
              case (wbs_dat_i) is
                when DHCP_MESSAGETYPE_OPTION_ID =>
                  state := receive_messagetype;
                when DHCP_SERVERID_OPTION_ID =>
                  state := receive_serverid;
                when DHCP_ROUTER_OPTION_ID =>
                  state := receive_router;
                when DHCP_END_OPTION_ID =>
                  state := done_state;
                when others =>
                  state := receive_optionlength;
             end case;
          end if;
-------------------------------------------------------------------------------
        when receive_messagetype =>
          if (wbs_stb_i = '1') then
            case (byte_count) is
map_loop_([i], 0, [network_header_transform_], [dnl
   [dnl --- mesasge type length
                if (wbs_dat_i /= DHCP_MESSAGETYPE_OPTION_LEN) then
                  state := wait_state;
                end if;                                                      ],
   [dnl --- message type value
                message_type_out <= wbs_dat_i;                               ]
])
                state := receive_option;

              when others => null;
            end case;
            byte_count <= byte_count + 1;
          end if;
-------------------------------------------------------------------------------
        when receive_serverid =>
          if (wbs_stb_i = '1') then
            case (byte_count) is
map_loop_([i], 0, [network_header_transform_], [dnl
   [dnl --- server id length
                if (wbs_dat_i /= DHCP_SERVERID_OPTION_LEN) then
                  state := wait_state;
                end if;                                                      ],
   [dnl --- server id value
                server_ip_addr_out(0 to 7) <= wbs_dat_i;                     ],
   [dnl
                server_ip_addr_out(8 to 15) <= wbs_dat_i;                    ],
   [dnl
                server_ip_addr_out(16 to 23) <= wbs_dat_i;                   ],
   [dnl
                server_ip_addr_out(24 to 31) <= wbs_dat_i;                   ]
])
                state := receive_option;

              when others => null;
            end case;
            byte_count <= byte_count + 1;
          end if;
-------------------------------------------------------------------------------
        when receive_router =>
          if (wbs_stb_i = '1') then
            case (byte_count) is
map_loop_([i], 0, [network_header_transform_], [dnl
   [dnl --- server id length
                if (wbs_dat_i /= DHCP_ROUTER_OPTION_LEN) then
                  state := wait_state;
                end if;                                                      ],
   [dnl --- server id value
                router_ip_addr_out(0 to 7) <= wbs_dat_i;                     ],
   [dnl
                router_ip_addr_out(8 to 15) <= wbs_dat_i;                    ],
   [dnl
                router_ip_addr_out(16 to 23) <= wbs_dat_i;                   ],
   [dnl
                router_ip_addr_out(24 to 31) <= wbs_dat_i;                   ]
])
                state := receive_option;

              when others => null;
            end case;
            byte_count <= byte_count + 1;
          end if;
-------------------------------------------------------------------------------
        when receive_optionlength =>
          if (wbs_stb_i = '1') then
            byte_count <= to_integer(unsigned(wbs_dat_i)-1);
            state := receive_discard;
          end if;
-------------------------------------------------------------------------------
        when receive_discard =>
          if (wbs_stb_i = '1') then
            if (byte_count = 0) then
              state := receive_option;
            else
               byte_count <= byte_count - 1;
            end if;
          end if;
-------------------------------------------------------------------------------
        when done_state =>
          m_cyc_o <= '1';
          if (m_ack_i = '1') then
            state := wait_state;
          end if;
-------------------------------------------------------------------------------
        when wait_state =>
          m_cyc_o <= '0';
          if (wbs_cyc_i = '0') then
            state := idle;
            header_ack <= '0';
          end if;
-------------------------------------------------------------------------------
        when others => null;
      end case;
    end if; -- rising_edge(wb_clk_i)
  end process;

  wbs_ack_o <= header_ack and wbs_stb_i;
])
