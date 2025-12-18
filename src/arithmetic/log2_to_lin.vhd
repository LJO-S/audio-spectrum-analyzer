-- ===========================================================================================
-- "Log2 to linear"
-- Converts log2 in Q Format to linear output. Uses a LUT to grab fractional values
-- Principle:
-- 
-- 
-- log2 = I.F = 2^(I + F/2^Q)    where Q is Q Format
--            = (2^I) * 2^(F/2^Q)   
--            = (1 << I) * FRAC_TABLE[F]     where FRAC_TABLE contains 0..2**Q-1 fractional values 
--            = (FRAC_TABLE[F] << I) >> QQ   where QQ is the LUT fractional value Q Format
-- 
-- 
-- ===========================================================================================
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity log2_to_lin is
    generic (
        G_DATA_WIDTH    : integer := 8;
        G_INPUT_QFORMAT : integer := 3;
        G_LUT_QFORMAT   : integer := 16;
        G_INIT_FILE     : string
    );
    port (
        clk : in std_logic;
        -- In
        i_tdata  : in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        i_tvalid : in std_logic;
        -- Out
        o_tdata  : out std_logic_vector(2 ** (G_DATA_WIDTH - G_INPUT_QFORMAT) - 1 downto 0);
        o_tvalid : out std_logic
    );
end entity log2_to_lin;

architecture rtl of log2_to_lin is
    ------------------------------------------------------------------------
    -- Constants
    constant C_OUTPUT_WIDTH  : integer := 2 ** (G_DATA_WIDTH - G_INPUT_QFORMAT);
    constant C_LUT_DEPTH     : integer := 2 ** G_INPUT_QFORMAT;
    constant C_LUT_WIDTH     : integer := G_LUT_QFORMAT + 1;
    constant C_WIDE_BITS     : integer := C_OUTPUT_WIDTH + C_LUT_WIDTH;

    ------------------------------------------------------------------------
    -- Types
    -- Note: QFORMAT+1 due to fixed-point
    type t_frac_lut is array (0 to C_LUT_DEPTH - 1) of unsigned(C_LUT_WIDTH - 1 downto 0);
    ------------------------------------------------------------------------
    -- Functions
    -- The following code either initializes the memory values to a specified file or to all zeros to match hardware
    function f_initramfromfile (ramfilename : in string) return t_frac_lut is
        file ramfile                          : text is in ramfilename;
        variable ramfileline                  : line;
        variable ram_name                     : t_frac_lut;
        variable bitvec                       : bit_vector(C_LUT_WIDTH - 1 downto 0);
    begin
        for i in t_frac_lut'range loop
            readline (ramfile, ramfileline);
            read (ramfileline, bitvec);
            ram_name(i) := unsigned(to_stdlogicvector(bitvec));
        end loop;
        return ram_name;
    end function;
    function init_from_file_or_zeroes(ramfile : string) return t_frac_lut is
    begin
        if (ramfile = G_INIT_FILE) then
            return f_initramfromfile(ramfile);
        else
            return (others => (others => '0'));
        end if;
    end;
    ------------------------------------------------------------------------
    -- Signals
    signal r_frac_lut     : t_frac_lut                                              := init_from_file_or_zeroes(G_INIT_FILE);
    signal r_frac_lut_val : unsigned(C_LUT_WIDTH - 1 downto 0)                      := (others => '0');
    signal r_int_raw      : unsigned((G_DATA_WIDTH - G_INPUT_QFORMAT) - 1 downto 0) := (others => '0');
    signal r_frac_raw     : unsigned(G_INPUT_QFORMAT - 1 downto 0)                  := (others => '0');
    signal r_shifted      : unsigned(C_WIDE_BITS - 1 downto 0)                      := (others => '0');
    signal r_linear_value : unsigned(C_OUTPUT_WIDTH - 1 downto 0)                   := (others => '0');
    signal r_valid        : std_logic                                               := '0';
    signal r_valid_d1     : std_logic                                               := '0';
    signal r_valid_d2     : std_logic                                               := '0';
begin
    -- ===========================================================================================
    -- Stage 1
    -- Fetch integer & frac part, read from LUT
    p_stage_1 : process (clk)
        variable v_int_raw  : unsigned(r_int_raw'range)  := (others => '0');
        variable v_frac_raw : unsigned(r_frac_raw'range) := (others => '0');
    begin
        if rising_edge(clk) then
            -- Integer
            v_int_raw := unsigned(i_tdata(i_tdata'high downto i_tdata'low + G_INPUT_QFORMAT));
            r_int_raw <= v_int_raw;
            -- Fractional
            v_frac_raw := unsigned(i_tdata(G_INPUT_QFORMAT - 1 downto 0));
            r_frac_raw     <= v_frac_raw;
            r_frac_lut_val <= r_frac_lut(to_integer(v_frac_raw));
            -- Valid
            r_valid <= i_tvalid;
        end if;
    end process p_stage_1;
    -- ===========================================================================================
    -- PIPE 1
    p_stage_2 : process (clk)
        variable v_frac_lut_val_extended : unsigned(C_WIDE_BITS - 1 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            -- Multiply fractional by integer
            v_frac_lut_val_extended                       := (others => '0');
            v_frac_lut_val_extended(r_frac_lut_val'range) := r_frac_lut_val;
            r_shifted <= shift_left(v_frac_lut_val_extended, to_integer(r_int_raw));

            -- Valid
            r_valid_d1 <= r_valid;
        end if;
    end process p_stage_2;
    -- ===========================================================================================
    -- PIPE 2
    p_stage_3 : process (clk)
    begin
        if rising_edge(clk) then
            -- Shift right by G_LUT_QFORMAT
            r_linear_value <= r_shifted(r_shifted'low + G_LUT_QFORMAT + C_OUTPUT_WIDTH - 1 downto r_shifted'low + G_LUT_QFORMAT);
            -- Valid
            r_valid_d2 <= r_valid_d1;
        end if;
    end process p_stage_3;
    -- ===========================================================================================
    -- Output
    o_tdata  <= std_logic_vector(r_linear_value);
    o_tvalid <= r_valid_d2;
    -- ===========================================================================================
end architecture;