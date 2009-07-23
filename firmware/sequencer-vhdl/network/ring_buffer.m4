dnl--*-VHDL-*-
-- Ring buffer for implementing LRU storage.
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- This is a circular array of items which has an adjacent head and tail.
-- The items can all be shifted one location from the head to the tail,
-- adding a new head and discarding an old tail.
-- The buffer supports two operations:
-- Shift : the old tail is push back as the new head.
-- Insert: the old tail is discarded and an new item is pushed in.

-- This module is designed to be implemented in the FPGA's built-in RAM
-- blocks automatically as an optimised shift register
-- b/c it is an array of registers with the same width, clock, clock_enable,
-- and shift direction.

-- WB_STB_I indicates a new operation.
-- WB_WE_I high indicates insertion, otherwise shifting is performed.
-- WB_DAT_O is always the current tail/new head when WB_ACK_O is high.
-- WB_DAT_I is the new head to insert into the ring buffer (if WB_WE_I is high)
-- WB_ACK_O is tied asynchronously to WB_STB_I b/c all operations complete
-- in one cycle.
-- no WB_CYC_I for the same reason and b/c we usually have only one master
-- no WB_ADR_I b/c there is only one location to write to (the head)
--    or read from (the tail).
-- no WB_RST_I b/c we don't initialise memory to save space

unit_([ring_buffer], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
    WIDTH : positive := 8;
    DEPTH : positive := 4;
],[dnl -- Ports ---------------------------------------------------------------
    wb_clk_i : in  std_logic;
    wb_stb_i : in  std_logic;
    wb_we_i  : in  std_logic;
    wb_dat_i : in  std_logic_vector(WIDTH-1 downto 0);
    wb_dat_o : out std_logic_vector(WIDTH-1 downto 0);
    wb_ack_o : out std_logic;
],[dnl -- Declarations --------------------------------------------------------
  subtype item is std_logic_vector(WIDTH-1 downto 0);

  type ring_buffer_type is array(0 to DEPTH-1) of item;

  signal ring_buffer : ring_buffer_type;

  attribute ramstyle : string;
  attribute ramstyle of ring_buffer : signal is "M4K";
],[dnl -- Body ----------------------------------------------------------------
  -- we respond instantaneously (within 1 cycle)
  wb_ack_o <= wb_stb_i;

  buffer_process : process(wb_clk_i, wb_stb_i)

  begin

    if (rising_edge(wb_clk_i) and (wb_stb_i = '1')) then

      -- shift all items in ring buffer toward tail
      for i in 0 to DEPTH-2 loop
        ring_buffer(i+1)   <= ring_buffer(i);
      end loop;  -- i

      if (wb_we_i = '1') then
        -- if we are writing, push the new head into the vacated old head
        ring_buffer(0) <= wb_dat_i;
      else
        -- if we are "reading" (not writing), wrap the tail to the head
        ring_buffer(0) <= ring_buffer(DEPTH-1);
      end if;

      -- b/c of pipeline, the new tail next cycle is the next to last this time
      wb_dat_o <= ring_buffer(DEPTH-2);

    end if;

  end process;
])
