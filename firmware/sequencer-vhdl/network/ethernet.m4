dnl--*-VHDL-*-
-- Top-level Ethernet module.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- This module currently just wraps the modules ethernet_transmit and
-- ethernet_receive. But when this turns into a full-fledged Ethernet MAC
-- eventually, it will also contain the clock generators and registers for
-- the management interface.

unit_([ethernet], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
  ADDRESS_WIDTH      : positive := 8;
  STABLE_COUNT       : positive := 2;
],[dnl -- Ports ---------------------------------------------------------------
  wb_rst_i                : in  std_logic;
  wb_clk_i                : in  std_logic;
  self_mac_addr_in        : in  mac_address := SELF_MAC_ADDRESS;
  -- Ethernet transmit Wishbone slave interface from IP layer
  ip_xmit_wb_cyc_i        : in  std_logic;
  ip_xmit_wb_stb_i        : in  std_logic;
  ip_xmit_wb_ack_o        : out std_logic;
  ip_xmit_wb_dat_i        : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  ip_xmit_total_length_in : in  ip_total_length;
  ip_xmit_type_length_in  : in  ethernet_type_length;
  ip_xmit_dest_addr_in    : in  mac_address;
  xmit_debug_led_out      : out byte;
ethernet_phy_transmit_ports_
  -- Ethernet receive Wishbone master interface to IP layer
  ip_recv_wb_cyc_o        : out std_logic;
  ip_recv_wb_stb_o        : out std_logic;
  ip_recv_wb_dat_o        : out std_logic_vector(DATA_WIDTH-1 downto 0);
  ip_recv_wb_ack_i        : in  std_logic;
  ip_recv_type_length_out : out ethernet_type_length;
  ip_recv_error_out       : out std_logic;
  recv_debug_led_out      : out byte;
ethernet_phy_receive_ports_
],[dnl -- Declarations --------------------------------------------------------
ethernet_transmit_component_
ethernet_receive_component_
memory_dual_dc_component_
async_fifo_component_

  -- Signals for ethernet recv fifo and proxy
  signal ip_recv_wb_cyc         : std_logic;
  signal ip_recv_type_length    : ethernet_type_length;
  signal ip_recv_error          : std_logic;
  signal ether_recv_wb_cyc      : std_logic;
  signal ether_recv_wb_stb      : std_logic;
  signal ether_recv_wb_dat      : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal ether_recv_wb_ack      : std_logic;
  signal ether_recv_type_length : ethernet_type_length;

  subtype ethernet_buffer_address_type is
    std_logic_vector(ETHERNET_BUFFER_ADDRESS_WIDTH-1 downto 0);

  -- Intermediate signal to convert ip_xmit register feedback in to async
  signal ip_xmit_enable         : std_logic;
  signal ip_xmit_ready_flag     : boolean;
  signal ip_xmit_done_flag      : boolean;
  signal ip_xmit_addr           : ethernet_buffer_address_type;
  signal ip_xmit_end_addr       : ethernet_buffer_address_type;
  signal ether_xmit_addr        : ethernet_buffer_address_type;
  signal ether_xmit_wb_cyc      : std_logic;
  signal ether_xmit_wb_stb      : std_logic;
  signal ether_xmit_wb_dat      : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal ether_xmit_wb_ack      : std_logic;
  signal ether_xmit_type_length : ethernet_type_length;
  signal ether_xmit_dest_addr   : mac_address;
  signal ether_xmit_cyc         : std_logic;
  signal ether_xmit_stb         : std_logic;
  signal ether_xmit_ack         : std_logic;

  -- Internal error signals
  signal eth_recv_checksum_error : std_logic;
  signal eth_recv_length_error   : std_logic;
  signal eth_recv_header_valid   : std_logic;

  signal ether_recv_writing      : std_logic;
  signal recv_stable_counter     : natural range 0 to STABLE_COUNT+1;
],[dnl -- Body ----------------------------------------------------------------
  recv_fifo : async_fifo
    generic map (
      DATA_WIDTH       =>  DATA_WIDTH,
      WORD_COUNT_WIDTH =>  ADDRESS_WIDTH
      )
    port map (
      wb_rst_i         => wb_rst_i,
      wb_read_clk_i    => wb_clk_i,
      wb_read_cyc_o    => ip_recv_wb_cyc_o,
      wb_read_stb_o    => ip_recv_wb_stb_o,
      wb_read_dat_o    => ip_recv_wb_dat_o,
      wb_read_ack_i    => ip_recv_wb_ack_i,
      wb_write_clk_i   => eth_recv_clock,
      wb_write_cyc_i   => ether_recv_wb_cyc,
      wb_write_stb_i   => ether_recv_wb_stb,
      wb_write_dat_i   => ether_recv_wb_dat,
      wb_write_ack_o   => ether_recv_wb_ack,
      writing_cyc_out  => ether_recv_writing
--      debug_led_out    => recv_debug_led_out
      );
  -----------------------------------------------------------------------------
  xmit_fifo : memory_dual_dc
    generic map (
      DATA_WIDTH     => DATA_WIDTH,
      ADDRESS_WIDTH  => ETHERNET_BUFFER_ADDRESS_WIDTH
      )
    port map (
      -- First port
      wb1_clk_i      => eth_xmit_clock,
      wb1_cyc_i      => ether_xmit_wb_cyc,
      wb1_stb_i      => ether_xmit_wb_stb,
      wb1_we_i       => '0',
      wb1_adr_i      => (others => '0'),
      wb1_dat_i      => (others => '0'),
      wb1_dat_o      => ether_xmit_wb_dat,
      wb1_ack_o      => ether_xmit_wb_ack,
      burst1_in      => ether_xmit_wb_cyc,
      addr1_out      => ether_xmit_addr,
      -- Second port
      wb2_clk_i     => wb_clk_i,
      wb2_cyc_i     => ip_xmit_wb_cyc_i and ip_xmit_enable, 
      wb2_stb_i     => ip_xmit_wb_stb_i,
      wb2_we_i      => ip_xmit_wb_cyc_i,
      wb2_adr_i     => (others => '0'),
      wb2_dat_i     => ip_xmit_wb_dat_i,
--      wb2_dat_o 
      wb2_ack_o     => ip_xmit_wb_ack_o,
      burst2_in     => ip_xmit_wb_cyc_i,
      addr2_out     => ip_xmit_addr
      );

  xmit_writer : process(wb_rst_i, wb_clk_i)

    type state_type is (
      idle,
      writing_in,
      reading_out,
      waiting_fall
      );

    variable state          : state_type;
    variable stable_counter : natural range 0 to STABLE_COUNT+1;

  begin
    if (wb_rst_i = '1') then
      state := idle;
      ip_xmit_enable <= '0';
      ip_xmit_ready_flag <= false;
    elsif (rising_edge(wb_clk_i)) then
      case (state) is
        -----------------------------------------------------------------------
        when idle =>
          if (ip_xmit_wb_cyc_i = '1') then
            ip_xmit_enable <= '1';
            state := writing_in;
          end if;
        -----------------------------------------------------------------------
        when writing_in =>
          if (ip_xmit_wb_cyc_i = '0') then
            -- prevent overlaps
            ip_xmit_ready_flag <= true;
            ip_xmit_enable <= '0';
            ip_xmit_end_addr <= ip_xmit_addr;
            stable_counter := 0;
            state := reading_out;
          end if;
        -----------------------------------------------------------------------
        when reading_out =>
          if (stable_counter >= STABLE_COUNT) then
            ip_xmit_ready_flag <= false;
            stable_counter := 0;
            state := waiting_fall;
          elsif (ip_xmit_done_flag) then
            stable_counter := stable_counter + 1;
          end if;
        -----------------------------------------------------------------------
        when waiting_fall =>
          if (stable_counter >= STABLE_COUNT) then
            stable_counter := 0;
            state := idle;
          elsif (not ip_xmit_done_flag) then
            stable_counter := stable_counter + 1;
          end if;
        -----------------------------------------------------------------------
        when others => null;
      end case;
    end if;

  end process;

  -----------------------------------------------------------------------------
  xmit_reader : process(wb_rst_i, eth_xmit_clock)

    type state_type is (
      idle,
      reading,
      reading_data,
      reading_ack,
      waiting_fall
      );

    variable state          : state_type;
    variable stable_counter : natural range 0 to STABLE_COUNT+1;
    variable end_address    : ethernet_buffer_address_type;

  begin
    if (wb_rst_i = '1') then
      stable_counter := 0;
      state := idle;
    elsif (rising_edge(eth_xmit_clock)) then
      case (state) is
        -----------------------------------------------------------------------
        when idle =>
          ether_xmit_cyc <= '0';
          ether_xmit_stb <= '0';
          ip_xmit_done_flag <= false;
          if (stable_counter >= STABLE_COUNT) then
            end_address := std_logic_vector(unsigned(end_address) - 1);
            state := reading_data;
          else
            if (ip_xmit_ready_flag and (end_address = ip_xmit_end_addr) and
                (ether_xmit_dest_addr = ip_xmit_dest_addr_in) and
                (ether_xmit_type_length = ip_xmit_type_length_in)) then
              stable_counter := stable_counter + 1;
            else
              stable_counter         := 0;
              end_address            := ip_xmit_end_addr;
              ether_xmit_dest_addr   <= ip_xmit_dest_addr_in;
              ether_xmit_type_length <= ip_xmit_type_length_in;
            end if;
          end if;
        -----------------------------------------------------------------------
        when reading_data =>
          ether_xmit_cyc <= '1';
          ether_xmit_stb <= '1';
          if (ether_xmit_addr >= end_address) then
            stable_counter := 0;
            state := reading_ack;
          end if;
        -----------------------------------------------------------------------
        when reading_ack =>
          ether_xmit_stb <= '0';
          if (ether_xmit_ack = '1') then
            ether_xmit_cyc <= '0';
            state := idle;
            ip_xmit_done_flag <= true;
            state := waiting_fall;
          end if;
        -----------------------------------------------------------------------
        when waiting_fall =>
          if (stable_counter >= STABLE_COUNT) then
            stable_counter := 0;
            state := idle;
          elsif (not ip_xmit_ready_flag) then
            stable_counter := stable_counter + 1;
          end if;
        -----------------------------------------------------------------------
        when others => null;
      end case;
    end if;

  end process;

--   recv_debug_led_out    <= ip_recv_wb_dat_o;
--   xmit_debug_led_out(7) <= ip_recv_wb_cyc_o;
--   xmit_debug_led_out(6) <= ip_recv_wb_stb_o;
--   xmit_debug_led_out(5) <= ip_recv_wb_ack_i;
--   xmit_debug_led_out    <= ip_xmit_wb_dat_i;
--   recv_debug_led_out(7) <= ip_xmit_wb_cyc_i;
--   recv_debug_led_out(6) <= ip_xmit_wb_stb_i;
--   recv_debug_led_out(5) <= ip_xmit_wb_ack_o;
  -----------------------------------------------------------------------------
  transmitter : ethernet_transmit
    generic map (
      DATA_WIDTH => DATA_WIDTH
      )
    port map (
      -- Wishbone slave interface
      wb_rst_i       => wb_rst_i,
      s_cyc_i        => ether_xmit_cyc,
      s_stb_i        => ether_xmit_stb,
      s_ack_o        => ether_xmit_ack,
      wb_cyc_o       => ether_xmit_wb_cyc,
      wb_stb_o       => ether_xmit_wb_stb,
      wb_dat_i       => ether_xmit_wb_dat,
      wb_ack_i       => ether_xmit_wb_ack,
      -- Non-Wishbone interface to Ethernet MAC
      dest_addr_in   => ether_xmit_dest_addr,
      src_addr_in    => self_mac_addr_in,
      type_length_in => ether_xmit_type_length,
      -- Non-Wishbone interface to Ethernet PHY/MII
      phy_clock      => eth_xmit_clock,
      nibble_out     => eth_xmit_data_out,
      phy_enable     => eth_xmit_enable,
      debug_led_out  => xmit_debug_led_out
      );
  -----------------------------------------------------------------------------
  receiver : ethernet_receive
    generic map (
      DATA_WIDTH => DATA_WIDTH
      )
    port map (
      -- Wishbone master interface
      wb_rst_i         => wb_rst_i,
      wb_cyc_o         => ether_recv_wb_cyc,
      wb_stb_o         => ether_recv_wb_stb,
      wb_dat_o         => ether_recv_wb_dat,
      wb_ack_i         => ether_recv_wb_ack,
      -- Non-Wishbone interface to Ethernet MAC
      src_addr_in      => self_mac_addr_in,
      type_length_out  => ether_recv_type_length,
--      src_addr_out    => ip_recv_src_addr_out  -- currently discard this
      checksum_error   => eth_recv_checksum_error,
      length_error     => eth_recv_length_error,
      debug_led_out   => recv_debug_led_out,
      header_valid_out => eth_recv_header_valid,
      -- Non-Wishbone interface to Ethernet PHY/MII
      phy_clock        => eth_recv_clock,
      nibble_in        => eth_recv_data_in,
      phy_data_valid   => eth_recv_data_valid
      );

  -- Process to latch type-length and errors
  recv_latching : process(wb_rst_i, wb_clk_i)

    type state_type is (
      idle,
      active
      );

    variable state : state_type;

  begin
    if (wb_rst_i = '1') then
      state := idle;
      ip_recv_error <= '0';
      ip_recv_type_length <= (others => '0');
      recv_stable_counter <= 0;
    elsif (rising_edge(wb_clk_i)) then
      case (state) is
        -----------------------------------------------------------------------
        when idle =>
          if ((ether_recv_writing = '1') and
              (recv_stable_counter >= STABLE_COUNT)) then
--            ip_recv_type_length <= ether_recv_type_length;
            recv_stable_counter <= 0;
            state := active;
          elsif (eth_recv_header_valid = '1') then
            if (ether_recv_type_length = ip_recv_type_length) then
              recv_stable_counter <= recv_stable_counter + 1;
            else
              recv_stable_counter <= 0;
              ip_recv_type_length <= ether_recv_type_length;
            end if;
          end if;
        -----------------------------------------------------------------------
        when active =>
          if (ether_recv_writing = '0') then
            -- Latch error at the end so that checksum has already occurred
            ip_recv_error <= eth_recv_checksum_error or eth_recv_length_error;
            state := idle;
          end if;
        when others => null;
      end case;
    end if;
  end process;

   ip_recv_error_out <= ip_recv_error;
   ip_recv_type_length_out <= ip_recv_type_length;

])
