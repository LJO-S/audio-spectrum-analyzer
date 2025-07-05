library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sig_gen_pkg.all;

-- TODO no tile scaling for text!!!

entity ascii_table is
    port (
        clk_25 : in std_logic;
        -- From image gen
        i_counter_X : in std_logic_vector(9 downto 0);
        i_counter_Y : in std_logic_vector(9 downto 0);
        -- From FFT evaluator
        i_max_freq : in unsigned(16 downto 0);
        -- From Filters
        i_lpf_cutoff : in unsigned(16 downto 0) := (others => '0');
        i_bpf_cutoff : in unsigned(16 downto 0) := (others => '0');
        i_hpf_cutoff : in unsigned(16 downto 0) := (others => '0');
        -- 
        o_glyph_active : out std_logic;
        o_video_red    : out std_logic_vector(7 downto 0);
        o_video_grn    : out std_logic_vector(7 downto 0);
        o_video_blu    : out std_logic_vector(7 downto 0)
    );
end entity ascii_table;

architecture rtl of ascii_table is
    ----------------------------------------------------
    signal w_col_count_div_1_2 : unsigned(8 downto 0);                            -- 80
    signal w_row_count_div_1_2 : unsigned(8 downto 0);                            -- 60
    signal w_col_addr_1_2      : std_logic_vector(2 downto 0) := (others => '0'); -- 0-7 X
    signal r_col_addr_1_2_d0   : std_logic_vector(2 downto 0) := (others => '0'); -- 0-7 X
    signal r_col_addr_1_2_d1   : std_logic_vector(2 downto 0) := (others => '0'); -- 0-7 X
    signal w_row_addr_1_2      : std_logic_vector(3 downto 0) := (others => '0'); -- 0-15 Y
    signal r_draw              : std_logic                    := '0';
    signal w_bit_index         : std_logic_vector(2 downto 0) := (others => '0');
begin
    -- 1:2:8 = 1:16 tile scaling to acquire which letter is currently active
    w_letter_index <= i_counter_X(5 downto 3);
    -- 1:2 Tile scaling
    w_col_addr_1_2      <= i_counter_X(3 downto 1); -- Range: 0-8
    w_row_addr_1_2      <= i_counter_Y(4 downto 1); -- Range: 0-15
    w_col_count_div_1_2 <= unsigned(i_counter_X(i_counter_X'left downto 1));
    w_row_count_div_1_2 <= unsigned(i_counter_Y(i_counter_Y'left downto 1));
    --------------------------------------------------------------------

    p_word_fetcher : process (clk_25)
        variable v_tilemap_index : natural := 0;
    begin
        -- Operation
        -- 1. Acquire index from tilemap above
        -- 2. Acquire font line
        -- 3. Get bit (with bit reverse)
        if rising_edge(clk_25) then
            r_draw <= '0';
            ------------------------------------------------------------------------------
            if (w_col_count_div_1_2 >= C_LONG_X_LEFT) and (w_col_count_div_1_2 <= C_LONG_X_RIGHT) and
                (w_row_count_div_1_2 >= 8) and (w_row_count_div_1_2                <= 16) then
                -- "CAPTURE"

                -- 0-7
                v_tilemap_index := C_TILEMAP_CAPTURE(to_integer(unsigned(w_letter_index)));

                r_font_line <= C_FONT_ROM(v_tilemap_index)(to_integer(unsigned(w_row_addr_1_2)));
                r_draw      <= '1';
                ------------------------------------------------------------------------------
            elsif (w_col_count_div_1_2 > C_LONG_X_LEFT) and (w_col_count_div_1_2 < C_LONG_X_RIGHT) and
                (w_row_count_div_1_2 > 32) and (w_row_count_div_1_2 < 40) then
                -- "INTERNAL"
                ------------------------------------------------------------------------------
            elsif (w_row_count_div_1_2 > 56) and (w_row_count_div_1_2 < 64) then
                -- "MAX @" & "XX KHZ" todo
                if (w_col_count_div_1_2 > XXX) and (w_col_count_div_1_2 < XXX) then
                    -- "MAX @"
                elsif (w_col_count_div_1_2 > XXX) and (w_col_count_div_1_2 < XXX) then
                    -- "XX KHZ"
                    -- todo need logic for chaning tilemap
                end if;
                ------------------------------------------------------------------------------
            elsif (w_row_count_div_1_2 > 80) and (w_row_count_div_1_2 < 88) then
                -- "LPF @" & "XX KHZ" todo
                if (w_col_count_div_1_2 > XXX) and (w_col_count_div_1_2 < XXX) then
                    -- "LPF @"
                elsif (w_col_count_div_1_2 > XXX) and (w_col_count_div_1_2 < XXX) then
                    -- "XX KHZ"
                    -- todo need logic for chaning tilemap
                end if;
                ------------------------------------------------------------------------------
            elsif (w_row_count_div_1_2 > 104) and (w_row_count_div_1_2 < 112) then
                -- "BPF @" & "XX KHZ" todo
                if (w_col_count_div_1_2 > XXX) and (w_col_count_div_1_2 < XXX) then
                    -- "BPF @"
                elsif (w_col_count_div_1_2 > XXX) and (w_col_count_div_1_2 < XXX) then
                    -- "XX KHZ"
                    -- todo need logic for chaning tilemap
                end if;
                ------------------------------------------------------------------------------
            elsif (w_row_count_div_1_2 > 128) and (w_row_count_div_1_2 < 136) then
                -- "HPF @" & "XX KHZ" todo
                if (w_col_count_div_1_2 > XXX) and (w_col_count_div_1_2 < XXX) then
                    -- "HPF @"
                elsif (w_col_count_div_1_2 > XXX) and (w_col_count_div_1_2 < XXX) then
                    -- "XX KHZ"
                    -- todo need logic for chaning tilemap
                end if;
                ------------------------------------------------------------------------------
            elsif (w_col_count_div_1_2 >) and (w_col_count_div_1_2 <) and
                (w_row_count_div_1_2 > 152) and (w_row_count_div_1_2 < 160) then
                -- "EMA"
                ------------------------------------------------------------------------------
            elsif (w_col_count_div_1_2 >) and (w_col_count_div_1_2 <) and
                (w_row_count_div_1_2 > 176) and (w_row_count_div_1_2 < 184) then
                -- "EMA"
                ------------------------------------------------------------------------------
            elsif (w_col_count_div_1_2 >) and (w_col_count_div_1_2 <) and
                (w_row_count_div_1_2 > 208) and (w_row_count_div_1_2 < 216) then
                -- "Author"
                ------------------------------------------------------------------------------
            elsif (w_col_count_div_1_2 >) and (w_col_count_div_1_2 <) and
                (w_row_count_div_1_2 > 232) and (w_row_count_div_1_2 < 240) then
                -- "LJO-S"
                ------------------------------------------------------------------------------
            end if;
        end if;
    end process p_word_fetcher;

    p_output : process (clk_25)
    begin
        if rising_edge(clk_25) then
            o_video_red    <= (others => '0');
            o_video_grn    <= (others => '0');
            o_video_blu    <= (others => '0');
            o_glyph_active <= '0';
            if (r_draw = '1') and (r_font_line(not w_col_addr_1_2)) then
                o_video_red    <= (others => '1');
                o_video_grn    <= (others => '1');
                o_video_blu    <= (others => '1');
                o_glyph_active <= '1';
            end if;
        end if;
    end process p_output;

end architecture;