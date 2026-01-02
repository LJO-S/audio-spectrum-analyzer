-- ============================================================================ 
-- Audio Codec Interface and Filters
-- ============================================================================ 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity audio_top is
    generic (
        G_DATA_BUFFER_DEPTH : positive := 1024;
        G_NBR_OF_TAPS       : positive := 101;
        G_QFORMAT           : positive := 15;
        G_INPUT_WIDTH       : positive := 16;
        G_COEFF_WIDTH       : positive := 16
    );
    port (
        clk_100 : in std_logic;
        -- PS i/f
        i_i2c_cfg_done        : in std_logic;
        i_new_data_strobe_lpf : in std_logic;
        o_updating_coeffs_lpf : out std_logic;
        o_raddr_lpf           : out unsigned(8 downto 0);
        i_rdata_lpf           : in std_logic_vector(G_COEFF_WIDTH - 1 downto 0);
        i_new_data_strobe_hpf : in std_logic;
        o_updating_coeffs_hpf : out std_logic;
        o_raddr_hpf           : out unsigned(8 downto 0);
        i_rdata_hpf           : in std_logic_vector(G_COEFF_WIDTH - 1 downto 0);
        -- ctrl i/f
        i_capture_en : in std_logic;
        i_lpf_en     : in std_logic;
        i_hpf_en     : in std_logic;
        -- SSM2603 i/f input
        i_sdata : in std_logic;
        -- SSM2603 i/f output 
        o_mclk  : out std_logic; -- master clk
        o_lrclk : out std_logic; -- left/right clk
        o_bclk  : out std_logic; -- bit clk
        o_pbdat : out std_logic; -- serialized data
        -- FFT i/f
        o_tdata  : out std_logic_vector(31 downto 0);
        o_tvalid : out std_logic;
        o_tlast  : out std_logic;
        i_tready : in std_logic
    );
end entity audio_top;

architecture rtl of audio_top is
    -- Constants
    signal r_clk_counter : unsigned(11 downto 0) := (others => '0');
    signal w_lrclk       : std_logic;
    signal w_bclk        : std_logic;
    -- I2S_deser to Audio_buffer
    signal w_i2s_to_filter_data  : std_logic_vector(15 downto 0);
    signal w_i2s_to_filter_valid : std_logic;

    signal w_filter_to_buffer_data  : std_logic_vector(15 downto 0);
    signal w_filter_to_buffer_valid : std_logic;

    signal w_buffer_to_top_data : std_logic_vector(15 downto 0);

    signal w_audio_buffer_draining : std_logic;
    signal w_capture_en            : std_logic;
begin
    /* ------------------------------------------------------ */
    --  Combinatorial assignments

    -- Master clk 
    o_mclk <= r_clk_counter(1); -- 25 MHz

    -- Left/right clk same as samling freq, i.e. ~48 kHz with divider: /2/256 = /512
    w_lrclk <= r_clk_counter(10); -- 48 kHz
    o_lrclk <= w_lrclk;

    -- Bit clock >= (fs * 2 * wl) = 48k * 2 * 16 = 1.5 MHz... 
    -- 3.125MHz lets us include all invalid bits required in the read operation
    w_bclk <= r_clk_counter(4); -- 3.125 MHz
    o_bclk <= w_bclk;

    -- Fill Imaginary part with 0s and Real part with capture data
    o_tdata <= x"0000" & w_buffer_to_top_data;

    /* ------------------------------------------------------ */
    p_clk_counter : process (clk_100)
    begin
        if rising_edge(clk_100) then
            r_clk_counter <= r_clk_counter + 1;
        end if;
    end process p_clk_counter;
    /* ------------------------------------------------------ */
    -- Capture disable guard, to allow for full G_NFFT-sample offload
    -- before shutting down module
    w_capture_en <= i_capture_en or w_audio_buffer_draining;
    /* ------------------------------------------------------ */
    -- I2S Deserializer
    i2s_deser_inst : entity work.i2s_deser
        port map
        (
            clk_100       => clk_100,
            i_lrclk       => w_lrclk,
            i_bclk        => w_bclk,
            i_serial_data => i_sdata,
            i_en          => i_i2c_cfg_done,
            o_data        => w_i2s_to_filter_data,
            o_valid       => w_i2s_to_filter_valid
        );
    /* ------------------------------------------------------ */

    -- Filter Bank 
    filter_bank_inst : entity work.filter_bank
        generic map(
            G_NBR_OF_TAPS => G_NBR_OF_TAPS,
            G_QFORMAT     => G_QFORMAT,
            G_INPUT_WIDTH => G_INPUT_WIDTH,
            G_COEFF_WIDTH => G_COEFF_WIDTH
        )
        port map
        (
            clk_100 => clk_100,
            -- Filter ctrl
            i_lpf_en => i_lpf_en,
            i_hpf_en => i_hpf_en,
            -- Input data
            i_tvalid => w_i2s_to_filter_valid,
            i_tdata  => w_i2s_to_filter_data,
            -- PS LPF I/F
            i_new_data_strobe_lpf => i_new_data_strobe_lpf,
            o_updating_coeffs_lpf => o_updating_coeffs_lpf,
            o_raddr_lpf           => o_raddr_lpf,
            i_rdata_lpf           => i_rdata_lpf,
            -- PS HPF I/F
            i_new_data_strobe_hpf => i_new_data_strobe_hpf,
            o_updating_coeffs_hpf => o_updating_coeffs_hpf,
            o_raddr_hpf           => o_raddr_hpf,
            i_rdata_hpf           => i_rdata_hpf,
            -- Output data
            o_tvalid => w_filter_to_buffer_valid,
            o_tdata  => w_filter_to_buffer_data
        );
    /* ------------------------------------------------------ */
    -- Audio Buffer
    -- Buffers G_NNFT audio samples and then outputs them to FFT engine.
    -- Might miss 1 or 2 audio samples, negligable. If FFT engine temporarily 
    -- halts we might miss more.
    audio_buffer_inst : entity work.audio_buffer
        generic map(
            G_DATA_DEPTH => G_DATA_BUFFER_DEPTH
        )
        port map
        (
            clk_100      => clk_100,
            i_capture_en => w_capture_en,
            o_draining   => w_audio_buffer_draining,
            i_pdata      => w_filter_to_buffer_data,
            i_valid      => w_filter_to_buffer_valid,
            i_tready     => i_tready,
            o_tdata      => w_buffer_to_top_data,
            o_tvalid     => o_tvalid,
            o_tlast      => o_tlast
        );

    /* ------------------------------------------------------ */
    -- I2S Serializer
    -- Data is streamed (no backpressure) from the deserialized input via
    -- the filter bank and out again. 
    i2s_ser_inst : entity work.i2s_ser
        port map
        (
            clk_100  => clk_100,
            i_en     => w_capture_en,
            i_pbclk  => w_lrclk,
            i_bclk   => w_bclk,
            i_tdata  => w_filter_to_buffer_data,
            i_tvalid => w_filter_to_buffer_valid,
            o_pbdat  => o_pbdat
        );
    /* ------------------------------------------------------ */
end architecture;