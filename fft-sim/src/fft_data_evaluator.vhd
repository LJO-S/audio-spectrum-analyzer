library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sig_gen_pkg.all;

entity fft_data_evaluator is
    port (
        clk_25 : in std_logic;
        -- Compare values
        i_compare_limit      : in unsigned(31 downto 0);
        i_compare_subtractor : in unsigned(31 downto 0);
        -- PingPong memory
        i_fft_data : in std_logic_vector(31 downto 0);
        o_rd_addr  : out std_logic_vector(9 downto 0);
        -- TMDS
        o_HSYNC : out std_logic;
        o_VSYNC : out std_logic;
        -- Drawing
        o_draw      : out std_logic;
        o_video_red : out std_logic_vector(7 downto 0);
        o_video_grn : out std_logic_vector(7 downto 0);
        o_video_blu : out std_logic_vector(7 downto 0)
    );
end entity fft_data_evaluator;

architecture rtl of fft_data_evaluator is
    -- Constants

    -- Debug for adjusting levels
    signal r_debug_color_on : std_logic := '0';

    -- Drawing
    signal r_counter_X : UNSIGNED(9 downto 0) := (others => '0');
    signal r_counter_Y : UNSIGNED(9 downto 0) := (others => '0');
    signal r_HSYNC     : std_logic            := '0';
    signal r_VSYNC     : std_logic            := '0';
    signal r_draw      : std_logic            := '0';

    -- Pipeline
    signal r_counter_X_d1 : UNSIGNED(9 downto 0) := (others => '0');
    signal r_counter_X_d2 : UNSIGNED(9 downto 0) := (others => '0');
    signal r_counter_Y_d1 : UNSIGNED(9 downto 0) := (others => '0');
    signal r_counter_Y_d2 : UNSIGNED(9 downto 0) := (others => '0');
    signal r_HSYNC_d1     : std_logic            := '0';
    signal r_HSYNC_d2     : std_logic            := '0';
    signal r_VSYNC_d1     : std_logic            := '0';
    signal r_VSYNC_d2     : std_logic            := '0';
    signal r_draw_d1      : std_logic            := '0';
    signal r_draw_d2      : std_logic            := '0';

    signal w_col_count_div : unsigned(6 downto 0);                            -- 40
    signal w_row_count_div : unsigned(6 downto 0);                            -- 30
    signal w_col_addr      : std_logic_vector(2 downto 0) := (others => '0'); -- 0-7 X
    signal w_col_addr_d0   : std_logic_vector(2 downto 0) := (others => '0'); -- 0-7 X
    signal w_col_addr_d1   : std_logic_vector(2 downto 0) := (others => '0'); -- 0-7 X

    signal w_row_addr      : std_logic_vector(3 downto 0) := (others => '0'); -- 0-15 Y
    signal r_symbol_active : std_logic_vector(3 downto 0) := (others => '0');
    signal r_ROM_data      : std_logic_vector(7 downto 0) := (others => '0');
    signal r_bit_draw      : std_logic                    := '0';
    signal r_ROM_addr      : std_logic_vector(7 downto 0);

    signal r_compare_value : unsigned(31 downto 0) := TO_UNSIGNED(C_INTERNAL_COMP_LIMIT, 32);

    -- We have a 640x480p image. Count 800x525p. Copy-pasted from previous project
    -- Bins/columns 0-512 --> 0-48 kHz. Columns 513-640 are left as freeplay (such as capture/internal). 
begin
    --*****************************************************************************
    -- Concurrent assignments 
    o_draw    <= r_draw_d1;
    o_HSYNC   <= r_HSYNC_d1;
    o_VSYNC   <= r_VSYNC_d1;
    o_rd_addr <= std_logic_vector(r_counter_X);
    --*****************************************************************************
    p_pipeline : process (clk_25)
    begin
        if rising_edge(clk_25) then
            r_counter_X_d1 <= r_counter_X;
            r_counter_X_d2 <= r_counter_X_d1;

            r_counter_Y_d1 <= r_counter_Y;
            r_counter_Y_d2 <= r_counter_Y_d1;

            r_HSYNC_d1 <= r_HSYNC;
            r_HSYNC_d2 <= r_HSYNC_d1;

            r_VSYNC_d1 <= r_VSYNC;
            r_VSYNC_d2 <= r_VSYNC_d1;

            r_draw_d1 <= r_draw;
            r_draw_d2 <= r_draw_d1;
        end if;
    end process p_pipeline;
    --*****************************************************************************
    p_video_draw : process (clk_25)
    begin
        if rising_edge(clk_25) then
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
    end process p_video_draw;
    --*****************************************************************************
    p_eval_fft_data : process (clk_25)
    begin
        if rising_edge(clk_25) then
            o_video_red <= (others => '0');
            o_video_grn <= (others => '0');
            o_video_blu <= (others => '0');

            if (r_counter_X_d1 = 799) then
                -- updating row
                r_compare_value <= r_compare_value - i_compare_subtractor;
                if (r_counter_Y_d1 > 479) then
                    -- end of screen
                    r_compare_value <= i_compare_limit;
                end if;
            end if;

            if (r_counter_X_d1 < 512) and (r_draw_d1 = '1') then
                if (unsigned(i_fft_data) > r_compare_value) then
                    o_video_red <= (others => '1');
                    o_video_grn <= (others => '1');
                    o_video_blu <= (others => '1');
                end if;
            end if;
        end if;
    end process p_eval_fft_data;
    --*****************************************************************************
end architecture;