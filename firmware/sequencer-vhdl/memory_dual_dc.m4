dnl--*-VHDL-*-
-- Dual-clocked burst controller to dual-port memory.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

unit_([memory_dual_dc],
  [dnl -- Libraries
library altera_mf;
use altera_mf.altera_mf_components.all;
use ieee.numeric_std.all;
sequencer_libraries_
],[dnl -- Generics
    DATA_WIDTH          : positive := 8;
    ADDRESS_WIDTH       : positive := 4;
],[dnl -- Ports ---------------------------------------------------------------
    -- First port
    wb1_clk_i : in  std_logic;
    wb1_cyc_i : in  std_logic;
    wb1_stb_i : in  std_logic;
    wb1_we_i  : in  std_logic;
    wb1_adr_i : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    wb1_dat_i : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    wb1_dat_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
    wb1_ack_o : out std_logic;
    burst1_in : in  std_logic;
    addr1_out : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    -- Second port
    wb2_clk_i : in  std_logic;
    wb2_cyc_i : in  std_logic;
    wb2_stb_i : in  std_logic;
    wb2_we_i  : in  std_logic;
    wb2_adr_i : in  std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    wb2_dat_i : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    wb2_dat_o : out std_logic_vector(DATA_WIDTH-1 downto 0);
    wb2_ack_o : out std_logic;
    burst2_in : in  std_logic;
    addr2_out : out std_logic_vector(ADDRESS_WIDTH-1 downto 0);
],[dnl -- Declarations --------------------------------------------------------
   signal first_port_wren : std_logic;
   signal first_port_write_data : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal first_port_read_data : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal first_port_address   : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
   -- left open
   signal second_port_wren : std_logic;
   signal second_port_write_data : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal second_port_read_data : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal second_port_address   : std_logic_vector(ADDRESS_WIDTH-1 downto 0);
],[dnl -- Component Instantiation ---------------------------------------------

  first_port : memory_burst_controller
    generic map (
      DATA_WIDTH        => DATA_WIDTH,
      ADDRESS_WIDTH     => ADDRESS_WIDTH,
      READ_PIPELINE_DELAY => 1
      )
    port map (
      ext_wb_we_o  => first_port_wren,
      ext_wb_dat_o => first_port_write_data,
      ext_wb_dat_i => first_port_read_data,
      ext_wb_adr_o => first_port_address,
      wb_clk_i     => wb1_clk_i,
      wb_cyc_i     => wb1_cyc_i,
      wb_stb_i     => wb1_stb_i,
      wb_we_i      => wb1_we_i,
      wb_adr_i     => wb1_adr_i,
      wb_dat_i     => wb1_dat_i,
      wb_dat_o     => wb1_dat_o,
      wb_ack_o     => wb1_ack_o,
      burst_in     => burst1_in,
      addr_out     => addr1_out
      );

   -- This is a read-only controller
  second_port : memory_burst_controller
    generic map (
      DATA_WIDTH        => DATA_WIDTH,
      ADDRESS_WIDTH     => ADDRESS_WIDTH,
      READ_PIPELINE_DELAY => 1
      )
    port map (
      ext_wb_we_o  => second_port_wren,
      ext_wb_dat_o => second_port_write_data,
      ext_wb_dat_i => second_port_read_data,
      ext_wb_adr_o => second_port_address,
      wb_clk_i     => wb2_clk_i,
      wb_cyc_i     => wb2_cyc_i,
      wb_stb_i     => wb2_stb_i,
      wb_we_i      => wb2_we_i,
      wb_adr_i     => wb2_adr_i,
      wb_dat_i     => wb2_dat_i,
      wb_dat_o     => wb2_dat_o,
      wb_ack_o     => wb2_ack_o,
      burst_in     => burst2_in,
      addr_out     => addr2_out
      );
   
  storage : altsyncram
    generic map (
      operation_mode            => "BIDIR_DUAL_PORT",
      width_a                   => DATA_WIDTH,
      widthad_a                 => ADDRESS_WIDTH,
      numwords_a                => 2**ADDRESS_WIDTH,
      width_b                   => DATA_WIDTH,
      widthad_b                 => ADDRESS_WIDTH,
      numwords_b                => 2**ADDRESS_WIDTH,
      lpm_type                  => "altsyncram",
      width_byteena_a           => 1,
      width_byteena_b           => 1,
      outdata_reg_a             => "UNREGISTERED",
      outdata_aclr_a            => "NONE",
      outdata_reg_b             => "UNREGISTERED",
      indata_aclr_a             => "NONE",
      wrcontrol_aclr_a          => "NONE",
      address_aclr_a            => "NONE",
      indata_reg_b              => "CLOCK1",
      address_reg_b             => "CLOCK1",
      wrcontrol_wraddress_reg_b => "CLOCK1",
      indata_aclr_b             => "NONE",
      wrcontrol_aclr_b          => "NONE",
      address_aclr_b            => "NONE",
      outdata_aclr_b            => "NONE",
      power_up_uninitialized    => "FALSE",
      intended_device_family    => "Cyclone"
      )
    port map (
      clocken0  => '1',
      clocken1  => '1',
      wren_a    => first_port_wren,
      clock0    => wb1_clk_i,
      wren_b    => second_port_wren,
      clock1    => wb2_clk_i,
      address_a => first_port_address,
      address_b => second_port_address,
      data_a    => first_port_write_data,
      data_b    => second_port_write_data,
      q_a       => first_port_read_data,
      q_b       => second_port_read_data
    );
])

