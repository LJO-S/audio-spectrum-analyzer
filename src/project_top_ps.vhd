/* --------------------------------------------------------------------- */
/*
Name: Project Top Processing System
Description: Holds the instantiation of the Zynq7 core. The PS core is responsible
    for the following:
    - I2C configuration of the Audio Codec SSM2603.
* /
/* --------------------------------------------------------------------- */

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity project_top_ps is
    port (
        clk : in std_logic

    );
end entity project_top_ps;

architecture rtl of project_top_ps is
begin
    process (clk)
    begin
        if rising_edge(clk) then
            null;
        end if;
    end process;
end architecture;
