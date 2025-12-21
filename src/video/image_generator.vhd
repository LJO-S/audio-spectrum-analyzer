library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sig_gen_pkg.all;

entity image_generator is
    port (
        clk_100 : in std_logic;
        i_ce    : in std_logic;
        -- Compare values
        i_compare_limit      : in unsigned(31 downto 0);
        i_compare_subtractor : in unsigned(31 downto 0);
        -- Frame Buffer memory
        i_fft_data_log    : in std_logic_vector(7 downto 0);
        i_fft_data_linear : in std_logic_vector(31 downto 0);
        o_rd_addr_X       : out std_logic_vector(9 downto 0);
        o_rd_addr_Y       : out std_logic_vector(9 downto 0);
        -- GUI data
        i_100ms_strb   : in std_logic;
        i_capture_on   : in std_logic;
        i_lpf_on       : in std_logic;
        i_lpf_incr     : in std_logic;
        i_lpf_decr     : in std_logic;
        i_bpf_on       : in std_logic;
        i_bpf_cutoff   : in unsigned(16 downto 0) := (others => '0');
        i_hpf_on       : in std_logic;
        i_hpf_incr     : in std_logic;
        i_hpf_decr     : in std_logic;
        i_waterfall_on : in std_logic;
        i_ema_on       : in std_logic;
        -- TMDS
        o_HSYNC : out std_logic;
        o_VSYNC : out std_logic;
        -- Drawing
        o_draw      : out std_logic;
        o_video_red : out std_logic_vector(7 downto 0);
        o_video_grn : out std_logic_vector(7 downto 0);
        o_video_blu : out std_logic_vector(7 downto 0)
    );
end entity image_generator;

architecture rtl of image_generator is

    -- Drawing
    signal r_counter_X : UNSIGNED(9 downto 0) := (others => '0');
    signal r_counter_Y : UNSIGNED(9 downto 0) := (others => '0');
    signal r_HSYNC     : std_logic            := '0';
    signal r_VSYNC     : std_logic            := '0';
    signal r_draw      : std_logic            := '0';

    -- Input data
    signal r_fft_data_log    : std_logic_vector(7 downto 0)  := (others => '0');
    signal r_fft_data_linear : std_logic_vector(31 downto 0) := (others => '0');

    -- Pipeline
    signal r_counter_X_d1 : UNSIGNED(9 downto 0) := (others => '0');
    signal r_counter_Y_d1 : UNSIGNED(9 downto 0) := (others => '0');
    signal r_HSYNC_d1     : std_logic            := '0';
    signal r_VSYNC_d1     : std_logic            := '0';
    signal r_draw_d1      : std_logic            := '0';
    signal r_counter_X_d2 : UNSIGNED(9 downto 0) := (others => '0');
    signal r_counter_Y_d2 : UNSIGNED(9 downto 0) := (others => '0');
    signal r_HSYNC_d2     : std_logic            := '0';
    signal r_VSYNC_d2     : std_logic            := '0';
    signal r_draw_d2      : std_logic            := '0';

    -- Spectrum Signals
    signal r_compare_value      : unsigned(31 downto 0) := TO_UNSIGNED(C_INTERNAL_COMP_LIMIT, 32);
    signal r_draw_spectrum      : std_logic             := '0';
    signal w_video_red_spectrum : std_logic_vector(7 downto 0);
    signal w_video_grn_spectrum : std_logic_vector(7 downto 0);
    signal w_video_blu_spectrum : std_logic_vector(7 downto 0);
    signal r_video_red_spectrum : std_logic_vector(7 downto 0);
    signal r_video_grn_spectrum : std_logic_vector(7 downto 0);
    signal r_video_blu_spectrum : std_logic_vector(7 downto 0);
    signal r_curr_freq          : unsigned(16 downto 0) := (others => '0');
    signal r_max_freq           : unsigned(16 downto 0) := (others => '0');
    signal r_max_value          : unsigned(31 downto 0) := (others => '0');

    -- Filter Signals
    signal r_lpf_cutoff     : unsigned(16 downto 0) := to_unsigned(10_000, 17);
    signal r_hpf_cutoff     : unsigned(16 downto 0) := to_unsigned(10_000, 17);
    signal w_freq_lpf_1000s : unsigned(6 downto 0);
    signal w_freq_hpf_1000s : unsigned(6 downto 0);
    signal r_lpf_x_axis     : unsigned(9 downto 0) := (others => '0');
    signal r_hpf_x_axis     : unsigned(9 downto 0) := (others => '0');

    -- GUI
    signal w_ascii_draw      : std_logic;
    signal w_video_red_ascii : std_logic_vector(7 downto 0);
    signal w_video_grn_ascii : std_logic_vector(7 downto 0);
    signal w_video_blu_ascii : std_logic_vector(7 downto 0);

    signal r_gui_draw      : std_logic;
    signal r_video_red_gui : std_logic_vector(7 downto 0);
    signal r_video_grn_gui : std_logic_vector(7 downto 0);
    signal r_video_blu_gui : std_logic_vector(7 downto 0);
    -- Line draw
    -- We have a 640x480p image. Count 800x525p. Copy-pasted from previous project
    -- Bins/columns 0-512 --> 0-48 kHz. Columns 513-640 are left as freeplay (such as capture/internal). 
begin
    --*****************************************************************************
    -- Concurrent assignments 
    o_draw      <= r_draw_d2;
    o_HSYNC     <= r_HSYNC_d2;
    o_VSYNC     <= r_VSYNC_d2;
    o_rd_addr_X <= std_logic_vector(r_counter_X);
    o_rd_addr_Y <= std_logic_vector(r_counter_Y);
    --*****************************************************************************
    p_output_mux : process (all)
    begin
        o_video_red <= (others => '0');
        o_video_grn <= (others => '0');
        o_video_blu <= (others => '0');
        if (r_gui_draw = '1') then
            o_video_red <= r_video_red_gui;
            o_video_grn <= r_video_grn_gui;
            o_video_blu <= r_video_blu_gui;
        elsif (r_draw_spectrum = '1') then
            o_video_red <= r_video_red_spectrum;
            o_video_grn <= r_video_grn_spectrum;
            o_video_blu <= r_video_blu_spectrum;
        elsif (w_ascii_draw = '1') then
            o_video_red <= w_video_red_ascii;
            o_video_grn <= w_video_grn_ascii;
            o_video_blu <= w_video_blu_ascii;
        end if;
    end process p_output_mux;
    --*****************************************************************************
    p_pipeline : process (clk_100)
    begin
        if rising_edge(clk_100) then

            if (i_ce = '1') then
                -- ------------
                -- PIPE 1
                -- ------------
                r_counter_X_d1 <= r_counter_X;
                r_counter_Y_d1 <= r_counter_Y;
                r_HSYNC_d1     <= r_HSYNC;
                r_VSYNC_d1     <= r_VSYNC;
                r_draw_d1      <= r_draw;

                -- ------------
                -- PIPE 2
                -- ------------
                -- RD_addr to RD_data (framebuf): 4cc
                -- RD_data via log2lin: 3cc (say 4cc)
                r_counter_X_d2    <= r_counter_X_d1;
                r_counter_Y_d2    <= r_counter_Y_d1;
                r_HSYNC_d2        <= r_HSYNC_d1;
                r_VSYNC_d2        <= r_VSYNC_d1;
                r_draw_d2         <= r_draw_d1;
                r_fft_data_log    <= i_fft_data_log;
                r_fft_data_linear <= i_fft_data_linear;
            end if;
        end if;
    end process p_pipeline;
    --*****************************************************************************
    p_video_draw : process (clk_100)
    begin
        if rising_edge(clk_100) then
            if (i_ce = '1') then
                if (r_counter_X = 799) then
                    r_counter_X <= (others => '0');
                    if (r_counter_Y = 524) then
                        r_counter_Y <= (others => '0');
                    else
                        r_counter_Y <= r_counter_Y + 1;
                    end if;
                else
                    r_counter_X <= r_counter_X + 1;
                end if;

                if (r_counter_X < 640) and (r_counter_Y < 480) then
                    r_draw <= '1';
                else
                    r_draw <= '0';
                end if;

                -- Note: these are inverted compared to VGA HS/VS signals
                -- A HI signal notifies the TMDS_encoder that we're syncing
                -- (instead of turning off the electron beam in a CRT monitor)
                r_HSYNC <= '1' when ((r_counter_X >= 656) and (r_counter_X < 752)) else
                    '0';
                r_VSYNC <= '1' when ((r_counter_Y >= 490) and (r_counter_Y < 492)) else
                    '0';
            end if;
        end if;
    end process p_video_draw;
    --*****************************************************************************
    p_update_cutoffs : process (clk_100)
    begin
        if rising_edge(clk_100) then
            -- LPF
            if (i_lpf_incr = '1') and (r_lpf_cutoff < C_MAX_FILTER_CUTOFF) then
                r_lpf_cutoff <= r_lpf_cutoff + C_FILTER_STEP;
            elsif (i_lpf_decr = '1') and (r_lpf_cutoff > C_MIN_FILTER_CUTOFF) then
                r_lpf_cutoff <= r_lpf_cutoff - C_FILTER_STEP;
            end if;
            -- HPF
            if (i_hpf_incr = '1') and (r_hpf_cutoff < C_MAX_FILTER_CUTOFF) then
                r_hpf_cutoff <= r_hpf_cutoff + C_FILTER_STEP;
            elsif (i_hpf_decr = '1') and (r_hpf_cutoff > C_MIN_FILTER_CUTOFF) then
                r_hpf_cutoff <= r_hpf_cutoff - C_FILTER_STEP;
            end if;
        end if;
    end process p_update_cutoffs;
    --*****************************************************************************
    p_eval_fft_data : process (clk_100)
    begin
        if rising_edge(clk_100) then
            if (i_ce = '1') then
                ----------------------------
                -- Default values
                ----------------------------
                r_draw_spectrum      <= '0';
                r_video_red_spectrum <= (others => '0');
                r_video_grn_spectrum <= (others => '0');
                r_video_blu_spectrum <= (others => '0');

                ----------------------------
                -- Update comparison value
                ----------------------------
                if (r_counter_X_d2 = 799) then
                    -- updating row
                    r_compare_value <= r_compare_value - i_compare_subtractor;
                    if (r_counter_Y_d2 >= C_SPECTRUM_Y_UPPER) then
                        -- end of screen
                        r_compare_value <= i_compare_limit;
                    end if;
                end if;

                ----------------------------
                -- Draw spectrum decision            
                ----------------------------
                if (r_counter_X_d2 < C_SPECTRUM_X_UPPER) and (r_counter_Y_d2 < C_SPECTRUM_Y_UPPER) then
                    r_draw_spectrum <= '1';
                    if (i_waterfall_on = '1') then
                        r_video_red_spectrum <= w_video_red_spectrum;
                        r_video_grn_spectrum <= w_video_grn_spectrum;
                        r_video_blu_spectrum <= w_video_blu_spectrum;
                    else
                        if (unsigned(r_fft_data_linear) > r_compare_value) then
                            r_video_red_spectrum <= (others => '1');
                            r_video_grn_spectrum <= (others => '1');
                            r_video_blu_spectrum <= (others => '1');
                        end if;
                    end if;
                    -- 1. Compare input value to comparison value
                    -- 2. Find max frequency of input data
                    if (unsigned(r_fft_data_linear) > r_max_value) then
                        r_max_value <= unsigned(r_fft_data_linear);
                        r_max_freq  <= r_curr_freq;
                    end if;
                end if;
                ----------------------------
                -- Find current frequency
                ----------------------------
                -- X*47 = X*32 + X*8 + X*4 + X*2 + X 
                r_curr_freq <= resize(
                    (r_counter_X_d1 & "00000") +
                    (r_counter_X_d1 & "000") +
                    (r_counter_X_d1 & "00") +
                    (r_counter_X_d1 & "0") +
                    (r_counter_X_d1),
                    r_curr_freq'length
                    );
            end if;
            -- Reset max value every 100 ms
            if (i_100ms_strb = '1') then
                r_max_value <= (others => '0');
            end if;
        end if;
    end process p_eval_fft_data;
    --*****************************************************************************
    p_draw_lines : process (clk_100)
    begin
        if rising_edge(clk_100) then
            if (i_ce = '1') then
                r_gui_draw      <= '0';
                r_video_red_gui <= x"00";
                r_video_grn_gui <= x"00";
                r_video_blu_gui <= x"00";
                if (r_counter_X_d2 = C_SPECTRUM_X_UPPER) or
                    (r_counter_Y_d2 = C_SPECTRUM_Y_UPPER) or
                    ((r_counter_X_d2 > C_SPECTRUM_X_UPPER) and
                    ((r_counter_Y_d2 = 48) or
                    (r_counter_Y_d2 = 96) or
                    (r_counter_Y_d2 = 144) or
                    (r_counter_Y_d2 = 192) or
                    (r_counter_Y_d2 = 240) or
                    (r_counter_Y_d2 = 288) or
                    (r_counter_Y_d2 = 400))) then
                    -- Straight lines for GUI
                    r_gui_draw      <= '1';
                    r_video_red_gui <= x"3F";
                    r_video_grn_gui <= x"3F";
                    r_video_blu_gui <= x"3F";
                    -- 5k = pxl 104
                    -- 10k = pxl 216
                elsif (r_counter_Y_d2 >= C_SPECTRUM_Y_UPPER) and (r_counter_Y_d2 < C_SPECTRUM_Y_UPPER + 16) and
                    ((r_counter_X_d2 = 104) or
                    (r_counter_X_d2 = 216) or
                    (r_counter_X_d2 = 320) or
                    (r_counter_X_d2 = 424)) then
                    -- X-axis large ticks for frequency
                    r_gui_draw      <= '1';
                    r_video_red_gui <= x"9F";
                    r_video_grn_gui <= x"9F";
                    r_video_blu_gui <= x"9F";
                elsif (r_counter_Y_d2 >= C_SPECTRUM_Y_UPPER) and (r_counter_Y_d2 < C_SPECTRUM_Y_UPPER + 8) and
                    ((r_counter_X_d2 = 52) or
                    (r_counter_X_d2 = 160) or
                    (r_counter_X_d2 = 268) or
                    (r_counter_X_d2 = 372)) then
                    -- X-axis small ticks for frequency
                    r_gui_draw      <= '1';
                    r_video_red_gui <= x"9F";
                    r_video_grn_gui <= x"9F";
                    r_video_blu_gui <= x"9F";
                elsif (r_counter_Y_d2 < C_SPECTRUM_Y_UPPER) then
                    -- LPF / HPF cutoff lines
                    if (r_counter_X_d2 = r_lpf_x_axis) then
                        r_gui_draw      <= i_lpf_on;
                        r_video_red_gui <= x"00";
                        r_video_grn_gui <= x"4C";
                        r_video_blu_gui <= x"99";
                    elsif (r_counter_X_d2 = r_hpf_x_axis) then
                        r_gui_draw      <= i_hpf_on;
                        r_video_red_gui <= x"99";
                        r_video_grn_gui <= x"00";
                        r_video_blu_gui <= x"00";
                    end if;
                end if;
            end if;
        end if;
    end process p_draw_lines;
    --*****************************************************************************
    -- Converting cutoff to x-axis position. Each kHz occupies ~ 21 pixels on the screen 
    -- Multiply by 21 = 16 + 4 + 1 = (X << 4) + (X << 2) + (X << 0)
    p_convert_freq_to_x_pos : process (clk_100)
    begin
        if rising_edge(clk_100) then
            r_lpf_x_axis <= resize((w_freq_lpf_1000s & "0000") + (w_freq_lpf_1000s & "00") + w_freq_lpf_1000s, r_lpf_x_axis'length);
            r_hpf_x_axis <= resize((w_freq_hpf_1000s & "0000") + (w_freq_hpf_1000s & "00") + w_freq_hpf_1000s, r_hpf_x_axis'length);
        end if;
    end process p_convert_freq_to_x_pos;
    --*****************************************************************************
    ascii_generator_inst : entity work.ascii_generator
        port map
        (
            clk_100          => clk_100,
            i_ce             => i_ce,
            i_counter_X      => r_counter_X_d1,
            i_counter_Y      => r_counter_Y_d1,
            i_max_freq       => r_max_freq,
            i_capture_on     => i_capture_on,
            i_lpf_on         => i_lpf_on,
            i_lpf_cutoff     => r_lpf_cutoff,
            i_bpf_on         => i_bpf_on,
            i_bpf_cutoff     => i_bpf_cutoff,
            i_hpf_on         => i_hpf_on,
            i_hpf_cutoff     => r_hpf_cutoff,
            i_waterfall_on   => i_waterfall_on,
            i_ema_on         => i_ema_on,
            o_freq_lpf_1000s => w_freq_lpf_1000s,
            o_freq_hpf_1000s => w_freq_hpf_1000s,
            o_glyph_active   => w_ascii_draw,
            o_video_red      => w_video_red_ascii,
            o_video_grn      => w_video_grn_ascii,
            o_video_blu      => w_video_blu_ascii
        );
    --*****************************************************************************
    -- Holds colormap for waterfall
    spectrum_palette_rom_inst : entity work.spectrum_palette_rom
        port map
        (
            clk    => clk_100,
            en     => i_waterfall_on,
            i_addr => r_fft_data_log,
            o_red  => w_video_red_spectrum,
            o_grn  => w_video_grn_spectrum,
            o_blu  => w_video_blu_spectrum
        );
    --*****************************************************************************
end architecture;