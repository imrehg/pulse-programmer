dnl--*-VHDL-*-
-- I2C wishbone controller that contains the OpenCores I2C master.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- Both transmit/write and receive/read operations are shown below with
-- the associated states in parens.

-- 1. Set the clock scale registers.
--    [setting_clock_high, setting_clock_low]
-- 2. Enable the I2C master with interrupts.
--    [enabling]
-- 3. Wait for our master to request either a write or a read transfer.
--    [idle]
-- 4. For any request, latch wb_we_i and send the slave address wb_adr_i
--    over the I2C bus. If latch_we = '1', mark started here.
--    [setting_transmit_data, transmitting]
-- 5. Wait for slave ack over the I2C bus.
--    [waiting_ack, waiting_interrupt]
-- 6. Clear the interrupt and decide where to go next based on latched_we.
--    [handling_interrupt, interrupt_ack]
-- Writing
--  7w. Ack falls low b/c we don't know if master is strobing us again.
--      This isn't necessary for the first byte.
--      [next_transmit_strobe]
--  8w. Check that our master is still strobing us. If not, wait here until
--      stb goes high or cyc goes low.
--      [setting_transmit_data]
--  9w. If so, send transmit command over I2C bus. Then go to 5.
--      [transmitting]
-- Reading
--  7r. Read the receive register of the I2C master.
--      [reading_received_byte]
--  8r. Latch out the received byte; if this isn't the first, ack our master.
--      [latch_output_byte]
--  9r. If our master is still strobing us, send the read command.
--      If cyc is low, send a nak and a stop command to terminate our slave.
--      Mark as startd here. Go to 5.
--      [receiving]
  
unit_([i2c_controller],
  [dnl -- Libraries
sequencer_libraries_
],[dnl -- Generics
  -- HS (High Speed) for clk0
  --   prescale = [100 MHz / (5 *   2 MHz)] - 1 =  9   = 0x0009
  -- FS (Full Speed) for clk0
  --   prescale = [100 MHz / (5 * 400 KHz)] - 1 = 49   = 0x0031
  -- LS (Low Speed) for clk0
  --   prescale = [100 MHz / (5 * 100 KHz)] - 1 = 199  = 0x00C7
  -- HS (High Speed) for eth_rx_clk
  --   prescale = [ 25 MHz / (5 *   2 MHz)] - 1 =  1.5 = 0x0002
  -- FS (Full Speed) for eth_rx_clk
  --   prescale = [ 25 MHz / (5 * 400 KHz)] - 1 = 11.5 = 0x000C
  -- LS (Low Speed) for eth_rx_clk
  --   prescale = [ 25 MHz / (5 * 100 KHz)] - 1 = 49   = 0x0031
  -- HS (High Speed) for network_clock
  --   prescale = [ 50 MHz / (5 *   2 MHz)] - 1 =  4   = 0x0004
  -- FS (Full Speed) for network_clock
  --   prescale = [ 50 MHz / (5 * 400 KHz)] - 1 = 24   = 0x0018
  -- LS (Low Speed) for network_clock
  --   prescale = [ 50 MHz / (5 * 100 KHz)] - 1 = 99   = 0x0064
  -- FS (Full Speed) for eth_rx_clk 10 Mbps
  --   prescale = [ 2.5 MHz / (5 * 400 KHz)] - 1 = 0 = 0x0000
  -- LS (Low Speed) for eth_rx_clk 10 Mbps
  --   prescale = [ 2.5 MHz / (5 * 100 KHz)] - 1 = 4 = 0x004
   CLOCK_PRESCALE : std_logic_vector(15 downto 0) := X"0031";
],[dnl -- Ports
wb_common_port_
    wb_cyc_i      : in    std_logic;
    wb_stb_i      : in    std_logic;
    wb_we_i       : in    std_logic;
    wb_adr_i      : in    i2c_slave_address_type;
    wb_dat_i      : in    byte;
    wb_dat_o      : out   byte;
    wb_ack_o      : out   std_logic;    
    
    -- Physical I2C pins
    sda            : inout std_logic;
    scl            : inout std_logic;
],[dnl -- Declarations

  subtype reg_addr is unsigned(2 downto 0);

  -- I2C Controller Register addresses
  constant CLOCK_PRESCALE_LO_REG : reg_addr := ("000");
  constant CLOCK_PRESCALE_HI_REG : reg_addr := ("001");
  constant CONTROL_REG           : reg_addr := ("010");
  constant TRANSMIT_REG          : reg_addr := ("011");
  constant RECEIVE_REG           : reg_addr := ("011");
  constant COMMAND_REG           : reg_addr := ("100");
  constant STATUS_REG            : reg_addr := ("100");

  -- I2C Control Register Bits
  constant ENABLE                : byte     := B"1000_0000";
  constant INTERRUPT_ENABLE      : byte     := B"0100_0000";

  -- I2C Command Register Bits
  constant START_COMMAND         : byte     := B"1000_0000";
  constant STOP_COMMAND          : byte     := B"0100_0000";
  constant READ_COMMAND          : byte     := B"0010_0000";
  constant WRITE_COMMAND         : byte     := B"0001_0000";
  constant NACK_COMMAND          : byte     := B"0000_1000";
  constant IACK_COMMAND          : byte     := B"0000_0001";

  --I2C Status Register Bit Indices
  constant RX_ACK_STATUS         : natural  := 7;
  constant BUSY_STATUS           : natural  := 6;
  constant ARB_LOST_STATUS       : natural  := 5;
  constant TIP_STATUS            : natural  := 1;
  constant INTERRUPT_STATUS      : natural  := 0;

i2c_master_top_component_

  constant BUS_FREE_COUNT : positive := 131;

  -- I2C Wishbone slave interface
  signal i2c_wb_rst        : std_logic;
  signal i2c_wb_adr        : unsigned(2 downto 0);
  signal i2c_wb_read_data  : byte;
  signal i2c_wb_write_data : byte;
  signal i2c_wb_we         : std_logic;
  signal i2c_wb_stb        : std_logic;
  signal i2c_wb_cyc        : std_logic;
  signal i2c_wb_ack        : std_logic;
  signal i2c_wb_inta       : std_logic;
  signal latched_we        : std_logic;

  signal i2c_scl_pad_i     : std_logic;
  signal i2c_scl_pad_o     : std_logic;
  signal i2c_scl_padoen_o  : std_logic;
  signal i2c_sda_pad_i     : std_logic;
  signal i2c_sda_pad_o     : std_logic;
  signal i2c_sda_padoen_o  : std_logic;

  type i2c_state is (
    setting_clock_high,
    setting_clock_low,
    enabling,
    reading_received_byte,
    latching_output_byte,
    setting_transmit_data,
    next_receive_strobe,
    next_transmit_strobe,
    transmitting,
    receiving,
    waiting_ack,
    waiting_interrupt,
    handling_interrupt,
    interrupt_ack,
    stopping,
    stopping_ack,
    idle
    );

  type i2c_sending_state is (
    slave_address,
    data_byte,
    done,
    stopping
    );

  signal state         : i2c_state;
  signal sending_state : i2c_sending_state;
  signal bus_wait      : std_logic;
],[dnl -- Body
      
  i2c : i2c_master_top
    port map (
      wb_clk_i  => wb_clk_i,
      wb_rst_i  => wb_rst_i,
--      arst_i    : in  std_logic := not ARST_LVL;    -- asynchronous reset
      wb_adr_i  => i2c_wb_adr,
      wb_dat_i  => i2c_wb_write_data,
      wb_dat_o  => i2c_wb_read_data,
      wb_we_i   => i2c_wb_we,
      wb_stb_i  => i2c_wb_stb,
      wb_cyc_i  => i2c_wb_cyc,
      wb_ack_o  => i2c_wb_ack,
      wb_inta_o => i2c_wb_inta,

      -- i2c lines
      scl_pad_i    => i2c_scl_pad_i,
      scl_pad_o    => i2c_scl_pad_o,
      scl_padoen_o => i2c_scl_padoen_o,
      sda_pad_i    => i2c_sda_pad_i,
      sda_pad_o    => i2c_sda_pad_o,
      sda_padoen_o => i2c_sda_padoen_o
      );

  scl           <= i2c_scl_pad_o when (i2c_scl_padoen_o = '0') else 'Z';
  i2c_scl_pad_i <= scl;
  sda           <= i2c_sda_pad_o when (i2c_sda_padoen_o = '0') else 'Z';
  i2c_sda_pad_i <= sda;

  process(wb_rst_i, wb_cyc_i, wb_stb_i, wb_clk_i)

    variable idle_count      : natural;
    variable started         : boolean;
    variable slave_addr_sent : boolean;

  begin

    if (wb_rst_i = '1') then
      state         <= setting_clock_high;
      sending_state <= done;
      idle_count    := 0;
      started       := false;
      bus_wait      <= '0';
      i2c_wb_cyc    <= '0';
      i2c_wb_stb    <= '0';
      i2c_wb_we     <= '0';
      latched_we    <= '0';
      wb_ack_o      <= '0';

    elsif (rising_edge(wb_clk_i)) then
        case (state) is
-------------------------------------------------------------------------------
          when setting_clock_high =>
          -- initiate wishbone cycle to transfer high byte of clock prescale
            i2c_wb_cyc        <= '1';
            i2c_wb_stb        <= '1';
            i2c_wb_we         <= '1';
            i2c_wb_adr        <= CLOCK_PRESCALE_HI_REG;
            i2c_wb_write_data <= CLOCK_PRESCALE(15 downto 8);
            state             <= setting_clock_low;
-------------------------------------------------------------------------------
          when setting_clock_low =>
            -- initiate wb cycle to transfer low byte of clock prescale
            if (i2c_wb_ack = '1') then
              i2c_wb_adr        <= CLOCK_PRESCALE_LO_REG;
              i2c_wb_write_data <= CLOCK_PRESCALE(7 downto 0);
              state             <= enabling;
            end if;
-------------------------------------------------------------------------------
          when enabling =>
            -- enable the controller (with interrupts)
            if (i2c_wb_ack = '1') then
              i2c_wb_adr        <= CONTROL_REG;
              i2c_wb_write_data <= ENABLE or INTERRUPT_ENABLE;
              state             <= idle;
            end if;
-------------------------------------------------------------------------------
          when idle =>
            slave_addr_sent := false;
            if (bus_wait = '1') then
              -- wait here after a transfer for the required free time
              i2c_wb_cyc    <= '0';
              i2c_wb_stb    <= '0';
              idle_count    := idle_count + 1;
              if (idle_count >= BUS_FREE_COUNT) then
                bus_wait    <= '0';
              end if;
            elsif (wb_cyc_i = '1') then
              bus_wait      <= '1';    -- signal that we are busy
              latched_we    <= wb_we_i;
              -- both receive and transmit operations begin the same
              -- (transmitting slave address)
              state         <= setting_transmit_data;
              sending_state <= slave_address;
            end if;
-------------------------------------------------------------------------------
          when next_transmit_strobe =>
            -- Fall low, b/c we don't know if we are being strobed again.
            wb_ack_o <= '0';
            state <= setting_transmit_data;
-------------------------------------------------------------------------------
          when setting_transmit_data =>
            if (wb_stb_i = '1') then
              i2c_wb_cyc <= '1';
              i2c_wb_stb <= '1';
              i2c_wb_we  <= '1';
              i2c_wb_adr <= TRANSMIT_REG;
              case (sending_state) is
                when slave_address =>
                  -- 7-bit addr plus nWRITE bit
                  -- R/nW bit is oppose of latched_we/wb_we_i
                  i2c_wb_write_data <= wb_adr_i & (not latched_we);
                  sending_state <= data_byte;
                  state         <= transmitting;
                when data_byte =>
                  i2c_wb_write_data  <= wb_dat_i;
                  sending_state <= data_byte;
                  state         <= transmitting;
                when others =>
                  sending_state <= done;
                  state         <= stopping;
              end case;
            elsif (wb_cyc_i = '0') then
              sending_state <= done;
              state         <= stopping;
            end if;
-------------------------------------------------------------------------------
          when transmitting =>
            if (i2c_wb_ack = '1') then
              i2c_wb_adr <= COMMAND_REG;
              if (started) then
                i2c_wb_write_data <= WRITE_COMMAND or IACK_COMMAND;
              else
                i2c_wb_write_data <= START_COMMAND or WRITE_COMMAND or
                                     IACK_COMMAND;
                if (latched_we = '1') then
                  started := true;
                else
                  -- if this is a slave address for reading, do not
                  -- flag started here, since we want a repeated start
                  -- before the data
                  started := false;
                end if;
              end if;
              state <= waiting_ack;
            end if;
-------------------------------------------------------------------------------
          when reading_received_byte =>
            i2c_wb_cyc <= '1';
            i2c_wb_stb <= '1';
            i2c_wb_we  <= '0';
            i2c_wb_adr <= RECEIVE_REG;
            state      <= latching_output_byte;
-------------------------------------------------------------------------------
          when latching_output_byte =>
            -- This is called after receiving a byte.
            if (i2c_wb_ack = '1') then
              i2c_wb_cyc <= '0';
              i2c_wb_stb <= '0';
              if (started) then
                wb_dat_o <= i2c_wb_read_data; -- latch onto data to load
                wb_ack_o <= '1';
              end if;
              state      <= next_receive_strobe;
            end if;
-------------------------------------------------------------------------------
          when next_receive_strobe =>
            -- Fall low b/c we don't know if master will strobe us again
            wb_ack_o <= '0';
            state <= receiving;
-------------------------------------------------------------------------------
          when receiving =>
            started := true;
            i2c_wb_cyc <= '1';
            i2c_wb_stb <= '1';
            i2c_wb_we  <= '1';
            i2c_wb_adr <= COMMAND_REG;
            if (wb_cyc_i = '0') then
              i2c_wb_write_data <= NACK_COMMAND or STOP_COMMAND;
              state <= stopping_ack;
            elsif (wb_stb_i = '1') then
              i2c_wb_write_data <= READ_COMMAND;
              state <= waiting_ack;
            end if;
-------------------------------------------------------------------------------
          when waiting_ack =>
            wb_ack_o <= '0';
            if (i2c_wb_ack = '1') then
              i2c_wb_cyc <= '0';
              i2c_wb_stb <= '0';
              state      <= waiting_interrupt;
            end if;
-------------------------------------------------------------------------------
          when waiting_interrupt =>
            i2c_wb_cyc <= '1';
            i2c_wb_stb <= '1';
            i2c_wb_we  <= '0';
            i2c_wb_adr <= STATUS_REG;
            -- waiting for slave to ack that it has latched address and data.
            -- wait for i2c_master to interrupt us
            if ((i2c_wb_inta = '1') and (i2c_wb_ack = '1')) then
              state <= handling_interrupt;
            end if;
-------------------------------------------------------------------------------
          when handling_interrupt =>
              if (i2c_wb_read_data(INTERRUPT_STATUS) = '1') then
                if (i2c_wb_read_data(RX_ACK_STATUS) = '0') then

                  i2c_wb_cyc        <= '1';
                  i2c_wb_stb        <= '1';
                  i2c_wb_we         <= '1';
                  i2c_wb_adr        <= COMMAND_REG;
                  i2c_wb_write_data <= IACK_COMMAND;
                  state             <= interrupt_ack;

                else
                  -- in this case, no ack received, retry transmission
                  if (latched_we = '1') then
                    state <= transmitting;
                  else
                    state <= receiving;
                  end if;
                end if;
              else
                -- keep polling until the interrupt fires
                state <= waiting_interrupt;
              end if;
-------------------------------------------------------------------------------
          when interrupt_ack =>
            if ((i2c_wb_ack = '1') and (i2c_wb_inta = '0')) then
              i2c_wb_cyc <= '0';
              i2c_wb_stb <= '0';
              case (sending_state) is
                when stopping =>
                  state <= idle;
                when done =>
                  state <= stopping;
                when data_byte =>
                  if (latched_we = '1') then
                    -- ack our master that a byte was successfully xmited
                    if (slave_addr_sent) then
                      wb_ack_o <= '1';
                    else
                      slave_addr_sent := true;
                    end if;
                    state <= next_transmit_strobe;
                  else
                    state <= reading_received_byte;
                  end if;
                when others =>
                  state <= stopping;
              end case;
            end if;
-------------------------------------------------------------------------------
          when stopping =>
            wb_ack_o          <= '0';
            -- waiting for slave to ack that it has latched address and data.
            i2c_wb_cyc        <= '1';
            i2c_wb_stb        <= '1';
            i2c_wb_we         <= '1';
            i2c_wb_adr        <= COMMAND_REG;
            i2c_wb_write_data <= STOP_COMMAND;
            state             <= stopping_ack;
-------------------------------------------------------------------------------
          when stopping_ack =>
            started    := false;
            idle_count := 0;
            if (i2c_wb_ack = '1') then
              i2c_wb_cyc <= '0';
              i2c_wb_stb <= '0';
              sending_state     <= stopping;
              state      <= waiting_interrupt;
            end if;
-------------------------------------------------------------------------------
          when others =>
            state <= stopping;
        end case;
    end if;
  end process;
])
