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
        i_raddr_a : in std_logic_vector(integer(log2(real(G_DATA_DEPTH))) - 1 downto 0);
        i_valid_a : in std_logic;
        -- Port B
        i_raddr_b : in std_logic_vector(integer(log2(real(G_DATA_DEPTH))) - 1 downto 0);
        i_valid_b : in std_logic;
        -- Output A
        o_data_a  : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        o_valid_a : out std_logic;
        -- Output B
        o_data_b  : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        o_valid_b : out std_logic
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
    signal coefficient_memory                 : t_array_slv(0 to (G_DATA_DEPTH) - 1)(G_DATA_WIDTH - 1 downto 0) := init_ram_from_file;
    signal r_data_a, r_data_a_d1              : std_logic_vector(G_DATA_WIDTH - 1 downto 0)                     := (others => '0');
    signal r_valid_a, r_valid_a_d1            : std_logic                                                       := '0';
    signal r_valid_b, r_valid_b_d1            : std_logic                                                       := '0';
    signal r_data_b, r_data_b_d1              : std_logic_vector(G_DATA_WIDTH - 1 downto 0)                     := (others => '0');
    attribute ram_style                       : string;
    attribute ram_style of coefficient_memory : signal is "block";
begin
    -- ======================================================================= 
    -- Combinatorial
    o_data_a  <= r_data_a_d1;
    o_valid_a <= r_valid_a_d1;
    o_data_b  <= r_data_b_d1;
    o_valid_b <= r_valid_b_d1;
    -- ======================================================================= 
    p_lut_readout : process (clk)
    begin
        if rising_edge(clk) then
            --------------------
            -- PIPE 0
            --------------------
            r_valid_a <= '0';
            r_valid_b <= '0';
            if (i_valid_a = '1') then
                r_data_a  <= coefficient_memory(to_integer(unsigned(i_raddr_a)));
                r_valid_a <= '1';
            end if;
            if (i_valid_b = '1') then
                r_data_b  <= coefficient_memory(to_integer(unsigned(i_raddr_b)));
                r_valid_b <= '1';
            end if;
            --------------------
            -- PIPE 1
            --------------------
            r_data_a_d1  <= r_data_a;
            r_valid_a_d1 <= r_valid_a;
            r_data_b_d1  <= r_data_b;
            r_valid_b_d1 <= r_valid_b;
        end if;
    end process p_lut_readout;
    -- ======================================================================= 
end architecture;