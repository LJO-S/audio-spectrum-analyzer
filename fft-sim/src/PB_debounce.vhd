library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PB_debounce is
    generic (
        -- 10ms with 25 MHz clk 
        G_DEBOUNCE_LIMIT : natural := 250_000;
        G_DEBUG          : boolean := FALSE
    )
    port (
        i_CLK         : in std_logic; -- 25 MHz
        i_PB          : in std_logic;
        o_PB_debounce : out std_logic
    );
end entity;

architecture rtl of PB_debounce is
    constant c_COUNTER_LIMIT : integer                            := G_DEBOUNCE_LIMIT;
    signal r_counter         : integer range 0 to c_COUNTER_LIMIT := 0;
    signal r_PB              : std_logic                          := '0';
begin
    process
    begin
        if (G_DEBUG = FALSE) then
            assert (G_DEBOUNCE_LIMIT > 250_000)
            report "Debounce limit is less than 250_000 when DEBUG=FALSE. Currently set to (" & natural'image(G_DEBOUNCE_LIMIT) & ")!"
                severity error;
        else
            assert G_DEBUG = TRUE
            report "PB debounce is currently set to debug!"
                severity warning;

        end if;
    end process;

    process (i_CLK)
    begin
        if rising_edge(i_CLK) then
            if (r_PB /= i_PB) then
                if (r_counter = c_COUNTER_LIMIT - 1) then
                    r_counter <= 0;
                    r_PB      <= i_PB;
                else
                    r_counter <= r_counter + 1;
                end if;
            else
                r_counter <= 0;
            end if;
        end if;
    end process;

    o_PB_debounce <= r_PB;

end architecture;