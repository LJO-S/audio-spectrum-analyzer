--  Single Port Asynchronous Read (Distributed RAM)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity spmem_dram is
    generic (
        G_RAM_WIDTH : integer := 8; -- Specify RAM data width
        G_RAM_DEPTH : integer := 64 -- Specify RAM depth (number of entries)
    );
    port (
        clk    : in std_logic;
        i_addr : in std_logic_vector(9 downto 0);
        i_din  : in std_logic_vector(G_RAM_WIDTH - 1 downto 0);
        i_we   : in std_logic;
        o_dout : out std_logic_vector(G_RAM_WIDTH - 1 downto 0)
    );
end entity;

architecture rtl of spmem_dram is
    -- Note :
    -- If the chosen width and depth values are low, Synthesis will infer Distributed RAM.
    -- C_RAM_DEPTH should be a power of 2
    constant C_RAM_WIDTH : integer := G_RAM_WIDTH;
    constant C_RAM_DEPTH : integer := G_RAM_DEPTH;
    -- Define RAM
    type ram_type is array (0 to C_RAM_DEPTH - 1) of std_logic_vector (C_RAM_WIDTH - 1 downto 0); -- 2D Array Declaration for RAM signal
    signal ram_data_array : ram_type;
begin
    /* ----------------------------------------------------------------------- */
    process (clk)
    begin
        if rising_edge(clk) then
            if (i_we = '1') then
                ram_data_array(to_integer(unsigned(i_addr))) <= i_din;
            end if;
        end if;
    end process;
    /* ----------------------------------------------------------------------- */
    o_dout <= ram_data_array(to_integer(unsigned(i_addr)));
    /* ----------------------------------------------------------------------- */
end architecture;
