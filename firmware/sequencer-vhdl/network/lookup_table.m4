dnl--*-VHDL-*-
-- Lookup table for ARP
-------------------------------------------------------------------------------
-- MIT-NIST-ARDA Pulse Sequencer
-- http://qubit.media.mit.edu/sequencer
-- Paul Pham
-- MIT Center for Bits and Atoms
-------------------------------------------------------------------------------

-- This is not really a table but an associative list between Ethernet
-- MAC addresses (48-bit keys) and IP addresses (32-bit values), although
-- these widths have been parameterised so you can reuse this module for
-- similar but different applications.

-- The list is implemented as two circular buffers, one for keys and one for
-- values, which are shifted (always towards the head) in synchrony.
-- The "head" of the buffer is the least-recently and highest-indexed item.
-- The "tail" is the most recently inserted/updated/looked-up item.

-- This module is synchronised to a clock and supports two operations:
-- inserting/update a key/value pair and looking up a value given a key.
-- The first operation implies the second, since if a key is found, it's
-- value is updated.

-- Both operations take O(n) running time and O(n) space.
-- It could be shrunk in size by using built-in FPGA RAM at the risk of being
-- less portable. We could also implement this as a linked list or a hash table
-- in memory.

-- Assert the "load" signal with "wb_we_i" high or low to request an
-- operation, monitor "done" and "found" for results; if "found" is high,
-- then latch in the data on "value_out".

unit_([lookup_table], dnl
  [dnl -- Libraries -----------------------------------------------------------
sequencer_libraries_
],[dnl -- Generics ------------------------------------------------------------
    KEY_WIDTH          : positive := 32;
    VALUE_WIDTH        : positive := 48;
    DEPTH              : positive := 4;
],[dnl -- Ports ---------------------------------------------------------------
wb_common_port_
    wb_stb_i : in  std_logic;
    wb_we_i  : in  std_logic;
    wb_adr_i : in  std_logic_vector(KEY_WIDTH-1 downto 0);
    wb_dat_i : in  std_logic_vector(VALUE_WIDTH-1 downto 0);
    wb_dat_o : out std_logic_vector(VALUE_WIDTH-1 downto 0);
    wb_ack_o : out std_logic;
    wb_err_o : out std_logic;
],[dnl -- Declarations --------------------------------------------------------
  subtype key_item   is std_logic_vector(KEY_WIDTH-1 downto 0);
  subtype value_item is std_logic_vector(VALUE_WIDTH-1 downto 0);

  signal key_head   : key_item;
  signal value_head : value_item;

  signal strobe         : std_logic;
  signal write_enable   : std_logic;
  signal key_new_head   : key_item;
  signal key_old_tail   : key_item;
  signal key_ack        : std_logic;
  signal value_new_head : value_item;
  signal value_old_tail : value_item;
  signal value_ack      : std_logic;

  -- intermediate value of wb_err_o, b/c we cannot read the output found
  signal found_inter : boolean;

  signal target_count : natural range 0 to DEPTH;
  signal insert_shift : std_logic;

  signal key_reg : key_item;
  signal value_reg : value_item;
],[dnl -- Body ----------------------------------------------------------------
  key_ring_buffer : ring_buffer
    generic map (
      WIDTH => KEY_WIDTH,
      DEPTH => DEPTH-1
    )
    port map (
      wb_clk_i => wb_clk_i,
      wb_stb_i => strobe,
      wb_we_i  => write_enable,
      wb_dat_i => key_new_head,
      wb_dat_o => key_old_tail,
      wb_ack_o => key_ack
    );

  value_ring_buffer : ring_buffer
    generic map (
      WIDTH => VALUE_WIDTH,
      DEPTH => DEPTH-1
    )
    port map (
      wb_clk_i => wb_clk_i,
      wb_stb_i => strobe,
      wb_we_i  => write_enable,
      wb_dat_i => value_new_head,
      wb_dat_o => value_old_tail,
      wb_ack_o => value_ack
    );
-------------------------------------------------------------------------------
  buffer_process : process(wb_clk_i, wb_rst_i, wb_stb_i)

    type buffer_states is (
      idle,
      lookup
      );

    -- the current state of this module
    variable state       : buffer_states;
    variable insert_flag : boolean;

  begin

    if (wb_rst_i = '1') then
      wb_ack_o     <= '0';
      found_inter  <= false;
      write_enable <= '0';
      strobe       <= '0';
      state        := idle;
      
    elsif (rising_edge(wb_clk_i)) then
      case (state) is

        when idle =>
          -- Hang out here in between operations
          if (wb_stb_i = '1') then

            key_reg   <= wb_adr_i;
            value_reg <= wb_dat_i;

            if (wb_we_i = '1') then
              insert_flag := true;
            else
              insert_flag := false;
            end if;
            -- if we are inserting/updating a key/value pair,
            -- tell lookup to return to inserting after searching
            -- +1 b/c we need an extra shift to insert the new head
            target_count <= DEPTH;

            -- all operations (reading or writing) require a lookup first.
            if (key_head = wb_adr_i) then
              -- best case; the desired item was already at the tail
              found_inter  <= true;
              wb_ack_o     <= '1';
            else
              -- we want to shift our head value through ring buffers
              -- start the pipeline now
              write_enable <= '1';
              found_inter  <= false;
              strobe       <= '1';
              state        := lookup;
            end if;
           else
             wb_ack_o      <= '0';
          end if;                       -- wb_stb_i = '1'

        when lookup =>
          -- search through the table by shifting and comparing the
          -- head item (0) with the desired key
          case (target_count) is
            when 0 =>
              if (wb_stb_i = '0') then
                state := idle;
              end if;
              if (insert_flag) then
                insert_flag := false;
                key_head    <= wb_adr_i;
                value_head  <= wb_dat_i;
                wb_ack_o    <= '1';
--               else
--                 wb_ack_o    <= '0';
              end if;
              write_enable  <= '0';
              strobe        <= '0';
            when 1 =>
              if ((not insert_flag) or found_inter) then
                -- if we aren't inserting a *new* key/value, stop pipeline now
                write_enable <= '0';
                strobe       <= '0';
                if (not insert_flag) then
                  wb_ack_o   <= '1';
                end if;
              end if;
              if (not found_inter) then
                key_head <= key_old_tail;
                value_head <= value_old_tail;
              end if;
              target_count <= 0;
            when others =>
              if ((key_ack = '1') and (value_ack = '1')) then
                
                -- while we haven't searched through the whole table yet
                if (key_old_tail = wb_adr_i) then
                  found_inter <= true;
                  -- no need to shift in our head value into ring buffer anymore
                  write_enable <= '0';
                end if;
              end if;
              if (not found_inter) then
                key_head   <= key_old_tail;
                value_head <= value_old_tail;
              end if;
              target_count <= target_count - 1;
          end case;
          
        when others => null;
                       
      end case;

    end if;

  end process;

  key_new_head   <= key_old_tail   when (found_inter) else key_head;
  value_new_head <= value_old_tail when (found_inter) else value_head;

  wb_dat_o <= value_head;

  -- opposite to make it wishbone compliant
  wb_err_o <= '0' when (found_inter) else '1';
])
