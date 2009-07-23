dnl-*-VHDL-*-
-- I/O multiplexer for ports and interrupts to core.

-------------------------------------------------------------------------------
-- External multeplexer for AVR core
-- Version 2.1
-- Designed by Ruslan Lepetenok 05.11.2001
-- Modified 02.11.2002
-------------------------------------------------------------------------------

unit_([io_mux], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
use seqlib.avr.all;
],[dnl -- Generics ------------------------------------------------------------
  PORT_COUNT : positive := 8;  
],[dnl -- Ports ---------------------------------------------------------------
  ramre              : in  std_logic;
  dbus_out           : out std_logic_vector (7 downto 0);
  ram_data_out       : in  std_logic_vector (7 downto 0);
  io_port_bus        : in  multibus_byte(PORT_COUNT downto 0);
  io_port_en_bus     : in  multibus_bit(PORT_COUNT downto 0);
  irqack             : in  std_logic;
  irqackad           : in  std_logic_vector(4 downto 0);		  
  ind_irq_ack        : out std_logic_vector(22 downto 0);
],[dnl -- Declarations --------------------------------------------------------
  signal   ext_mux_out      : ext_mux_data_type(PORT_COUNT downto 0);
],[dnl -- Body ----------------------------------------------------------------

  -- MUX grants precedence to ports in decreasing order
  -- (0 is highest, 1 is next, etc.)
  ext_mux_out(0) <= io_port_bus(0) when io_port_en_bus(0)='1'
                  else (others => '0');

  data_mux_for_read : for i in 1 to PORT_COUNT generate
    ext_mux_out(i) <= io_port_bus(i) when io_port_en_bus(i)='1'
                    else ext_mux_out(i-1);
  end generate;	

  -- MUX assigns data bus out to external RAM (highest precedence)
  -- or to the winner of the ports above
  dbus_out <= ram_data_out when ramre='1'
              else ext_mux_out(PORT_COUNT);

  -- When the interrupt is acked, raise the ack of the independent
  -- input interrupt requests (and all higher requests).
  interrupt_ack : for i in ind_irq_ack'range generate
    ind_irq_ack(i) <= '1' when (irqackad=i+1 and irqack='1') else '0';
  end generate;	
])
