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
    constant clk_period_100 : time := 10 ns;
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
    constant G_PRELOAD_DIRECTIVE    : string   := "testbench";
    constant G_DEBUG                : boolean  := true;
    -- Ports
    signal i_clk_25              : std_logic := '1';
    signal i_clk_100             : std_logic := '0';
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
    signal w_pb_lrclk            : std_logic;
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
    signal i_uart_gpio_if        : std_logic_vector(31 downto 0) := (others => '0');
    -- Audio Sin Gen
    signal tb_sin_tdata  : signed(15 downto 0);
    signal tb_sin_tvalid : std_logic;
    signal tb_pbclk      : std_logic;
    signal tb_pbclk_fe   : std_logic;
    -- Procedures
    procedure wait_clock (
        signal clk         : std_logic;
        constant clk_ticks : integer) is
    begin
        for i in 0 to clk_ticks - 1 loop
            wait until rising_edge(clk);
        end loop;
    end procedure;
begin
    --============================================================================
    -------------------------------------------------------------------------------
    -- Audio Sine generator
    -- Sine Generator
    p_sin_gen : process (i_clk_100)
        variable v_sin_phase      : real     := 0.0;
        variable v_noise_seed1    : positive := 1;
        variable v_noise_seed2    : positive := 2;
        variable v_noise          : real     := 0.0;
        variable v_sample         : real     := 0.0;
        variable v_seed1, v_seed2 : integer  := 999;
        impure function f_rand_int (
            min_val : integer;
            max_val : integer
        ) return integer is
            variable v_real : real;
        begin
            uniform(v_seed1, v_seed2, v_real);
            return integer(
            round(v_real * real(max_val - min_val + 1) + real(min_val) - 0.5)
            );
        end function;
    begin
        if rising_edge(i_clk_100) then
            if (tb_pbclk_fe = '1') then
                v_sin_phase := (v_sin_phase + 0.1) mod MATH_2_PI;
                uniform(v_noise_seed1, v_noise_seed2, v_noise);
                -- uniform returns [0,1); centre and scale to [-tb_noise_amp, +tb_noise_amp]
                v_sample := sin(v_sin_phase) + (v_noise * 2.0 - 1.0) * 0.2;
                -- Clamp to [-1, 1] before scaling to avoid overflow
                if v_sample > 1.0 then
                    v_sample := 1.0;
                elsif v_sample <- 1.0 then
                    v_sample := - 1.0;
                end if;
            end if;
            tb_sin_tdata  <= to_signed(integer(v_sample * real(2 ** (16 - 1) - 1)), 16);
            tb_sin_tvalid <= tb_pbclk_fe;
        end if;
    end process p_sin_gen;
    -------------------------------------------------------------------------------
    tb_pbclk_fe <= tb_pbclk and not(w_pb_lrclk);
    -------------------------------------------------------------------------------
    process (i_clk_100)
    begin
        if rising_edge(i_clk_100) then
            tb_pbclk <= w_pb_lrclk;
        end if;
    end process;
    -------------------------------------------------------------------------------
    i2s_ser_inst : entity work.i2s_ser
        port map
        (
            clk_100  => i_clk_100,
            i_pbclk  => w_pb_lrclk,
            i_bclk   => o_bclk,
            i_tdata  => std_logic_vector(tb_sin_tdata),
            i_tvalid => tb_sin_tvalid,
            i_en     => '1',
            o_pbdat  => i_sdata
        );
    --============================================================================
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
            G_PRELOAD_DIRECTIVE    => G_PRELOAD_DIRECTIVE,
            G_DEBUG                => G_DEBUG
        )
        port map
        (
            i_clk_25              => i_clk_25,
            i_clk_100             => i_clk_100,
            i_clk_250             => i_clk_250,
            i_uart_gpio_if        => i_uart_gpio_if,
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
            o_pb_lrclk            => w_pb_lrclk,
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
    i_clk_100 <= not i_clk_100 after clk_period_100/2;
    i_clk_250 <= not i_clk_250 after clk_period_250/2;
    -- ====================================================================
    main : process
        ----------------------------------
        procedure proc_set_internal is
        begin
            i_dip_vector(3) <= '0';
        end procedure;
        ----------------------------------
        procedure proc_set_capture is
        begin
            i_dip_vector(3) <= '1';
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
            wait_clock(i_clk_100, G_DEBOUNCE_LIMIT + 10);
            i_pb_vector <= (others => '0');
            wait_clock(i_clk_100, G_DEBOUNCE_LIMIT + 10);
        end procedure;
        ----------------------------------
        procedure proc_set_waterfall(
            constant active : in boolean
        ) is
        begin
            if (i_dip_vector(3) /= '1') then
                -- Internal
                i_dip_vector(1) <= '1' when active = true else
                '0';
            else
                -- Capture
                i_dip_vector(0) <= '1' when active = true else
                '0';
            end if;
        end procedure;
        ----------------------------------
        procedure proc_set_oscilloscope(active : boolean) is
        begin
            if (active = true) then
                i_uart_gpio_if(0) <= '1';
            else
                i_uart_gpio_if(0) <= '0';
            end if;
        end procedure;
        ----------------------------------
    begin
        test_runner_setup(runner, runner_cfg);
        if run("visual") then
            info("Running tb_project_top-visual");
            wait_clock(10, clk_period_100);
            proc_set_capture;
            i_i2c_cfg_done <= '1';
            -- 1. Set internally generated
            -- proc_set_internal;
            -- -- 2. Configure internal
            -- for i in 0 to 10 loop
            --     select_sig_gen(0);
            -- end loop;
            -- for i in 0 to 0 loop
            --     select_sig_gen(2);
            -- end loop;
            -- for i in 0 to 10 loop
            --     select_sig_gen(4);
            -- end loop;
            -- Activate waterfall
            -- proc_set_waterfall(true);
            -- wait_clock(1_000, clk_period_100);
            proc_set_oscilloscope(true);
            wait_clock(10_000_000, clk_period_100);
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ====================================================================
end;