library ieee;
use ieee.std_logic_1164.all;
entity i2s_top is
    port (
        clk_25     : in std_logic;
        clk_12_288 : in std_logic

    );
end entity i2s_top;

architecture rtl of i2s_top is
begin
    process (clk_25)
    begin
        if rising_edge(clk_25) then
            null;
        end if;
    end process;
end architecture;