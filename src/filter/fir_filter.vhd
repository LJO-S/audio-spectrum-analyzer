library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fir_filter is
    port (
        clk_25 : in std_logic

    );
end entity fir_filter;

architecture rtl of fir_filter is

begin
    process (clk_25)
    begin
        if rising_edge(clk_25) then
            null;
        end if;
    end process;
end architecture;