dnl-*-VHDL-*-
-- I/O address decoder.

-- Internal I/O registers decoder/multiplexer for the AVR core
-- Version 1.1
-- Designed by Ruslan Lepetenok
-- Modified 02.11.2002

unit_([io_adr_dec], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.avr.all;
],[dnl -- Generics ------------------------------------------------------------
],[dnl -- Ports ---------------------------------------------------------------
   adr          : in std_logic_vector(5 downto 0);         
   iore         : in std_logic;         
   dbusin_ext   : in std_logic_vector(7 downto 0);
   dbusin_int   : out std_logic_vector(7 downto 0);
                   
   spl_out      : in std_logic_vector(7 downto 0); 
   sph_out      : in std_logic_vector(7 downto 0);           
   sreg_out     : in std_logic_vector(7 downto 0);           
   rampz_out    : in std_logic_vector(7 downto 0);
],[dnl -- Declarations --------------------------------------------------------
],[dnl -- Body ----------------------------------------------------------------
dbusin_int <= spl_out   when (adr=SPL_Address  and iore='1') else
              sph_out  when  (adr=SPH_Address  and iore='1') else
              sreg_out when  (adr=SREG_Address  and iore='1') else
              rampz_out when (adr=RAMPZ_Address and iore='1') else
              dbusin_ext;
])
