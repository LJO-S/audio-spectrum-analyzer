
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- 
use work.tb_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity video_driver_top_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of video_driver_top_tb is
    -- Clock period
    constant clk_period_25  : time := 40 ns;
    constant clk_period_100 : time := 10 ns;
    constant clk_period_250 : time := 4 ns;
    -- Generics
    -- Ports
    signal clk_25         : std_logic := '0';
    signal clk_100        : std_logic := '0';
    signal clk_tmds_250   : std_logic := '0';
    signal i_100ms_strb   : std_logic;
    signal i_capture_en   : std_logic;
    signal i_lpf_en       : std_logic;
    signal i_hpf_en       : std_logic;
    signal i_waterfall_en : std_logic;
    signal i_ema_en       : std_logic;
    signal i_lpf_incr     : std_logic;
    signal i_lpf_decr     : std_logic;
    signal i_hpf_incr     : std_logic;
    signal i_hpf_decr     : std_logic;
    signal o_rd_addr_X    : std_logic_vector(9 downto 0);
    signal o_rd_addr_Y    : std_logic_vector(9 downto 0);
    signal i_rd_data      : std_logic_vector(31 downto 0);
    signal o_TMDS_clk_p   : std_logic;
    signal o_TMDS_clk_n   : std_logic;
    signal o_video_0_p    : std_logic;
    signal o_video_0_n    : std_logic;
    signal o_video_1_p    : std_logic;
    signal o_video_1_n    : std_logic;
    signal o_video_2_p    : std_logic;
    signal o_video_2_n    : std_logic;
begin
    -- ===============================================================
    clk_25       <= not clk_25 after clk_period_25/2;
    clk_100      <= not clk_100 after clk_period_100/2;
    clk_tmds_250 <= not clk_tmds_250 after clk_period_250/2;
    -- ===============================================================
    video_driver_top_inst : entity work.video_driver_top
        port map
        (
            clk_25         => clk_25,
            clk_100        => clk_100,
            clk_tmds_250   => clk_tmds_250,
            i_100ms_strb   => i_100ms_strb,
            i_capture_en   => i_capture_en,
            i_lpf_en       => i_lpf_en,
            i_hpf_en       => i_hpf_en,
            i_waterfall_en => i_waterfall_en,
            i_ema_en       => i_ema_en,
            i_lpf_incr     => i_lpf_incr,
            i_lpf_decr     => i_lpf_decr,
            i_hpf_incr     => i_hpf_incr,
            i_hpf_decr     => i_hpf_decr,
            o_rd_addr_X    => o_rd_addr_X,
            o_rd_addr_Y    => o_rd_addr_Y,
            i_rd_data      => i_rd_data,
            o_TMDS_clk_p   => o_TMDS_clk_p,
            o_TMDS_clk_n   => o_TMDS_clk_n,
            o_video_0_p    => o_video_0_p,
            o_video_0_n    => o_video_0_n,
            o_video_1_p    => o_video_1_p,
            o_video_1_n    => o_video_1_n,
            o_video_2_p    => o_video_2_p,
            o_video_2_n    => o_video_2_n
        );
    -- ===============================================================
    main : process
        alias tb_vsync is << signal video_driver_top_inst.w_VSYNC : std_logic >> ;
    begin
        test_runner_setup(runner, runner_cfg);
        if run("visual") then
            info("Running tb_video_driver_top-visual");
            wait until clk_100 = '1';
            for i in 0 to 99 loop
                wait until rising_edge(tb_vsync);
            end loop;
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ===============================================================
end;