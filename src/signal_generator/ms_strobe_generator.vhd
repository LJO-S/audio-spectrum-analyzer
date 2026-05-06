library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity ms_strobe_generator is
    generic (
        G_SYS_CLK_FREQ : natural := 100_000_000
    );
    port (
        clk         : in std_logic;
        o_ms_strobe : out std_logic
    );
end entity ms_strobe_generator;

architecture rtl of ms_strobe_generator is
    --------------------
    -- Constants
    --------------------
    constant C_CC_PER_US : natural := integer(round(10.0 ** (-6) / (1.0 / real(G_SYS_CLK_FREQ))));
    --------------------
    -- Signals
    --------------------
    signal r_cc_counter : unsigned(integer(ceil(log2(real(C_CC_PER_US)))) - 1 downto 0) := (others => '0');
    signal r_us_counter : unsigned(integer(ceil(log2(real(1000)))) - 1 downto 0)        := (others => '0');
    signal r_ms_strobe  : std_logic                                                     := '0';
begin
    -- ============================================================
    o_ms_strobe <= r_ms_strobe;
    -- ============================================================
    p_ms_strobe_generator : process (clk)
    begin
        if rising_edge(clk) then
            r_ms_strobe  <= '0';
            r_cc_counter <= r_cc_counter + 1;
            if (r_cc_counter >= C_CC_PER_US - 1) then
                r_cc_counter <= (others => '0');
                r_us_counter <= r_us_counter + 1;
                if (r_us_counter >= 999) then
                    r_us_counter <= (others => '0');
                    r_ms_strobe  <= '1';
                end if;
            end if;
        end if;
    end process p_ms_strobe_generator;
    -- ============================================================
end architecture;