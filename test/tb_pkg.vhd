library ieee;
use ieee.std_logic_1164.all;

package tb_pkg is
    -- -------------------------------------------------
    procedure reset_hold (
        signal reset        : inout std_logic;
        constant clk_ticks  : in integer;
        constant clk_period : in time
    );
    -- -------------------------------------------------
    procedure wait_clock (
        constant clk_ticks  : in integer;
        constant clk_period : in time
    );
    -- -------------------------------------------------
end package;

package body tb_pkg is
    -- -------------------------------------------------
    procedure reset_hold (
        signal reset        : inout std_logic;
        constant clk_ticks  : in integer;
        constant clk_period : in time
    ) is
    begin
        reset <= '0';
        for i in 0 to clk_ticks loop
            wait for clk_period;
        end loop;
        reset <= '1';
    end procedure;
    -- -------------------------------------------------
    procedure wait_clock (
        constant clk_ticks  : in integer;
        constant clk_period : in time
    ) is
    begin
        wait for (clk_ticks * clk_period);
    end procedure;
    -- -------------------------------------------------
end package body;