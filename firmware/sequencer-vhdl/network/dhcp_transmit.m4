dnl-*-VHDL-*-
-- DHCP transmitter module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([dhcp_transmit], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
   RETRY_TIMEOUT   : positive := 50;
   MAX_RETRY_COUNT : positive := 2;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
wb_master_port_
    s_cyc_i           : in  std_logic;
    s_ack_o           : out std_logic;
    -- Non-wishbone slave interface, synced to signals above
    self_mac_addr_in  : in  mac_address := SELF_MAC_ADDRESS;
    message_type_in   : in  dhcp_messagetype_type;
    server_ip_addr_in : in  ip_address;
    self_ip_addr_in   : in  ip_address;
    timed_out         : out std_logic;
    debug_led_out     : out byte;
],[dnl -- Declarations --------------------------------------------------------
   -- Max of all header segments is filename
byte_count_signals_(DHCP_FILE_BYTE_LENGTH)
   signal timeout_counter : natural range 0 to RETRY_TIMEOUT+1;
],[dnl -- Body ----------------------------------------------------------------

  process(wb_rst_i, wb_clk_i)

    type dhcp_states is (
      idle,
      transmit_header,
      transmit_zero_addr,
      transmit_chaddr,
      transmit_chaddr_zero,
      transmit_sname,
      transmit_file,
      transmit_options,
      done_state,
      timed_out_state
      );

    variable state       : dhcp_states;
    variable first_data  : boolean;
    variable retry_count : natural range 0 to MAX_RETRY_COUNT;

  begin

    if (wb_rst_i = '1') then
      wbm_cyc_o   <= '0';
      wbm_stb_o   <= '0';
      s_ack_o     <= '0';
      timed_out   <= '0';
      retry_count := 0;
      state       := idle;

    elsif (rising_edge(wb_clk_i)) then

      case (state) is
        -----------------------------------------------------------------------
        when idle =>
          if ((s_cyc_i = '1') and (wbm_ack_i = '0')) then
            state := transmit_header;
            first_data := true;
            byte_count <= 0;
          end if;
        -----------------------------------------------------------------------
        when transmit_header =>
          wbm_cyc_o <= '1';
          wbm_stb_o <= '1';
          if ((wbm_ack_i = '1') or first_data) then
            first_data := false;

            case (byte_count) is
map_loop_([i], 0, [network_header_transform_], [dnl
   [dnl --- op
                wbm_dat_o <= DHCP_BOOTREQUEST_OPCODE;                        ],
   [dnl --- htype
                wbm_dat_o <= DHCP_ETHERNET_HTYPE;                            ],
   [dnl --- hlen
                wbm_dat_o <= ETHERNET_HARDWARE_SIZE;                         ],
   [dnl --- hops
                wbm_dat_o <= X"00";                                          ],
   [dnl --- xid
                wbm_dat_o <= DHCP_DEFAULT_XID(0 to 7);                       ],
   [dnl
                wbm_dat_o <= DHCP_DEFAULT_XID(8 to 15);                      ],
   [dnl
                wbm_dat_o <= DHCP_DEFAULT_XID(16 to 23);                     ],
   [dnl
                wbm_dat_o <= DHCP_DEFAULT_XID(24 to 31);                     ],
   [dnl --- secs (unused)
                wbm_dat_o <= X"00";                                          ],
   [dnl
                wbm_dat_o <= X"00";                                          ],
   [dnl --- flags (broadcast)
                wbm_dat_o <= X"80";                                          ],
   [dnl
                wbm_dat_o <= X"00";                                          ],
   [dnl --- ciaddr
                wbm_dat_o <= self_ip_addr_in(0 to 7);                        ],
   [dnl
                wbm_dat_o <= self_ip_addr_in(8 to 15);                       ],
   [dnl
                wbm_dat_o <= self_ip_addr_in(16 to 23);                      ],
   [dnl
                wbm_dat_o <= self_ip_addr_in(24 to 31);                      ]
])
                state := transmit_zero_addr;
              when others => null;
              
            end case;

            if (byte_count = 15) then
              byte_count <= 0;
            else
              byte_count <= byte_count + 1;
            end if;

          end if;                       -- wbm_ack_i = '1' or first_data
        -----------------------------------------------------------------------
        when transmit_zero_addr =>
          -- yiaddr = 4 bytes; siaddr = 4 bytes; giaddr = 4 bytes
          if (wbm_ack_i = '1') then
            wbm_dat_o <= X"00";
            if (byte_count = 11) then
              byte_count <= 0;
              state := transmit_chaddr;
            else
              byte_count <= byte_count + 1;
            end if;
          end if;
        -----------------------------------------------------------------------
        when transmit_chaddr =>
          if (wbm_ack_i = '1') then
            case (byte_count) is
map_loop_([i], 0, [network_header_transform_], [dnl
   [dnl --- chaddr
                wbm_dat_o <= self_mac_addr_in(7 downto 0);                   ],
   [dnl
                wbm_dat_o <= self_mac_addr_in(15 downto 8);                  ],
   [dnl
                wbm_dat_o <= self_mac_addr_in(23 downto 16);                 ],
   [dnl
                wbm_dat_o <= self_mac_addr_in(31 downto 24);                 ],
   [dnl
                wbm_dat_o <= self_mac_addr_in(39 downto 32);                 ],
   [dnl
                wbm_dat_o <= self_mac_addr_in(47 downto 40);                 ]
])
                state := transmit_chaddr_zero;
              when others => null;
              
            end case;

            if (byte_count = 5) then
              byte_count <= 0;
            else
              byte_count <= byte_count + 1;
            end if;

          end if;                       -- wbm_ack_i = '1' or first_data
        -----------------------------------------------------------------------
        when transmit_chaddr_zero =>
          if (wbm_ack_i = '1') then
            wbm_dat_o <= X"00";
            if (byte_count = 9) then
              byte_count <= 0;
              state := transmit_sname;
            else
              byte_count <= byte_count + 1;
            end if;
          end if;
        -----------------------------------------------------------------------
        when transmit_sname =>
          if (wbm_ack_i = '1') then
            wbm_dat_o <= X"00";
            if (byte_count = DHCP_SNAME_BYTE_LENGTH-1) then
              byte_count <= 0;
              state := transmit_file;
            else
              byte_count <= byte_count + 1;
            end if;
          end if;
        -----------------------------------------------------------------------
        when transmit_file =>
          if (wbm_ack_i = '1') then
            wbm_dat_o <= X"00";
            if (byte_count = DHCP_FILE_BYTE_LENGTH-1) then
              byte_count <= 0;
              state := transmit_options;
            else
              byte_count <= byte_count + 1;
            end if;
          end if;
        -----------------------------------------------------------------------
        when transmit_options =>
          if (wbm_ack_i = '1') then
            case (byte_count) is
map_loop_([i], 0, [network_header_transform_], [dnl
   [dnl --- magic cookie
                wbm_dat_o <= DHCP_MAGIC_COOKIE(0 to 7);                      ],
   [dnl
                wbm_dat_o <= DHCP_MAGIC_COOKIE(8 to 15);                     ],
   [dnl
                wbm_dat_o <= DHCP_MAGIC_COOKIE(16 to 23);                    ],
   [dnl
                wbm_dat_o <= DHCP_MAGIC_COOKIE(24 to 31);                    ],
   [dnl --- message type option id
                wbm_dat_o <= DHCP_MESSAGETYPE_OPTION_ID;                     ],
   [dnl --- mesasge type length
                wbm_dat_o <= DHCP_MESSAGETYPE_OPTION_LEN;                    ],
   [dnl --- message type value
                wbm_dat_o <= message_type_in;                                ],
   [dnl --- server id option id
                if (message_type_in = DHCP_DISCOVER_MESSAGE_TYPE) then
                  wbm_dat_o <= DHCP_END_OPTION_ID;
                else
                  wbm_dat_o <= DHCP_SERVERID_OPTION_ID;
                end if;                                                      ],
   [dnl --- server id option length
                if (message_type_in = DHCP_DISCOVER_MESSAGE_TYPE) then
                  wbm_dat_o <= X"00";
                else
                  wbm_dat_o <= DHCP_SERVERID_OPTION_LEN;
                end if;                                                      ],
   [dnl --- server id option value
                if (message_type_in = DHCP_DISCOVER_MESSAGE_TYPE) then
                  wbm_dat_o <= X"00";
                else
                  wbm_dat_o <= server_ip_addr_in(0 to 7);
                end if;                                                      ],
   [dnl
                if (message_type_in = DHCP_DISCOVER_MESSAGE_TYPE) then
                  wbm_dat_o <= X"00";
                else
                  wbm_dat_o <= server_ip_addr_in(8 to 15);
                end if;                                                      ],
   [dnl
                if (message_type_in = DHCP_DISCOVER_MESSAGE_TYPE) then
                  wbm_dat_o <= X"00";
                else
                  wbm_dat_o <= server_ip_addr_in(16 to 23);
                end if;                                                      ],
   [dnl
                if (message_type_in = DHCP_DISCOVER_MESSAGE_TYPE) then
                  wbm_dat_o <= X"00";
                else
                  wbm_dat_o <= server_ip_addr_in(24 to 31);
                end if;                                                      ],
   [dnl
                wbm_dat_o <= DHCP_END_OPTION_ID;                             ]
])
              when others =>
                wbm_cyc_o <= '0';
                wbm_stb_o <= '0';
                s_ack_o <= '1';
                timeout_counter <= 0;
                state := done_state;
            end case;

            if (byte_count = DHCP_OPTION_BYTE_LENGTH) then
              byte_count <= 0;
            else
              byte_count <= byte_count + 1;
            end if;
          end if;
        -----------------------------------------------------------------------
        when done_state =>
          if (s_cyc_i = '0') then
            s_ack_o     <= '0';
            retry_count := 0;
            state       := idle;
          else
            if (timeout_counter >= RETRY_TIMEOUT-1) then
              retry_count := retry_count + 1;
              first_data  := true;
              byte_count  <= 0;
              s_ack_o     <= '0';
              state       := transmit_header;
            else
              timeout_counter <= timeout_counter + 1;
              if (retry_count >= MAX_RETRY_COUNT-1) then
                timed_out   <= '1';
                state       := timed_out_state;
              end if;
            end if;
          end if;
        -----------------------------------------------------------------------
        when others =>
          if (s_cyc_i = '0') then
            s_ack_o <= '0';
          end if;
          -- timed_out_state; we're stuck here
      end case;
    end if; -- rising_edge(wb_clk_i)

    debug_led_out <= std_logic_vector(to_unsigned(retry_count, 8));
  end process;
])
