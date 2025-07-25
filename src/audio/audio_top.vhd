library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity audio_top is
    port (
        clk_25 : in std_logic;
        -- PS i/f
        i_i2c_cfg_done : in std_logic;
        -- ctrl i/f
        i_capture_en    : in std_logic;
        o_tlast_pending : out std_logic;
        -- SSM2603 i/f input
        i_sdata : in std_logic;
        -- SSM2603 i/f output 
        o_mclk  : out std_logic; -- master clk
        o_lrclk : out std_logic; -- left/right clk
        o_bclk  : out std_logic; -- bit clk
        -- FFT i/f
        o_tdata  : out std_logic_vector(31 downto 0);
        o_tvalid : out std_logic;
        o_tlast  : out std_logic;
        i_tready : in std_logic
    );
end entity audio_top;

architecture rtl of audio_top is
    signal r_clk_counter : unsigned(9 downto 0) := (others => '0');
    signal w_lrclk       : std_logic;
    signal w_bclk        : std_logic;
    -- I2S_deser to Audio_buffer
    signal w_i2s_to_buffer_data  : std_logic_vector(15 downto 0);
    signal w_i2s_to_buffer_valid : std_logic;
    signal w_buffer_to_top_data  : std_logic_vector(15 downto 0);
begin
    /* ------------------------------------------------------ */
    --  Combinatorial assignments

    -- SSM2603 signals
    -- Master clk same as system
    o_mclk <= clk_25; -- 25 MHz
    -- Left/right clk same as samling freq, i.e. ~48 kHz with divider: /2/256 = /512
    w_lrclk <= r_clk_counter(9); -- 48 kHz
    o_lrclk <= w_lrclk;
    -- Bit clock >= (fs * 2 * wl) = 48k * 2 * 16 = 1.5 MHz... 
    -- 3.125MHz lets us include all invalid bits required in the read operation
    w_bclk <= r_clk_counter(3); -- 3.125 MHz
    o_bclk <= w_bclk;

    -- Fill Imaginary part with 0s and Real part with capture data
    o_tdata <= x"0000" & w_buffer_to_top_data;

    /* ------------------------------------------------------ */
    p_clk_counter : process (clk_25)
    begin
        if rising_edge(clk_25) then
            r_clk_counter <= r_clk_counter + 1;
        end if;
    end process p_clk_counter;
    /* ------------------------------------------------------ */
    -- I2S Deserializer
    i2s_deser_inst : entity work.i2s_deser
        port map
        (
            clk_25        => clk_25,
            i_lrclk       => w_lrclk,
            i_bclk        => w_bclk,
            i_serial_data => i_sdata,
            i_en          => i_i2c_cfg_done,
            o_data        => w_i2s_to_buffer_data,
            o_valid       => w_i2s_to_buffer_valid
        );
    /* ------------------------------------------------------ */
    -- Audio Buffer
    -- Buffers 1024 audio samples and then outputs them to FFT engine.
    -- Might miss 1 or 2 audio samples, negligable. If FFT engine temporarily 
    -- halts we might miss more.
    audio_buffer_inst : entity work.audio_buffer
        port map
        (
            clk_25          => clk_25,
            i_capture_en    => i_capture_en,
            o_tlast_pending => o_tlast_pending,
            i_pdata         => w_i2s_to_buffer_data,
            i_valid         => w_i2s_to_buffer_valid,
            i_tready        => i_tready,
            o_tdata         => w_buffer_to_top_data,
            o_tvalid        => o_tvalid,
            o_tlast         => o_tlast
        );
    /* ------------------------------------------------------ */
end architecture;