library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fft_data_evaluator is
    port (
        clk_25   : in std_logic
    );
end entity fft_data_evaluator;

architecture rtl of fft_data_evaluator is
begin
    process (clk_25)
    begin
        if rising_edge(clk_25) then
            null;
        end if;
    end process;
end architecture;