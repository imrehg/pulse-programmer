dnl-*-VHDL-*-
-- DMA module to copy TCP segments into SRAM.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Warning does not handle zero-length transfers correctly (at least 1)
  
unit_([dma_controller], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
   ADDRESS_WIDTH : positive := 10;
   ABORT_TIMEOUT : positive := 1024;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   -- Wishbone master interface to ip_transmit
wb_xmit_master_port_
   -- Wishbone slave interface from ip_receive
wb_recv_slave_port_
  -- Memory outputs to SRAM or sizer
  mem_wbm_cyc_o          : out std_logic;
  mem_wbm_stb_o          : out std_logic;
  mem_wbm_we_o           : out std_logic;
  mem_wbm_adr_o          : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  mem_wbm_dat_i          : in  std_logic_vector(DATA_WIDTH-1 downto 0);
  mem_wbm_dat_o          : out std_logic_vector(DATA_WIDTH-1 downto 0);
  mem_wbm_ack_i          : in  std_logic;
  mem_burst              : out std_logic;
  mem_addr_in            : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  -- b/c the memory isn't a master by itself
  xmit_wbs_stb_i         : in  std_logic;
  xmit_wbs_ack_o         : out std_logic;
  xmit_length_in         : in  unsigned(0 to 15);
  xmit_length_out        : out unsigned(0 to 15);
  recv_wbm_stb_o         : buffer std_logic;
  recv_wbm_ack_i         : in  std_logic;
  recv_length_in         : in  unsigned(0 to 15);
  recv_length_out        : out unsigned(0 to 15);
  xmit_buffer_start_addr : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
  recv_buffer_start_addr : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);

],[dnl -- Declarations --------------------------------------------------------
  constant LENGTH_START_INDEX : natural := TCP_LENGTH_WIDTH - ADDRESS_WIDTH;

  signal xmit_grant      : boolean;
  signal recv_grant      : boolean;
  signal dma_xmit_wb_cyc : std_logic;
  signal dma_xmit_wb_stb : std_logic;
  signal dma_xmit_wb_dat : std_logic;
  signal dma_xmit_wb_ack : std_logic;
  signal end_address     : unsigned(ADDRESS_WIDTH-1 downto 0);
  signal length_count    : tcp_length_type;
  signal xmit_mem_stb    : std_logic;
  signal ack_enable      : std_logic;
--  signal abort_timer     : natural range 0 to ABORT_TIMEOUT;
],[dnl -- Body ----------------------------------------------------------------

  -- I think I am so clever; they will never suspect!
  xmit_wbm_cyc_o <= '1' when (xmit_grant) else '0';
  xmit_wbm_dat_o <= mem_wbm_dat_i;
  mem_wbm_dat_o <= recv_wbs_dat_i;
  mem_wbm_cyc_o <= '1' when (xmit_grant or recv_grant) else '0';
  mem_wbm_stb_o <= xmit_mem_stb when (xmit_grant) else
                   recv_wbs_stb_i       when (recv_grant) else
                   '0';
  -- either respond to master's strobes while granted or ack out errant strobes
  recv_wbs_ack_o <= mem_wbm_ack_i when (recv_grant) else
                    (recv_wbs_stb_i and ack_enable);

  -- DMA process to arbitrate between xmit/recv and transfer data.
  process (wb_clk_i, wb_rst_i)

    type state_type is (
      idle,
      receiving,
      transmit_read,
      transmit_write,
      receive_done,
      transmit_done,
      receive_wait_release
      );

    variable state       : state_type;
    
  begin

    if (wb_rst_i = '1') then
      state := idle;
      mem_burst       <= '0';
      mem_wbm_we_o    <= '0';
      xmit_wbs_ack_o  <= '0';
      xmit_wbm_stb_o  <= '0';
      xmit_mem_stb    <= '0';
      xmit_grant      <= false;
      recv_grant      <= false;
      recv_wbm_stb_o  <= '0';
--       xmit_length_out <= (others => '0');
--       recv_length_out <= (others => '0');
      ack_enable      <= '0';

    elsif (rising_edge(wb_clk_i)) then
      case (state) is
-------------------------------------------------------------------------------
        when idle =>
          xmit_wbs_ack_o <= '0';
          length_count <= (others => '0');
          if (xmit_wbs_stb_i = '1') then
            -- respond to our DMA transmit master
            xmit_grant      <= true;
            xmit_mem_stb    <= '1';
            mem_wbm_adr_o   <= xmit_buffer_start_addr;
            mem_burst       <= '1';
            xmit_length_out <= xmit_length_in;
            state           := transmit_read;
          elsif (recv_wbm_stb_o = '1') then
            -- wait for DMA receive slave to respond
            if (recv_wbm_ack_i = '1') then
              recv_wbm_stb_o <= '0';
              state          := receive_wait_release;
            end if;
          elsif (recv_wbs_cyc_i = '1') then
            -- respond to our DMA receive master
            recv_grant      <= true;
            mem_wbm_we_o    <= '1';
            mem_wbm_adr_o   <= recv_buffer_start_addr;
            mem_burst       <= '1';
            recv_length_out <= recv_length_in;
            state           := receiving;
          end if;
-------------------------------------------------------------------------------
        when receiving =>
          if (mem_wbm_ack_i = '1') then
            length_count <= length_count + 1;
          end if;
          if ((length_count >= recv_length_in) or (recv_wbs_cyc_i = '0')) then
            state := receive_done;
          end if;
-------------------------------------------------------------------------------
        when transmit_read =>
          if (xmit_wbs_stb_i = '0') then
            xmit_mem_stb <= '0';
            state        := transmit_done;
          elsif (mem_wbm_ack_i = '1') then
            length_count   <= length_count + 1;
            xmit_mem_stb   <= '0';
            xmit_wbm_stb_o <= '1';
--            abort_timer    <= 0;
            state          := transmit_write;
          end if;
-------------------------------------------------------------------------------
        when transmit_write =>
          if (xmit_wbs_stb_i = '0') then
            xmit_wbm_stb_o <= '0';
            state := transmit_done;
          elsif (xmit_wbm_ack_i = '1') then
            if (length_count >= xmit_length_in) then
              state := transmit_done;
            else
              xmit_mem_stb <= '1';
              state := transmit_read;
            end if;
            xmit_wbm_stb_o <= '0';
--          elsif (abort_timer >= ABORT_TIMEOUT-2) then
--            xmit_wbm_stb_o <= '0';
--            state := transmit_done;
--          else
--            abort_timer <= abort_timer + 1;
          end if;
-------------------------------------------------------------------------------
        when transmit_done =>
          -- we have to release the memory first, otherwise we deadlock
          xmit_grant <= false;
          xmit_wbs_ack_o <= '1';
          if (xmit_wbs_stb_i = '0') then
            mem_burst <= '0';
            state := idle;
          else
          end if;
-------------------------------------------------------------------------------
        when receive_done =>
          -- we have to release the memory first, otherwise we deadlock
          recv_grant <= false;
          recv_length_out <= length_count;
          mem_wbm_we_o     <= '0';
          if (recv_wbs_cyc_i = '0') then
            recv_wbm_stb_o <= '1';
            mem_burst      <= '0';
            ack_enable     <= '0';
            state          := idle;
          else
            -- ack out any errant bytes
            ack_enable     <= '1';
          end if;
-------------------------------------------------------------------------------
        when receive_wait_release =>
          -- wait for our slave ack to go low so it doesn't trip us again
          if (recv_wbm_ack_i = '0') then
            state := idle;
          end if;
-------------------------------------------------------------------------------
        when others =>
          null;
      end case;
    end if; -- rising_edge(wb_clk_i)

  end process;


])
