dnl-*-VHDL-*-
-- PCP library and packages.

-- For usage information, see the invididual VHDL source files.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library seqlib;
use seqlib.constants.all;
use seqlib.network.all;

package instructions is

  subtype pcp_pulse_type is std_logic_vector(LVDS_TRANSMIT_WIDTH-1 downto 0);

  -----------------------------------------------------------------------------
  -- PCP32 constants and types

  constant PCP32_INSTRUCTION_WIDTH : positive := 32;
  subtype pcp32_instruction_type is std_logic_vector(PCP32_INSTRUCTION_WIDTH-1
                                                   downto 0);

  constant PCP32_ADDRESS_WIDTH : positive := 19;
  subtype pcp32_address_type is unsigned (PCP32_ADDRESS_WIDTH-1 downto 0);

  constant PCP32_TIMER_WIDTH : positive := 28;
  subtype pcp32_timer_constant_type is
    unsigned(PCP32_TIMER_WIDTH-1 downto 0);

  constant PCP32_OUTPUT_CONSTANT_WIDTH : positive := 16;
  subtype pcp32_output_constant_type is
    std_logic_vector(PCP32_OUTPUT_CONSTANT_WIDTH-1 downto 0);

  constant PCP32_OPCODE_WIDTH : positive := 4;
  subtype pcp32_opcode_type is std_logic_vector(PCP32_OPCODE_WIDTH-1 downto 0);

  constant PCP32_PHASE_WORD_WIDTH    : positive := 32;
  subtype pcp32_phase_word_type is std_logic_vector(PCP32_PHASE_WORD_WIDTH-1
                                                    downto 0);
  constant PCP32_PHASE_ADDEND_WIDTH  : positive := 32;
  subtype pcp32_phase_addend_type is
    std_logic_vector(PCP32_PHASE_ADDEND_WIDTH-1 downto 0);
  constant PCP32_PHASE_ADJUST_WIDTH  : positive := 14;
  subtype pcp32_phase_adjust_type is
    std_logic_vector(PCP32_PHASE_ADJUST_WIDTH-1 downto 0);

  subtype pcp_sel8_type is std_logic_vector(3 downto 0);
  subtype pcp_sel16_type is std_logic_vector(1 downto 0);
  subtype pcp_sel32_type is std_logic;

  constant PCP_LVDS_RECV_0_TRIGGER : trigger_source_type := B"0_0000_0001";
  constant PCP_LVDS_RECV_1_TRIGGER : trigger_source_type := B"0_0000_0010";
  constant PCP_LVDS_RECV_2_TRIGGER : trigger_source_type := B"0_0000_0100";
  constant PCP_LVDS_RECV_3_TRIGGER : trigger_source_type := B"0_0000_1000";
  constant PCP_LVDS_RECV_4_TRIGGER : trigger_source_type := B"0_0001_0000";
  constant PCP_LVDS_RECV_5_TRIGGER : trigger_source_type := B"0_0010_0000";
  constant PCP_LVDS_RECV_6_TRIGGER : trigger_source_type := B"0_0100_0000";
  constant PCP_LVDS_RECV_7_TRIGGER : trigger_source_type := B"0_1000_0000";
  constant PCP_SWITCH_TRIGGER      : trigger_source_type := B"1_0000_0000";
  constant PCP_NULL_TRIGGER        : trigger_source_type := B"0_0000_0000";

  -----------------------------------------------------------------------------
  -- pcp1 constants and types

  -- General-purpose registers for loop counting and jumping
  -- Maximum value for register address width is 5
  constant PCP1_REGISTER_ADDRESS_WIDTH : positive := 5;
  subtype pcp1_register_address_type is
    std_logic_vector(PCP1_REGISTER_ADDRESS_WIDTH-1 downto 0);

  constant PCP1_LOOP_REGISTER_WIDTH : positive := 8;

  constant PCP1_PHASE_ADDRESS_WIDTH : positive := 4;
  constant PCP1_LOOP_ADDRESS_WIDTH  : positive := 3;
  constant PCP1_STACK_ADDRESS_WIDTH : positive := 3;

  -- pcp1 opcodes
  constant PCP1_NOP_OPCODE  : pcp32_opcode_type := B"0000";  -- 0x0
  constant PCP1_BTR_OPCODE  : pcp32_opcode_type := B"0011";  -- 0x3
  constant PCP1_J_OPCODE    : pcp32_opcode_type := B"0100";  -- 0x4
  constant PCP1_SUB_OPCODE  : pcp32_opcode_type := B"0101";  -- 0x5
  constant PCP1_RET_OPCODE  : pcp32_opcode_type := B"0110";  -- 0x6
  constant PCP1_HALT_OPCODE : pcp32_opcode_type := B"1000";  -- 0x8
  constant PCP1_WAIT_OPCODE : pcp32_opcode_type := B"1001";  -- 0x9
  constant PCP1_BDEC_OPCODE : pcp32_opcode_type := B"1010";  -- 0xA
  constant PCP1_LDC_OPCODE  : pcp32_opcode_type := B"1011";  -- 0xB
  constant PCP1_P16_OPCODE  : pcp32_opcode_type := B"1100";  -- 0xC
  constant PCP1_PP_OPCODE   : pcp32_opcode_type := B"1101";  -- 0xD
  constant PCP1_LP_OPCODE   : pcp32_opcode_type := B"1110";  -- 0xE

  -----------------------------------------------------------------------------
  -- PCP32/16 constants and types

  constant PCP3216_INSTRUCTION_WIDTH : positive := 32;
  subtype pcp3216_instruction_type is
    std_logic_vector(PCP3216_INSTRUCTION_WIDTH-1 downto 0);

  constant PCP3216_ADDRESS_WIDTH : positive := 19;
  subtype pcp3216_address_type is unsigned (PCP3216_ADDRESS_WIDTH-1 downto 0);

  constant PCP3216_TIMER_WIDTH : positive := 27;
  subtype pcp3216_timer_constant_type is
    unsigned(PCP3216_TIMER_WIDTH-1 downto 0);

  constant PCP3216_DATA_WIDTH : positive := 16;  -- data width for pcp3
  subtype pcp3216_data_type is std_logic_vector(PCP3216_DATA_WIDTH-1 downto 0);

  constant PCP3216_OPCODE_WIDTH : positive := 5;
  subtype pcp3216_opcode_type is std_logic_vector(PCP3216_OPCODE_WIDTH-1
                                                  downto 0);

  constant PCP3216_HARD_TRIGGER_WIDTH : positive := 8;
  subtype pcp3216_hard_trigger_type is
    std_logic_vector(PCP3216_HARD_TRIGGER_WIDTH-1 downto 0);
  constant PCP3216_FIRM_TRIGGER_WIDTH : positive := 6;
  subtype pcp3216_firm_trigger_type is
    std_logic_vector(PCP3216_FIRM_TRIGGER_WIDTH-1 downto 0);

  constant PCP3216_UPPER_RAM_ADDRESS_WIDTH : positive := 3;

  constant PCP3216_REGISTER_ADDRESS_WIDTH : positive := 4;
  subtype pcp3216_register_address_type is
    std_logic_vector(PCP3216_REGISTER_ADDRESS_WIDTH-1 downto 0);

  constant PCP3216_DMEM_DATA_WIDTH : positive := 16;
  subtype pcp3216_dmem_data_type is
    std_logic_vector(PCP3216_DMEM_DATA_WIDTH-1 downto 0);

  -- pcp3 machine-dependent parameters
  constant PCP3_DMEM_ADDRESS_WIDTH : positive := 10;
  subtype pcp3_dmem_address_type is
    std_logic_vector(PCP3_DMEM_ADDRESS_WIDTH-1 downto 0);
  constant PCP3_IMEM_ADDRESS_WIDTH : positive := 12;
  subtype pcp3_imem_address_type is
    std_logic_vector(PCP3_IMEM_ADDRESS_WIDTH-1 downto 0);

 ------------------------------------------------------------------------------
 -- Device specific parameters
 ------------------------------------------------------------------------------
  constant DDS_ADDRESS_WIDTH : positive := 6;
  constant DAC_START_PIN : positive := 2;  -- dac start pin
  constant DAC_WIDTH : positive := 14;  -- dac bit count
  constant DAC_WRB_PIN : positive := 1;  -- wrb pin for the dac

  constant DDS_PSEN_PIN : positive := 16;  -- PSEN pin for the dds
  constant DDS_WRB_PIN : positive := 17;  -- WRB pin for the dds
  constant DDS_ADDR_START_PIN : positive := 18;
  constant DDS_ADDR_WIDTH : positive := 6;
  constant DDS_DATA_START_PIN : positive := 24;
  constant DDS_DATA_WIDTH : positive := 8;
  constant DDS_PROFILE_START_PIN : positive := 59;
  constant DDS_PROFILE_WIDTH : positive := 2;
  constant DDS_IOUPDATE_PIN : positive := 48;

  constant TTL_OUT_START_PIN : positive := 32;
  constant TTL_WIDTH : positive := 16;
  constant UPPER_TTL_START_PIN : positive := 55;
  constant UPPER_TTL_WIDTH : positive := 5;

  constant CHAIN_DDS_START_PIN : positive := 51;
  constant CHAIN_DAC_START_PIN : positive := 60;

  -- Insn opcodes
  constant PCP3216_NOP_OPCODE    : pcp3216_opcode_type := B"00000";  -- 0x00
  constant PCP3216_HALT_OPCODE   : pcp3216_opcode_type := B"00001";  -- 0x01
  constant PCP3216_WAIT_OPCODE   : pcp3216_opcode_type := B"00010";  -- 0x02
  constant PCP3216_BTR_OPCODE    : pcp3216_opcode_type := B"00011";  -- 0x03
  constant PCP3216_J_OPCODE      : pcp3216_opcode_type := B"00100";  -- 0x04
  constant PCP3216_MV_OPCODE     : pcp3216_opcode_type := B"00101";  -- 0x05
  constant PCP3216_CALL_OPCODE   : pcp3216_opcode_type := B"00110";  -- 0x06
  constant PCP3216_RET_OPCODE    : pcp3216_opcode_type := B"00111";  -- 0x07
  constant PCP3216_CMP_OPCODE    : pcp3216_opcode_type := B"01000";  -- 0x08
  constant PCP3216_BF_OPCODE     : pcp3216_opcode_type := B"01001";  -- 0x09
  constant PCP3216_LCR_OPCODE    : pcp3216_opcode_type := B"01010";  -- 0x0A
  constant PCP3216_SCR_OPCODE    : pcp3216_opcode_type := B"01011";  -- 0x0B
  constant PCP3216_LDR_OPCODE    : pcp3216_opcode_type := B"01100";  -- 0x0C
  constant PCP3216_STR_OPCODE    : pcp3216_opcode_type := B"01101";  -- 0x0D
  constant PCP3216_RD_OPCODE     : pcp3216_opcode_type := B"01110";  -- 0x0E
  constant PCP3216_WR_OPCODE     : pcp3216_opcode_type := B"01111";  -- 0x0F
  constant PCP3216_ADD_OPCODE    : pcp3216_opcode_type := B"10000";  -- 0x10
  -- 0x11 is unused
  constant PCP3216_MUL_OPCODE    : pcp3216_opcode_type := B"10010";  -- 0x12
  constant PCP3216_DIV_OPCODE    : pcp3216_opcode_type := B"10011";  -- 0x13
  constant PCP3216_PP_OPCODE     : pcp3216_opcode_type := B"10100";  -- 0x14
  constant PCP3216_LP_OPCODE     : pcp3216_opcode_type := B"10101";  -- 0x15
  constant PCP3216_PDAC_OPCODE   : pcp3216_opcode_type := B"10110";  -- 0x16
  -- 0x17 is unused
  constant PCP3216_PDDS_OPCODE   : pcp3216_opcode_type := B"11000";  -- 0x18
  constant PCP3216_PDDSP_OPCODE  : pcp3216_opcode_type := B"11001";  -- 0x19
  constant PCP3216_PTTLH_OPCODE  : pcp3216_opcode_type := B"11010";  -- 0x1A
  constant PCP3216_PTTLL_OPCODE  : pcp3216_opcode_type := B"11011";  -- 0x1B
  constant PCP3216_PCHAIN_OPCODE : pcp3216_opcode_type := B"11100";  -- 0x1C
  constant PCP3216_INC_OPCODE    : pcp3216_opcode_type := B"11101";  -- 0x1D
  -- 0x1E is unused
  constant PCP3216_LDC_OPCODE    : pcp3216_opcode_type := B"11111";  -- 0x1F
end package;
