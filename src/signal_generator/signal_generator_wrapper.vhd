library ieee;
use ieee.std_logic_1164.all;

entity signal_generator_wrapper is
    generic (
        G_FFT_BIT_SIZE      : natural := 16;
        G_RAM_DEPTH         : natural := 2048;
        G_100MS_CYCLES      : natural := 10_000_000;
        G_PRELOAD_DIRECTIVE : string  := "build"
    );
    port (
        clk_100 : in std_logic;
        -- GPIO
        i_sig_gen_src_sel : in std_logic_vector(3 downto 0);
        i_sel_up_lo       : in std_logic;
        -- Misc
        o_reset      : out std_logic;
        o_100ms_strb : out std_logic;
        -- AXIS
        i_s_axis_tready : in std_logic;
        o_m_axis_tdata  : out std_logic_vector(2 * G_FFT_BIT_SIZE - 1 downto 0);
        o_m_axis_tvalid : out std_logic;
        o_m_axis_tlast  : out std_logic
    );
end entity signal_generator_wrapper;

architecture rtl of signal_generator_wrapper is
begin
    -- =============================================================
    signal_generator_top_inst : entity work.signal_generator_top
        generic map(
            G_FFT_BIT_SIZE      => G_FFT_BIT_SIZE,
            G_RAM_DEPTH         => G_RAM_DEPTH,
            G_100MS_CYCLES      => G_100MS_CYCLES,
            G_PRELOAD_DIRECTIVE => G_PRELOAD_DIRECTIVE
        )
        port map
        (
            clk_100         => clk_100,
            i_pbuttons      => i_sig_gen_src_sel,
            i_sel_up_lo     => i_sel_up_lo,
            o_100ms_strb    => o_100ms_strb,
            o_reset         => o_reset,
            i_s_axis_tready => i_s_axis_tready,
            o_m_axis_tdata  => o_m_axis_tdata,
            o_m_axis_tvalid => o_m_axis_tvalid,
            o_m_axis_tlast  => o_m_axis_tlast
        );
    -- =============================================================
end architecture;
