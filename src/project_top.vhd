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
        G_FFT_BIT_SIZE : natural := 16;
        G_RAM_DEPTH    : natural := 1024;
        -- FFT refresh period
        G_100MS_CYCLES : natural := 2_500_000;
        -- Debouncers config
        G_DEBOUNCE_LIMIT : natural := 250_000;
        G_DEBUG          : boolean := false
    );
    port (
        -- Master clock 25 MHz
        i_clk_25 : in std_logic;
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
        i_sdata : in std_logic;
        o_mclk  : out std_logic;
        o_lrclk : out std_logic;
        o_bclk  : out std_logic;
        o_pbdat : out std_logic;
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
    -- XFFT IF
    signal w_event_data_in_channel_halt  : std_logic;
    signal w_event_data_out_channel_halt : std_logic;
    signal w_event_frame_started         : std_logic;
    signal w_event_status_channel_halt   : std_logic;
    signal w_event_tlast_missing         : std_logic;
    signal w_event_tlast_unexpected      : std_logic;
    signal w_m_axis_data_tlast           : std_logic;
    signal w_m_axis_data_tvalid          : std_logic;
    signal w_BLK_EXP                     : std_logic_vector (7 downto 0);
    signal w_FFT_mag                     : std_logic_vector (31 downto 0);
    signal w_XK_INDEX                    : std_logic_vector (9 downto 0);

    signal w_axis_tready_xfft_out : std_logic;
    signal w_axis_tdata_xfft_in   : std_logic_vector(2 * G_FFT_BIT_SIZE - 1 downto 0);
    signal w_axis_tvalid_xfft_in  : std_logic;
    signal w_axis_tlast_xfft_in   : std_logic;

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

    -- AXI Bram Control
    signal w_waddr_lpf : std_logic_vector(6 downto 0);
    signal w_wdata_lpf : std_logic_vector(15 downto 0);
    signal w_we_lpf    : std_logic;
    signal w_waddr_hpf : std_logic_vector(6 downto 0);
    signal w_wdata_hpf : std_logic_vector(15 downto 0);
    signal w_we_hpf    : std_logic;

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

begin
    -- ============================================================================ 
    -- ============================================================================ 
    -- Combinatorial Assignments

    -- ============================================================================ 
    -- ============================================================================ 
    signal_generator_wrapper_inst : entity work.signal_generator_wrapper
        generic map(
            G_FFT_BIT_SIZE   => G_FFT_BIT_SIZE,
            G_RAM_DEPTH      => G_RAM_DEPTH,
            G_100MS_CYCLES   => G_100MS_CYCLES,
            G_DEBOUNCE_LIMIT => G_DEBOUNCE_LIMIT,
            G_DEBUG          => G_DEBUG
        )
        port map
        (
            clk_25            => i_clk_25,
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
    -- TODO replace this with own FFT
    -- Input: from Signal Generator Wrapper & Audio Top
    -- Output: to ppMem
    xfft_mag_wrapper_inst : entity work.xfft_mag_wrapper
        port map
        (
            S_AXIS_DATA_0_tdata         => w_axis_tdata_xfft_in,
            S_AXIS_DATA_0_tlast         => w_axis_tlast_xfft_in,
            S_AXIS_DATA_0_tready        => w_axis_tready_xfft_out,
            S_AXIS_DATA_0_tvalid        => w_axis_tvalid_xfft_in,
            event_data_in_channel_halt  => w_event_data_in_channel_halt,
            event_data_out_channel_halt => w_event_data_out_channel_halt,
            event_frame_started         => w_event_frame_started,
            event_status_channel_halt   => w_event_status_channel_halt,
            event_tlast_missing         => w_event_tlast_missing,
            event_tlast_unexpected      => w_event_tlast_unexpected,
            i_clk_25                    => i_clk_25,
            m_axis_data_tlast           => w_m_axis_data_tlast,
            m_axis_data_tvalid          => w_m_axis_data_tvalid,
            o_BLK_EXP                   => w_BLK_EXP,
            o_FFT_mag                   => w_FFT_mag,
            o_XK_INDEX                  => w_XK_INDEX
        );

    -- ============================================================================ 
    -- ============================================================================
    ping_pong_memory_inst : entity work.ping_pong_memory
        port map
        (
            clk_25           => i_clk_25,
            i_fft_data_magn  => w_FFT_mag,
            i_fft_data_last  => w_m_axis_data_tlast,
            i_fft_data_valid => w_m_axis_data_tvalid,
            i_xk_index       => w_XK_INDEX,
            i_rd_addr        => w_rd_addr,
            o_rd_data        => w_rd_data
        );

    -- ============================================================================ 
    -- ============================================================================ 
    video_driver_top_inst : entity work.video_driver_top
        port map
        (
            clk_25       => i_clk_25,
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
            clk_25       => i_clk_25,
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
            clk_25 => i_clk_25,
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
            clk_25         => i_clk_25,
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
            o_lrclk      => o_lrclk,
            o_bclk       => o_bclk,
            o_pbdat      => o_pbdat,
            o_tdata      => w_axis_tdata_audio_to_xfft,
            o_tvalid     => w_axis_tvalid_audio_to_xfft,
            o_tlast      => w_axis_tlast_audio_to_xfft,
            i_tready     => w_axis_tready_xfft_to_audio
        );

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
    p_drain_guard : process (i_clk_25)
    begin
        if rising_edge(i_clk_25) then
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