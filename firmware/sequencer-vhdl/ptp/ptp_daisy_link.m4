dnl-*-VHDL-*-
-- PTP daisy-chain link level.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([ptp_daisy_link], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
data_generic_
   STABLE_COUNT  : positive := 1;
   ABORT_TIMEOUT : positive := 10;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   -- Daisy-chain Wishbone transmit interface
wb_xmit_slave_port_
   xmit_interface_in               : ptp_interface_type;
   -- Daisy-chain Wishbone receive interface
wb_recv_master_port_
   -- Physical daisy chain pins to master
   master_xmit_stb_ack             : buffer std_logic;
   master_xmit_dat_cyc             : buffer std_logic;
   master_recv_stb_ack             : in     std_logic;
   master_recv_dat_cyc             : in     std_logic;
   -- Physical daisy chain pins to slave
   slave_xmit_stb_ack              : buffer std_logic;
   slave_xmit_dat_cyc              : buffer std_logic;
   slave_recv_stb_ack              : in     std_logic;
   slave_recv_dat_cyc              : in     std_logic;
   -- Debugging LED outputs
   master_xmit_debug_led_out       : out    byte;
   master_recv_debug_led_out       : out    byte;
   slave_xmit_debug_led_out        : out    byte;
   slave_recv_debug_led_out        : out    byte;
   recv_arbiter_debug_led_out      : out    byte;
   state_debug_led_out             : out    byte;
   debug_led_out                   : out    byte;
],[dnl -- Declarations --------------------------------------------------------
   signal master_xmit_wbs_cyc_i    : std_logic;
   signal master_xmit_wbs_ack_o    : std_logic;
   signal slave_xmit_wbs_cyc_i     : std_logic;
   signal slave_xmit_wbs_ack_o     : std_logic;

   -- Wishbone signals from master daisy-chain receiver to be arbitrated
   signal master_recv_wbm_cyc_o    : std_logic;
   signal master_recv_wbm_stb_o    : std_logic;
   signal master_recv_wbm_dat_o    : std_logic_vector(0 to 7);
   signal master_recv_wbm_ack_i    : std_logic;

   -- Wishbone signals from slave daisy-chain receiver to be arbitrated
   signal slave_recv_wbm_cyc_o     : std_logic;
   signal slave_recv_wbm_stb_o     : std_logic;
   signal slave_recv_wbm_dat_o     : std_logic_vector(0 to 7);
   signal slave_recv_wbm_ack_i     : std_logic;

   signal xmit_arbiter_gnt         : std_logic_vector(0 to 2);
   signal recv_arbiter_gnt         : multibus_bit(0 to 1);
   signal recv_arbiter_ack         : multibus_bit(0 to 1);

   -- Grant signals for daisy-chain transmit line arbiter
   signal master_xmit_gnt          : std_logic;
   signal master_recv_gnt          : std_logic;
   signal slave_xmit_gnt           : std_logic;
   signal slave_recv_gnt           : std_logic;

   -- Daisy-chain transmit lines for master and slave to be arbitrated
   signal master_xmit_xmit_stb_ack : std_logic;
   signal master_xmit_xmit_dat_cyc : std_logic;
   signal master_recv_xmit_stb_ack : std_logic;
   signal master_recv_xmit_dat_cyc : std_logic;
   signal slave_xmit_xmit_stb_ack  : std_logic;
   signal slave_xmit_xmit_dat_cyc  : std_logic;
   signal slave_recv_xmit_stb_ack  : std_logic;
   signal slave_recv_xmit_dat_cyc  : std_logic;

   signal master_xmit_busy         : boolean;
   signal master_recv_busy         : boolean;
   signal slave_xmit_busy          : boolean;
   signal slave_recv_busy          : boolean;

   signal ack_stable_count : natural range 0 to STABLE_COUNT+1;
   signal timeout_counter  : natural range 0 to ABORT_TIMEOUT+1;

   signal master_xmit_stable_count : natural range 0 to STABLE_COUNT;
   signal master_recv_stable_count : natural range 0 to STABLE_COUNT;
   signal slave_xmit_stable_count  : natural range 0 to STABLE_COUNT;
   signal slave_recv_stable_count  : natural range 0 to STABLE_COUNT;

ptp_daisy_receive_component_
ptp_daisy_transmit_component_
],[dnl -- Body ----------------------------------------------------------------
-------------------------------------------------------------------------------
-- Daisy-chain transmitter and receiver to master (up the chain)
  master_transmitter : ptp_daisy_transmit
    generic map (
      DATA_WIDTH          => DATA_WIDTH,
      STABLE_COUNT        => STABLE_COUNT,
      ABORT_TIMEOUT       => ABORT_TIMEOUT
      )
    port map (
      -- Wishbone common signals
      wb_clk_i            => wb_clk_i,
      wb_rst_i            => wb_rst_i,
      -- Wishbone Daisy-chain transmit interface
      xmit_wbs_cyc_i      => master_xmit_wbs_cyc_i,
      xmit_wbs_stb_i      => xmit_wbs_stb_i,
      xmit_wbs_dat_i      => xmit_wbs_dat_i,
      xmit_wbs_ack_o      => master_xmit_wbs_ack_o,
      debug_led_out       => master_xmit_debug_led_out,
      busy_out            => master_xmit_busy,
      -- Non-Wishbone physical daisy-chain pins
      daisy_xmit_stb_ack  => master_xmit_xmit_stb_ack,
      daisy_xmit_dat_cyc  => master_xmit_xmit_dat_cyc,
      daisy_recv_stb_ack  => master_recv_stb_ack and master_xmit_gnt,
      daisy_recv_dat_cyc  => master_recv_dat_cyc and master_xmit_gnt
      );

  master_receive : ptp_daisy_receive
    generic map (
      DATA_WIDTH          => DATA_WIDTH,
      STABLE_COUNT        => STABLE_COUNT,
      ABORT_TIMEOUT       => ABORT_TIMEOUT
      )
    port map (
      -- Wishbone common signals
      wb_clk_i            => wb_clk_i,
      wb_rst_i            => wb_rst_i,
      -- Wishbone Daisy-chain transmit interface
      recv_wbm_cyc_o      => master_recv_wbm_cyc_o,
      recv_wbm_stb_o      => master_recv_wbm_stb_o,
      recv_wbm_dat_o      => master_recv_wbm_dat_o,
      recv_wbm_ack_i      => master_recv_wbm_ack_i,
      debug_led_out       => master_recv_debug_led_out,
      busy_out            => master_recv_busy,
      -- Wishbone daisy-chain receive interface
      daisy_xmit_stb_ack  => master_recv_xmit_stb_ack,
      daisy_xmit_dat_cyc  => master_recv_xmit_dat_cyc,
      daisy_recv_stb_ack  => master_recv_stb_ack and master_recv_gnt,
      daisy_recv_dat_cyc  => master_recv_dat_cyc and master_recv_gnt
    );

-------------------------------------------------------------------------------
-- Daisy-chain transmitter and receiver to slave (down the chain)
  slave_transmitter : ptp_daisy_transmit
    generic map (
      DATA_WIDTH          => DATA_WIDTH,
      STABLE_COUNT        => STABLE_COUNT,
      ABORT_TIMEOUT       => ABORT_TIMEOUT
      )
    port map (
      -- Wishbone common signals
      wb_clk_i            => wb_clk_i,
      wb_rst_i            => wb_rst_i,
      -- Wishbone Daisy-chain transmit interface
      xmit_wbs_cyc_i      => slave_xmit_wbs_cyc_i,
      xmit_wbs_stb_i      => xmit_wbs_stb_i,
      xmit_wbs_dat_i      => xmit_wbs_dat_i,
      xmit_wbs_ack_o      => slave_xmit_wbs_ack_o,
      debug_led_out       => slave_xmit_debug_led_out,
      busy_out            => slave_xmit_busy,
      -- Non-Wishbone physical daisy-chain pins
      daisy_xmit_stb_ack  => slave_xmit_xmit_stb_ack,
      daisy_xmit_dat_cyc  => slave_xmit_xmit_dat_cyc,
      daisy_recv_stb_ack  => slave_recv_stb_ack and slave_xmit_gnt,
      daisy_recv_dat_cyc  => slave_recv_dat_cyc and slave_xmit_gnt
      );

  slave_receive : ptp_daisy_receive
    generic map (
      DATA_WIDTH          => DATA_WIDTH,
      STABLE_COUNT        => STABLE_COUNT,
      ABORT_TIMEOUT       => ABORT_TIMEOUT
      )
    port map (
      -- Wishbone common signals
      wb_clk_i            => wb_clk_i,
      wb_rst_i            => wb_rst_i,
      -- Wishbone Daisy-chain transmit interface
      recv_wbm_cyc_o      => slave_recv_wbm_cyc_o,
      recv_wbm_stb_o      => slave_recv_wbm_stb_o,
      recv_wbm_dat_o      => slave_recv_wbm_dat_o,
      recv_wbm_ack_i      => slave_recv_wbm_ack_i,
      debug_led_out       => slave_recv_debug_led_out,
      busy_out            => slave_recv_busy,
      -- Wishbone daisy-chain receive interface
      daisy_xmit_stb_ack  => slave_recv_xmit_stb_ack,
      daisy_xmit_dat_cyc  => slave_recv_xmit_dat_cyc,
      daisy_recv_stb_ack  => slave_recv_stb_ack and slave_recv_gnt,
      daisy_recv_dat_cyc  => slave_recv_dat_cyc and slave_recv_gnt
    );

-------------------------------------------------------------------------------
-- Transmit arbiter from Wishbone interface to daisy-chain master or slave
   xmit_arbiter : process(wb_rst_i, wb_clk_i, xmit_interface_in,
                          xmit_wbs_cyc_i, xmit_arbiter_gnt, xmit_wbs_stb_i,
                          master_xmit_wbs_ack_o, slave_xmit_wbs_ack_o)

   begin
     if (wb_rst_i = '1') then
       xmit_arbiter_gnt <= B"000";
     elsif (rising_edge(wb_clk_i)) then
       if (xmit_wbs_cyc_i = '1') then
         case (xmit_interface_in) is
           when to_master =>
             xmit_arbiter_gnt <= B"100";
           when to_slave =>
             xmit_arbiter_gnt <= B"010";
           when others =>
             xmit_arbiter_gnt <= B"001";
         end case;
       else
         xmit_arbiter_gnt <= B"000";
       end if;
     end if;                            -- rising_edge(wb_clk_i)

     master_xmit_wbs_cyc_i <= xmit_wbs_cyc_i and xmit_arbiter_gnt(0);
     slave_xmit_wbs_cyc_i  <= xmit_wbs_cyc_i and xmit_arbiter_gnt(1);

     case (xmit_arbiter_gnt) is
       when B"100" =>
         xmit_wbs_ack_o <= master_xmit_wbs_ack_o;
       when B"010" =>
         xmit_wbs_ack_o <= slave_xmit_wbs_ack_o;
       when B"001" =>
         xmit_wbs_ack_o <= xmit_wbs_stb_i;
       when others =>
         xmit_wbs_ack_o <= '0';
     end case;

   end process;
-------------------------------------------------------------------------------
-- Receive arbiter from either daisy-chain master or slave to Wishbone slave
    recv_arbiter : wb_intercon
      generic map (
        MASTER_COUNT  => 2
        )
      port map (
        wb_clk_i      => wb_clk_i,
        wb_rst_i      => wb_rst_i,

        wbm_cyc_i     => (master_recv_wbm_cyc_o, slave_recv_wbm_cyc_o),
        wbm_stb_i     => (master_recv_wbm_stb_o, slave_recv_wbm_stb_o),
        wbm_dat_i     => (master_recv_wbm_dat_o, slave_recv_wbm_dat_o),
        wbm_ack_o     => recv_arbiter_ack,
        wbm_gnt_o     => recv_arbiter_gnt,

        wbs_cyc_o     => recv_wbm_cyc_o,
        wbs_stb_o     => recv_wbm_stb_o,
        wbs_dat_o     => recv_wbm_dat_o,
        wbs_ack_i     => recv_wbm_ack_i,
        debug_led_out => recv_arbiter_debug_led_out
        );

    master_recv_wbm_ack_i <= recv_arbiter_ack(0);
    slave_recv_wbm_ack_i  <= recv_arbiter_ack(1);
-------------------------------------------------------------------------------
-- Arbiter between daisy-chain master xmit/recv and slave xmit/recv

  debug_led_out(7) <= master_recv_gnt;
  debug_led_out(6) <= master_xmit_gnt;
  debug_led_out(5) <= slave_recv_gnt;
  debug_led_out(4) <= slave_xmit_gnt;
  debug_led_out(3 downto 1) <= xmit_arbiter_gnt;

  state_debug_led_out(7) <= '1' when master_recv_busy else '0';
  state_debug_led_out(6) <= '1' when master_xmit_busy else '0';
  state_debug_led_out(5) <= '1' when slave_recv_busy  else '0';
  state_debug_led_out(4) <= '1' when slave_xmit_busy  else '0';
 
  daisy_arbiter : process(wb_rst_i, wb_clk_i)

    type daisy_arbiter_states is (
      idle,
      master_xmit_start,
      master_xmit,
      master_recv_start,
      master_recv,
      slave_xmit_start,
      slave_xmit,
      slave_recv_start,
      slave_recv
      );

    variable state                    : daisy_arbiter_states;

  begin

    if (wb_rst_i = '1') then
      master_recv_gnt          <= '0';
      master_xmit_gnt          <= '0';
      slave_recv_gnt           <= '0';
      slave_xmit_gnt           <= '0';
      master_xmit_stable_count <= 0;
      master_recv_stable_count <= 0;
      slave_xmit_stable_count  <= 0;
      slave_recv_stable_count  <= 0;
      state                    := idle;

    elsif (rising_edge(wb_clk_i)) then
      case (state) is
-------------------------------------------------------------------------------
        when idle =>
          ack_stable_count <= 0;
          state_debug_led_out(3 downto 0) <= B"0001";
          if ((master_recv_stb_ack = '0') and
              (master_recv_dat_cyc = '1')) then
            slave_xmit_stable_count  <= 0;
            master_xmit_stable_count <= 0;
            slave_recv_stable_count  <= 0;

            if (master_recv_stable_count >= STABLE_COUNT-1) then
              master_recv_gnt <= '1';
              state           := master_recv_start;
            else
              master_recv_stable_count <= master_recv_stable_count + 1;
            end if;

          elsif ((slave_xmit_xmit_stb_ack = '0') and
                 (slave_xmit_xmit_dat_cyc = '1')) then
            master_xmit_stable_count <= 0;
            master_recv_stable_count <= 0;
            slave_recv_stable_count  <= 0;

            if (slave_xmit_stable_count >= STABLE_COUNT-1) then
              slave_xmit_gnt <= '1';
              state          := slave_xmit_start;
            else
              slave_xmit_stable_count <= slave_xmit_stable_count + 1;
            end if;
            
          elsif ((slave_recv_stb_ack = '0') and
                 (slave_recv_dat_cyc = '1')) then
            master_xmit_stable_count <= 0;
            master_recv_stable_count <= 0;
            slave_xmit_stable_count  <= 0;

            if (slave_recv_stable_count >= STABLE_COUNT-1) then
              slave_recv_gnt <= '1';
              state          := slave_recv_start;
            else
              slave_recv_stable_count <= slave_recv_stable_count + 1;
            end if;
            
          elsif ((master_xmit_xmit_stb_ack = '0') and
                 (master_xmit_xmit_dat_cyc = '1')) then
            slave_xmit_stable_count  <= 0;
            master_recv_stable_count <= 0;
            slave_recv_stable_count  <= 0;

            if (master_xmit_stable_count >= STABLE_COUNT-1) then
              master_xmit_gnt <= '1';
              state           := master_xmit_start;
            else
              master_xmit_stable_count <= master_xmit_stable_count + 1;
            end if;
          end if;
-------------------------------------------------------------------------------
        when master_recv_start =>
          state_debug_led_out(3 downto 0) <= B"0010";
          master_recv_stable_count <= 0;
          if (master_recv_busy) then
            state := master_recv;
          end if;
          
        when master_recv =>
          state_debug_led_out(3 downto 0) <= B"0011";

          if (not master_recv_busy) then
            master_recv_gnt <= '0';
            state := idle;  
          end if;
-------------------------------------------------------------------------------
        when master_xmit_start =>
          state_debug_led_out(3 downto 0) <= B"0100";
          master_xmit_stable_count <= 0;
          if (master_xmit_busy) then
            state := master_xmit;
          end if;
          
        when master_xmit =>
          state_debug_led_out(3 downto 0) <= B"0101";
          if (not master_xmit_busy) then
            master_xmit_gnt <= '0';
            state := idle;
          end if;
-------------------------------------------------------------------------------
        when slave_recv_start =>
          state_debug_led_out(3 downto 0) <= B"0110";
          slave_recv_stable_count <= 0;
          if (slave_recv_busy) then
            state := slave_recv;
          end if;
          
        when slave_recv =>
          state_debug_led_out(3 downto 0) <= B"0111";
          if (not slave_recv_busy) then
            slave_recv_gnt <= '0';
            state :=idle;
          end if;
-------------------------------------------------------------------------------
        when slave_xmit_start =>
          state_debug_led_out(3 downto 0) <= B"1000";
          slave_xmit_stable_count <= 0;
          if (slave_xmit_busy) then
            state := slave_xmit;
          end if;
          
        when slave_xmit =>
          state_debug_led_out(3 downto 0) <= B"1001";
          if (not slave_xmit_busy) then
            slave_xmit_gnt <= '0';
            state := idle;
          end if;
-------------------------------------------------------------------------------
        when others =>
          state_debug_led_out(3 downto 0) <= B"1010";
          state                    := idle;
          master_xmit_gnt          <= '0';
          master_recv_gnt          <= '0';
          slave_xmit_gnt           <= '0';
          slave_recv_gnt           <= '0';
          master_recv_stable_count <= 0;
          slave_xmit_stable_count  <= 0;
          slave_recv_stable_count  <= 0;
          master_xmit_stable_count <= 0;
      end case;

    end if;

  end process;

  master_xmit_stb_ack <=
    (master_xmit_xmit_stb_ack and master_xmit_gnt) or
    (master_recv_xmit_stb_ack and master_recv_gnt);

  master_xmit_dat_cyc <=
    (master_xmit_xmit_dat_cyc and master_xmit_gnt) or
    (master_recv_xmit_dat_cyc and master_recv_gnt);
    
  slave_xmit_stb_ack <=
    (slave_xmit_xmit_stb_ack and slave_xmit_gnt) or
    (slave_recv_xmit_stb_ack and slave_recv_gnt);

  slave_xmit_dat_cyc <=
    (slave_xmit_xmit_dat_cyc and slave_xmit_gnt) or
    (slave_recv_xmit_dat_cyc and slave_recv_gnt);
    
])
