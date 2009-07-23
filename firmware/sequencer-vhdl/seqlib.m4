dnl-*-VHDL-*-
-- Sequencer library and packages.

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

package constants is

  -- Version 0.32
  constant FIRMWARE_MAJOR_VERSION_NUMBER : std_logic_vector(0 to 7) :=
    std_logic_vector(to_unsigned(0, 8));
  constant FIRMWARE_MINOR_VERSION_NUMBER : std_logic_vector(0 to 7) :=
    std_logic_vector(to_unsigned(32, 8));

  constant ENABLE_DEBUG_LEDS : boolean := false;
 
--  constant GLOBAL_COUNTER_WIDTH : positive := 62;
  -- 25 MHz reference clock has quantum of 40 ns
--  constant GLOBAL_REFERENCE_QUANTUM : positive := 40;
  -- 100 MHz clock (on-board oscillator) has quantum of 10 ns
  -- Divide the on-board oscillator down by two for a standard network clock.
  constant CLOCK_QUANTUM : positive := 20;
  -- at most, a clock can be 2**6 times faster than reference clock, or ~1 GHz
  constant GLOBAL_CLOCK_SCALE_WIDTH : positive := 6;
  constant ENABLE_CLOCK_SCALING : boolean := false;

  subtype clock_scale_quantum_type is unsigned(GLOBAL_CLOCK_SCALE_WIDTH-1
                                               downto 0);
--  constant CLOCK_SCALE_STABLE_COUNT : positive := 32;
  -- VHDL positives are limited to 2**31
  constant GLOBAL_SUBCOUNTER_WIDTH : positive := 31;

  constant SRAM_ADDRESS_WIDTH  : positive := 19;
  constant SRAM_DATA_WIDTH     : positive := 36;

  subtype sram_address_type is std_logic_vector(SRAM_ADDRESS_WIDTH-1 downto 0);
  subtype sram_data_type    is std_logic_vector(SRAM_DATA_WIDTH-1 downto 0);

  constant LVDS_TRANSMIT_WIDTH : positive := 64;
  constant LVDS_RECEIVE_WIDTH  : positive := 8;
  constant SWITCH_WIDTH : positive := 8; -- positions 7 and 8 not connected
  constant DAISY_WIDTH : positive := 4;

  constant I2C_SLAVE_ADDRESS_WIDTH : positive := 6;
  subtype i2c_slave_address_type is std_logic_vector(6 downto 0);

  -- TPIC120 LED driver slave address (7:1)
  constant I2C_LED_SLAVE_ADDRESS : i2c_slave_address_type := B"110_0000";

  -- By default, all clients of SRAM have a 16-bit address space of 8-bit words
  constant VIRTUAL_ADDRESS_WIDTH     : positive := 16;
  subtype virtual_address_type is std_logic_vector(VIRTUAL_ADDRESS_WIDTH-1
                                                   downto 0);
  subtype virtual_data_type is std_logic_vector(7 downto 0);

  -- 16-bit address of 8-bit word memory
  -- 19 - (16 - 2) = 5 bit prefix
  constant VIRTUAL8_ADDRESS_WIDTH : positive := SRAM_ADDRESS_WIDTH+2;
  subtype virtual8_address_type is std_logic_vector(VIRTUAL8_ADDRESS_WIDTH-1
                                                    downto 0);
  constant VIRTUAL16_ADDRESS_WIDTH : positive := SRAM_ADDRESS_WIDTH+1;
  subtype virtual16_address_type is std_logic_vector(VIRTUAL16_ADDRESS_WIDTH-1
                                                    downto 0);

--  constant VIRTUAL8_ADDRESS_PREFIX_WIDTH : positive := 5;
--  subtype virtual8_address_prefix_type is
--    std_logic_vector(SRAM_ADDRESS_WIDTH-1 downto VIRTUAL_ADDRESS_WIDTH-2);

  -- 16-bit address of 16-bit word memory
  -- 19 - (16 - 1) = 4 bit prefix
--  constant VIRTUAL16_ADDRESS_PREFIX_WIDTH : positive := 4;
--  subtype virtual16_address_prefix_type is
--    std_logic_vector(SRAM_ADDRESS_WIDTH-1 downto VIRTUAL_ADDRESS_WIDTH-1);

  -- We just need this for backward compatibility with 8/16-bit sizers.
--  subtype virtual32_address_prefix_type is
--    std_logic_vector(SRAM_ADDRESS_WIDTH-1 downto VIRTUAL_ADDRESS_WIDTH);
  
  -- Virtual address prefixes
--  constant AVR_IMEM_ADDR_PREFIX   : virtual16_address_prefix_type := B"1111";
--  constant AVR_DMEM_ADDR_PREFIX   : virtual8_address_prefix_type  := B"11101";

  constant DAISY_CHAIN_STABLE_COUNT       : positive := 3;
  constant DAISY_CHAIN_ABORT_TIMEOUT      : positive := 100;
  constant TERMINATOR_DETECT_STABLE_COUNT : positive := 10;

  -- Network Parameters -------------------------------------------------------
  constant NETWORK_DETECT_STABLE_COUNT   : positive := 10;
  constant NETWORK_DATA_WIDTH            : positive := 8;
  constant ETHERNET_BUFFER_ADDRESS_WIDTH : positive := 10;
  constant ARP_TABLE_DEPTH               : positive := 3;
  constant IP_BUFFER_ADDRESS_WIDTH       : positive := 10;
  constant IP_BUFFER_COUNT_WIDTH         : natural  := 0;
  constant ICMP_BUFFER_ADDRESS_WIDTH     : positive := 7;
  constant UDP_BUFFER_ADDRESS_WIDTH      : positive := 10;
  constant PTP_BUFFER_ADDRESS_WIDTH      : positive := 10;
  -- Must be enough tries so that Ethernet chip has enough time to boot
  -- up cold from power-off.
  constant DHCP_MAX_RETRY_COUNT          : positive := 5;
   -- 1 second for new 50 MHz standard clock
  constant DHCP_RETRY_TIMEOUT : positive := 1_000_000_000 / CLOCK_QUANTUM;
   -- 2 seconds
  constant TCP_RETRY_TIMEOUT  : positive := 2_000_000_000 / CLOCK_QUANTUM;

  -- 50 milliseconds
  constant BOOT_LED_INTERVAL : positive := 50_000_000 / CLOCK_QUANTUM;

  -- * 40 ns = 80 milliseconds
  --constant BOOT_LED_100baseT_INTERVAL : positive := 2_000_000;
  -- * 400 ns = 80 milliseconds
  --constant BOOT_LED_10baseT_INTERVAL  : positive := 200_000;

  -- Network Enables ----------------------------------------------------------
  constant NETWORK_ICMP_ENABLE : boolean := false;

  -- PTP Enables --------------------------------------------------------------
  constant PTP_I2C_ENABLE      : boolean := true;
  constant PTP_TRIGGER_ENABLE  : boolean := true;

  -- Processor Enables --------------------------------------------------------
  constant AVR_ENABLE          : boolean := false;
  constant PCP32_ENABLE        : boolean := true;

  -- don't count the PTP start trigger; this is muxed internally
  constant GLOBAL_TRIGGER_COUNT : positive := 9;
  subtype trigger_source_type is
    std_logic_vector(GLOBAL_TRIGGER_COUNT-1 downto 0);

  -- plus 1 for null trigger
  subtype trigger_index_type is
    natural range 0 to GLOBAL_TRIGGER_COUNT+1;

  constant TRIGGER_NULL         : trigger_index_type := 10;
  constant TRIGGER_PTP_START    : trigger_index_type := 9;
  constant TRIGGER_LVDS_RECV_0  : trigger_index_type := 0;
  constant TRIGGER_LVDS_RECV_1  : trigger_index_type := 1;
  constant TRIGGER_LVDS_RECV_2  : trigger_index_type := 2;
  constant TRIGGER_LVDS_RECV_3  : trigger_index_type := 3;
  constant TRIGGER_LVDS_RECV_4  : trigger_index_type := 4;
  constant TRIGGER_LVDS_RECV_5  : trigger_index_type := 5;
  constant TRIGGER_LVDS_RECV_6  : trigger_index_type := 6;
  constant TRIGGER_LVDS_RECV_7  : trigger_index_type := 7;
  constant TRIGGER_SWITCH       : trigger_index_type := 8;

  constant TRIGGER_STABLE_COUNT : positive := 2;

  type endian_type is (
    little_endian,
    big_endian
    );

  constant FIFO8_WORD_COUNT_WIDTH  : positive := 3;
  constant ASYNC_FIFO_STABLE_COUNT : positive := 2;
  constant ASYNC_FIFO_HYSTERESIS   : positive := 2;

end constants;

-------------------------------------------------------------------------------
-- Utility Package

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

-- Utility components
package util is

  subtype bit_int is integer range 0 to 1;

  -- LSB first nibble (for Ethernet)
  subtype nibble is std_logic_vector(3 downto 0);

  -- LSB first byte (for Ethernet)
  subtype byte is std_logic_vector(7 downto 0);

  -- MSB first nibble (for IP)
  subtype nnibble is std_logic_vector(0 to 3);

  -- MSB first byte (for IP)
  subtype nbyte is std_logic_vector(0 to 7);

  type multibus_byte is array (natural range <>) of byte;

  type multibus_bit is array (natural range <>) of std_logic;

wb_intercon_component_

divider_component_

memory_controller_component_

memory_dual_controller_component_

memory_burst_controller_component_

memory_sizer_component_

dma_controller_component_

async_fifo_component_

clock_divider_component_

clock_shifter_component_

  component clock_buffer
    port (
      inclk0  : in  std_logic  := '0';
      pllena  : in  std_logic  := '1';
      pfdena  : in  std_logic  := '1';
      areset  : in  std_logic  := '0';
      c0      : out std_logic;
      locked  : out std_logic
    );
  end component;

  component clock_doubler
    port (
      inclk0 : in  std_logic := '0';
      c0     : out std_logic 
    );
  end component;

  component clock_gate
    port (
      inclk0 : in  std_logic  := '0';
      pllena : in  std_logic  := '1';
      c0     : out std_logic 
    );
  end component;

  component clockdiv
    port (
      inclk0  : IN STD_LOGIC  := '0';
      c0      : OUT STD_LOGIC ;
      locked  : OUT STD_LOGIC 
    );
  end component;

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.constants.all;
use work.util.all;

package avr is

  constant AVR_IO_ADDRESS_WIDTH   : positive := 6;

  constant AVR_IMEM_ADDRESS_WIDTH : positive := 16;
  constant AVR_IMEM_DATA_WIDTH    : positive := 16;
  constant AVR_DMEM_ADDRESS_WIDTH : positive := 16;
  constant AVR_DMEM_DATA_WIDTH    : positive := 8;

  subtype avr_instruction_word_type is std_logic_vector(AVR_IMEM_DATA_WIDTH-1
                                                        downto 0);

  constant AVR_IMEM_START_ADDRESS : sram_address_type := B"110" & X"0000";
  constant AVR_DMEM_START_ADDRESS : sram_address_type := B"111" & X"0000";

  -- copied from Ruslan's original AVRuCPackage
  -- Old package
  constant ext_mux_in_num : integer := 63;
  type ext_mux_din_type is array(0 to ext_mux_in_num) of
    std_logic_vector(7 downto 0);
  type ext_mux_data_type is array(natural range <>) of byte;
  subtype ext_mux_en_type is std_logic_vector(0 to ext_mux_in_num);
  -- End of old package

  -- I/O port addresses
  constant IOAdrWidth    : positive := 6;

  -- I/O register file
  constant RAMPZ_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#3B#,IOAdrWidth);
  constant SPL_Address   : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#3D#,IOAdrWidth);
  constant SPH_Address   : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#3E#,IOAdrWidth);
  constant SREG_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#3F#,IOAdrWidth);
  -- End of I/O register file

  -- UART
  constant UDR_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#0C#,IOAdrWidth);
  constant UBRR_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#09#,IOAdrWidth);
  constant USR_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#0B#,IOAdrWidth);
  constant UCR_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#0A#,IOAdrWidth);
  -- End of UART	

  -- Timer/Counter
  constant TCCR0_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#33#,IOAdrWidth);
  constant TCCR1A_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#2F#,IOAdrWidth);
  constant TCCR1B_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#2E#,IOAdrWidth);
  constant TCCR2_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#25#,IOAdrWidth);
  constant ASSR_Address   : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#30#,IOAdrWidth);
  constant TIMSK_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#37#,IOAdrWidth);
  constant TIFR_Address   : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#36#,IOAdrWidth);
  constant TCNT0_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#32#,IOAdrWidth);
  constant TCNT2_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#24#,IOAdrWidth);
  constant OCR0_Address   : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#31#,IOAdrWidth);
  constant OCR2_Address   : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#23#,IOAdrWidth);
  constant TCNT1H_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#2D#,IOAdrWidth);
  constant TCNT1L_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#2C#,IOAdrWidth);
  constant OCR1AH_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#2B#,IOAdrWidth);
  constant OCR1AL_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#2A#,IOAdrWidth);
  constant OCR1BH_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#29#,IOAdrWidth);
  constant OCR1BL_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#28#,IOAdrWidth);
  constant ICR1AH_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#27#,IOAdrWidth);
  constant ICR1AL_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#26#,IOAdrWidth);
  -- End of Timer/Counter 

  -- Service module
  constant MCUCR_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#35#,IOAdrWidth);
  constant EIMSK_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#39#,IOAdrWidth);
  constant EIFR_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#38#,IOAdrWidth);
  constant EICR_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#3A#,IOAdrWidth);
  constant MCUSR_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#34#,IOAdrWidth);
  constant XDIV_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#3C#,IOAdrWidth);
  -- End of service module

  -- PORTA addresses 
  constant PORTA_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#1B#,IOAdrWidth);
  constant DDRA_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#1A#,IOAdrWidth);
  constant PINA_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#19#,IOAdrWidth);

  -- PORTB addresses 
  constant PORTB_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#18#,IOAdrWidth);
  constant DDRB_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#17#,IOAdrWidth);
  constant PINB_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#16#,IOAdrWidth);

  -- PORTC addresses 
  constant PORTC_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#15#,IOAdrWidth);
  -- not supported; PORTC is output only
  constant DDRC_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#FF#,IOAdrWidth);
  constant PINC_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#FF#,IOAdrWidth);

  -- PORTD addresses 
  constant PORTD_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#12#,IOAdrWidth);
  constant DDRD_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#11#,IOAdrWidth);
  constant PIND_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#10#,IOAdrWidth);

  -- PORTE addresses 
  constant PORTE_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#03#,IOAdrWidth);
  constant DDRE_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#02#,IOAdrWidth);
  constant PINE_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#01#,IOAdrWidth);

  -- PORTF addresses
  constant PINF_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#00#,IOAdrWidth);
  -- not supported; PORTF is input only
  constant PORTF_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#15#,IOAdrWidth);
  -- not supported; PORTC is output only
  constant DDRF_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#FF#,IOAdrWidth);

  -- Analog to digital converter
  constant ADCL_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#04#,IOAdrWidth);
  constant ADCH_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#05#,IOAdrWidth);
  constant ADCSR_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#06#,IOAdrWidth);
  constant ADMUX_Address : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#07#,IOAdrWidth);

  -- Analog comparator
  constant ACSR_Address  : std_logic_vector(IOAdrWidth-1 downto 0)
    := CONV_STD_LOGIC_VECTOR(16#08#,IOAdrWidth);

  -- Function declaration
  function LOG2(Number : positive) return natural;

  subtype avr_port_address_type is nibble;

  -- TCP port addresses for writing
  constant AVR_TCP_XMIT_BUFFER_HIGH_BYTE : avr_port_address_type := X"1";
  constant AVR_TCP_XMIT_BUFFER_LOW_BYTE  : avr_port_address_type := X"2";
  constant AVR_TCP_RECV_BUFFER_HIGH_BYTE : avr_port_address_type := X"3";
  constant AVR_TCP_RECV_BUFFER_LOW_BYTE  : avr_port_address_type := X"4";
  constant AVR_TCP_XMIT_LENGTH_HIGH_BYTE : avr_port_address_type := X"5";
  constant AVR_TCP_XMIT_LENGTH_LOW_BYTE  : avr_port_address_type := X"6";
  constant AVR_TCP_XMIT_IP_ADDR_BYTE_1   : avr_port_address_type := X"7";
  constant AVR_TCP_XMIT_IP_ADDR_BYTE_2   : avr_port_address_type := X"8";
  constant AVR_TCP_XMIT_IP_ADDR_BYTE_3   : avr_port_address_type := X"9";
  constant AVR_TCP_XMIT_IP_ADDR_BYTE_4   : avr_port_address_type := X"a";

  -- TCP port addresses for reading
  constant AVR_TCP_RECV_LENGTH_HIGH_BYTE : avr_port_address_type := X"5";
  constant AVR_TCP_RECV_LENGTH_LOW_BYTE  : avr_port_address_type := X"6";
  constant AVR_TCP_RECV_IP_ADDR_BYTE_1   : avr_port_address_type := X"7";
  constant AVR_TCP_RECV_IP_ADDR_BYTE_2   : avr_port_address_type := X"8";
  constant AVR_TCP_RECV_IP_ADDR_BYTE_3   : avr_port_address_type := X"9";
  constant AVR_TCP_RECV_IP_ADDR_BYTE_4   : avr_port_address_type := X"a";
  constant AVR_TCP_SELF_IP_ADDR_BYTE_1   : avr_port_address_type := X"b";
  constant AVR_TCP_SELF_IP_ADDR_BYTE_2   : avr_port_address_type := X"c";
  constant AVR_TCP_SELF_IP_ADDR_BYTE_3   : avr_port_address_type := X"d";
  constant AVR_TCP_SELF_IP_ADDR_BYTE_4   : avr_port_address_type := X"e";

end package;

package body avr is

  -- Functions    
  function LOG2(Number : positive) return natural is
    variable Temp : positive := 1;
  begin
    if Number=1 then 
      return 0;
    else 
      for i in 1 to integer'high loop
        Temp := 2*Temp; 
        if Temp>=Number then 
          return i;
        end if;
      end loop;
    end if;     
  end LOG2;     
  -- End of functions     

end package body;

-------------------------------------------------------------------------------
-- Network Package

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library seqlib;
use seqlib.util.all;
use seqlib.constants.all;
use seqlib.avr.all;

package network is
-------------------------------------------------------------------------------
  -- Ethernet constants
  constant NIBBLE_WIDTH                        : positive := 4;
  constant BYTE_WIDTH                          : positive := 8;
  constant MAC_ADDRESS_WIDTH                   : positive := 48;
  constant IP_ADDRESS_WIDTH                    : positive := 32;
  constant ETHERNET_TYPE_LENGTH_WIDTH          : positive := 16;
  constant CRC32_WIDTH                         : positive := 32;
  constant MAX_FRAME_BYTE_COUNT                : positive := 1500;
  constant ETHERNET_HEADER_BYTE_COUNT          : positive :=
    (2*MAC_ADDRESS_WIDTH + ETHERNET_TYPE_LENGTH_WIDTH + CRC32_WIDTH) /
    BYTE_WIDTH;

  subtype mac_address is std_logic_vector((MAC_ADDRESS_WIDTH-1) downto 0);
  -- in LSB first order for ARP/Ethernet
  subtype protocol_address is std_logic_vector((IP_ADDRESS_WIDTH-1) downto 0);
  subtype ethernet_type_length is
    std_logic_vector((ETHERNET_TYPE_LENGTH_WIDTH-1) downto 0);
  subtype crc32_checksum is std_logic_vector((CRC32_WIDTH-1) downto 0);

  -- MAC address constants
  constant BROADCAST_MAC_ADDRESS  : mac_address := X"FF_FF_FF_FF_FF_FF";
  constant SELF_MAC_ADDRESS       : mac_address := X"22_22_22_CA_01_00";

  -- ARP constants and subtypes
  constant ARP_OPCODE_WIDTH       : positive := 16;
  constant ARP_TYPE_LENGTH        : ethernet_type_length := X"0806";

  constant ETHERNET_HARDWARE_SIZE : byte := X"06";
  constant INTERNET_PROTOCOL_SIZE : byte := X"04";
-------------------------------------------------------------------------------
  -- ARP subtypes
  subtype arp_hardware_type is std_logic_vector(15 downto 0);
  subtype arp_protocol_type is std_logic_vector(15 downto 0);
  subtype arp_opcode is std_logic_vector(ARP_OPCODE_WIDTH-1 downto 0);

  constant ETHERNET_HARDWARE_TYPE : arp_hardware_type := X"0001";
  constant INTERNET_PROTOCOL_TYPE : arp_protocol_type := X"0800";
  constant ARP_REQUEST_OPCODE     : arp_opcode := X"0001";
  constant ARP_REPLY_OPCODE       : arp_opcode := X"0002";
  constant ARP_BYTE_LENGTH        : positive := 28;
-------------------------------------------------------------------------------
  -- IP constants
  constant IP_ID_WIDTH             : positive := 16;
  constant IP_PROTOCOL_WIDTH       : positive := 8;
  constant IP_TOTAL_LENGTH_WIDTH   : positive := 16;
  constant IP_FRAG_OFFSET_WIDTH    : positive := 13;
  constant CKSUM_WIDTH             : positive := 16;

  constant IP_TYPE_LENGTH          : ethernet_type_length := X"0800";
  constant IP_VERSION_FOUR         : nnibble := X"4";
  constant IP_MIN_HEADER_LENGTH    : unsigned(0 to 3) := X"5";
  constant IP_MIN_HEADER_BYTE_LENGTH : positive :=
    to_integer(IP_MIN_HEADER_LENGTH)*4;

  constant IP_TIME_TO_LIVE         : nbyte := X"40";  -- 64 seconds

  subtype ip_address      is std_logic_vector(0 to (IP_ADDRESS_WIDTH-1));
  subtype ip_id           is std_logic_vector(0 to (IP_ID_WIDTH-1));
  subtype ip_protocol     is std_logic_vector(0 to (IP_PROTOCOL_WIDTH-1));
  subtype ip_total_length is unsigned(0 to (IP_TOTAL_LENGTH_WIDTH-1));
  subtype ip_frag_offset  is unsigned(0 to (IP_FRAG_OFFSET_WIDTH-1));
  subtype ip_checksum     is std_logic_vector(0 to (CKSUM_WIDTH-1));
 
  -- Autoconfigured IP addresses at startup, 169.254.34.34, unrouteable
  constant SELF_AUTO_IP_ADDRESS    : ip_address := X"A9_FE_22_22";
  constant BROADCAST_IP_ADDRESS    : ip_address := X"FF_FF_FF_FF";
  constant IP_INTERNAL_SUBNET      : ip_address := X"C0_A8_00_DC";

  -- Transport layer constants
  constant PORT_WIDTH              : positive := 16;
-------------------------------------------------------------------------------
  -- ICMP constants
  constant ICMP_HEADER_BYTE_LENGTH : positive := 8;
  constant ICMP_PROTOCOL_TYPE      : ip_protocol := X"01";
  constant ICMP_TYPE_WIDTH         : positive := 8;
  constant ICMP_ID_WIDTH           : positive := 16;
  constant ICMP_SEQUENCE_WIDTH     : positive := 16;
  subtype icmp_type_type     is std_logic_vector(0 to ICMP_TYPE_WIDTH-1);
  subtype icmp_id_type       is std_logic_vector(0 to ICMP_ID_WIDTH-1);
  subtype icmp_sequence_type is std_logic_vector(0 to ICMP_SEQUENCE_WIDTH-1);

  constant ICMP_ECHO_REQUEST_TYPE  : icmp_type_type := X"08";
  constant ICMP_ECHO_REPLY_TYPE    : icmp_type_type := X"00";
-------------------------------------------------------------------------------
  -- UDP constants
  constant UDP_HEADER_BYTE_LENGTH : positive := 8;
  constant UDP_PSEUDO_HEADER_BYTE_LENGTH : positive := 12;
  constant UDP_PROTOCOL_TYPE      : ip_protocol := X"11";
  constant UDP_LENGTH_WIDTH : positive := 16;
  subtype udp_port_type is std_logic_vector(0 to PORT_WIDTH-1);
  subtype udp_length_type is unsigned(0 to UDP_LENGTH_WIDTH-1);
-------------------------------------------------------------------------------
  -- DHCP constants and subtypes
  constant DHCP_SERVER_PORT            : udp_port_type := X"0043";  -- D"67"
  constant DHCP_CLIENT_PORT            : udp_port_type := X"0044";  -- D"68"
  subtype dhcp_opcode_type             is std_logic_vector(0 to 7);
  subtype dhcp_htype_type              is std_logic_vector(0 to 7);
  subtype dhcp_xid_type                is std_logic_vector(0 to 31);
  subtype dhcp_messagetype_type        is std_logic_vector(0 to 7);
  subtype dhcp_optiontype_type         is std_logic_vector(0 to 7);
  subtype dhcp_optionlen_type          is std_logic_vector(0 to 7);
  constant DHCP_BOOTREQUEST_OPCODE     : dhcp_opcode_type := X"01";
  constant DHCP_BOOTREPLY_OPCODE       : dhcp_opcode_type := X"02";
  constant DHCP_ETHERNET_HTYPE         : dhcp_htype_type  := X"01";
  constant DHCP_DEFAULT_XID            : dhcp_xid_type    := X"22222222";
  constant DHCP_HEADER_BYTE_LENGTH     : positive := 44; -- up to chaddr
  constant DHCP_SNAME_BYTE_LENGTH      : positive := 64;
  constant DHCP_FILE_BYTE_LENGTH       : positive := 128;
  -- magic cookie (4) + message type (3) + server id (6) + end (1)
  constant DHCP_OPTION_BYTE_LENGTH     : positive := 14;
  constant DHCP_BYTE_LENGTH            : positive := DHCP_HEADER_BYTE_LENGTH +
                                                     DHCP_SNAME_BYTE_LENGTH  +
                                                     DHCP_FILE_BYTE_LENGTH   +
                                                     DHCP_OPTION_BYTE_LENGTH;
  constant DHCP_MAGIC_COOKIE           : std_logic_vector(0 to 31)
    := X"63_82_53_63";
  constant DHCP_MESSAGETYPE_OPTION_ID  : dhcp_optiontype_type  := X"35";
  constant DHCP_MESSAGETYPE_OPTION_LEN : dhcp_optionlen_type   := X"01";
  constant DHCP_SERVERID_OPTION_ID     : dhcp_optiontype_type  := X"36";
  constant DHCP_SERVERID_OPTION_LEN    : dhcp_optionlen_type   := X"04";
  constant DHCP_ROUTER_OPTION_ID       : dhcp_optiontype_type  := X"03";
  constant DHCP_ROUTER_OPTION_LEN      : dhcp_optionlen_type   := X"04";
  constant DHCP_REQUESTLIST_OPTION_ID  : dhcp_optiontype_type  := X"37";
  constant DHCP_REQUESTLIST_OPTION_LEN : dhcp_optionlen_type   := X"01";
  constant DHCP_DISCOVER_MESSAGE_TYPE  : dhcp_messagetype_type := X"01";
  constant DHCP_OFFER_MESSAGE_TYPE     : dhcp_messagetype_type := X"02";
  constant DHCP_REQUEST_MESSAGE_TYPE   : dhcp_messagetype_type := X"03";
  constant DHCP_DECLINE_MESSAGE_TYPE   : dhcp_messagetype_type := X"04";
  constant DHCP_ACK_MESSAGE_TYPE       : dhcp_messagetype_type := X"05";
  constant DHCP_NAK_MESSAGE_TYPE       : dhcp_messagetype_type := X"06";
  constant DHCP_RELEASE_MESSAGE_TYPE   : dhcp_messagetype_type := X"07";
  constant DHCP_END_OPTION_ID          : dhcp_optiontype_type  := X"FF";

-------------------------------------------------------------------------------
  -- TCP constants
  constant TCP_PROTOCOL_TYPE             : ip_protocol := X"06";
  constant TCP_HEADER_BYTE_LENGTH        : positive    := 20;
  constant TCP_PSEUDO_HEADER_BYTE_LENGTH : positive    := 12;
  constant TCP_LENGTH_WIDTH              : positive    := 16;
  constant TCP_SEQUENCE_NUMBER_WIDTH    : positive    := 32;
  constant TCP_WINDOW_WIDTH              : positive    := 16;
  subtype tcp_port_type is std_logic_vector(0 to PORT_WIDTH-1);
  subtype tcp_length_type is unsigned(0 to TCP_LENGTH_WIDTH-1);
  subtype tcp_sequence_number_type is
    unsigned(0 to TCP_SEQUENCE_NUMBER_WIDTH-1);
  constant TCP_MAX_SEQUENCE_NUMBER : tcp_sequence_number_type :=
    (others => '1');
  subtype tcp_window_type is unsigned(0 to TCP_WINDOW_WIDTH-1);
  subtype tcp_offset_type is natural range 0 to 1023;

  subtype tcp_state_type is nibble;

  constant TCP_CLOSED_STATE     : tcp_state_type := X"0";
  constant TCP_LISTEN_STATE     : tcp_state_type := X"1";
  constant TCP_SYN_RCVD_STATE   : tcp_state_type := X"2";
  constant TCP_SYN_SENT_STATE   : tcp_state_type := X"3";
  constant TCP_ESTAB_STATE      : tcp_state_type := X"4";
  constant TCP_FIN_WAIT_1_STATE : tcp_state_type := X"5";
  constant TCP_FIN_WAIT_2_STATE : tcp_state_type := X"6";
  constant TCP_CLOSE_WAIT_STATE : tcp_state_type := X"7";
  constant TCP_TIME_WAIT_STATE  : tcp_state_type := X"8";
  constant TCP_CLOSING_STATE    : tcp_state_type := X"9";

  subtype tcp_error_type is nibble;

  constant TCP_NO_ERROR                : tcp_error_type := X"0";
  constant TCP_CONN_NOT_OPEN_ERROR     : tcp_error_type := X"1";
  constant TCP_CONN_ALREADY_OPEN_ERROR : tcp_error_type := X"2";
  constant TCP_NO_RESOURCES_ERROR      : tcp_error_type := X"3";
  constant TCP_CONN_CLOSING_ERROR      : tcp_error_type := X"4";
  constant TCP_CONN_NOT_BOUND_ERROR    : tcp_error_type := X"5";

  constant TCP_LISTEN_PORT      : tcp_port_type := X"0000";
  constant TCP_DEFAULT_ISS      : tcp_sequence_number_type := X"0000_0000";

crc32_component_

ring_buffer_component_

lookup_table_component_

in_cksum_component_

end network;

-------------------------------------------------------------------------------
-- Pulse Transfer Protocol Package

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;
use work.util.all;
use work.network.all;
use work.avr.all;

package ptp is
-------------------------------------------------------------------------------
  -- PTP constants
  constant PTP_HEADER_BYTE_LENGTH : positive := 10;
  constant PTP_SERVER_PORT_0 : udp_port_type := X"2220"; -- D"8736"
  constant PTP_SERVER_PORT_1 : udp_port_type := X"2221"; -- D"8737"
  constant PTP_SERVER_PORT_2 : udp_port_type := X"2222"; -- D"8738"
  constant PTP_SERVER_PORT_3 : udp_port_type := X"2223"; -- D"8739"
  constant PTP_SERVER_PORT_4 : udp_port_type := X"2224"; -- D"8740"
  constant PTP_SERVER_PORT_5 : udp_port_type := X"2225"; -- D"8741"
  constant PTP_SERVER_PORT_6 : udp_port_type := X"2226"; -- D"8742"
  constant PTP_SERVER_PORT_7 : udp_port_type := X"2227"; -- D"8743"
  constant PTP_SERVER_PORT_8 : udp_port_type := X"2228"; -- D"8744"
  constant PTP_SERVER_PORT_9 : udp_port_type := X"2229"; -- D"8745"
  constant PTP_SERVER_PORT_A : udp_port_type := X"222A"; -- D"8746"
  constant PTP_SERVER_PORT_B : udp_port_type := X"222B"; -- D"8747"
  constant PTP_SERVER_PORT_C : udp_port_type := X"222C"; -- D"8748"
  constant PTP_SERVER_PORT_D : udp_port_type := X"222D"; -- D"8749"
  constant PTP_SERVER_PORT_E : udp_port_type := X"222E"; -- D"8750"
  constant PTP_SERVER_PORT_F : udp_port_type := X"222F"; -- D"8751"
  constant PTP_CLIENT_PORT   : udp_port_type := X"2221"; -- D"8737"
  constant PTP_ID_WIDTH : positive := 8;
  subtype ptp_id_type is std_logic_vector(0 to PTP_ID_WIDTH-1);
  subtype ptp_opcode_type  is std_logic_vector(0 to 7);
  constant PTP_ADDRESS_WIDTH : positive := 16;
  subtype ptp_address_type is std_logic_vector(0 to PTP_ADDRESS_WIDTH-1);
  constant PTP_LENGTH_WIDTH : positive := 16;
  subtype ptp_length_type  is unsigned(0 to PTP_LENGTH_WIDTH-1);

  -- Opcodes
  constant PTP_NULL_OPCODE             : ptp_opcode_type := X"00";

  constant PTP_STATUS_REQUEST_OPCODE   : ptp_opcode_type := X"01";
  constant PTP_STATUS_REPLY_OPCODE     : ptp_opcode_type := X"11";

  constant PTP_MEMORY_REQUEST_OPCODE   : ptp_opcode_type := X"02";
  constant PTP_MEMORY_REPLY_OPCODE     : ptp_opcode_type := X"12";

  constant PTP_START_REQUEST_OPCODE    : ptp_opcode_type := X"04";
  constant PTP_START_REPLY_OPCODE      : ptp_opcode_type := X"14";

  constant PTP_TRIGGER_REQUEST_OPCODE  : ptp_opcode_type := X"05";
  constant PTP_TRIGGER_REPLY_OPCODE    : ptp_opcode_type := X"15";

  constant PTP_I2C_REQUEST_OPCODE      : ptp_opcode_type := X"07";
  constant PTP_I2C_REPLY_OPCODE        : ptp_opcode_type := X"17";

  constant PTP_DEBUG_REQUEST_OPCODE    : ptp_opcode_type := X"08";
  constant PTP_DEBUG_REPLY_OPCODE      : ptp_opcode_type := X"18";

  constant PTP_DISCOVER_REQUEST_OPCODE : ptp_opcode_type := X"09";
  constant PTP_DISCOVER_REPLY_OPCODE   : ptp_opcode_type := X"19";

  -- Subopcodes

  -- Memory Subopcodes
  constant PTP_MEMORY_NULL_SUBOPCODE       : ptp_opcode_type := X"00";
  constant PTP_MEMORY_SRAM_WRITE_SUBOPCODE : ptp_opcode_type := X"01";
  constant PTP_MEMORY_SRAM_READ_SUBOPCODE  : ptp_opcode_type := X"02";
  constant PTP_MEMORY_CLEAR_SUBOPCODE      : ptp_opcode_type := X"03";
  constant PTP_MEMORY_TABLE_SUBOPCODE      : ptp_opcode_type := X"04";
  constant PTP_MEMORY_DMEM_WRITE_SUBOPCODE : ptp_opcode_type := X"05";
  constant PTP_MEMORY_DMEM_READ_SUBOPCODE  : ptp_opcode_type := X"06";

  -- Start Subopcodes
  constant PTP_START_NULL_SUBOPCODE        : ptp_opcode_type := X"00";
  constant PTP_START_PCP_RESUME_SUBOPCODE  : ptp_opcode_type := X"01";
  constant PTP_START_PCP_SUSPEND_SUBOPCODE : ptp_opcode_type := X"02";
  constant PTP_START_AVR_RESUME_SUBOPCODE  : ptp_opcode_type := X"03";
  constant PTP_START_AVR_SUSPEND_SUBOPCODE : ptp_opcode_type := X"04";

  -- Debugging Subopcodes
  constant PTP_DEBUG_LED_SUBOPCODE     : ptp_opcode_type := X"01";
  constant PTP_DEBUG_MAC_SUBOPCODE     : ptp_opcode_type := X"02";

  subtype ptp_status_type is std_logic_vector(0 to 3);

  constant PTP_IDLE_STATUS            : ptp_status_type := X"1";
  constant PTP_RUNNING_STATUS         : ptp_status_type := X"2";
  constant PTP_TRIGGER_STATUS         : ptp_status_type := X"3";
  constant PTP_UNKNOWN_STATUS         : ptp_status_type := X"0";

  constant PTP_AUTO_SELF_ID           : ptp_id_type := X"02";
  constant PTP_HOST_ID                : ptp_id_type := X"00";
  constant PTP_AVR_ID                 : ptp_id_type := X"01";
  constant PTP_BROADCAST_ID           : ptp_id_type := X"FF";

  type ptp_interface_type is (to_master, to_slave, to_avr);

  constant PTP_SRAM_ADDRESS_WIDTH     : positive := SRAM_ADDRESS_WIDTH;
  constant PTP_SRAM_DATA_WIDTH        : positive := 8;

--   subtype trigger_opcode is std_logic_vector(0 to 7);
--   constant LVDS_RECV_0_TRIGGER_OPCODE : trigger_opcode := X"00";
--   constant LVDS_RECV_1_TRIGGER_OPCODE : trigger_opcode := X"01";
--   constant LVDS_RECV_2_TRIGGER_OPCODE : trigger_opcode := X"02";
--   constant LVDS_RECV_3_TRIGGER_OPCODE : trigger_opcode := X"03";
--   constant LVDS_RECV_4_TRIGGER_OPCODE : trigger_opcode := X"04";
--   constant LVDS_RECV_5_TRIGGER_OPCODE : trigger_opcode := X"05";
--   constant LVDS_RECV_6_TRIGGER_OPCODE : trigger_opcode := X"06";
--   constant LVDS_RECV_7_TRIGGER_OPCODE : trigger_opcode := X"07";
--   constant SWITCH_TRIGGER_OPCODE      : trigger_opcode := X"08";
--   constant START_TRIGGER_OPCODE       : trigger_opcode := X"09";
--   constant NULL_TRIGGER_OPCODE        : trigger_opcode := X"0a";

  -- PTP port addresses for writing from the AVR
  constant AVR_PTP_XMIT_BUFFER_HIGH_BYTE : avr_port_address_type := X"1";
  constant AVR_PTP_XMIT_BUFFER_LOW_BYTE  : avr_port_address_type := X"2";
  constant AVR_PTP_RECV_BUFFER_HIGH_BYTE : avr_port_address_type := X"3";
  constant AVR_PTP_RECV_BUFFER_LOW_BYTE  : avr_port_address_type := X"4";
  constant AVR_PTP_XMIT_LENGTH_HIGH_BYTE : avr_port_address_type := X"5";
  constant AVR_PTP_XMIT_LENGTH_LOW_BYTE  : avr_port_address_type := X"6";

  -- TCP port addresses for reading
  constant AVR_PTP_RECV_LENGTH_HIGH_BYTE : avr_port_address_type := X"5";
  constant AVR_PTP_RECV_LENGTH_LOW_BYTE  : avr_port_address_type := X"6";
  constant AVR_PTP_SELF_ID               : avr_port_address_type := X"7";

end package;
