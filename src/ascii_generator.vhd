library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sig_gen_pkg.all;

entity ascii_generator is
    port (
        clk_25 : in std_logic;
        -- From image gen
        i_counter_X : in unsigned(9 downto 0);
        i_counter_Y : in unsigned(9 downto 0);
        -- From FFT evaluator
        i_max_freq   : in unsigned(16 downto 0);
        i_capture_on : in std_logic;
        -- From Filters
        i_lpf_on     : in std_logic;
        i_lpf_cutoff : in unsigned(16 downto 0) := (others => '0');
        i_bpf_on     : in std_logic;
        i_bpf_cutoff : in unsigned(16 downto 0) := (others => '0');
        i_hpf_on     : in std_logic;
        i_hpf_cutoff : in unsigned(16 downto 0) := (others => '0');
        i_ema_on     : in std_logic;
        -- 
        o_glyph_active : out std_logic;
        o_video_red    : out std_logic_vector(7 downto 0);
        o_video_grn    : out std_logic_vector(7 downto 0);
        o_video_blu    : out std_logic_vector(7 downto 0)
    );
end entity ascii_generator;

architecture rtl of ascii_generator is
    ----------------------------------------------------
    signal w_col_count_div_1_2 : unsigned(8 downto 0);                            -- 80
    signal w_row_count_div_1_2 : unsigned(8 downto 0);                            -- 60
    signal w_col_addr          : std_logic_vector(2 downto 0) := (others => '0'); -- [0-7] X
    signal w_col_addr_1_8      : unsigned(2 downto 0)         := (others => '0'); -- 1:8 [0-7] X
    signal w_col_addr_1_8_half : unsigned(1 downto 0)         := (others => '0'); -- 1:8 [0-3] X
    signal w_row_addr          : unsigned(3 downto 0)         := (others => '0'); -- [0-15] Y
    signal r_draw              : std_logic                    := '0';
    signal r_draw_lpf          : std_logic                    := '0';
    signal r_draw_bpf          : std_logic                    := '0';
    signal r_draw_hpf          : std_logic                    := '0';
    signal r_draw_ema          : std_logic                    := '0';
    signal r_draw_capture      : std_logic                    := '0';
    signal r_draw_internal     : std_logic                    := '0';
    signal w_bit_index         : std_logic_vector(2 downto 0) := (others => '0');
    -- Variable frequency tilemaps
    signal r_tilemap_freq_max : t_tilemap_short              := (0, 0, 0, 0);
    signal r_tilemap_freq_lpf : t_tilemap_short              := (0, 0, 0, 0);
    signal r_tilemap_freq_bpf : t_tilemap_short              := (0, 0, 0, 0);
    signal r_tilemap_freq_hpf : t_tilemap_short              := (0, 0, 0, 0);
    signal r_font_line        : std_logic_vector(7 downto 0) := (others => '0');
begin
    --============================================================================
    --============================================================================
    -- 1:8 for indexing glyphs
    w_col_addr_1_8 <= i_counter_X(5 downto 3);
    -- 1:8 [0-3] for indexing short words
    w_col_addr_1_8_half <= i_counter_X(2 downto 1); -- Range: 0-8
    -- 1:2 Tile scaling
    w_col_addr          <= std_logic_vector(i_counter_X(2 downto 0)); -- Range: 0-8
    w_row_addr          <= i_counter_Y(3 downto 0);                   -- Range: 0-15
    w_col_count_div_1_2 <= unsigned(i_counter_X(i_counter_X'left downto 1));
    w_row_count_div_1_2 <= unsigned(i_counter_Y(i_counter_Y'left downto 1));
    --============================================================================
    --============================================================================
    p_word_fetcher : process (clk_25)
        variable v_tilemap_index : natural := 0;
    begin
        -- Operation
        -- 1. Acquire index from tilemap above
        -- 2. Acquire font line
        -- 3. Get bit (with bit reverse)
        if rising_edge(clk_25) then
            r_draw          <= '0';
            r_draw_lpf      <= '0';
            r_draw_bpf      <= '0';
            r_draw_hpf      <= '0';
            r_draw_ema      <= '0';
            r_draw_capture  <= '0';
            r_draw_internal <= '0';
            r_font_line     <= C_FONT_ROM(v_tilemap_index)(to_integer(unsigned(w_row_addr)));
            ------------------------------------------------------------------------------
            if (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < (C_WORD_X_LEFT + 8)) and
                (i_counter_Y >= 16) and (i_counter_Y < 31) then
                -- "CAPTURE"
                v_tilemap_index := C_TILEMAP_CAPTURE(to_integer(unsigned(w_col_addr_1_8)));
                r_draw_capture <= '1';
                ------------------------------------------------------------------------------
            elsif (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < (C_WORD_X_LEFT + 8)) and
                (i_counter_Y >= 64) and (i_counter_Y < 80) then
                -- "INTERNAL"
                v_tilemap_index := C_TILEMAP_INTERNAL(to_integer(unsigned(w_col_addr_1_8)));
                r_draw_internal <= '1';
                ------------------------------------------------------------------------------
            elsif (i_counter_Y >= 112) and (i_counter_Y < 128) then
                -- "MAX:" & "XX" & "KHZ"
                if (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < (C_WORD_X_LEFT + 4)) then
                    -- "MAX:"
                    v_tilemap_index := C_TILEMAP_MAX(to_integer(unsigned(w_col_addr_1_8_half)));
                    r_draw <= '1';
                elsif (i_counter_X >= C_WORD_X_LEFT + 4) and (i_counter_X < C_WORD_X_LEFT + 8) then
                    -- numbers
                    v_tilemap_index := r_tilemap_freq_max(to_integer(unsigned(w_col_addr_1_8_half)));
                    r_draw <= '1';
                elsif (i_counter_X >= C_WORD_X_LEFT + 8) and (i_counter_X < C_WORD_X_LEFT + 12) then
                    -- "KHZ"
                    v_tilemap_index := C_TILEMAP_KHZ(to_integer(unsigned(w_col_addr_1_8_half)));
                    r_draw <= '1';
                end if;
                ------------------------------------------------------------------------------
            elsif (i_counter_Y >= 160) and (i_counter_Y < 176) then
                -- "LPF:" & "XX" & "KHZ"
                if (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < (C_WORD_X_LEFT + 4)) then
                    -- "LPF:"
                    v_tilemap_index := C_TILEMAP_LPF(to_integer(unsigned(w_col_addr_1_8_half)));
                    r_draw_lpf <= '1';
                elsif (i_counter_X >= C_WORD_X_LEFT + 4) and (i_counter_X < C_WORD_X_LEFT + 8) then
                    -- numbers
                    v_tilemap_index := r_tilemap_freq_lpf(to_integer(unsigned(w_col_addr_1_8_half)));
                    r_draw_lpf <= '1';
                elsif (i_counter_X >= C_WORD_X_LEFT + 8) and (i_counter_X < C_WORD_X_LEFT + 12) then
                    -- "KHZ"
                    v_tilemap_index := C_TILEMAP_KHZ(to_integer(unsigned(w_col_addr_1_8_half)));
                    r_draw_lpf <= '1';
                end if;
                ------------------------------------------------------------------------------
            elsif (i_counter_Y >= 208) and (i_counter_Y < 224) then
                -- "BPF:" & "XX" & "KHZ"
                if (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < (C_WORD_X_LEFT + 4)) then
                    -- "LPF:"
                    v_tilemap_index := C_TILEMAP_BPF(to_integer(unsigned(w_col_addr_1_8_half)));
                    r_draw_bpf <= '1';
                elsif (i_counter_X >= C_WORD_X_LEFT + 4) and (i_counter_X < C_WORD_X_LEFT + 8) then
                    -- numbers
                    v_tilemap_index := r_tilemap_freq_bpf(to_integer(unsigned(w_col_addr_1_8_half)));
                    r_draw_bpf <= '1';
                elsif (i_counter_X >= C_WORD_X_LEFT + 8) and (i_counter_X < C_WORD_X_LEFT + 12) then
                    -- "KHZ"
                    v_tilemap_index := C_TILEMAP_KHZ(to_integer(unsigned(w_col_addr_1_8_half)));
                    r_draw_bpf <= '1';
                end if;
                ------------------------------------------------------------------------------
            elsif (i_counter_Y >= 256) and (i_counter_Y < 272) then
                -- "HPF:" & "XX" & " KHZ"
                if (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < (C_WORD_X_LEFT + 4)) then
                    -- "LPF:"
                    v_tilemap_index := C_TILEMAP_HPF(to_integer(unsigned(w_col_addr_1_8_half)));
                    r_draw_hpf <= '1';
                elsif (i_counter_X >= C_WORD_X_LEFT + 4) and (i_counter_X < C_WORD_X_LEFT + 8) then
                    -- numbers
                    v_tilemap_index := r_tilemap_freq_hpf(to_integer(unsigned(w_col_addr_1_8_half)));
                    r_draw_hpf <= '1';
                elsif (i_counter_X >= C_WORD_X_LEFT + 8) and (i_counter_X < C_WORD_X_LEFT + 12) then
                    -- "KHZ"
                    v_tilemap_index := C_TILEMAP_KHZ(to_integer(unsigned(w_col_addr_1_8_half)));
                    r_draw_hpf <= '1';
                end if;
                ------------------------------------------------------------------------------
            elsif (i_counter_Y >= 304) and (i_counter_Y < 320) and
                (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < C_WORD_X_LEFT + 4) then
                -- "EMA"
                v_tilemap_index := C_TILEMAP_EMA(to_integer(unsigned(w_col_addr_1_8_half)));
                r_draw_ema <= '1';
                ------------------------------------------------------------------------------
            elsif (i_counter_Y >= 336) and (i_counter_Y < 352) and
                (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < C_WORD_X_LEFT + 4) then
                -- "EMA"
                v_tilemap_index := C_TILEMAP_EMA(to_integer(unsigned(w_col_addr_1_8_half)));
                r_draw_ema <= '1';
                ------------------------------------------------------------------------------
            elsif (i_counter_Y >= 416) and (i_counter_Y < 432) and
                (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < C_WORD_X_LEFT + 8) then
                -- "CREATOR"
                v_tilemap_index := C_TILEMAP_CREATOR(to_integer(unsigned(w_col_addr_1_8_half)));
                r_draw <= '1';
                ------------------------------------------------------------------------------
            elsif (i_counter_Y >= 432) and (i_counter_Y < 448) and
                (i_counter_X >= C_WORD_X_LEFT) and (i_counter_X < C_WORD_X_LEFT + 8) then
                -- "LJOS"
                v_tilemap_index := C_TILEMAP_LJOS(to_integer(unsigned(w_col_addr_1_8_half)));
                r_draw <= '1';
                ------------------------------------------------------------------------------
            end if;
        end if;
    end process p_word_fetcher;
    --============================================================================
    --============================================================================
    p_freq_into_ascii : process (clk_25)
    begin
        if rising_edge(clk_25) then
            -- Max Frequency
            r_tilemap_freq_max(1) <= to_integer((i_max_freq / 10));
            r_tilemap_freq_max(2) <= to_integer(i_max_freq mod 10);
            -- LPF
            r_tilemap_freq_lpf(1) <= to_integer(i_lpf_cutoff / 10);
            r_tilemap_freq_lpf(2) <= to_integer(i_lpf_cutoff mod 10);
            -- BPF
            r_tilemap_freq_bpf(1) <= to_integer(i_bpf_cutoff / 10);
            r_tilemap_freq_bpf(2) <= to_integer(i_bpf_cutoff mod 10);
            -- HPF
            r_tilemap_freq_hpf(1) <= to_integer(i_hpf_cutoff / 10);
            r_tilemap_freq_hpf(2) <= to_integer(i_hpf_cutoff mod 10);
        end if;
    end process;
    --============================================================================
    --============================================================================
    p_output : process (clk_25)
    begin
        if rising_edge(clk_25) then
            o_video_red    <= (others => '0');
            o_video_grn    <= (others => '0');
            o_video_blu    <= (others => '0');
            o_glyph_active <= '0';
            if (r_draw = '1') then
                -- Note: the not() causes bit-reversion, i.e. 0-->7, 1-->6 and so on
                o_video_red    <= (others => (r_font_line(to_integer(unsigned(not(w_col_addr))))));
                o_video_grn    <= (others => (r_font_line(to_integer(unsigned(not(w_col_addr))))));
                o_video_blu    <= (others => (r_font_line(to_integer(unsigned(not(w_col_addr))))));
                o_glyph_active <= '1';
            elsif (r_draw_capture = '1') then
                if (r_font_line(to_integer(unsigned(not(w_col_addr)))) = '1') then
                    o_video_red <= (others => not(i_capture_on));
                    o_video_grn <= (others => not(i_capture_on));
                    o_video_blu <= (others => not(i_capture_on));
                elsif (i_capture_on = '1') then
                    o_video_red <= (others => '1');
                    o_video_grn <= (others => '1');
                    o_video_blu <= (others => '0');
                end if;
            elsif (r_draw_internal = '1') then
                if (r_font_line(to_integer(unsigned(not(w_col_addr)))) = '1') then
                    o_video_red <= (others => i_capture_on);
                    o_video_grn <= (others => i_capture_on);
                    o_video_blu <= (others => i_capture_on);
                elsif (i_capture_on = '0') then
                    o_video_red <= (others => '1');
                    o_video_grn <= (others => '1');
                    o_video_blu <= (others => '0');
                end if;
            elsif (r_draw_lpf = '1') then
                if (r_font_line(to_integer(unsigned(not(w_col_addr)))) = '1') then
                    o_video_red <= (others => not(i_lpf_on));
                    o_video_grn <= (others => not(i_lpf_on));
                    o_video_blu <= (others => not(i_lpf_on));
                elsif (i_lpf_on = '1') then
                    o_video_red <= (others => '1');
                    o_video_grn <= (others => '1');
                    o_video_blu <= (others => '0');
                end if;
            elsif (r_draw_bpf = '1') then
                if (r_font_line(to_integer(unsigned(not(w_col_addr)))) = '1') then
                    o_video_red <= (others => not(i_bpf_on));
                    o_video_grn <= (others => not(i_bpf_on));
                    o_video_blu <= (others => not(i_bpf_on));
                elsif (i_bpf_on = '1') then
                    o_video_red <= (others => '1');
                    o_video_grn <= (others => '1');
                    o_video_blu <= (others => '0');
                end if;
            elsif (r_draw_hpf = '1') then
                if (r_font_line(to_integer(unsigned(not(w_col_addr)))) = '1') then
                    o_video_red <= (others => not(i_hpf_on));
                    o_video_grn <= (others => not(i_hpf_on));
                    o_video_blu <= (others => not(i_hpf_on));
                elsif (i_hpf_on = '1') then
                    o_video_red <= (others => '1');
                    o_video_grn <= (others => '1');
                    o_video_blu <= (others => '0');
                end if;
            elsif (r_draw_ema = '1') then
                if (r_font_line(to_integer(unsigned(not(w_col_addr)))) = '1') then
                    o_video_red <= (others => not(i_ema_on));
                    o_video_grn <= (others => not(i_ema_on));
                    o_video_blu <= (others => not(i_ema_on));
                elsif (i_ema_on = '1') then
                    o_video_red <= (others => '1');
                    o_video_grn <= (others => '1');
                    o_video_blu <= (others => '0');
                end if;
            end if;
        end if;
    end process p_output;
    --============================================================================
    --============================================================================
end architecture;