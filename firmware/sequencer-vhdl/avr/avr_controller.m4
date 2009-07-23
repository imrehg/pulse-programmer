dnl-*-VHDL-*-
-- Top-level AVR microcontroller.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([avr_controller], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.avr.all;
],[dnl -- Generics ------------------------------------------------------------
   IMEM_ADDRESS_WIDTH : positive := 16;
   IMEM_DATA_WIDTH    : positive := 16;
   DMEM_ADDRESS_WIDTH : positive := 16;
   DMEM_DATA_WIDTH    : positive := 8;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
   -- Synchronous reset
   sclr             : in     std_logic;
   -- Instruction memory signals
   imem_wbm_cyc_o   : buffer std_logic;
   imem_wbm_stb_o   : out    std_logic;
   imem_wbm_adr_o   : out    std_logic_vector(IMEM_ADDRESS_WIDTH-1 downto 0);
   imem_wbm_dat_i   : in     std_logic_vector(IMEM_DATA_WIDTH-1 downto 0);
   imem_wbm_ack_i   : in     std_logic;

   -- Data memory signals
   dmem_wbm_cyc_o   : buffer std_logic;
   dmem_wbm_stb_o   : buffer std_logic;
   dmem_wbm_we_o    : out    std_logic;
   dmem_wbm_adr_o   : out    std_logic_vector(DMEM_ADDRESS_WIDTH-1 downto 0);
   dmem_wbm_dat_o   : out    std_logic_vector(DMEM_DATA_WIDTH-1 downto 0);
   dmem_wbm_dat_i   : in     std_logic_vector(DMEM_DATA_WIDTH-1 downto 0);
   dmem_wbm_ack_i   : in     std_logic;

   debug_led_out    : out byte;

   avr_port_ports_(a)
   avr_port_ports_(b)
dnl   avr_port_ports_(c)
   avr_port_ports_(d)
   avr_port_ports_(e)
dnl   avr_port_ports_(f)
],[dnl -- Declarations --------------------------------------------------------
avr_core_component_
avr_port_component_
io_mux_component_
  constant  PORT_COUNT     : positive := 4;
  -----------------------------------------------------------------------------
  -- Core Signals
  signal core_clock        : std_logic;
  signal core_clock_enable : std_logic;
  signal core_data_wait    : std_logic;
  signal core_io_adr       : std_logic_vector (AVR_IO_ADDRESS_WIDTH-1
                                               downto 0);
  signal core_iore         : std_logic;
  signal core_iowe         : std_logic;
  signal core_ramre        : std_logic;
  signal core_ramwe        : std_logic;
  signal core_read_data    : byte;
  signal core_write_data   : byte;

  signal core_irqlines     : std_logic_vector(22 downto 0);
  signal core_irqack       : std_logic;
  signal core_irqackad     : std_logic_vector(4 downto 0);
  signal ind_irq_ack       : std_logic_vector(core_irqlines'range);

  -----------------------------------------------------------------------------
  -- Port signals

avr_port_internal_signals_(a, A)
avr_port_internal_signals_(b, B)
dnl avr_port_internal_signals_(c, C)
avr_port_internal_signals_(d, D)
avr_port_internal_signals_(e, E)
dnl avr_port_internal_signals_(f, F)

  -----------------------------------------------------------------------------
  -- IO
  signal io_port_out         : multibus_byte(0 to PORT_COUNT);
  signal io_port_out_en      : multibus_bit(0 to PORT_COUNT);
  -- negative true reset
  signal nreset              : std_logic;
  signal data_access         : std_logic;
  signal data_loaded         : boolean;
  signal data_deferred       : boolean;
  -- registers to cut the data paths from the AVR (slow)
  signal pc_latched          : std_logic_vector(IMEM_ADDRESS_WIDTH-1 downto 0);
  signal instruction_latched : std_logic_vector(IMEM_DATA_WIDTH-1 downto 0);
  signal address_latched     : std_logic_vector(DMEM_ADDRESS_WIDTH-1 downto 0);
  signal data_in_latched     : std_logic_vector(DMEM_DATA_WIDTH-1 downto 0);

  type state_type is (
    idle,
    insn_wait,
    data_wait,
    insn_stall,
    data_stall
    );

  signal state                  : state_type;
  
],[dnl -- Body ----------------------------------------------------------------

  nreset <= not wb_rst_i;
  core_clock <= wb_clk_i;
   
  core : avr_core
    port map (
      cp2           => core_clock,
      clk_en        => core_clock_enable,
      sclr          => sclr,
      ireset        => nreset,
      cpuwait       => core_data_wait,
      pc            => pc_latched,
      inst          => instruction_latched,
      adr           => core_io_adr,
      iore          => core_iore,
      iowe          => core_iowe,
      ramadr        => address_latched,
      ramre         => core_ramre,
      ramwe         => core_ramwe,
      dbusin        => core_read_data,
      dbusout       => core_write_data,
      irqlines      => core_irqlines,
      irqack        => core_irqack,
      irqackad      => core_irqackad,
      debug_led_out => debug_led_out
      );

  data_access <= core_ramre or core_ramwe;

  -- Process to synchronize data producer (external memory) with Wishbone
  -- clock. Takes care of inserting wait states.
  process(wb_clk_i, wb_rst_i, sclr)

    variable insn_loaded : boolean;

  begin
--     if (wb_rst_i = '1') then
--       state               <= idle;
--       core_clock_enable   <= '0';
--       imem_wbm_cyc_o      <= '0';
--       imem_wbm_stb_o      <= '0';
--       imem_wbm_adr_o      <= (others => '0');
--       instruction_latched <= (others => '0');
--       insn_loaded         := false;
--       data_deferred       <= false;
--       data_loaded         <= false;

--       dmem_wbm_cyc_o      <= '0';
--       dmem_wbm_stb_o      <= '0';
--       dmem_wbm_we_o       <= '0';
--       dmem_wbm_adr_o      <= (others => '0');
--       dmem_wbm_dat_o      <= (others => '0');
--       data_in_latched     <= (others => '0');
      
    if (rising_edge(wb_clk_i)) then

      if ((sclr = '1') or (wb_rst_i = '1')) then
        state               <= idle;
        imem_wbm_cyc_o      <= '0';
        imem_wbm_stb_o      <= '0';
        imem_wbm_adr_o      <= (others => '0');
        instruction_latched <= (others => '0');
        insn_loaded         := false;
        data_deferred       <= false;
        data_loaded         <= false;

        dmem_wbm_cyc_o      <= '0';
        dmem_wbm_stb_o      <= '0';
        dmem_wbm_we_o       <= '0';
        dmem_wbm_adr_o      <= (others => '0');
        dmem_wbm_dat_o      <= (others => '0');
        data_in_latched     <= (others => '0');
      else
        -- this is all Ruslan Lepetenok's fault
         if ((data_access = '0' or data_loaded) and (core_clock_enable = '1')) then
           -- latch write data out right before each data access
           -- or right after we've already access the data, but
           -- not if an instruction is being loaded
           dmem_wbm_dat_o <= core_write_data;
         end if;

        -- instruction fetching
        case (state) is
-------------------------------------------------------------------------------
          when idle =>
            if ((data_access = '1') and
                ((not data_loaded) or data_deferred)) then
              -- core has requested a read or a write
              -- if we have already loaded data for the last instruction
              -- data_access = '1' for the next instruction; mark it for
              -- fetching later, b/c we have to enable the clock for now
              dmem_wbm_cyc_o <= '1';
              dmem_wbm_stb_o <= '1';
              dmem_wbm_adr_o <= address_latched;
              dmem_wbm_we_o  <= core_ramwe and (not core_ramre);
              state <= data_wait;
            else
              if (data_access = '1') then
                data_deferred <= true;
              end if;
              data_loaded    <= false;
              imem_wbm_cyc_o <= '1';
              imem_wbm_stb_o <= '1';
              imem_wbm_adr_o <= pc_latched;
              state <= insn_wait;
            end if;
-------------------------------------------------------------------------------
          when insn_wait =>
            if (imem_wbm_ack_i = '1') then
              -- wait for core clock to fall so it doesn't trip us again
              imem_wbm_cyc_o <= '0';
              imem_wbm_stb_o <= '0';
              insn_loaded := true;
              if (data_deferred) then
                -- if we have a deferred data access to handle, don't enable
                -- the clock, but just jump straight back to idle
                state <= idle;
              else
                -- otherwise, run the core for a cycle to decode fetched insn
                core_clock_enable <= '1';
                state <= insn_stall;
              end if;
              instruction_latched <= imem_wbm_dat_i;
            end if;
-------------------------------------------------------------------------------
          when data_wait =>
            if (dmem_wbm_ack_i = '1') then
              data_loaded <= true;
              data_deferred <= false;
              if (insn_loaded) then
                -- only let the core run if we haven't loaded an instruction
                -- yet between data accesses (needed for slow insns like call)
                insn_loaded := false;
                core_clock_enable <= '1';
              end if;
              dmem_wbm_cyc_o <= '0';
              dmem_wbm_stb_o <= '0';
              dmem_wbm_we_o  <= '0';
              data_in_latched <= dmem_wbm_dat_i;
              state <= data_stall;
            end if;
-------------------------------------------------------------------------------
          when data_stall =>
            core_clock_enable <= '0';
            state <= idle;
-------------------------------------------------------------------------------
          when insn_stall =>
            core_clock_enable <= '0';
            state <= idle;
-------------------------------------------------------------------------------
          when others =>
            null;
        end case;
      end if;                             -- rising_edge(wb_clk_i)
    end if;                             -- sclr = '1'

  end process;

  -- We generate wait states for data access on the falling edge for them
  -- to be latched in time by the core.
  wait_gen : process(wb_clk_i, wb_rst_i)

  begin
    if (wb_rst_i = '1') then
      core_data_wait <= '0';
    elsif (falling_edge(wb_clk_i)) then
      if (sclr = '1') then
        core_data_wait <= '0';
      else
        case (state) is
          when idle =>
            if ((data_access = '1') and
                ((not data_loaded) or data_deferred)) then
              core_data_wait <= '1';
            end if;
          when data_wait =>
            if (dmem_wbm_ack_i = '1') then
              core_data_wait <= '0';
            end if;              
          when others => null;
        end case;
      end if;
    end if;

  end process;

  core_irqlines <= (others => '0');

-------------------------------------------------------------------------------
-- Port instances
  avr_port_instance_(a, A, 0)
  avr_port_instance_(b, B, 1)
dnl  avr_port_instance_(c, C, 2)
  avr_port_instance_(d, D, 2)
  avr_port_instance_(e, E, 3)
dnl  avr_port_instance_(f, F, 5)

  external_mux : io_mux
    generic map (
      PORT_COUNT => PORT_COUNT
      )
    port map(
      ramre          => core_ramre,
      dbus_out       => core_read_data,
      ram_data_out   => data_in_latched,
      io_port_bus    => io_port_out,
      io_port_en_bus => io_port_out_en,
      irqack         => core_irqack,		  
      irqackad       => core_irqackad,
      ind_irq_ack    => ind_irq_ack
      );

  
])
