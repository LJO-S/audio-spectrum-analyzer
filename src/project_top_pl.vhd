/* --------------------------------------------------------------------- */
/*
Name: Project Top Programmable Logic
Description: Holds the instantiation of the programmable logic. The PL part is responsible
    for the following:
    - FFT (IP, TODO: non-IP)
    - Concat, MAC (IP)
    - DVI video drivers
    - I2S deserialisers
    - Signal Generators
    - Filters (TODO)
    - GPIO
    - And a bunch of control logic...
* /
/* --------------------------------------------------------------------- */

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity project_top_pl is
    port (
        clk : in std_logic

    );
end entity project_top_pl;

architecture rtl of project_top_pl is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            null;
        end if;
    end process;
end architecture;
