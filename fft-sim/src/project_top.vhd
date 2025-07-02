library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity project_top is
    generic (
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
        -- System clk 125 MHz
        i_sys_clk : in std_logic;
        -- GPIO
        i_pbuttons    : in std_logic_vector(3 downto 0);
        i_dip_switch0 : in std_logic;
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
    signal w_clk_25                      : std_logic;
    signal w_clk_250                     : std_logic;

    signal w_reset                       : std_logic;
    signal w_axis_tready_xfft_to_sig_gen : std_logic;
    signal w_axis_tdata_sig_gen_to_xfft  : std_logic_vector(2 * G_FFT_BIT_SIZE - 1 downto 0);
    signal w_axis_tvalid_sig_gen_to_xfft : std_logic;
    signal w_axis_tlast_sig_gen_to_xfft  : std_logic;

    signal w_rd_addr : std_logic_vector(9 downto 0);
    signal w_rd_data : std_logic_vector(31 downto 0);
begin
    ----------------------------------------------------------------------- 
    ----------------------------------------------------------------------- 
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
            clk_25          => w_clk_25,
            i_pbuttons      => i_pbuttons,
            i_dip_switch0   => i_dip_switch0,
            o_reset         => open,
            i_s_axis_tready => w_axis_tready_xfft_to_sig_gen,
            o_m_axis_tdata  => w_axis_tdata_sig_gen_to_xfft,
            o_m_axis_tvalid => w_axis_tvalid_sig_gen_to_xfft,
            o_m_axis_tlast  => w_axis_tlast_sig_gen_to_xfft
        );
    ----------------------------------------------------------------------- 
    ----------------------------------------------------------------------- 
    -- Input: from Signal Generator Wrapper
    -- Output: to ppMem
    top_appl_wrapper_inst : entity work.top_appl_wrapper
        port map
        (
            S_AXIS_DATA_0_tdata         => w_axis_tdata_sig_gen_to_xfft,
            S_AXIS_DATA_0_tlast         => w_axis_tlast_sig_gen_to_xfft,
            S_AXIS_DATA_0_tready        => w_axis_tready_xfft_to_sig_gen,
            S_AXIS_DATA_0_tvalid        => w_axis_tvalid_sig_gen_to_xfft,
            event_data_in_channel_halt  => w_event_data_in_channel_halt,
            event_data_out_channel_halt => w_event_data_out_channel_halt,
            event_frame_started         => w_event_frame_started,
            event_status_channel_halt   => w_event_status_channel_halt,
            event_tlast_missing         => w_event_tlast_missing,
            event_tlast_unexpected      => w_event_tlast_unexpected,
            m_axis_data_tlast           => w_m_axis_data_tlast,
            m_axis_data_tvalid          => w_m_axis_data_tvalid,
            o_BLK_EXP                   => w_BLK_EXP,
            o_FFT_mag                   => w_FFT_mag,
            o_XK_INDEX                  => w_XK_INDEX,
            o_clk_25                    => w_clk_25,
            o_clk_250                   => w_clk_250,
            sys_clock                   => i_sys_clk
        );
    ----------------------------------------------------------------------- 
    -----------------------------------------------------------------------
    ping_pong_memory_inst : entity work.ping_pong_memory
        port map
        (
            clk_25           => w_clk_25,
            i_fft_data_magn  => w_FFT_mag,
            i_fft_data_last  => w_m_axis_data_tlast,
            i_fft_data_valid => w_m_axis_data_tvalid,
            i_xk_index       => w_XK_INDEX,
            i_rd_addr        => w_rd_addr,
            o_rd_data        => w_rd_data
        );

    ----------------------------------------------------------------------- 
    ----------------------------------------------------------------------- 
    video_driver_top_inst : entity work.video_driver_top
        port map
        (
            clk_25       => w_clk_25,
            clk_tmds_250 => w_clk_250,
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
    ----------------------------------------------------------------------- 
    ----------------------------------------------------------------------- 
end architecture;