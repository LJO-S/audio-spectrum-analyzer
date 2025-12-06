
-- =============================================================
-- PROJECT_TOP
-- Instantiates all the sub-blocks and performs some simple logic

-- TODO
-- replace all the AXIS naming to something more appropriate

-- =============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

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
        -- FFT refresh period
        G_100MS_CYCLES : natural := 10_000_000;
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
    constant C_NFFT_LOG2 : integer := integer(ceil(log2(real(G_NFFT))));
    -- FFT
    -- TODO rename all axis crap
    signal r_fft_tlast_out        : std_logic := '0';
    signal r_fft_tlast_out_d1     : std_logic := '0';
    signal w_fft_tvalid_out       : std_logic;
    signal r_fft_tvalid_out       : std_logic := '0';
    signal r_fft_tvalid_out_d1    : std_logic := '0';
    signal w_xk_index             : std_logic_vector (C_NFFT_LOG2 - 1 downto 0);
    signal r_xk_index             : std_logic_vector (C_NFFT_LOG2 - 1 downto 0);
    signal r_xk_index_d1          : std_logic_vector (C_NFFT_LOG2 - 1 downto 0);
    signal w_axis_tready_xfft_out : std_logic;
    signal w_axis_tdata_xfft_in   : std_logic_vector(2 * G_FFT_BIT_SIZE - 1 downto 0);
    signal w_axis_tvalid_xfft_in  : std_logic;
    signal w_axis_tlast_xfft_in   : std_logic;
    signal w_fft_tdata_out_re     : std_logic_vector(G_FFT_BIT_SIZE - 1 downto 0);
    signal w_fft_tdata_out_im     : std_logic_vector(G_FFT_BIT_SIZE - 1 downto 0);

    -- FFT Magnitude Calculation
    signal r_fft_tdata_pow2_re : signed(2 * G_FFT_BIT_SIZE - 1 downto 0)       := (others => '0');
    signal r_fft_tdata_pow2_im : signed(2 * G_FFT_BIT_SIZE - 1 downto 0)       := (others => '0');
    signal r_fft_magnitude     : std_logic_vector(2 * G_FFT_BIT_SIZE downto 0) := (others => '0');

    -- Misc
    signal w_100ms_strb : std_logic;

    -- Sig Gen to FFT
    signal w_axis_tready_xfft_to_sig_gen : std_logic;
    signal w_axis_tdata_sig_gen_to_xfft  : std_logic_vector(2 * G_FFT_BIT_SIZE - 1 downto 0);
    signal w_axis_tvalid_sig_gen_to_xfft : std_logic;
    signal w_axis_tlast_sig_gen_to_xfft  : std_logic;

    -- Audio Capture to FFT
    signal w_axis_tready_xfft_to_audio : std_logic;
    signal w_axis_tdata_audio_to_xfft  : std_logic_vector(2 * G_FFT_BIT_SIZE - 1 downto 0);
    signal w_axis_tvalid_audio_to_xfft : std_logic;
    signal w_axis_tlast_audio_to_xfft  : std_logic;

    -- Video-PPmem IF
    signal w_rd_addr : std_logic_vector(9 downto 0);
    signal w_rd_data : std_logic_vector(31 downto 0);

    -- GPIO
    signal w_sig_gen_src_sel        : std_logic_vector(3 downto 0);
    signal w_lpf_en                 : std_logic;
    signal w_lpf_incr               : std_logic;
    signal w_lpf_incr_to_video      : std_logic;
    signal w_lpf_decr               : std_logic;
    signal w_lpf_decr_to_video      : std_logic;
    signal w_hpf_en                 : std_logic;
    signal w_hpf_incr               : std_logic;
    signal w_hpf_incr_to_video      : std_logic;
    signal w_hpf_decr               : std_logic;
    signal w_hpf_decr_to_video      : std_logic;
    signal w_ema_en                 : std_logic;
    signal w_sel_up_lo              : std_logic;
    signal w_capture_en             : std_logic;
    signal w_capture_en_drain_guard : std_logic;
    signal w_updating_coeffs_lpf    : std_logic;
    signal w_updating_coeffs_hpf    : std_logic;
    signal w_new_data_strobe_lpf    : std_logic;
    signal w_new_data_strobe_hpf    : std_logic;

    signal w_raddr_hpf : unsigned(8 downto 0);
    signal w_rdata_hpf : std_logic_vector(G_FIR_COEFF_WIDTH - 1 downto 0);
    signal w_raddr_lpf : unsigned(8 downto 0);
    signal w_rdata_lpf : std_logic_vector(G_FIR_COEFF_WIDTH - 1 downto 0);

    type t_drain_guard is (IDLE, AUDIO_WAITING, GENERATOR_WAITING, GENERATOR_DRAINING, AUDIO_DRAINING);
    signal s_state_drain_guard : t_drain_guard := IDLE;

    signal w_lrclk : std_logic;

begin
    -- ============================================================================ 
    -- ============================================================================ 
    -- Combinatorial Assignments

    -- ============================================================================ 
    -- ============================================================================ 
    signal_generator_wrapper_inst : entity work.signal_generator_wrapper
        generic map(
            G_FFT_BIT_SIZE      => G_FFT_BIT_SIZE,
            G_RAM_DEPTH         => G_NFFT,
            G_100MS_CYCLES      => G_100MS_CYCLES,
            G_PRELOAD_DIRECTIVE => G_PRELOAD_DIRECTIVE
        )
        port map
        (
            clk_100           => i_clk_100,
            i_sig_gen_src_sel => w_sig_gen_src_sel,
            i_sel_up_lo       => w_sel_up_lo,
            o_100ms_strb      => w_100ms_strb,
            o_reset           => open,
            i_s_axis_tready   => w_axis_tready_xfft_to_sig_gen,
            o_m_axis_tdata    => w_axis_tdata_sig_gen_to_xfft,
            o_m_axis_tvalid   => w_axis_tvalid_sig_gen_to_xfft,
            o_m_axis_tlast    => w_axis_tlast_sig_gen_to_xfft
        );
    -- ============================================================================ 
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
            clk        => i_clk_100,
            reset      => '0',
            i_tdata_re => w_axis_tdata_xfft_in(G_FFT_BIT_SIZE - 1 downto 0),
            i_tdata_im => w_axis_tdata_xfft_in(2 * G_FFT_BIT_SIZE - 1 downto G_FFT_BIT_SIZE),
            i_tvalid   => w_axis_tvalid_xfft_in,
            o_tready   => w_axis_tready_xfft_out,
            o_tdata_re => w_fft_tdata_out_re,
            o_tdata_im => w_fft_tdata_out_im,
            o_xk_index => w_xk_index,
            o_tvalid   => w_fft_tvalid_out
        );

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
        end if;
    end process p_magnitude_calc;

    p_pipeline_fft_output : process (i_clk_100)
    begin
        if rising_edge(i_clk_100) then
            r_fft_tlast_out <= '0';
            if (unsigned(r_xk_index) = G_NFFT - 2) then
                r_fft_tlast_out <= r_fft_tvalid_out;
            end if;
        end if;
    end process p_pipeline_fft_output;

    -- ============================================================================ 
    -- ============================================================================
    ping_pong_memory_inst : entity work.ping_pong_memory
        port map
        (
            clk_100          => i_clk_100,
            i_fft_data_magn  => r_fft_magnitude(r_fft_magnitude'high downto r_fft_magnitude'low + 1),
            i_fft_data_last  => r_fft_tlast_out_d1,
            i_fft_data_valid => r_fft_tvalid_out_d1,
            i_xk_index       => r_xk_index_d1,
            i_rd_addr        => w_rd_addr,
            o_rd_data        => w_rd_data
        );

    -- ============================================================================ 
    -- ============================================================================ 
    video_driver_top_inst : entity work.video_driver_top
        port map
        (
            clk_25       => i_clk_25,
            clk_100      => i_clk_100,
            clk_tmds_250 => i_clk_250,
            i_100ms_strb => w_100ms_strb,
            i_capture_en => w_capture_en_drain_guard,
            i_lpf_en     => w_lpf_en,
            i_hpf_en     => w_hpf_en,
            i_ema_en     => w_ema_en,
            i_lpf_incr   => w_lpf_incr_to_video,
            i_lpf_decr   => w_lpf_decr_to_video,
            i_hpf_incr   => w_hpf_incr_to_video,
            i_hpf_decr   => w_hpf_decr_to_video,
            o_rd_addr    => w_rd_addr,
            i_rd_data    => w_rd_data,
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
    -- ============================================================================ 
    gpio_ctrl_inst : entity work.gpio_ctrl
        generic map(
            G_DEBOUNCE_LIMIT => G_DEBOUNCE_LIMIT,
            G_DEBUG          => G_DEBUG
        )
        port map
        (
            clk_100      => i_clk_100,
            i_pb_vector  => i_pb_vector,
            i_dip_vector => i_dip_vector,
            -- Internal Src Selection
            o_sig_gen_src_sel => w_sig_gen_src_sel,
            o_sel_up_lo       => w_sel_up_lo,
            -- LPF
            o_lpf_en   => w_lpf_en,
            o_lpf_incr => w_lpf_incr,
            o_lpf_decr => w_lpf_decr,
            -- HPF
            o_hpf_en   => w_hpf_en,
            o_hpf_incr => w_hpf_incr,
            o_hpf_decr => w_hpf_decr,
            -- EMA
            o_ema_en => w_ema_en,
            -- Capture/Internal
            o_capture_en => w_capture_en
        );

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

            i_capture_en => w_capture_en_drain_guard,
            i_sdata      => i_sdata,
            o_mclk       => o_mclk,
            o_lrclk      => w_lrclk,
            o_bclk       => o_bclk,
            o_pbdat      => o_pbdat,
            o_tdata      => w_axis_tdata_audio_to_xfft,
            o_tvalid     => w_axis_tvalid_audio_to_xfft,
            o_tlast      => w_axis_tlast_audio_to_xfft,
            i_tready     => w_axis_tready_xfft_to_audio
        );

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
    -- ============================================================================
    -- This capture_en will only switch ON when a state declares that we are dealing with audio data
    -- This capture_en will only switch OFF when a state declares that we are not currently sending audio data  
    w_capture_en_drain_guard <= '1' when (s_state_drain_guard = AUDIO_WAITING) or (s_state_drain_guard = AUDIO_DRAINING) else
        '0';

    -- This FSM keeps track of internal/capture mode determined by GPIOs.
    -- If TVALID='1' for Generator/Audio, the data mux will not change the data source if capture_en should toggle. This 
    -- holds until we have seen a TLAST. This allows the XFFT to always receive 1024 samples correctly without unexpected interrupts. 
    -- In other words, never change the data source when draining.
    p_drain_guard : process (i_clk_100)
    begin
        if rising_edge(i_clk_100) then
            case s_state_drain_guard is
                    -- -----------------------------------------------------------
                when IDLE =>
                    if (w_capture_en = '1') then
                        s_state_drain_guard <= AUDIO_WAITING;
                    else
                        s_state_drain_guard <= GENERATOR_WAITING;
                    end if;
                    -- -----------------------------------------------------------
                when AUDIO_WAITING =>
                    if (w_axis_tvalid_xfft_in = '1') then
                        s_state_drain_guard <= AUDIO_DRAINING;
                    elsif (w_capture_en = '0') then
                        s_state_drain_guard <= GENERATOR_WAITING;
                    end if;
                    -- -----------------------------------------------------------
                when AUDIO_DRAINING =>
                    if (w_axis_tlast_xfft_in = '1') then
                        s_state_drain_guard <= AUDIO_WAITING;
                    end if;
                    -- -----------------------------------------------------------
                when GENERATOR_WAITING =>
                    if (w_axis_tvalid_xfft_in = '1') then
                        s_state_drain_guard <= GENERATOR_DRAINING;
                    elsif (w_capture_en = '1') then
                        s_state_drain_guard <= AUDIO_WAITING;
                    end if;
                    -- -----------------------------------------------------------
                when GENERATOR_DRAINING =>
                    if (w_axis_tlast_xfft_in = '1') then
                        s_state_drain_guard <= GENERATOR_WAITING;
                    end if;
                    -- -----------------------------------------------------------
                when others =>
                    s_state_drain_guard <= IDLE;
                    -- -----------------------------------------------------------
            end case;
        end if;
    end process p_drain_guard;

    -- Combinatorial source mux
    p_sample_src_mux : process (
        s_state_drain_guard,
        w_axis_tdata_audio_to_xfft,
        w_axis_tvalid_audio_to_xfft,
        w_axis_tlast_audio_to_xfft,
        w_axis_tready_xfft_out,
        w_axis_tdata_sig_gen_to_xfft,
        w_axis_tvalid_sig_gen_to_xfft,
        w_axis_tlast_sig_gen_to_xfft
        )
    begin
        w_axis_tdata_xfft_in          <= (others => 'X');
        w_axis_tvalid_xfft_in         <= '0';
        w_axis_tlast_xfft_in          <= '0';
        w_axis_tready_xfft_to_audio   <= '0';
        w_axis_tready_xfft_to_sig_gen <= '0';
        if (s_state_drain_guard = AUDIO_WAITING) or (s_state_drain_guard = AUDIO_DRAINING) then
            w_axis_tdata_xfft_in        <= w_axis_tdata_audio_to_xfft;
            w_axis_tvalid_xfft_in       <= w_axis_tvalid_audio_to_xfft;
            w_axis_tlast_xfft_in        <= w_axis_tlast_audio_to_xfft;
            w_axis_tready_xfft_to_audio <= w_axis_tready_xfft_out;
        elsif (s_state_drain_guard = GENERATOR_WAITING) or (s_state_drain_guard = GENERATOR_DRAINING) then
            w_axis_tdata_xfft_in          <= w_axis_tdata_sig_gen_to_xfft;
            w_axis_tvalid_xfft_in         <= w_axis_tvalid_sig_gen_to_xfft;
            w_axis_tlast_xfft_in          <= w_axis_tlast_sig_gen_to_xfft;
            w_axis_tready_xfft_to_sig_gen <= w_axis_tready_xfft_out;
        end if;
    end process p_sample_src_mux;
    -- ============================================================================ 
    -- ============================================================================ 
end architecture;