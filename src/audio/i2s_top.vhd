library ieee;
use ieee.std_logic_1164.all;


entity i2s_top is
    port (
        clk   : in std_logic
        
    );
end entity i2s_top;

architecture rtl of i2s_top is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            null;
        end if;
    end process;
    

end architecture;