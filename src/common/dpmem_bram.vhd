-- ---------------------------------------------------
-- Dual-port memory often inferred as block ram.
-- 
-- Note: Port A has higher write priority than Port B
-- ---------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity dpmem_bram is
    generic (
        G_RAM_WIDTH      : integer := 8; -- Specify RAM data width
        G_RAM_DEPTH_BITS : integer := 9  -- Specify RAM depth in bits (number of entries)
    );
    port (
        clk : in std_logic;
        -- Port A
        i_addra : in std_logic_vector(G_RAM_DEPTH_BITS - 1 downto 0);
        i_dina  : in std_logic_vector(G_RAM_WIDTH - 1 downto 0);
        i_wea   : in std_logic;
        o_douta : out std_logic_vector(G_RAM_WIDTH - 1 downto 0);
        -- Port B
        i_addrb : in std_logic_vector(G_RAM_DEPTH_BITS - 1 downto 0);
        i_dinb  : in std_logic_vector(G_RAM_WIDTH - 1 downto 0);
        i_web   : in std_logic;
        o_doutb : out std_logic_vector(G_RAM_WIDTH - 1 downto 0)
    );
end entity;

architecture rtl of dpmem_bram is
    -- Note :
    -- If the chosen width and depth values are low, Synthesis will infer Distributed RAM.
    -- C_RAM_DEPTH should be a power of 2
    constant C_RAM_WIDTH : integer := G_RAM_WIDTH;
    constant C_RAM_DEPTH : integer := 2 ** G_RAM_DEPTH_BITS;
    -- Define RAM
    type ram_type is array (0 to C_RAM_DEPTH - 1) of std_logic_vector (C_RAM_WIDTH - 1 downto 0); -- 2D Array Declaration for RAM signal
    signal ram_data_array : ram_type;
begin
    /* ----------------------------------------------------------------------- */
    process (clk)
    begin
        if rising_edge(clk) then
            if (i_wea = '1') then
                ram_data_array(to_integer(unsigned(i_addra))) <= i_dina;
            elsif (i_web = '1') then
                ram_data_array(to_integer(unsigned(i_addra))) <= i_dinb;
            end if;
            o_douta <= ram_data_array(to_integer(unsigned(i_addra)));
            o_doutb <= ram_data_array(to_integer(unsigned(i_addrb)));
        end if;
    end process;
    /* ----------------------------------------------------------------------- */
end architecture;
