library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
-- 
use work.tb_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity project_top_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of project_top_tb is
    -- Clock period
    constant clk_period_25  : time := 40 ns;
    constant clk_period_250 : time := 4 ns;
    -- Generics
    constant G_FIR_NBR_OF_TAPS      : positive := 101;
    constant G_FIR_COEFF_QFORMAT    : positive := 15;
    constant G_FIR_DATA_INPUT_WIDTH : positive := 16;
    constant G_FIR_COEFF_WIDTH      : positive := 16;
    constant G_FFT_BIT_SIZE         : natural  := 16;
    constant G_NFFT                 : natural  := 1024;
    constant G_FFT_TW_QFORMAT       : natural  := 15;
    constant G_100MS_CYCLES         : natural  := 5_000;
    constant G_DEBOUNCE_LIMIT       : natural  := 250;
    constant G_DEBUG                : boolean  := true;
    -- Ports
    signal i_clk_25              : std_logic := '0';
    signal i_clk_250             : std_logic := '0';
    signal i_i2c_cfg_done        : std_logic := '0';
    signal i_new_data_strobe_lpf : std_logic := '0';
    signal i_new_data_strobe_hpf : std_logic := '0';
    signal i_ps_fir_ctrl_ack     : std_logic := '0';
    signal o_fir_ctrl            : std_logic_vector(3 downto 0);
    signal o_raddr_hpf           : std_logic_vector(31 downto 0);
    signal i_rdata_hpf           : std_logic_vector(31 downto 0);
    signal o_raddr_lpf           : std_logic_vector(31 downto 0);
    signal i_rdata_lpf           : std_logic_vector(31 downto 0);
    signal i_pb_vector           : std_logic_vector(3 downto 0) := (others => '0');
    signal i_dip_vector          : std_logic_vector(3 downto 0) := (others => '0');
    signal i_sdata               : std_logic;
    signal o_mclk                : std_logic;
    signal o_rec_lrclk           : std_logic;
    signal o_bclk                : std_logic;
    signal o_pb_lrclk            : std_logic;
    signal o_pbdat               : std_logic;
    signal o_dac_muten           : std_logic;
    signal o_TMDS_clk_p          : std_logic;
    signal o_TMDS_clk_n          : std_logic;
    signal o_video_0_p           : std_logic;
    signal o_video_0_n           : std_logic;
    signal o_video_1_p           : std_logic;
    signal o_video_1_n           : std_logic;
    signal o_video_2_p           : std_logic;
    signal o_video_2_n           : std_logic;
begin

    project_top_inst : entity work.project_top
        generic map(
            G_FIR_NBR_OF_TAPS      => G_FIR_NBR_OF_TAPS,
            G_FIR_COEFF_QFORMAT    => G_FIR_COEFF_QFORMAT,
            G_FIR_DATA_INPUT_WIDTH => G_FIR_DATA_INPUT_WIDTH,
            G_FIR_COEFF_WIDTH      => G_FIR_COEFF_WIDTH,
            G_FFT_BIT_SIZE         => G_FFT_BIT_SIZE,
            G_NFFT                 => G_NFFT,
            G_FFT_TW_QFORMAT       => G_FFT_TW_QFORMAT,
            G_100MS_CYCLES         => G_100MS_CYCLES,
            G_DEBOUNCE_LIMIT       => G_DEBOUNCE_LIMIT,
            G_DEBUG                => G_DEBUG
        )
        port map
        (
            i_clk_25              => i_clk_25,
            i_clk_250             => i_clk_250,
            i_i2c_cfg_done        => i_i2c_cfg_done,
            i_new_data_strobe_lpf => i_new_data_strobe_lpf,
            i_new_data_strobe_hpf => i_new_data_strobe_hpf,
            i_ps_fir_ctrl_ack     => i_ps_fir_ctrl_ack,
            o_fir_ctrl            => o_fir_ctrl,
            o_raddr_hpf           => o_raddr_hpf,
            i_rdata_hpf           => i_rdata_hpf,
            o_raddr_lpf           => o_raddr_lpf,
            i_rdata_lpf           => i_rdata_lpf,
            i_pb_vector           => i_pb_vector,
            i_dip_vector          => i_dip_vector,
            i_sdata               => i_sdata,
            o_mclk                => o_mclk,
            o_rec_lrclk           => o_rec_lrclk,
            o_bclk                => o_bclk,
            o_pb_lrclk            => o_pb_lrclk,
            o_pbdat               => o_pbdat,
            o_dac_muten           => o_dac_muten,
            o_TMDS_clk_p          => o_TMDS_clk_p,
            o_TMDS_clk_n          => o_TMDS_clk_n,
            o_video_0_p           => o_video_0_p,
            o_video_0_n           => o_video_0_n,
            o_video_1_p           => o_video_1_p,
            o_video_1_n           => o_video_1_n,
            o_video_2_p           => o_video_2_p,
            o_video_2_n           => o_video_2_n
        );
    -- ====================================================================
    i_clk_25  <= not i_clk_25 after clk_period_25/2;
    i_clk_250 <= not i_clk_250 after clk_period_250/2;
    -- ====================================================================
    main : process
        ----------------------------------
        procedure proc_set_internal is
        begin
            i_dip_vector(3) <= '0';
        end procedure;
        ----------------------------------
        procedure select_sig_gen(
            constant sel : in integer range 0 to 7
        ) is
        begin
            if (sel > 7) or (sel < 0) then
                assert false report "Invalid select!" severity failure;
            elsif (sel > 3) then
                i_dip_vector(0) <= '1';
            else
                i_dip_vector(0) <= '0';
            end if;
            i_pb_vector            <= (others => '0');
            i_pb_vector(sel mod 4) <= '1';
        end procedure;
        ----------------------------------
    begin
        test_runner_setup(runner, runner_cfg);
        if run("visual") then
            info("Running tb_project_top-visual");
            wait_clock(10, clk_period_25);
            -- Set internally generated
            proc_set_internal;
            -- Select signal generator
            select_sig_gen(2);
            wait_clock(100_000, clk_period_25);
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ====================================================================
end;