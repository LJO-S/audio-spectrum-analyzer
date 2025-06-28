library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sig_gen_pkg.all;

entity video_driver_top is
    port (
        clk_25       : in std_logic;
        clk_tmds_250 : in std_logic;
        -- PING_PONG memory I/O ports
        o_rd_addr : out std_logic_vector(9 downto 0);
        -- Memory output data
        i_rd_data : in std_logic_vector(31 downto 0);
        -- PIN mapping ports
        o_TMDS_clk_p : out std_logic;
        o_TMDS_clk_n : out std_logic;

        o_video_0_p : out std_logic;
        o_video_0_n : out std_logic;

        o_video_1_p : out std_logic;
        o_video_1_n : out std_logic;

        o_video_2_p : out std_logic;
        o_video_2_n : out std_logic
    );
end entity video_driver_top;

architecture rtl of video_driver_top is

    -- Data Eval
    signal w_comp_limit_value : unsigned(31 downto 0) := TO_UNSIGNED(C_INTERNAL_COMP_LIMIT, 32);
    signal w_subtract_value   : unsigned(31 downto 0) := TO_UNSIGNED(C_INTERNAL_SUBTRACT, 32);

    -- Drawing
    signal w_HDMI_HPD  : std_logic;
    signal w_counter_X : unsigned(9 downto 0);
    signal w_counter_Y : unsigned(9 downto 0);
    signal w_HSYNC     : std_logic;
    signal w_VSYNC     : std_logic;
    signal w_draw      : std_logic;
    signal w_video_red : std_logic_vector(7 downto 0);
    signal w_video_grn : std_logic_vector(7 downto 0);
    signal w_video_blu : std_logic_vector(7 downto 0);

    -- OBUFDS 0
    signal w_video_0_p : std_logic;
    signal w_video_0_n : std_logic;

    -- OBUFDS 1
    signal w_video_1_p : std_logic;
    signal w_video_1_n : std_logic;

    -- OBUFDS 2
    signal w_video_2_p : std_logic;
    signal w_video_2_n : std_logic;

    -- OBUFDS 3
    signal w_TMDS_out_clk   : std_logic;
    signal w_TMDS_out_clk_p : std_logic;
    signal w_TMDS_out_clk_n : std_logic;

    signal w_TMDS : std_logic_vector(2 downto 0);
begin
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    fft_data_evaluator_inst : entity work.fft_data_evaluator
        port map
        (
            clk_25               => clk_25,
            i_compare_limit      => w_comp_limit_value,
            i_compare_subtractor => w_subtract_value,
            i_fft_data           => i_rd_data,
            o_rd_addr            => o_rd_addr,
            o_HSYNC              => w_HSYNC,
            o_VSYNC              => w_VSYNC,
            o_draw               => w_draw,
            o_video_red          => w_video_red,
            o_video_grn          => w_video_grn,
            o_video_blu          => w_video_blu
        );
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    TMDS_top_inst : entity work.TMDS_top
        port map
        (
            i_TMDS_clk  => clk_tmds_250,
            i_pixclk    => clk_25,
            i_HSYNC     => w_HSYNC,
            i_VSYNC     => w_VSYNC,
            i_draw      => w_draw,
            i_video_red => w_video_red,
            i_video_grn => w_video_grn,
            i_video_blu => w_video_blu,
            temp        => open,
            o_TMDS      => w_TMDS,
            o_TMDS_clk  => w_TMDS_out_clk,
            o_HDMI_HPD  => w_HDMI_HPD
        );
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    -- BLU
    obufds_top_inst_0 : entity work.obufds_top
        port map
        (
            d0        => w_TMDS(0),
            d0_out    => w_video_0_p,
            d0_out_ob => w_video_0_n
        );
    ----------------
    -- GRN
    obufds_top_inst_1 : entity work.obufds_top
        port map
        (
            d0        => w_TMDS(1),
            d0_out    => w_video_1_p,
            d0_out_ob => w_video_1_n
        );
    ----------------
    -- RED
    obufds_top_inst_2 : entity work.obufds_top
        port map
        (
            d0        => w_TMDS(2),
            d0_out    => w_video_2_p,
            d0_out_ob => w_video_2_n
        );
    ----------------
    -- CLK
    obufds_top_inst_3 : entity work.obufds_top
        port map
        (
            d0        => w_TMDS_out_clk,
            d0_out    => w_TMDS_out_clk_p,
            d0_out_ob => w_TMDS_out_clk_n
        );
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    -- Outputs
    --o_HDMI_HPD <= w_HDMI_HPD;

    o_TMDS_clk_p <= w_TMDS_out_clk_p;
    o_TMDS_clk_n <= w_TMDS_out_clk_n;

    o_video_0_p <= w_video_0_p;
    o_video_0_n <= w_video_0_n;

    o_video_1_p <= w_video_1_p;
    o_video_1_n <= w_video_1_n;

    o_video_2_p <= w_video_2_p;
    o_video_2_n <= w_video_2_n;

end architecture;