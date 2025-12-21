library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sig_gen_pkg.all;

entity video_driver_top is
    port (
        clk_25       : in std_logic;
        clk_100      : in std_logic;
        clk_tmds_250 : in std_logic;
        -- Misc
        i_100ms_strb : in std_logic;
        -- Internal/Capture IF
        i_capture_en : in std_logic;
        -- Filter IF
        i_lpf_en   : in std_logic;
        i_hpf_en   : in std_logic;
        i_lpf_incr : in std_logic;
        i_lpf_decr : in std_logic;
        i_hpf_incr : in std_logic;
        i_hpf_decr : in std_logic;
        -- Display Settings
        i_waterfall_en : in std_logic;
        i_ema_en       : in std_logic;
        -- Ping Pong Mem IF
        o_rd_addr_X      : out std_logic_vector(9 downto 0);
        o_rd_addr_Y      : out std_logic_vector(9 downto 0);
        i_rd_data_log    : in std_logic_vector(7 downto 0);
        i_rd_data_linear : in std_logic_vector(31 downto 0);
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

    -- Clock Enable
    signal r_ce_counter : unsigned(1 downto 0) := (others => '0');
    signal w_ce         : std_logic;
    signal r_ce         : std_logic := '0';

    -- Data Eval
    signal r_comp_limit_value : unsigned(31 downto 0) := TO_UNSIGNED(C_INTERNAL_COMP_LIMIT, 32);
    signal r_subtract_value   : unsigned(31 downto 0) := TO_UNSIGNED(C_INTERNAL_SUBTRACT, 32);

    -- Drawing
    signal w_HDMI_HPD  : std_logic;
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
    --                _   _   _   _   _   _   _   _   _   _
    -- clk_100      _| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_
    --       
    -- counter       00  01  10  11  00  01  10  11  00  01
    --                        _______         _______
    -- counter(1)   _________|       |_______|       |_______
    --    
    --                        ___             ___
    -- w_ce         _________|   |___________|   |_______
    -- 
    --                            ___             ___
    -- r_ce         _____________|   |___________|   |___
    --    
    p_25mhz_ce : process (clk_100)
    begin
        if rising_edge(clk_100) then
            -- Clk Divider
            r_ce_counter <= r_ce_counter + 1;
            -- Reg CE
            r_ce <= w_ce;
        end if;
    end process p_25mhz_ce;
    w_ce <= r_ce_counter(1) and not(r_ce);
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    process (clk_100)
    begin
        if rising_edge(clk_100) then
            if (i_capture_en = '1') then
                r_comp_limit_value <= TO_UNSIGNED(C_EXTERNAL_COMP_LIMIT, 32);
                r_subtract_value   <= TO_UNSIGNED(C_EXTERNAL_SUBTRACT, 32);
            else
                r_comp_limit_value <= TO_UNSIGNED(C_INTERNAL_COMP_LIMIT, 32);
                r_subtract_value   <= TO_UNSIGNED(C_INTERNAL_SUBTRACT, 32);
            end if;
        end if;
    end process;
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    image_generator_inst : entity work.image_generator
        port map
        (
            clk_100              => clk_100,
            i_ce                 => w_ce,
            i_compare_limit      => r_comp_limit_value,
            i_compare_subtractor => r_subtract_value,
            i_fft_data_log       => i_rd_data_log,
            i_fft_data_linear    => i_rd_data_linear,
            o_rd_addr_X          => o_rd_addr_X,
            o_rd_addr_Y          => o_rd_addr_Y,
            i_100ms_strb         => i_100ms_strb,
            i_capture_on         => i_capture_en,
            i_lpf_on             => i_lpf_en,
            i_lpf_incr           => i_lpf_incr,
            i_lpf_decr           => i_lpf_decr,
            i_bpf_on             => '0',
            i_bpf_cutoff => (others => '0'),
            i_hpf_on             => i_hpf_en,
            i_hpf_incr           => i_hpf_incr,
            i_hpf_decr           => i_hpf_decr,
            i_waterfall_on       => i_waterfall_en,
            i_ema_on             => i_ema_en,
            -- 
            o_HSYNC     => w_HSYNC,
            o_VSYNC     => w_VSYNC,
            o_draw      => w_draw,
            o_video_red => w_video_red,
            o_video_grn => w_video_grn,
            o_video_blu => w_video_blu
        );
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    TMDS_top_inst : entity work.TMDS_top
        port map
        (
            i_clk_25    => clk_25,
            i_clk_100   => clk_100,
            i_clk_250   => clk_tmds_250,
            i_25m_ce    => w_ce,
            i_HSYNC     => w_HSYNC,
            i_VSYNC     => w_VSYNC,
            i_draw      => w_draw,
            i_video_red => w_video_red,
            i_video_grn => w_video_grn,
            i_video_blu => w_video_blu,
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

    o_TMDS_clk_p <= w_TMDS_out_clk_p;
    o_TMDS_clk_n <= w_TMDS_out_clk_n;

    o_video_0_p <= w_video_0_p;
    o_video_0_n <= w_video_0_n;

    o_video_1_p <= w_video_1_p;
    o_video_1_n <= w_video_1_n;

    o_video_2_p <= w_video_2_p;
    o_video_2_n <= w_video_2_n;

end architecture;