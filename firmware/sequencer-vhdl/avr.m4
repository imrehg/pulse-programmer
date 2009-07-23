divert(-1)dnl
# Macros for AVR instances and signals to include in top-level sequencer.
# ---------------------------------------------------------------------------
# MIT-NIST-ARDA Pulse Sequencer
# http://qubit.media.mit.edu/sequencer
# Paul Pham
# MIT Center for Bits and Atoms
# ---------------------------------------------------------------------------

###############################################################################
# AVR port instance (A-F)
#   $1 = lowercase letter of port
#   $2 = uppercase letter of port
#   $3 = mux port index
define([avr_port_instance_], [dnl
-------------------------------------------------------------------------------
  port_$1 :component avr_port  
    generic map (
      PORTX_Adr => PORT$2_Address,
      DDRX_Adr  => DDR$2_Address,
      PINX_Adr  => PIN$2_Address
      )
    port map (
      -- AVR Control
      ireset     => nreset,
      sclr       => sclr,
      cp2        => core_clock,
      adr        => core_io_adr,
      dbus_in    => core_write_data,
      dbus_out   => port$1_dbusout,
      iore       => core_iore,
      iowe       => core_iowe,
      out_en     => port$1_out_en,
      -- External connection
      portx      => Port$2Reg,
      ddrx       => DDR$2Reg,
      pinx       => port_$1_in
      );
  
  -- PORT$2 connection to the external multiplexer
  io_port_out($3)    <= port$1_dbusout;
  io_port_out_en($3) <= port$1_out_en;

  -- Tri-state control for PORT$2
  port_$1_out <= Port$2Reg;
dnl  Port$2ZCtrl:for i in port_$1_out'range generate
dnl    port_$1_out(i) <= Port$2Reg(i) when DDR$2Reg(i)='1' else 'Z';
dnl  end generate;
])

###############################################################################
# AVR port ports (A-F)
#   $1 = lowercase letter of port
define([avr_port_ports_], [dnl
  port_$1_in  : in  byte;
  port_$1_out : out byte;
])

###############################################################################
# AVR port signals (A-F)
#   $1 = lowercase letter of port
#   $2 = uppercase letter of port
define([avr_port_internal_signals_], [dnl
  signal Port$2Reg      : byte;
  signal DDR$2Reg       : byte;
  signal port$1_dbusout : byte;
  signal port$1_out_en  : std_logic;
])

###############################################################################
# inteface macro to AVR
#  $1 = unit name
#  $2 = additional ports
#  $3 = write address decoding
#  $4 = read address decoding
#  $5 = declarations
#  $6 = recv cyc behaviour
define([avr_interface_unit_], [dnl
unit_([$1], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
  -- Ports to AVR
  control_port_in       : in  byte;
  data_port_in          : in  byte;
  control_port_out      : out byte;
  data_port_out         : out byte;
  -- Ports to PTP DMA
  xmit_buffer_start_out : out virtual_address_type;
  xmit_length_out       : out ip_total_length;
  xmit_dma_stb_out      : out std_logic;
  xmit_dma_ack_in       : in     std_logic;
  recv_buffer_start_out : out    virtual_address_type;
  recv_length_in        : in     ip_total_length;
  recv_dma_stb_in       : in     std_logic;
  recv_dma_ack_out      : buffer std_logic;
$2
],[dnl -- Declarations --------------------------------------------------------
  signal write_stb       : std_logic;
  signal xmit_cyc        : std_logic;
  signal xmit_ack        : std_logic;
  signal recv_ack        : std_logic;
  signal recv_cyc        : std_logic;
  signal address         : avr_port_address_type;
  signal initialised     : boolean;
$5
],[dnl -- Body---------------------------------------

  write_stb <= control_port_in(0);
  xmit_cyc  <= control_port_in(2);
  recv_ack  <= control_port_in(3);
  control_port_out(2) <= xmit_ack;
  control_port_out(3) <= recv_cyc;
  address   <= control_port_in(7 downto 4);

  process(wb_rst_i, wb_clk_i)

    type state_type is (
      idle,
      done_state
      );

    variable state : state_type;

  begin

    if (wb_rst_i = '1') then
      initialised <= false;
      state       := idle;

    elsif (rising_edge(wb_clk_i)) then

      if (recv_dma_stb_in = '1') then
$6
      end if;

      if (write_stb = '1') then
        initialised <= true;
        case (address) is
$3
          when others =>
            null;
        end case;
      end if;

      case (address) is
$4
        when others => null;
      end case;

    end if; -- rising_edge(wb_clk_i)

  end process;

  control_port_out(1 downto 0) <= (others => '0');
  control_port_out(7 downto 4) <= (others => '0');

  xmit_dma_stb_out <= xmit_cyc;
  xmit_ack <= xmit_dma_ack_in;

  recv_cyc <= recv_dma_stb_in;
  recv_dma_ack_out <= recv_ack when initialised else '1';
])
])

###############################################################################
# Top-level AVR controller instance

define([avr_controller_instance_], [dnl

avr_controller_gen: if (AVR_ENABLE) generate
  pre_sizer16_wb_write_data <= (others => '0');
  pre_sizer16_wb_we         <= '0';
  pre_sizer16_burst         <= '0';
  pre_sizer16_addr_prefix   <= AVR_IMEM_ADDR_PREFIX;

  avr : avr_controller
    generic map (
      IMEM_ADDRESS_WIDTH => AVR_IMEM_ADDRESS_WIDTH,
      IMEM_DATA_WIDTH    => AVR_IMEM_DATA_WIDTH,
      DMEM_ADDRESS_WIDTH => AVR_DMEM_ADDRESS_WIDTH,
      DMEM_DATA_WIDTH    => AVR_DMEM_DATA_WIDTH
      )
    port map (
      -- Wishbone common signals
      wb_clk_i           => network_clock,
      sclr               => avr_reset,
      wb_rst_i           => wb_rst_i,
      -- Instruction memory signals
      imem_wbm_cyc_o     => pre_sizer16_wb_cyc,
      imem_wbm_stb_o     => pre_sizer16_wb_stb,
      imem_wbm_adr_o     => pre_sizer16_wb_adr,
      imem_wbm_dat_i     => pre_sizer16_wb_read_data,
      imem_wbm_ack_i     => pre_sizer16_wb_ack,
      -- Data memory signals
      dmem_wbm_cyc_o     => avr_dmem_wb_cyc,
      dmem_wbm_stb_o     => avr_dmem_wb_stb,
      dmem_wbm_we_o      => avr_dmem_wb_we,
      dmem_wbm_adr_o     => avr_dmem_wb_adr,
      dmem_wbm_dat_o     => avr_dmem_wb_write_data,
      dmem_wbm_dat_i     => pre_sizer8_wb_read_data,
      dmem_wbm_ack_i     => avr_dmem_wb_ack,
      -- I/O ports
      port_a_in          => avr_port_a_in,
      port_b_in          => avr_port_b_in,
--      port_c_in          => avr_port_c_in,
      port_d_in          => avr_port_d_in,
      port_e_in          => avr_port_e_in,
--      port_f_in          => avr_port_f_in,
      port_a_out         => avr_port_a_out,
      port_b_out         => avr_port_b_out,
--      port_c_out         => avr_port_c_out,
      port_d_out         => avr_port_d_out,
      port_e_out         => avr_port_e_out
--      port_f_out         => avr_port_f_out
      );
end generate avr_controller_gen;

avr_controller_notgen: if (not AVR_ENABLE) generate
  -- Instruction memory signals
  pre_sizer16_wb_cyc <= '0';
  pre_sizer16_wb_stb <= '0';
  -- Data memory signals
  avr_dmem_wb_cyc <= '0';
  avr_dmem_wb_stb <= '0';
  avr_dmem_wb_we <= '0';
end generate avr_controller_notgen;
])])

###############################################################################
# AVR memory signals
define([avr_sram_signals_], [dnl
  -- Data memory interface to SRAM sizer arbiter
  signal avr_dmem_wb_cyc         : std_logic;
  signal avr_dmem_wb_stb         : std_logic;
  signal avr_dmem_wb_we          : std_logic;
  signal avr_dmem_wb_adr         : virtual_address_type;
  signal avr_dmem_wb_write_data  : virtual_data_type;
  signal avr_dmem_wb_ack         : std_logic;
])

###############################################################################
define([avr_port_signals_], [dnl
  signal avr_port_a_in  : byte;
  signal avr_port_b_in  : byte;
  signal avr_port_c_in  : byte;
  signal avr_port_d_in  : byte;
  signal avr_port_e_in  : byte;
  signal avr_port_f_in  : byte;
  signal avr_port_a_out : byte;
  signal avr_port_b_out : byte;
  signal avr_port_c_out : byte;
  signal avr_port_d_out : byte;
  signal avr_port_e_out : byte;
  signal avr_port_f_out : byte;
])

###############################################################################
define([avr_common_signals_], [dnl
  signal avr_reset : std_logic;
])

###############################################################################
# AVR component instances

define([avr_instances_], [dnl
avr_controller_instance_
])

###############################################################################
# AVR signals 

define([avr_signals_], [dnl
avr_common_signals_
avr_sram_signals_
avr_port_signals_

avr_controller_component_

])


# Renable output for processed file
divert(0)dnl