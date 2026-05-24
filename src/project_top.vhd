
-- =============================================================
-- PROJECT_TOP
-- Instantiates all the sub-blocks and performs some simple logic
-- =============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.project_common_pkg.all;

entity project_top is
    generic (
        G_FIR_NBR_OF_TAPS      : positive := 101;
        G_FIR_COEFF_QFORMAT    : positive := 15;
        G_FIR_DATA_INPUT_WIDTH : positive := 16;
        G_FIR_COEFF_WIDTH      : positive := 16;
        -- FFT input data config
        G_FFT_BIT_SIZE   : natural := 16;
        G_NFFT           : natural := 1024;
        G_FFT_TW_QFORMAT : natural := 15;
        -- Debouncers config
        G_DEBOUNCE_LIMIT : natural := 1_000_000;
        -- Debug (set preload to "build" or "testbench")
        G_PRELOAD_DIRECTIVE : string  := "build";
        G_DEBUG             : boolean := false
    );
    port (
        -- Pixel clock 25 MHz
        i_clk_25 : in std_logic;

        -- Master clock 100 MHz
        i_clk_100 : in std_logic;

        -- TMDS clock 250 MHz
        i_clk_250 : in std_logic;

        -- PS IF 
        i_uart_gpio_if        : in std_logic_vector(31 downto 0);
        i_i2c_cfg_done        : in std_logic;
        i_new_data_strobe_lpf : in std_logic;
        i_new_data_strobe_hpf : in std_logic;
        i_ps_fir_ctrl_ack     : in std_logic;
        o_fir_ctrl            : out std_logic_vector(3 downto 0);

        -- BRAM Controller IF
        o_raddr_hpf : out std_logic_vector(31 downto 0);
        i_rdata_hpf : in std_logic_vector(31 downto 0);
        o_raddr_lpf : out std_logic_vector(31 downto 0);
        i_rdata_lpf : in std_logic_vector(31 downto 0);

        -- GPIO
        i_pb_vector  : in std_logic_vector(3 downto 0);
        i_dip_vector : in std_logic_vector(3 downto 0);

        -- Audio Codec IF (SSM2603)
        i_sdata     : in std_logic;
        o_mclk      : out std_logic;
        o_rec_lrclk : out std_logic;
        o_bclk      : out std_logic;
        o_pb_lrclk  : out std_logic;
        o_pbdat     : out std_logic;
        o_dac_muten : out std_logic;

        -- TMDS CLK
        o_TMDS_clk_p : out std_logic;
        o_TMDS_clk_n : out std_logic;
        -- BLU
        o_video_0_p : out std_logic;
        o_video_0_n : out std_logic;
        -- GRN
        o_video_1_p : out std_logic;
        o_video_1_n : out std_logic;
        -- RED
        o_video_2_p : out std_logic;
        o_video_2_n : out std_logic
    );
end entity project_top;

architecture rtl of project_top is
    ----------------------
    -- Constants
    ----------------------
    constant C_NFFT_LOG2           : integer := integer(ceil(log2(real(G_NFFT))));
    constant C_SYS_CLK_FREQ        : natural := 100_000_000;
    constant C_DDS_FREQ_WIDTH      : natural := 16;
    constant C_DDS_FREQ_FRAC_WIDTH : natural := 16;
    constant C_DDS_TIME_WIDTH      : natural := 16;

    ----------------------
    -- Signals
    ----------------------
    -- Windowing
    signal w_window_data_i_out : std_logic_vector(G_FFT_BIT_SIZE - 1 downto 0);
    signal w_window_data_q_out : std_logic_vector(G_FFT_BIT_SIZE - 1 downto 0);
    signal w_window_valid_out  : std_logic;
    -- FFT
    signal r_fft_tlast_out     : std_logic := '0';
    signal r_fft_tlast_out_d1  : std_logic := '0';
    signal r_fft_tlast_out_d2  : std_logic := '0';
    signal r_fft_tlast_out_d3  : std_logic := '0';
    signal w_fft_tvalid_out    : std_logic;
    signal r_fft_tvalid_out    : std_logic := '0';
    signal r_fft_tvalid_out_d1 : std_logic := '0';
    signal w_xk_index          : std_logic_vector (C_NFFT_LOG2 - 1 downto 0);
    signal r_xk_index          : std_logic_vector (C_NFFT_LOG2 - 1 downto 0);
    signal r_xk_index_d1       : std_logic_vector (C_NFFT_LOG2 - 1 downto 0);
    signal w_fft_ready_out     : std_logic;
    signal w_muxed_src_data    : std_logic_vector(2 * G_FFT_BIT_SIZE - 1 downto 0);
    signal w_muxed_src_valid   : std_logic;
    signal w_fft_tdata_out_re  : std_logic_vector(G_FFT_BIT_SIZE - 1 downto 0);
    signal w_fft_tdata_out_im  : std_logic_vector(G_FFT_BIT_SIZE - 1 downto 0);

    -- FFT Magnitude Calculation & Log2
    signal r_fft_tdata_pow2_re : signed(2 * G_FFT_BIT_SIZE - 1 downto 0)       := (others => '0');
    signal r_fft_tdata_pow2_im : signed(2 * G_FFT_BIT_SIZE - 1 downto 0)       := (others => '0');
    signal r_fft_magnitude     : std_logic_vector(2 * G_FFT_BIT_SIZE downto 0) := (others => '0');
    -- Magnitude Log2
    signal w_mag_log2_data_out  : std_logic_vector(C_FFT_LOG2_DATA_WIDTH - 1 downto 0);
    signal w_mag_log2_valid_out : std_logic;

    -- Misc
    signal w_100ms_strb : std_logic;

    -- Sig Gen to FFT
    signal w_sig_gen_data_out  : std_logic_vector(2 * G_FFT_BIT_SIZE - 1 downto 0);
    signal w_sig_gen_valid_out : std_logic;

    -- Audio Capture to FFT
    signal w_audio_data_out  : std_logic_vector(2 * G_FFT_BIT_SIZE - 1 downto 0);
    signal w_audio_valid_out : std_logic;

    -- Video-FrameBufMem IF
    signal w_rd_addr_X              : std_logic_vector(9 downto 0);
    signal w_rd_addr_Y              : std_logic_vector(9 downto 0);
    signal w_rd_addr_X_framebuf     : std_logic_vector(integer(ceil(log2(real(C_FRAMEBUF_X_SIZE)))) - 1 downto 0);
    signal w_rd_addr_Y_framebuf     : std_logic_vector(integer(ceil(log2(real(C_FRAMEBUF_Y_SIZE)))) - 1 downto 0);
    signal w_frame_buf_rdata_log    : std_logic_vector(C_FFT_LOG2_DATA_WIDTH - 1 downto 0);
    signal r_frame_buf_rdata_log    : std_logic_vector(C_FFT_LOG2_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal r_frame_buf_rdata_log_d1 : std_logic_vector(C_FFT_LOG2_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal r_frame_buf_rdata_log_d2 : std_logic_vector(C_FFT_LOG2_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal w_frame_buf_data_linear  : std_logic_vector(2 ** (C_FFT_LOG2_DATA_WIDTH - C_FFT_LOG2_QFORMAT) - 1 downto 0);

    -- GPIO
    signal w_dds_ctrl            : std_logic_vector(3 downto 0);
    signal w_lpf_en              : std_logic;
    signal w_lpf_incr            : std_logic;
    signal w_lpf_incr_to_video   : std_logic;
    signal w_lpf_decr            : std_logic;
    signal w_lpf_decr_to_video   : std_logic;
    signal w_hpf_en              : std_logic;
    signal w_hpf_incr            : std_logic;
    signal w_hpf_incr_to_video   : std_logic;
    signal w_hpf_decr            : std_logic;
    signal w_hpf_decr_to_video   : std_logic;
    signal w_oscilloscope_en     : std_logic;
    signal w_waterfall_en        : std_logic;
    signal w_sel_up_lo           : std_logic;
    signal w_capture_en          : std_logic;
    signal w_updating_coeffs_lpf : std_logic;
    signal w_updating_coeffs_hpf : std_logic;
    signal w_new_data_strobe_lpf : std_logic;
    signal w_new_data_strobe_hpf : std_logic;

    -- Filters
    signal w_raddr_hpf : unsigned(8 downto 0);
    signal w_rdata_hpf : std_logic_vector(G_FIR_COEFF_WIDTH - 1 downto 0);
    signal w_raddr_lpf : unsigned(8 downto 0);
    signal w_rdata_lpf : std_logic_vector(G_FIR_COEFF_WIDTH - 1 downto 0);

    -- Drain Guard

    -- Sampling Clocks
    signal w_lrclk     : std_logic;
    signal w_ms_strobe : std_logic;

    -- Misc
    signal w_video_to_trigger_capture_raddr : std_logic_vector(integer(ceil(log2(real(C_SPECTRUM_X_UPPER)))) - 1 downto 0);
    signal w_trigger_capture_to_video_rdata : std_logic_vector(G_FFT_BIT_SIZE - 1 downto 0);
begin
    -- ============================================================================ 
    -- Combinatorial Assignments
    -- ============================================================================ 
    ms_strobe_generator_inst : entity work.ms_strobe_generator
        generic map(
            G_SYS_CLK_FREQ => C_SYS_CLK_FREQ
        )
        port map
        (
            clk         => i_clk_100,
            o_ms_strobe => w_ms_strobe
        );
    -- =========================================================================
    signal_generator_top_inst : entity work.signal_generator_top
        generic map(
            G_FFT_SIZE            => (2 ** G_FFT_BIT_SIZE),
            G_SYS_CLK_FREQ        => C_SYS_CLK_FREQ,
            G_DDS_FREQ_WIDTH      => C_DDS_FREQ_WIDTH,
            G_DDS_FREQ_FRAC_WIDTH => C_DDS_FREQ_FRAC_WIDTH,
            G_DDS_TIME_WIDTH      => C_DDS_TIME_WIDTH
        )
        port map
        (
            clk          => i_clk_100,
            i_en         => not(w_capture_en),
            i_pbuttons   => w_dds_ctrl,
            i_sel_up_lo  => w_sel_up_lo,
            i_fs_clk     => w_lrclk,
            i_ms_strobe  => w_ms_strobe,
            o_100ms_strb => w_100ms_strb,
            o_reset      => open,
            o_iq_data    => w_sig_gen_data_out,
            o_iq_valid   => w_sig_gen_valid_out,
            o_iq_last    => open
        );
    -- ============================================================================ 
    window_function_time_inst : entity work.window_function_time
        generic map(
            G_INPUT_DATA_WIDTH  => G_FFT_BIT_SIZE,
            G_INPUT_DATA_DEPTH  => G_NFFT,
            G_WINDOW_DATA_WIDTH => 16,
            G_INIT_FILE         => "/mnt/tools/projects/fpga/audio-spectrum-analyzer/src/filter/windowing/window_coefficients.txt"
        )
        port map
        (
            clk => i_clk_100,
            -- Input
            i_data_i => w_muxed_src_data(G_FFT_BIT_SIZE - 1 downto 0),
            i_data_q => w_muxed_src_data(2 * G_FFT_BIT_SIZE - 1 downto G_FFT_BIT_SIZE),
            i_valid  => w_muxed_src_valid,
            o_ready  => open, -- Note: accepts the possible data drop
            -- Output
            o_data_i => w_window_data_i_out,
            o_data_q => w_window_data_q_out,
            o_valid  => w_window_valid_out,
            i_ready  => w_fft_ready_out,
            o_last   => open
        );
    -- ============================================================================ 
    fft_inst : entity work.fft
        generic map(
            G_NFFT              => G_NFFT,
            G_DATA_WIDTH        => G_FFT_BIT_SIZE,
            G_QFORMAT           => G_FFT_TW_QFORMAT,
            G_PRELOAD_DIRECTIVE => G_PRELOAD_DIRECTIVE
        )
        port map
        (
            clk   => i_clk_100,
            reset => '0',
            -- Input
            i_tdata_re => w_window_data_i_out,
            i_tdata_im => w_window_data_q_out,
            i_tvalid   => w_window_valid_out,
            o_tready   => w_fft_ready_out,
            -- Output
            o_tdata_re => w_fft_tdata_out_re,
            o_tdata_im => w_fft_tdata_out_im,
            o_xk_index => w_xk_index,
            o_tvalid   => w_fft_tvalid_out
        );
    -- ============================================================================ 
    -- Calculate output magnitude
    p_magnitude_calc : process (i_clk_100)
    begin
        if rising_edge(i_clk_100) then
            -- ---------------
            -- PIPE 0
            -- ---------------
            -- Calc square
            r_fft_tdata_pow2_re <= signed(w_fft_tdata_out_re) * signed(w_fft_tdata_out_re);
            r_fft_tdata_pow2_im <= signed(w_fft_tdata_out_im) * signed(w_fft_tdata_out_im);
            r_fft_tvalid_out    <= w_fft_tvalid_out;
            r_xk_index          <= w_xk_index;
            -- ---------------
            -- PIPE 1
            -- ---------------
            -- Calc addition
            r_fft_magnitude <= std_logic_vector(
                resize(r_fft_tdata_pow2_re, r_fft_magnitude'length) +
                resize(r_fft_tdata_pow2_im, r_fft_magnitude'length)
                );
            r_fft_tvalid_out_d1 <= r_fft_tvalid_out;
            r_fft_tlast_out_d1  <= r_fft_tlast_out;
            r_xk_index_d1       <= r_xk_index;
            -- ---------------
            -- PIPE 2 
            -- ---------------
            r_fft_tlast_out_d2 <= r_fft_tlast_out_d1;
            -- ---------------
            -- PIPE 3
            -- ---------------
            r_fft_tlast_out_d3 <= r_fft_tlast_out_d2;
        end if;
    end process p_magnitude_calc;
    -- ============================================================================ 
    p_fft_output_tlast : process (i_clk_100)
    begin
        if rising_edge(i_clk_100) then
            r_fft_tlast_out <= '0';
            if (unsigned(r_xk_index) = G_NFFT - 2) then
                r_fft_tlast_out <= r_fft_tvalid_out;
            end if;
        end if;
    end process p_fft_output_tlast;
    -- ============================================================================
    log_2_inst : entity work.log_2
        generic map(
            G_DATA_WIDTH => 32,
            -- QFORMAT adjusted to give 1 byte output
            G_QFORMAT => C_FFT_LOG2_QFORMAT
        )
        port map
        (
            clk      => i_clk_100,
            i_tdata  => r_fft_magnitude(r_fft_magnitude'high downto r_fft_magnitude'low + 1),
            i_tvalid => r_fft_tvalid_out_d1,
            o_tdata  => w_mag_log2_data_out,
            o_tvalid => w_mag_log2_valid_out
        );
    -- ============================================================================ 
    -- Refit to insize
    p_framebuf_resize : process (w_rd_addr_X, w_rd_addr_Y)
        variable v_rd_addr_Y_start : integer;
    begin
        w_rd_addr_X_framebuf <= w_rd_addr_X(w_rd_addr_X_framebuf'range);
        v_rd_addr_Y_start := w_rd_addr_Y'low + (C_SPECTRUM_Y_UPPER / C_FRAMEBUF_Y_SIZE)/2;
        w_rd_addr_Y_framebuf <= w_rd_addr_Y(
            v_rd_addr_Y_start + w_rd_addr_Y_framebuf'length - 1 downto v_rd_addr_Y_start
            );
    end process p_framebuf_resize;

    spectrum_framebuffer_inst : entity work.spectrum_framebuffer
        generic map(
            G_DATA_WIDTH   => C_FFT_LOG2_DATA_WIDTH,
            G_DATA_DEPTH_X => C_FRAMEBUF_X_SIZE,
            G_DATA_DEPTH_Y => C_FRAMEBUF_Y_SIZE
        )
        port map
        (
            clk => i_clk_100,
            -- Ctrl
            i_waterfall_en => w_waterfall_en,
            i_tdata        => w_mag_log2_data_out,
            i_tvalid       => w_mag_log2_valid_out,
            i_tlast        => r_fft_tlast_out_d3,
            -- Out
            i_rd_addr_X => w_rd_addr_X_framebuf,
            i_rd_addr_Y => w_rd_addr_Y_framebuf,
            o_rd_data   => w_frame_buf_rdata_log
        );
    -- ============================================================================ 

    -- Synthesis
    g_log2lin_build : if (G_PRELOAD_DIRECTIVE = "build") generate
        log2_to_lin_inst : entity work.log2_to_lin
            generic map(
                G_DATA_WIDTH    => C_FFT_LOG2_DATA_WIDTH,
                G_INPUT_QFORMAT => C_FFT_LOG2_QFORMAT,
                G_LUT_QFORMAT   => 16,
                G_INIT_FILE     => "../../scripts/log2lin_frac_lut/log2lin_frac_lut.txt"
            )
            port map
            (
                clk      => i_clk_100,
                i_tdata  => w_frame_buf_rdata_log,
                i_tvalid => '1',
                o_tdata  => w_frame_buf_data_linear,
                o_tvalid => open
            );
    end generate;

    -- Testbench
    g_log2lin_test : if (G_PRELOAD_DIRECTIVE = "testbench") generate
        log2_to_lin_inst : entity work.log2_to_lin
            generic map(
                G_DATA_WIDTH    => C_FFT_LOG2_DATA_WIDTH,
                G_INPUT_QFORMAT => C_FFT_LOG2_QFORMAT,
                G_LUT_QFORMAT   => 16,
                G_INIT_FILE     => "../../../scripts/log2lin_frac_lut/log2lin_frac_lut.txt"
            )
            port map
            (
                clk      => i_clk_100,
                i_tdata  => w_frame_buf_rdata_log,
                i_tvalid => '1',
                o_tdata  => w_frame_buf_data_linear,
                o_tvalid => open
            );
    end generate;

    -- ============================================================================ 
    p_pipe_log_lin_data : process (i_clk_100)
    begin
        if rising_edge(i_clk_100) then
            r_frame_buf_rdata_log    <= w_frame_buf_rdata_log;
            r_frame_buf_rdata_log_d1 <= r_frame_buf_rdata_log;
            r_frame_buf_rdata_log_d2 <= r_frame_buf_rdata_log_d1;
        end if;
    end process p_pipe_log_lin_data;
    -- ============================================================================ 
    video_driver_top_inst : entity work.video_driver_top
        port map
        (
            -- CLKs
            clk_25       => i_clk_25,
            clk_100      => i_clk_100,
            clk_tmds_250 => i_clk_250,
            -- Strobe
            i_100ms_strb => w_100ms_strb,
            -- GUI configuration
            i_capture_en      => w_capture_en,
            i_lpf_en          => w_lpf_en,
            i_hpf_en          => w_hpf_en,
            i_lpf_incr        => w_lpf_incr_to_video,
            i_lpf_decr        => w_lpf_decr_to_video,
            i_hpf_incr        => w_hpf_incr_to_video,
            i_hpf_decr        => w_hpf_decr_to_video,
            i_waterfall_en    => w_waterfall_en,
            i_oscilloscope_en => w_oscilloscope_en,
            -- X/Y positions
            o_rd_addr_X => w_rd_addr_X,
            o_rd_addr_Y => w_rd_addr_Y,
            -- Input values
            i_rd_data_log     => r_frame_buf_rdata_log_d2,
            i_rd_data_linear  => w_frame_buf_data_linear,
            i_rd_data_trigger => w_trigger_capture_to_video_rdata,
            -- TMDS signals
            o_TMDS_clk_p => o_TMDS_clk_p,
            o_TMDS_clk_n => o_TMDS_clk_n,
            o_video_0_p  => o_video_0_p,
            o_video_0_n  => o_video_0_n,
            o_video_1_p  => o_video_1_p,
            o_video_1_n  => o_video_1_n,
            o_video_2_p  => o_video_2_p,
            o_video_2_n  => o_video_2_n
        );
    -- ============================================================================ 
    gpio_ctrl_inst : entity work.gpio_ctrl
        generic map(
            G_DEBOUNCE_LIMIT => G_DEBOUNCE_LIMIT,
            G_DEBUG          => G_DEBUG
        )
        port map
        (
            clk_100        => i_clk_100,
            i_pb_vector    => i_pb_vector,
            i_dip_vector   => i_dip_vector,
            i_uart_gpio_if => i_uart_gpio_if,
            -- Internal Src Selection
            o_dds_ctrl  => w_dds_ctrl,
            o_sel_up_lo => w_sel_up_lo,
            -- LPF
            o_lpf_en   => w_lpf_en,
            o_lpf_incr => w_lpf_incr,
            o_lpf_decr => w_lpf_decr,
            -- HPF
            o_hpf_en   => w_hpf_en,
            o_hpf_incr => w_hpf_incr,
            o_hpf_decr => w_hpf_decr,
            -- WATERFALL
            o_waterfall_en => w_waterfall_en,
            -- OSCILLOSCOPE
            o_oscilloscope_en => w_oscilloscope_en,
            -- Capture/Internal
            o_capture_en => w_capture_en
        );
    -- ============================================================================ 
    gpio_ps_interface_inst : entity work.gpio_ps_interface
        port map
        (
            clk_100 => i_clk_100,
            -- GPIO PB Presses
            i_lpf_incr => w_lpf_incr,
            i_lpf_decr => w_lpf_decr,
            i_hpf_incr => w_hpf_incr,
            i_hpf_decr => w_hpf_decr,
            -- Successful incr/decr to video
            o_lpf_incr => w_lpf_incr_to_video,
            o_lpf_decr => w_lpf_decr_to_video,
            o_hpf_incr => w_hpf_incr_to_video,
            o_hpf_decr => w_hpf_decr_to_video,
            -- To Filters
            o_new_data_strobe_lpf => w_new_data_strobe_lpf,
            o_new_data_strobe_hpf => w_new_data_strobe_hpf,
            -- Busy signals from filters
            i_updating_coeffs_lpf => w_updating_coeffs_lpf,
            i_updating_coeffs_hpf => w_updating_coeffs_hpf,
            -- Request to/acknowledge from PS
            i_new_data_strobe_lpf => i_new_data_strobe_lpf,
            i_new_data_strobe_hpf => i_new_data_strobe_hpf,
            i_ps_ack              => i_ps_fir_ctrl_ack,
            o_fir_ctrl            => o_fir_ctrl
        );
    -- ============================================================================ 
    w_video_to_trigger_capture_raddr <= w_rd_addr_X(w_video_to_trigger_capture_raddr'range);
    trigger_capture_inst : entity work.trigger_capture
        generic map(
            G_DATA_WIDTH  => G_FFT_BIT_SIZE,
            G_DATA_DEPTH  => C_SPECTRUM_X_UPPER,
            G_HOLD_OFF_MS => 50
        )
        port map
        (
            clk           => i_clk_100,
            i_ms_strobe   => w_ms_strobe,
            i_audio_data  => w_muxed_src_data(G_FFT_BIT_SIZE - 1 downto 0),
            i_audio_valid => w_muxed_src_valid,
            i_video_raddr => w_video_to_trigger_capture_raddr,
            o_video_rdata => w_trigger_capture_to_video_rdata
        );
    -- ============================================================================ 
    audio_top_inst : entity work.audio_top
        generic map(
            G_NBR_OF_TAPS => G_FIR_NBR_OF_TAPS,
            G_QFORMAT     => G_FIR_COEFF_QFORMAT,
            G_INPUT_WIDTH => G_FIR_DATA_INPUT_WIDTH,
            G_COEFF_WIDTH => G_FIR_COEFF_WIDTH
        )
        port map
        (
            clk_100        => i_clk_100,
            i_i2c_cfg_done => i_i2c_cfg_done,

            i_new_data_strobe_lpf => w_new_data_strobe_lpf,
            i_new_data_strobe_hpf => w_new_data_strobe_hpf,
            o_updating_coeffs_lpf => w_updating_coeffs_lpf,
            o_updating_coeffs_hpf => w_updating_coeffs_hpf,

            o_raddr_lpf => w_raddr_lpf,
            i_rdata_lpf => w_rdata_lpf,
            o_raddr_hpf => w_raddr_hpf,
            i_rdata_hpf => w_rdata_hpf,
            i_lpf_en    => w_lpf_en,
            i_hpf_en    => w_hpf_en,

            i_capture_en => w_capture_en,
            i_sdata      => i_sdata,
            o_mclk       => o_mclk,
            o_lrclk      => w_lrclk,
            o_bclk       => o_bclk,
            o_pbdat      => o_pbdat,
            -- Output
            o_tdata_i => w_audio_data_out(G_FFT_BIT_SIZE - 1 downto 0),
            o_tdata_q => w_audio_data_out(2 * G_FFT_BIT_SIZE - 1 downto G_FFT_BIT_SIZE),
            o_tvalid  => w_audio_valid_out
        );
    -- ============================================================================ 
    -- DAC Output Mute, Active Low
    o_dac_muten <= '1';
    o_rec_lrclk <= w_lrclk;
    o_pb_lrclk  <= w_lrclk;

    -- Resize to fit output
    o_raddr_lpf <= std_logic_vector(resize('0' & w_raddr_lpf, o_raddr_lpf'length));
    w_rdata_lpf <= i_rdata_lpf(G_FIR_COEFF_WIDTH - 1 downto 0);

    o_raddr_hpf <= std_logic_vector(resize('0' & w_raddr_hpf, o_raddr_hpf'length));
    w_rdata_hpf <= i_rdata_hpf(G_FIR_COEFF_WIDTH - 1 downto 0);
    -- ============================================================================ 
    -- Combinatorial source mux
    p_sample_src_mux : process (
        w_capture_en,
        w_audio_data_out,
        w_audio_valid_out,
        w_sig_gen_data_out,
        w_sig_gen_valid_out
        )
    begin
        w_muxed_src_data  <= (others => 'X');
        w_muxed_src_valid <= '0';
        if (w_capture_en = '1') then
            w_muxed_src_data  <= w_audio_data_out;
            w_muxed_src_valid <= w_audio_valid_out;
        else
            w_muxed_src_data  <= w_sig_gen_data_out;
            w_muxed_src_valid <= w_sig_gen_valid_out;
        end if;
    end process p_sample_src_mux;
    -- ============================================================================ 
end architecture;