--========================================================================
-- Synchronous Ring Buffer FIFO

-- Inspiration from: https://vhdlwhiz.com/ring-buffer-fifo/
--========================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ring_buffer_fifo is
    generic (
        G_DEPTH : natural := 8;
        G_WIDTH : natural := 8
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;
        -- Write Data
        i_wr_en   : in std_logic;
        i_wr_data : in std_logic_vector(G_WIDTH - 1 downto 0);
        -- Read Data
        i_rd_en    : in std_logic;
        o_rd_data  : out std_logic_vector(G_WIDTH - 1 downto 0);
        o_rd_valid : out std_logic;
        -- Status Flags
        o_empty      : out std_logic;
        o_empty_next : out std_logic;
        o_full       : out std_logic;
        o_full_next  : out std_logic
    );
end entity ring_buffer_fifo;

architecture rtl of ring_buffer_fifo is

    type t_FIFO_DATA is array (0 to G_DEPTH - 1) of std_logic_vector(i_wr_data'range);
    signal r_FIFO_DATA : t_FIFO_DATA := (others => (others => '0'));

    subtype t_ptr is integer range t_FIFO_DATA'range;
    signal r_head : t_ptr := 0;
    signal r_tail : t_ptr := 0;

    signal w_full       : std_logic;
    signal w_full_next  : std_logic;
    signal w_empty      : std_logic;
    signal w_empty_next : std_logic;

    signal w_fill_count : integer range G_DEPTH - 1 downto 0;

    -- Increment and Wrap
    procedure incr (
        signal ptr : inout t_ptr
    ) is
    begin
        if ptr = (t_ptr'high) then
            ptr <= t_ptr'low;
        else
            ptr <= ptr + 1;
        end if;
    end procedure;

begin
    -- ===============================================================
    -- Outputs
    o_full       <= w_full;
    o_full_next  <= w_full_next;
    o_empty      <= w_empty;
    o_empty_next <= w_empty_next;
    -- ===============================================================
    -- Combinatorial assignments
    w_full <= '1' when (w_fill_count >= G_DEPTH - 1) else
        '0';
    w_full_next <= '1' when (w_fill_count >= G_DEPTH - 2) else
        '0';

    w_empty <= '1' when (w_fill_count = 0) else
        '0';
    w_empty_next <= '1' when (w_fill_count <= 1) else
        '0';
    -- ===============================================================
    -- Write
    p_head : process (clk)
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                r_head <= 0;
            else
                if (i_wr_en = '1') and (w_full /= '1') then
                    incr(r_head);
                end if;
            end if;
        end if;
    end process p_head;
    -- Read
    p_tail : process (clk)
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                r_tail     <= 0;
                o_rd_valid <= '0';
            else
                o_rd_valid <= '0';
                if (i_rd_en = '1') and (w_empty /= '1') then
                    incr(r_tail);
                    o_rd_valid <= '1';
                end if;
            end if;
        end if;
    end process p_tail;
    -- ===============================================================
    p_memory : process (clk)
    begin
        if rising_edge(clk) then
            r_FIFO_DATA(r_head) <= i_wr_data;
            o_rd_data           <= r_FIFO_DATA(r_tail);
        end if;
    end process p_memory;
    -- ===============================================================
    p_fill_count : process (r_head, r_tail)
    begin
        if (r_head < r_tail) then
            w_fill_count <= (r_head + G_DEPTH) - r_tail;
        else
            w_fill_count <= r_head - r_tail;
        end if;
    end process p_fill_count;
    -- ===============================================================
end architecture;
