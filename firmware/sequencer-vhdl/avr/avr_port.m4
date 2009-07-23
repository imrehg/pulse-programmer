dnl-*-VHDL-*-
-- AVR I/O port.
-------------------------------------------------------------------------------
--  Parallel Port Peripheral for the AVR Core
--  Version 0.5 20.03.2003
--  Designed by Ruslan Lepetenok
-------------------------------------------------------------------------------

unit_([avr_port], dnl
  [dnl -- Libraries -----------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
sequencer_libraries_
use seqlib.avr.all;
],[dnl -- Generics ------------------------------------------------------------
  PORTX_Adr : std_logic_vector(IOAdrWidth-1 downto 0) := B"000000";
  DDRX_Adr  : std_logic_vector(IOAdrWidth-1 downto 0) := B"010101";
  PINX_Adr  : std_logic_vector(IOAdrWidth-1 downto 0) := B"101010";
],[dnl -- Ports ---------------------------------------------------------------
  -- AVR Control
  ireset     : in  std_logic;
  sclr       : in  std_logic;
  cp2	     : in  std_logic;
  -- No clock enable for ports b/c we want them always to be latched
  -- clk_en     : in  std_logic;
  adr        : in  std_logic_vector(5 downto 0);
  dbus_in    : in  byte;
  dbus_out   : out byte;
  iore       : in  std_logic;
  iowe       : in  std_logic;
  out_en     : out std_logic; 
  -- External connection
  portx      : out byte;
  ddrx       : out byte;
  pinx       : in  byte;
],[dnl -- Declarations --------------------------------------------------------
  signal PORTX_Int   : std_logic_vector(portx'range);
  signal DDRX_Int    : std_logic_vector(ddrx'range);
  signal PINX_InReg  : std_logic_vector(pinx'range);
  signal PINX_Resync  : std_logic_vector(pinx'range);

  signal PORTX_Sel : std_logic;
  signal DDRX_Sel  : std_logic;
  signal PINX_Sel  : std_logic;
],[dnl -- Body ----------------------------------------------------------------
  PORTX_Sel <= '1' when adr=PORTX_Adr else '0';
  DDRX_Sel  <= '1' when adr=DDRX_Adr else '0';	
  PINX_Sel  <= '1' when adr=PINX_Adr else '0';	

  out_en <= (PORTX_Sel or DDRX_Sel or PINX_Sel) and iore;

  PORTX_DFF : process(cp2, ireset, sclr)
  begin
    if (ireset = '0') then                  -- Reset
      PORTX_Int <= (others => '0'); 
    elsif (rising_edge(cp2)) then
      if (sclr = '1') then
        PORTX_Int <= (others => '0'); 
      else
        if (adr=PORTX_Adr and iowe='1') then             -- Clock enable
          PORTX_Int <= dbus_in;
        end if;
      end if;
    end if;
  end process;		

  DDRX_DFF : process(cp2, ireset, sclr)
  begin
    if (ireset = '0') then
      DDRX_Int <= (others => '0'); 
    elsif (rising_edge(cp2)) then
      if (sclr = '1') then
        DDRX_Int <= (others => '0'); 
      else
        if (adr=DDRX_Adr and iowe='1') then -- Clock enable
          DDRX_Int <= dbus_in;
        end if;
      end if;
    end if;
  end process;		

  PINXSynchronizer : process(cp2, ireset, sclr)
  begin
    if (ireset = '0') then                  -- Reset
      PINX_Resync <= (others => '0');
    elsif (falling_edge(cp2)) then
      if (sclr = '1') then
        PINX_Resync <= (others => '0');
      else
        PINX_Resync <= pinx;
      end if;
    end if;
  end process;		

  PINXInputReg : process(cp2, ireset, sclr)
  begin
    if (ireset = '0') then                  -- Reset
      PINX_InReg <= (others => '0'); 
    elsif (rising_edge(cp2)) then
      if (sclr = '1') then
        PINX_InReg <= (others => '0'); 
      else
        PINX_InReg <= PINX_Resync;
      end if;
    end if;
  end process;		

  DBusOutMux:for i in pinx'range generate
    dbus_out(i) <= (PORTX_Int(i) and PORTX_Sel)or(DDRX_Int(i) and DDRX_Sel)or(PINX_InReg(i) and PINX_Sel);
  end generate;

  portx <= PORTX_Int;
  ddrx  <= DDRX_Int;

])
