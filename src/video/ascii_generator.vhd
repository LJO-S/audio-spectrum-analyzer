library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.project_common_pkg.all;

entity ascii_generator is
    port (
        clk_100 : in std_logic;
        -- Clk enable
        i_ce : in std_logic;
        -- From image gen
        i_counter_X : in unsigned(9 downto 0);
        i_counter_Y : in unsigned(9 downto 0);
        -- From FFT evaluator
        i_max_freq   : in unsigned(16 downto 0);
        i_capture_on : in std_logic;
        -- From Filters
        i_lpf_on     : in std_logic;
        i_lpf_cutoff : in unsigned(16 downto 0);
        i_hpf_on     : in std_logic;
        i_hpf_cutoff : in unsigned(16 downto 0);
        -- Misc
        i_waterfall_on      : in std_logic;
        i_oscilloscope_en   : in std_logic;
        i_decimation_factor : in std_logic_vector(1 downto 0);
        i_frequency_shift   : in std_logic_vector(15 downto 0);
        -- 
        o_freq_lpf_1000s : out unsigned(6 downto 0);
        o_freq_hpf_1000s : out unsigned(6 downto 0);
        -- 
        o_glyph_active : out std_logic;
        o_video_red    : out std_logic_vector(7 downto 0);
        o_video_grn    : out std_logic_vector(7 downto 0);
        o_video_blu    : out std_logic_vector(7 downto 0)
    );
end entity ascii_generator;

architecture rtl of ascii_generator is
    ----------------------------------------------------
    signal w_col_count_div_1_2   : unsigned(8 downto 0);                            -- 80
    signal w_row_count_div_1_2   : unsigned(8 downto 0);                            -- 60
    signal w_col_addr            : std_logic_vector(2 downto 0) := (others => '0'); -- [0-7] X
    signal r_col_addr            : std_logic_vector(2 downto 0) := (others => '0'); -- [0-7] X
    signal w_col_addr_1_8        : unsigned(2 downto 0)         := (others => '0'); -- 1:8 [0-7] X
    signal w_col_addr_1_8_half   : unsigned(1 downto 0)         := (others => '0'); -- 1:8 [0-3] X
    signal w_col_addr_1_8_eighth : unsigned(0 downto 0)         := (others => '0'); -- 1:8 [0-1] X
    signal w_col_addr_1_8_double : unsigned(3 downto 0)         := (others => '0'); -- 1:8 [0-15] X
    signal w_row_addr            : unsigned(3 downto 0)         := (others => '0'); -- [0-15] Y
    signal r_draw                : std_logic                    := '0';
    signal r_draw_lpf            : std_logic                    := '0';
    signal r_draw_zoom           : std_logic                    := '0';
    signal r_draw_hpf            : std_logic                    := '0';
    signal r_draw_waterfall      : std_logic                    := '0';
    signal r_draw_oscilloscope   : std_logic                    := '0';
    signal r_draw_capture        : std_logic                    := '0';
    signal r_draw_internal       : std_logic                    := '0';
    -- Variable frequency tilemaps
    signal r_tilemap_freq_max     : t_tilemap_short      := (37, 0, 0, 37);
    signal r_freq_max_1000s       : unsigned(6 downto 0) := (others => '0');
    signal r_tilemap_freq_lpf     : t_tilemap_short      := (37, 0, 0, 37);
    signal r_freq_lpf_1000s       : unsigned(6 downto 0) := (others => '0');
    signal r_tilemap_freq_hpf     : t_tilemap_short      := (37, 0, 0, 37);
    signal r_freq_hpf_1000s       : unsigned(6 downto 0) := (others => '0');
    signal r_tilemap_zoom         : t_tilemap_long       := (36, 25, 25, 23, 10, 37, 37, 37); -- "ZOOM:   "
    signal r_freq_shift_khz       : unsigned(4 downto 0) := (others => '0');
    signal r_tick_base_khz        : unsigned(5 downto 0) := (others => '0');
    signal r_t1, r_t2, r_t3, r_t4 : unsigned(5 downto 0) := (others => '0');
    signal r_tilemap_tick_1       : t_tilemap_minimal    := (37, 5);
    signal r_tilemap_tick_2       : t_tilemap_minimal    := (1, 0);
    signal r_tilemap_tick_3       : t_tilemap_minimal    := (1, 5);
    signal r_tilemap_tick_4       : t_tilemap_minimal    := (2, 0);

    signal r_font_line : std_logic_vector(7 downto 0) := (others => '0');
begin
    --============================================================================
    --============================================================================
    -- 1:8 for indexing glyphs
    w_col_addr_1_8 <= i_counter_X(5 downto 3); -- Range: 0-7
    -- 1:8 [0-3] for indexing short words
    w_col_addr_1_8_double <= i_counter_X(6 downto 3); -- Range: 0-15
    w_col_addr_1_8_half   <= i_counter_X(4 downto 3); -- Range: 0-3
    w_col_addr_1_8_eighth <= i_counter_X(3 downto 3); -- Range: 0-1
    -- 1:2 Tile scaling
    w_col_addr          <= std_logic_vector(i_counter_X(2 downto 0)); -- Range: 0-8
    w_row_addr          <= i_counter_Y(3 downto 0);                   -- Range: 0-15
    w_col_count_div_1_2 <= unsigned(i_counter_X(i_counter_X'left downto 1));
    w_row_count_div_1_2 <= unsigned(i_counter_Y(i_counter_Y'left downto 1));
    --============================================================================
    --============================================================================
    p_word_fetcher : process (clk_100)
        variable v_tilemap_index : natural := 0;
    begin
        -- Operation
        -- 1. Acquire index from tilemap above
        -- 2. Acquire font line
        -- 3. Get bit (with bit reverse)
        if rising_edge(clk_100) then
            if (i_ce = '1') then
                r_draw              <= '0';
                r_draw_lpf          <= '0';
                r_draw_zoom         <= '0';
                r_draw_hpf          <= '0';
                r_draw_oscilloscope <= '0';
                r_draw_waterfall    <= '0';
                r_draw_capture      <= '0';
                r_draw_internal     <= '0';
                ------------------------------------------------------------------------------
                if (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < (C_WORD_X_LEFT + 64)) and
                    (i_counter_Y >= 16) and (i_counter_Y < 32) then
                    -- "CAPTURE"
                    v_tilemap_index := C_TILEMAP_CAPTURE(to_integer(unsigned(w_col_addr_1_8)));
                    r_draw_capture <= '1';
                    ------------------------------------------------------------------------------
                elsif (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < (C_WORD_X_LEFT + 64)) and
                    (i_counter_Y >= 64) and (i_counter_Y < 80) then
                    -- "INTERNAL"
                    v_tilemap_index := C_TILEMAP_INTERNAL(to_integer(unsigned(w_col_addr_1_8)));
                    r_draw_internal <= '1';
                    ------------------------------------------------------------------------------
                elsif (i_counter_Y >= 112) and (i_counter_Y < 128) then
                    -- "MAX:" & "XX" & "KHZ"
                    if (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < (C_WORD_X_LEFT + 32)) then
                        -- "MAX:"
                        v_tilemap_index := C_TILEMAP_MAX(to_integer(unsigned(w_col_addr_1_8_half)));
                        r_draw <= '1';
                    elsif (i_counter_X >= C_WORD_X_LEFT + 32) and (i_counter_X < C_WORD_X_LEFT + 64) then
                        -- numbers
                        v_tilemap_index := r_tilemap_freq_max(to_integer(unsigned(w_col_addr_1_8_half)));
                        r_draw <= '1';
                    elsif (i_counter_X >= C_WORD_X_LEFT + 64) and (i_counter_X < C_WORD_X_LEFT + 96) then
                        -- "KHZ"
                        v_tilemap_index := C_TILEMAP_KHZ(to_integer(unsigned(w_col_addr_1_8_half)));
                        r_draw <= '1';
                    end if;
                    ------------------------------------------------------------------------------
                elsif (i_counter_Y >= 160) and (i_counter_Y < 176) then
                    -- "LPF:" & "XX" & "KHZ"
                    if (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < (C_WORD_X_LEFT + 32)) then
                        -- "LPF:"
                        v_tilemap_index := C_TILEMAP_LPF(to_integer(unsigned(w_col_addr_1_8_half)));
                        r_draw_lpf <= '1';
                    elsif (i_counter_X >= C_WORD_X_LEFT + 32) and (i_counter_X < C_WORD_X_LEFT + 64) then
                        -- numbers
                        v_tilemap_index := r_tilemap_freq_lpf(to_integer(unsigned(w_col_addr_1_8_half)));
                        r_draw_lpf <= '1';
                    elsif (i_counter_X >= C_WORD_X_LEFT + 64) and (i_counter_X < C_WORD_X_LEFT + 96) then
                        -- "KHZ"
                        v_tilemap_index := C_TILEMAP_KHZ(to_integer(unsigned(w_col_addr_1_8_half)));
                        r_draw_lpf <= '1';
                    end if;
                    ------------------------------------------------------------------------------
                elsif (i_counter_Y >= 208) and (i_counter_Y < 224) then
                    -- "HPF:" & "XX" & " KHZ"
                    if (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < (C_WORD_X_LEFT + 32)) then
                        -- "HPF:"
                        v_tilemap_index := C_TILEMAP_HPF(to_integer(unsigned(w_col_addr_1_8_half)));
                        r_draw_hpf <= '1';
                    elsif (i_counter_X >= C_WORD_X_LEFT + 32) and (i_counter_X < C_WORD_X_LEFT + 64) then
                        -- numbers
                        v_tilemap_index := r_tilemap_freq_hpf(to_integer(unsigned(w_col_addr_1_8_half)));
                        r_draw_hpf <= '1';
                    elsif (i_counter_X >= C_WORD_X_LEFT + 64) and (i_counter_X < C_WORD_X_LEFT + 96) then
                        -- "KHZ"
                        v_tilemap_index := C_TILEMAP_KHZ(to_integer(unsigned(w_col_addr_1_8_half)));
                        r_draw_hpf <= '1';
                    end if;
                    ------------------------------------------------------------------------------
                elsif (i_counter_Y >= 256) and (i_counter_Y < 272) and
                    (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < (C_WORD_X_LEFT + 64)) then
                    -- ZOOM: <none>/2X /4X
                    v_tilemap_index := r_tilemap_zoom(to_integer(unsigned(w_col_addr_1_8)));
                    r_draw_zoom <= '1';
                    ------------------------------------------------------------------------------
                elsif (i_counter_Y >= 304) and (i_counter_Y < 320) and
                    (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < C_WORD_X_LEFT + 72) then
                    -- "WATERFALL"
                    v_tilemap_index := C_TILEMAP_WATERFALL(to_integer(unsigned(w_col_addr_1_8_double)));
                    r_draw_waterfall <= '1';
                    ------------------------------------------------------------------------------
                elsif (i_counter_Y >= 336) and (i_counter_Y < 352) and
                    (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < C_WORD_X_LEFT + 56) then
                    -- "O-SCOPE"
                    v_tilemap_index := C_TILEMAP_OSCILLOSCOPE(to_integer(unsigned(w_col_addr_1_8_double)));
                    r_draw_oscilloscope <= '1';
                    ------------------------------------------------------------------------------
                elsif (i_counter_Y >= 416) and (i_counter_Y < 432) and
                    (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < C_WORD_X_LEFT + 64) then
                    -- "CREATOR"
                    v_tilemap_index := C_TILEMAP_CREATOR(to_integer(unsigned(w_col_addr_1_8)));
                    r_draw <= '1';
                    ------------------------------------------------------------------------------
                elsif (i_counter_Y >= 416) and (i_counter_Y < 432) then
                    -- Ticks
                    if (i_counter_X >= 96) and (i_counter_X < 112) then
                        -- "10:"
                        v_tilemap_index := r_tilemap_tick_1(to_integer(unsigned(w_col_addr_1_8_eighth)));
                        r_draw <= '1';
                    elsif (i_counter_X >= 208) and (i_counter_X < 224) then
                        -- "20"
                        v_tilemap_index := r_tilemap_tick_2(to_integer(unsigned(w_col_addr_1_8_eighth)));
                        r_draw <= '1';
                    elsif (i_counter_X >= 312) and (i_counter_X < 328) then
                        -- "30"
                        v_tilemap_index := r_tilemap_tick_3(to_integer(unsigned(w_col_addr_1_8_eighth)));
                        r_draw <= '1';
                    elsif (i_counter_X >= 416) and (i_counter_X < 432) then
                        -- "40"
                        v_tilemap_index := r_tilemap_tick_4(to_integer(unsigned(w_col_addr_1_8_eighth)));
                        r_draw <= '1';
                    end if;
                elsif (i_counter_Y >= 432) and (i_counter_Y < 448) and
                    (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < C_WORD_X_LEFT + 32) then
                    -- "LJOS"
                    v_tilemap_index := C_TILEMAP_LJOS(to_integer(unsigned(w_col_addr_1_8_half)));
                    r_draw <= '1';
                    ------------------------------------------------------------------------------
                end if;
                r_font_line <= C_FONT_ROM(v_tilemap_index)(to_integer(unsigned(w_row_addr)));
            end if;
        end if;
    end process p_word_fetcher;
    --============================================================================
    --============================================================================
    p_pipeline : process (clk_100)
    begin
        if rising_edge(clk_100) then
            if (i_ce = '1') then
                r_col_addr <= w_col_addr;
            end if;
        end if;
    end process p_pipeline;
    --============================================================================
    --============================================================================
    p_dynamic_ascii : process (clk_100)
    begin
        if rising_edge(clk_100) then
            -- "Division by 1000"
            -- x/1000 ~= x/1024 + x/32768 = x>>10 + x>>15
            -- But our input frequencies are usually bounded by 25 kHz, then following approximation is better:
            -- x/1000 ~= x/1024 + x/16384 = x>>10 + x>>14

            -- ------------------
            -- Max Frequency
            -- ------------------
            r_freq_max_1000s      <= i_max_freq(i_max_freq'high downto 10) + i_max_freq(i_max_freq'high downto 15) + 1;
            r_tilemap_freq_max(1) <= to_integer(r_freq_max_1000s / 10);
            r_tilemap_freq_max(2) <= to_integer(r_freq_max_1000s mod 10);
            -- ------------------
            -- LPF
            -- ------------------
            r_freq_lpf_1000s      <= i_lpf_cutoff(i_lpf_cutoff'high downto 10) + i_lpf_cutoff(i_lpf_cutoff'high downto 15) + 1;
            r_tilemap_freq_lpf(1) <= to_integer(r_freq_lpf_1000s / 10);
            r_tilemap_freq_lpf(2) <= to_integer(r_freq_lpf_1000s mod 10);
            -- ------------------
            -- HPF
            -- ------------------
            r_freq_hpf_1000s      <= i_hpf_cutoff(i_hpf_cutoff'high downto 10) + i_hpf_cutoff(i_hpf_cutoff'high downto 15) + 1;
            r_tilemap_freq_hpf(1) <= to_integer(r_freq_hpf_1000s / 10);
            r_tilemap_freq_hpf(2) <= to_integer(r_freq_hpf_1000s mod 10);
            -- ------------------
            -- ZOOM
            -- ------------------
            -- Frequency Shift
            if (i_frequency_shift(i_frequency_shift'high) /= '1') then
                r_freq_shift_khz <= unsigned(i_frequency_shift(i_frequency_shift'high - 1 downto 10)) + 1;
            else
                r_freq_shift_khz <= (others => '0');
            end if;
            -- Decimation Factor
            case i_decimation_factor is
                when "01" =>
                    r_tilemap_zoom(5 to 7) <= (37, 2, 34);
                    r_tick_base_khz <= resize(r_freq_shift_khz, r_tick_base_khz'length);
                    r_t1            <= r_tick_base_khz + 2;
                    r_t2            <= r_tick_base_khz + 4;
                    r_t3            <= r_tick_base_khz + 6;
                    r_t4            <= r_tick_base_khz + 8;
                when "10" =>
                    r_tilemap_zoom(5 to 7) <= (37, 4, 34);
                    r_tick_base_khz <= resize(r_freq_shift_khz, r_tick_base_khz'length);
                    r_t1            <= r_tick_base_khz + 1;
                    r_t2            <= r_tick_base_khz + 2;
                    r_t3            <= r_tick_base_khz + 3;
                    r_t4            <= r_tick_base_khz + 4;
                when others =>
                    r_tilemap_zoom(5 to 7) <= (37, 37, 37);
                    r_t1 <= to_unsigned(5, r_t1'length);
                    r_t2 <= to_unsigned(10, r_t2'length);
                    r_t3 <= to_unsigned(15, r_t3'length);
                    r_t4 <= to_unsigned(20, r_t4'length);
            end case;
            if (r_t1 < 10) then
                r_tilemap_tick_1(0) <= 37;
            else
                r_tilemap_tick_1(0) <= to_integer(r_t1 / 10);
            end if;
            if (r_t2 < 10) then
                r_tilemap_tick_2(0) <= 37;
            else
                r_tilemap_tick_2(0) <= to_integer(r_t2 / 10);
            end if;
            if (r_t3 < 10) then
                r_tilemap_tick_3(0) <= 37;
            else
                r_tilemap_tick_3(0) <= to_integer(r_t3 / 10);
            end if;
            if (r_t4 < 10) then
                r_tilemap_tick_4(0) <= 37;
            else
                r_tilemap_tick_4(0) <= to_integer(r_t4 / 10);
            end if;
            r_tilemap_tick_1(1) <= to_integer(r_t1 mod 10);
            r_tilemap_tick_2(1) <= to_integer(r_t2 mod 10);
            r_tilemap_tick_3(1) <= to_integer(r_t3 mod 10);
            r_tilemap_tick_4(1) <= to_integer(r_t4 mod 10);
        end if;
    end process p_dynamic_ascii;
    o_freq_lpf_1000s <= r_freq_lpf_1000s;
    o_freq_hpf_1000s <= r_freq_hpf_1000s;
    --============================================================================
    --============================================================================
    p_output : process (clk_100)
    begin
        if rising_edge(clk_100) then
            if (i_ce = '1') then
                o_video_red    <= (others => '0');
                o_video_grn    <= (others => '0');
                o_video_blu    <= (others => '0');
                o_glyph_active <= (
                    r_draw or
                    r_draw_capture or
                    r_draw_internal or
                    r_draw_lpf or
                    r_draw_zoom or
                    r_draw_hpf or
                    r_draw_waterfall or
                    r_draw_oscilloscope);
                if (r_draw = '1') then
                    -- Note: the not() causes bit-reversion, i.e. 0-->7, 1-->6 and so on
                    o_video_red <= (others => (r_font_line(to_integer(unsigned(not(r_col_addr))))));
                    o_video_grn <= (others => (r_font_line(to_integer(unsigned(not(r_col_addr))))));
                    o_video_blu <= (others => (r_font_line(to_integer(unsigned(not(r_col_addr))))));
                elsif (r_draw_capture = '1') then
                    if (r_font_line(to_integer(unsigned(not(r_col_addr)))) = '1') then
                        -- Not causes white/black text depending on if ON/OFF
                        o_video_red <= (others => not(i_capture_on));
                        o_video_grn <= (others => not(i_capture_on));
                        o_video_blu <= (others => not(i_capture_on));
                    elsif (i_capture_on = '1') then
                        -- If ON, the background should we yellow
                        o_video_red <= (others => '1');
                        o_video_grn <= (others => '1');
                        o_video_blu <= (others => '0');
                    end if;
                elsif (r_draw_internal = '1') then
                    if (r_font_line(to_integer(unsigned(not(r_col_addr)))) = '1') then
                        o_video_red <= (others => i_capture_on);
                        o_video_grn <= (others => i_capture_on);
                        o_video_blu <= (others => i_capture_on);
                    elsif (i_capture_on = '0') then
                        o_video_red <= (others => '1');
                        o_video_grn <= (others => '1');
                        o_video_blu <= (others => '0');
                    end if;
                elsif (r_draw_lpf = '1') then
                    if (r_font_line(to_integer(unsigned(not(r_col_addr)))) = '1') then
                        o_video_red <= (others => not(i_lpf_on));
                        o_video_grn <= (others => not(i_lpf_on));
                        o_video_blu <= (others => not(i_lpf_on));
                    elsif (i_lpf_on = '1') then
                        o_video_red <= (others => '1');
                        o_video_grn <= (others => '1');
                        o_video_blu <= (others => '0');
                    end if;
                elsif (r_draw_zoom = '1') then
                    if (r_font_line(to_integer(unsigned(not(r_col_addr)))) = '1') then
                        o_video_red <= (others => or(i_decimation_factor));
                        o_video_grn <= (others => or(i_decimation_factor));
                        o_video_blu <= (others => or(i_decimation_factor));
                    elsif ( or (i_decimation_factor) = '1') then
                        o_video_red <= (others => '1');
                        o_video_grn <= (others => '1');
                        o_video_blu <= (others => '0');
                    end if;
                elsif (r_draw_hpf = '1') then
                    if (r_font_line(to_integer(unsigned(not(r_col_addr)))) = '1') then
                        o_video_red <= (others => not(i_hpf_on));
                        o_video_grn <= (others => not(i_hpf_on));
                        o_video_blu <= (others => not(i_hpf_on));
                    elsif (i_hpf_on = '1') then
                        o_video_red <= (others => '1');
                        o_video_grn <= (others => '1');
                        o_video_blu <= (others => '0');
                    end if;
                elsif (r_draw_waterfall = '1') then
                    if (r_font_line(to_integer(unsigned(not(r_col_addr)))) = '1') then
                        o_video_red <= (others => not(i_waterfall_on));
                        o_video_grn <= (others => not(i_waterfall_on));
                        o_video_blu <= (others => not(i_waterfall_on));
                    elsif (i_waterfall_on = '1') then
                        o_video_red <= (others => '1');
                        o_video_grn <= (others => '1');
                        o_video_blu <= (others => '0');
                    end if;
                elsif (r_draw_oscilloscope = '1') then
                    if (r_font_line(to_integer(unsigned(not(r_col_addr)))) = '1') then
                        o_video_red <= (others => not(i_oscilloscope_en));
                        o_video_grn <= (others => not(i_oscilloscope_en));
                        o_video_blu <= (others => not(i_oscilloscope_en));
                    elsif (i_oscilloscope_en = '1') then
                        o_video_red <= (others => '1');
                        o_video_grn <= (others => '1');
                        o_video_blu <= (others => '0');
                    end if;
                end if;
            end if;
        end if;
    end process p_output;
    --============================================================================
    --============================================================================
end architecture;