library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_deser is
    port (
        clk   : in std_logic
        
    );
end entity i2s_deser;

architecture rtl of i2s_deser is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            null;
        end if;
    end process;
end architecture;