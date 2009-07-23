dnl--*-VHDL-*-
-- I2C LED controller frontend to I2C Wishbone controller
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([i2c_led_controller],
  [dnl -- Libraries
sequencer_libraries_
],[dnl -- Generics
   ENABLE_DEBUG_LEDS : boolean := TRUE;
],[dnl -- Ports
wb_common_port_
    -- Wishbone slave inputs from LED master (top-level PTP)
    wbs_stb_i      : in  std_logic;
    wbs_dat_i      : in  byte;          -- the LED selector
    wbs_ack_o      : out std_logic;
    decode_in      : in  std_logic;     -- '0' to pass wbs_dat_i straight thru

    -- All the debugging LED inputs
    eth_xmit_debug_led_in              : in  byte;
    eth_recv_debug_led_in              : in  byte;
    ip_eth_debug_led_in                : in  byte;
    ip_arp_debug_led_in                : in  byte;
    ip_arp_xmit_debug_led_in           : in  byte;
    ip_arp_recv_debug_led_in           : in  byte;
    ip_xmit_debug_led_in               : in  byte;
    ip_recv_debug_led_in               : in  byte;
    ip_debug_led_in                    : in  byte;
    trans_xmit_debug_led_in            : in  byte;
    icmp_xmit_debug_led_in             : in  byte;
    icmp_recv_debug_led_in             : in  byte;
    icmp_debug_led_in                  : in  byte;
    udp_xmit_debug_led_in              : in  byte;
    udp_recv_debug_led_in              : in  byte;
    dhcp_debug_led_in                  : in  byte;
    ptp_link_master_xmit_debug_led_in  : in  byte;
    ptp_link_master_recv_debug_led_in  : in  byte;
    ptp_link_slave_xmit_debug_led_in   : in  byte;
    ptp_link_slave_recv_debug_led_in   : in  byte;
    ptp_link_state_debug_led_in        : in  byte;
    ptp_link_recv_arbiter_debug_led_in : in  byte;
    ptp_link_debug_led_in              : in  byte;
    ptp_route_debug_led_in             : in  byte;
    ptp_route_buffer_debug_led_in      : in  byte;
    ptp_route_xmit_debug_led_in        : in  byte;
    ptp_route_recv_debug_led_in        : in  byte;
    ptp_top_debug_led_in               : in  byte;
    ptp_debug_led_in                   : in  byte;
    sequencer_debug_led_in             : in  byte;

    -- Wishbone master outputs to I2C controller
    wbm_cyc_o      : out std_logic;
    wbm_stb_o      : out std_logic;
    wbm_we_o       : out std_logic;
    wbm_adr_o      : out i2c_slave_address_type;
    wbm_dat_o      : out byte;
    wbm_ack_i      : in  std_logic;
],[dnl -- Declarations
  constant LED_READ              : byte     := X"11";
  constant LED_WRITE_NO_OUTPUT   : byte     := X"11";
  constant LED_OUTPUT            : byte     := X"22";
  constant LED_WRITE_OUTPUT      : byte     := X"44";
],[dnl -- Body

   wbm_adr_o <= I2C_LED_SLAVE_ADDRESS;
   -- We only ever write to the LED controller
   wbm_we_o  <= '1';
   
   process (wb_rst_i, wb_clk_i)

     type led_state_type is (
       idle,
       sending,
       waiting_ack,
       done_state
       );

     variable state : led_state_type;
     variable overlap : boolean;
     
   begin
     if (wb_rst_i = '1') then
       state     := idle;
       wbs_ack_o <= '0';
       wbm_cyc_o <= '0';
       wbm_stb_o <= '0';
     elsif (rising_edge(wb_clk_i)) then
       case (state) is
-------------------------------------------------------------------------------
         when idle =>
           overlap := false;
           if (wbs_stb_i = '1') then
             wbm_dat_o <= LED_WRITE_OUTPUT;
             wbm_cyc_o <= '1';
             wbm_stb_o <= '1';
             state     := sending;
           end if;
-------------------------------------------------------------------------------
         when sending =>
           if (wbm_ack_i = '1') then
             if (ENABLE_DEBUG_LEDS) then
               if (decode_in = '1') then
                 case (wbs_dat_i) is
                   when X"00" =>
                     wbm_dat_o <= eth_xmit_debug_led_in;
                   when X"01" =>
                     wbm_dat_o <= eth_recv_debug_led_in;
                   when X"02" =>
                     wbm_dat_o <= ip_eth_debug_led_in;
                   when X"03" =>
                     wbm_dat_o <= ip_arp_debug_led_in;
                   when X"04" =>
                     wbm_dat_o <= ip_arp_xmit_debug_led_in;
                   when X"05" =>
                     wbm_dat_o <= ip_arp_recv_debug_led_in;
                   when X"06" =>
                     wbm_dat_o <= ip_xmit_debug_led_in;
                   when X"07" =>
                     wbm_dat_o <= ip_recv_debug_led_in;
                   when X"08" =>
                     wbm_dat_o <= ip_debug_led_in;
                   when X"09" =>
                     wbm_dat_o <= trans_xmit_debug_led_in;
                   when X"0a" =>
                     wbm_dat_o <= icmp_xmit_debug_led_in;
                   when X"0b" =>
                     wbm_dat_o <= icmp_recv_debug_led_in;
                   when X"0c" =>
                     wbm_dat_o <= icmp_debug_led_in;
                   when X"0d" =>
                     wbm_dat_o <= udp_xmit_debug_led_in;
                   when X"0e" =>
                     wbm_dat_o <= udp_recv_debug_led_in;
                   when X"0f" =>
                     wbm_dat_o <= dhcp_debug_led_in;
                   when X"10" =>
                     wbm_dat_o <= ptp_link_master_xmit_debug_led_in;
                   when X"11" =>
                     wbm_dat_o <= ptp_link_master_recv_debug_led_in;
                   when X"12" =>
                     wbm_dat_o <= ptp_link_slave_xmit_debug_led_in;
                   when X"13" =>
                     wbm_dat_o <= ptp_link_slave_recv_debug_led_in;
                   when X"14" =>
                     wbm_dat_o <= ptp_link_state_debug_led_in;
                   when X"15" =>
                     wbm_dat_o <= ptp_link_recv_arbiter_debug_led_in;
                   when X"16" =>
                     wbm_dat_o <= ptp_link_debug_led_in;
                   when X"17" =>
                     wbm_dat_o <= ptp_debug_led_in;
                   when X"18" =>
                     wbm_dat_o <= ptp_route_debug_led_in;
                   when X"19" =>
                     wbm_dat_o <= ptp_route_buffer_debug_led_in;
                   when X"1a" =>
                     wbm_dat_o <= ptp_route_xmit_debug_led_in;
                   when X"1b" =>
                     wbm_dat_o <= ptp_route_recv_debug_led_in;
                   when X"1c" =>
                     wbm_dat_o <= ptp_top_debug_led_in;
                   when X"1d" =>
                     wbm_dat_o <= sequencer_debug_led_in;
                   when others =>
                     -- for all other codes, just pass through without decoding
                     wbm_dat_o <= wbs_dat_i;
                 end case;
               else
                 wbm_dat_o <= wbs_dat_i;
               end if;
             else -- ENABLE DEBUG
               wbm_dat_o <= wbs_dat_i;
             end if;
             state := waiting_ack;
           end if;
-------------------------------------------------------------------------------
         when waiting_ack =>
           if (wbm_ack_i = '1') then
             wbm_stb_o <= '0';
             wbs_ack_o <= '1';
             state     := done_state;
           end if;
-------------------------------------------------------------------------------
         when done_state =>
           if (wbs_stb_i = '0') then
             overlap   := true;
             wbs_ack_o <= '0';
           end if;
           if (overlap and (wbm_ack_i = '0')) then
             wbm_cyc_o <= '0';
             state     := idle;
           end if;
-------------------------------------------------------------------------------
         when others =>
           state := done_state;
       end case;
     end if;

   end process;
])
