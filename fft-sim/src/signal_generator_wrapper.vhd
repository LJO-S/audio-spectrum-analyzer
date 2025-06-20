library ieee;
use ieee.std_logic_1164.all;

entity signal_generator_wrapper is
    generic (
        G_FFT_BIT_SIZE : natural := 16;
        G_RAM_DEPTH    : natural := 1024;
        G_100MS_CYCLES : natural := 2_500_000
    );
    port (
        clk_25 : in std_logic;
        -- GPIO
        i_pbuttons    : in std_logic_vector(3 downto 0);
        i_dip_switch0 : in std_logic;
        -- Misc
        o_reset : out std_logic;
        -- AXIS
        i_s_axis_tready : in std_logic;
        o_m_axis_tdata  : out std_logic_vector(2 * G_FFT_BIT_SIZE - 1 downto 0);
        o_m_axis_tvalid : out std_logic;
        o_m_axis_tlast  : out std_logic
    );
end entity signal_generator_wrapper;

architecture rtl of signal_generator_wrapper is
    signal w_pb_debounce  : std_logic_vector(3 downto 0);
    signal w_dip_debounce : std_logic;

begin
    -- =============================================================
    signal_generator_top_inst : entity work.signal_generator_top
        generic map(
            G_FFT_BIT_SIZE => G_FFT_BIT_SIZE,
            G_RAM_DEPTH    => G_RAM_DEPTH,
            G_100MS_CYCLES => G_100MS_CYCLES
        )
        port map
        (
            clk_25          => clk_25,
            i_pbuttons      => w_pb_debounce,
            i_dip_switch0   => w_dip_debounce,
            o_reset         => o_reset,
            i_s_axis_tready => i_s_axis_tready,
            o_m_axis_tdata  => o_m_axis_tdata,
            o_m_axis_tvalid => o_m_axis_tvalid,
            o_m_axis_tlast  => o_m_axis_tlast
        );
    -- =============================================================
    g_PB_debounce : for i in 0 to 3 generate
        PB_debounce_inst : entity work.PB_debounce
            generic map(
                G_DEBOUNCE_LIMIT => 1000,
                G_DEBUG          => true
            )
            port map
            (
                i_CLK         => clk_25,
                i_PB          => i_pbuttons(i),
                o_PB_debounce => w_pb_debounce(i)
            );
    end generate;
    -- =============================================================
    PB_debounce_inst : entity work.PB_debounce
        generic map(
            G_DEBOUNCE_LIMIT => 1000,
            G_DEBUG          => true
        )
        port map
        (
            i_CLK         => clk_25,
            i_PB          => i_dip_switch0,
            o_PB_debounce => w_dip_debounce
        );
    -- =============================================================
end architecture;
