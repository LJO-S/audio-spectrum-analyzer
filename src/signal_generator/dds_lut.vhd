library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
-- 
use std.textio.all;
-- 
entity dds_lut is
    generic (
        G_DATA_WIDTH : natural := 16;
        G_DATA_DEPTH : natural := 1024;
        G_INIT_FILE  : string  := "dds_lut_init.txt"
    );
    port (
        clk : in std_logic;
        -- Port A
        i_raddr : in std_logic_vector(integer(log2(real(G_DATA_DEPTH))) - 1 downto 0);
        i_valid : in std_logic;
        -- Output
        o_data  : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        o_valid : out std_logic
    );
end entity dds_lut;

architecture rtl of dds_lut is
    --------------------
    -- Constants
    --------------------
    --------------------
    -- Types
    --------------------
    type t_array_slv is array (natural range <>) of std_logic_vector;
    type t_array_of_array_slv is array (natural range <>) of t_array_slv;
    --------------------
    -- Functions
    --------------------
    -- The following code either initializes the memory values to a specified file or to all zeros to match hardware
    impure function init_ram_from_file return t_array_slv is
        file v_read_file : text open read_mode is G_INIT_FILE;
        variable v_line  : line;
        variable v_slv   : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        variable v_ram   : t_array_slv(0 to (G_DATA_DEPTH) - 1)(G_DATA_WIDTH - 1 downto 0);
        variable v_idx   : natural := 0;
    begin
        v_idx := 0;
        for i in 0 to (G_DATA_DEPTH) - 1 loop
            readline(v_read_file, v_line);
            read(v_line, v_slv);
            v_ram(v_idx) := v_slv;
            v_idx        := v_idx + 1;
        end loop;
        return v_ram;
    end function;
    --------------------
    -- Signals
    --------------------
    signal coefficient_memory : t_array_slv(0 to (G_DATA_DEPTH) - 1)(G_DATA_WIDTH - 1 downto 0) := init_ram_from_file;
begin
    -- ======================================================================= 
    p_lut_readout : process (clk)
    begin
        if rising_edge(clk) then
            o_data  <= (others => '0');
            o_valid <= '0';
            if (i_valid = '1') then
                o_data  <= coefficient_memory(to_integer(unsigned(i_raddr)));
                o_valid <= '1';
            end if;
        end if;
    end process p_lut_readout;
    -- ======================================================================= 
end architecture;