-- ===========================================================================================
-- ===========================================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity log_2 is
    generic (
        G_DATA_WIDTH : integer := 32;
        G_QFORMAT    : integer := 3
    );
    port (
        clk : in std_logic;
        -- Input
        i_tdata  : in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        i_tvalid : in std_logic;
        -- Output
        o_tdata  : out std_logic_vector(integer(ceil(log2(real(G_DATA_WIDTH)))) + G_QFORMAT - 1 downto 0);
        o_tvalid : out std_logic
    );
end entity log_2;

architecture rtl of log_2 is
    -- Constants
    constant C_ILOG2_WIDTH : integer := integer(ceil(log2(real(G_DATA_WIDTH))));

    -- Signals
    signal r_ilog2     : unsigned(C_ILOG2_WIDTH - 1 downto 0)        := (others => '0');
    signal r_ilog2_d1  : unsigned(C_ILOG2_WIDTH - 1 downto 0)        := (others => '0');
    signal r_mantissa  : unsigned(G_QFORMAT - 1 downto 0)            := (others => '0');
    signal r_tdata     : std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal r_tvalid    : std_logic                                   := '0';
    signal r_tvalid_d1 : std_logic                                   := '0';
    --  Functions
    function f_ilog2 (
        slv_in : std_logic_vector
    ) return integer is
        variable v_count : integer;
    begin
        v_count := 0;
        for i in slv_in'high downto slv_in'low loop
            if (slv_in(i) = '1') then
                return slv_in'high - v_count;
            else
                v_count := v_count + 1;
            end if;
        end loop;
        return 0;
    end function;
begin
    -- ===========================================================================================
    o_tdata  <= std_logic_vector(r_ilog2_d1) & std_logic_vector(r_mantissa);
    o_tvalid <= r_tvalid_d1;
    -- ===========================================================================================
    p_ilog10_calc : process (clk)
        variable v_mantissa_shift : unsigned(G_DATA_WIDTH - 1 downto 0);
    begin
        if rising_edge(clk) then
            ---------------------
            -- PIPE 0
            ---------------------
            -- Calculate integer part
            r_ilog2  <= to_unsigned(f_ilog2(i_tdata), r_ilog2'length);
            r_tvalid <= i_tvalid;
            r_tdata  <= i_tdata;
            ---------------------
            -- PIPE 1
            ---------------------
            -- Fetch exponent at MSB + mantissa
            if (r_ilog2 > G_QFORMAT) then
                v_mantissa_shift := shift_right(unsigned(r_tdata), to_integer(r_ilog2) - G_QFORMAT);
            else
                v_mantissa_shift := shift_left(unsigned(r_tdata), G_QFORMAT - to_integer(r_ilog2));
            end if;
            r_mantissa  <= v_mantissa_shift(G_QFORMAT - 1 downto 0);
            r_ilog2_d1  <= r_ilog2;
            r_tvalid_d1 <= r_tvalid;
        end if;
    end process p_ilog10_calc;
    -- ===========================================================================================
end architecture;