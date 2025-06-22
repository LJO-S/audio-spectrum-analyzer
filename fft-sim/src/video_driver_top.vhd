library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- TODO This shall instantiate 
-- A. TMDS_top --> TMDS_encoders x4
-- B. OBUFDS x4
-- C. "data_handler" connected to ping_pong memory with associated eval logic outputting color on/off, along with pipeline for HSYNC/VSYNC
-- D. TMDS_top

-- Note: we probably need a clk wiz in BD
-- Note: should probably make a new build out of the generated TCL file

entity video_driver_top is
    port (
        clk_25       : in std_logic;
        clk_tmds_250 : in std_logic;
        -- PING_PONG memory I/O ports

        -- PIN mapping ports
        temp : out std_logic
    );
end entity video_driver_top;

architecture rtl of video_driver_top is
    signal w_HDMI_HPD : std_logic;
    signal w_counter_X    : unsigned(9 downto 0);
    signal w_counter_Y    : unsigned(9 downto 0);
    signal w_HSYNC        : std_logic;
    signal w_VSYNC        : std_logic;
    signal w_draw         : std_logic;
    signal w_video_red    : std_logic_vector(7 downto 0);
    signal w_video_grn    : std_logic_vector(7 downto 0);
    signal w_video_blu    : std_logic_vector(7 downto 0);

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
    obufds_top_inst_0 : entity work.obufds_top
        port map
        (
            d0        => w_TMDS(0),
            d0_out    => w_video_0_p,
            d0_out_ob => w_video_0_n
        );

    obufds_top_inst_1 : entity work.obufds_top
        port map
        (
            d0        => w_TMDS(1),
            d0_out    => w_video_1_p,
            d0_out_ob => w_video_1_n
        );

    obufds_top_inst_2 : entity work.obufds_top
        port map
        (
            d0        => w_TMDS(2),
            d0_out    => w_video_2_p,
            d0_out_ob => w_video_2_n
        );

    obufds_top_inst_3 : entity work.obufds_top
        port map
        (
            d0        => w_TMDS_out_clk,
            d0_out    => w_TMDS_out_clk_p,
            d0_out_ob => w_TMDS_out_clk_n
        );
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    -- TODO
    fft_data_eval_inst : entity work.fft_data_evaluator
        port map
        (
            clk_25      => clk_25,
            o_counter_X => open,
            o_counter_Y => open,
            o_HSYNC     => w_HSYNC,
            o_VSYNC     => w_VSYNC,
            o_draw      => w_draw,
            o_video_red => w_video_red,
            o_video_grn => w_video_grn,
            o_video_blu => w_video_blu
        );
end architecture;