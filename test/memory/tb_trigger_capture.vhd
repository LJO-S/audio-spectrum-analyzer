library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
-- 
use work.project_common_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity trigger_capture_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of trigger_capture_tb is
    -- Clock period
    constant clk_period : time := 5 ns;
    -- Generics
    constant G_DATA_WIDTH : natural                           := 16;
    constant G_DATA_DEPTH : natural                           := C_SPECTRUM_X_UPPER;
    constant C_THRESH_HI  : signed(G_DATA_WIDTH - 1 downto 0) := shift_right(to_signed((2 ** (G_DATA_WIDTH - 1) - 1), G_DATA_WIDTH), (G_DATA_WIDTH - 1) / 3);
    constant C_THRESH_LO  : signed(G_DATA_WIDTH - 1 downto 0) := shift_right(to_signed( - (2 ** (G_DATA_WIDTH - 1)), G_DATA_WIDTH), (G_DATA_WIDTH - 1) / 3);
    constant C_MS_COUNT   : natural                           := 10;
    -- Ports
    signal clk            : std_logic := '0';
    signal i_audio_tdata  : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal i_audio_tvalid : std_logic;
    signal i_video_raddr  : std_logic_vector(integer(ceil(log2(real(G_DATA_DEPTH)))) - 1 downto 0);
    signal o_video_rdata  : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    -- Testbench
    signal tb_ms_cnt     : integer := 0;
    signal tb_ms_strobe  : std_logic;
    signal tb_sin_tdata  : signed(G_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal tb_sin_tvalid : std_logic                         := '0';
    -- Sin generator controls: frequency in radians/sample, noise amplitude in [0.0, 1.0]
    signal tb_sin_freq  : real                                                                 := 1.0;
    signal tb_noise_amp : real                                                                 := 0.0;
    signal tb_hcount    : unsigned(integer(log2(ceil(real(C_SPECTRUM_X_UPPER)))) - 1 downto 0) := (others => '0');
    signal tb_vcount    : unsigned(integer(log2(ceil(real(C_SPECTRUM_Y_UPPER)))) - 1 downto 0) := (others => '0');
    -- Procedure
    procedure wait_clock (clk_ticks : integer) is
    begin
        for i in 0 to clk_ticks - 1 loop
            wait until rising_edge(clk);
        end loop;
    end procedure;
begin
    -- ======================================================================
    clk <= not clk after clk_period/2;
    -- ======================================================================
    -- MS strobe generator
    p_ms_strobe : process (clk)
    begin
        if rising_edge(clk) then
            tb_ms_strobe <= '0';
            tb_ms_cnt    <= tb_ms_cnt + 1;
            if (tb_ms_cnt >= C_MS_COUNT - 1) then
                tb_ms_cnt    <= 0;
                tb_ms_strobe <= '1';
            end if;
        end if;
    end process p_ms_strobe;
    -- ======================================================================
    -- Sine Generator
    p_sin_gen : process (clk)
        variable v_sin_phase   : real     := 0.0;
        variable v_noise_seed1 : positive := 1;
        variable v_noise_seed2 : positive := 2;
        variable v_noise       : real     := 0.0;
        variable v_sample      : real     := 0.0;
    begin
        if rising_edge(clk) then
            v_sin_phase := (v_sin_phase + tb_sin_freq) mod MATH_2_PI;
            uniform(v_noise_seed1, v_noise_seed2, v_noise);
            -- uniform returns [0,1); centre and scale to [-tb_noise_amp, +tb_noise_amp]
            v_sample := sin(v_sin_phase) + (v_noise * 2.0 - 1.0) * tb_noise_amp;
            -- Clamp to [-1, 1] before scaling to avoid overflow
            if v_sample > 1.0 then
                v_sample := 1.0;
            elsif v_sample <- 1.0 then
                v_sample := - 1.0;
            end if;
            tb_sin_tdata  <= to_signed(integer(v_sample * real(2 ** (G_DATA_WIDTH - 1) - 1)), G_DATA_WIDTH);
            tb_sin_tvalid <= '1';
        end if;
    end process p_sin_gen;
    -- ======================================================================
    i_audio_tdata  <= std_logic_vector(tb_sin_tdata);
    i_audio_tvalid <= tb_sin_tvalid;
    -- ======================================================================
    -- HCOUNT and VCOUNT from video
    p_pixel_count : process (clk)
    begin
        if rising_edge(clk) then
            tb_hcount <= tb_hcount + 1;
            if (tb_hcount >= C_SPECTRUM_X_UPPER - 1) then
                tb_hcount <= (others => '0');
                tb_vcount <= tb_vcount + 1;
                if (tb_vcount >= C_SPECTRUM_Y_UPPER - 1) then
                    tb_vcount <= (others => '0');
                end if;
            end if;
        end if;
    end process p_pixel_count;
    -- ======================================================================
    trigger_capture_inst : entity work.trigger_capture
        generic map(
            G_DATA_WIDTH => G_DATA_WIDTH,
            G_DATA_DEPTH => G_DATA_DEPTH
        )
        port map
        (
            clk           => clk,
            i_ms_strobe   => tb_ms_strobe,
            i_audio_data  => i_audio_tdata,
            i_audio_valid => i_audio_tvalid,
            i_video_raddr => std_logic_vector(tb_hcount),
            o_video_rdata => o_video_rdata
        );
    -- ======================================================================
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        if run("auto") then
            tb_sin_freq  <= 0.1; -- low frequency
            tb_noise_amp <= 0.2; -- 20% noise
            wait_clock(500);
            tb_sin_freq <= 0.8; -- jump to higher frequency
            wait_clock(1200);
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ======================================================================
end;