library IEEE;
--library unisim;
use IEEE.STD_LOGIC_1164.all;
--use unisim.vcomponents.all;

entity obufds_top is
    port (
        d0        : in std_logic; --data in to obufds  
        d0_out    : out std_logic;
        d0_out_ob : out std_logic
    );

end obufds_top;

architecture struct of obufds_top is

    component OBUFDS
        port (
            I  : in std_logic;   -- 1-bit input: Buffer input
            O  : out std_logic;  -- 1-bit output: Diff_p output (connect directly to top-level port)
            OB : out std_logic); -- 1-bit output: Diff_n output (connect directly to top-level port)
    end component;

    attribute IOSTANDARD       : string;
    attribute IOSTANDARD of U0 : label is "TMDS_33";

begin

    U0 : OBUFDS
    port map
    (
        I  => d0,
        O  => d0_out,
        OB => d0_out_ob
    );

end architecture;