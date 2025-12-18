library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- 
use work.tb_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity log2_to_lin_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of log2_to_lin_tb is
    -- Clock period
    constant clk_period : time := 5 ns;
    -- Generics
    constant G_DATA_WIDTH    : integer := 8;
    constant G_INPUT_QFORMAT : integer := 3;
    constant G_LUT_QFORMAT   : integer := 16;
    constant G_INIT_FILE     : string  := "../../../scripts/log2lin_frac_lut/log2lin_frac_lut.txt";
    -- Ports
    signal clk      : std_logic := '0';
    signal i_tdata  : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal i_tvalid : std_logic;
    signal o_tdata  : std_logic_vector(2 ** (G_DATA_WIDTH - G_INPUT_QFORMAT) - 1 downto 0);
    signal o_tvalid : std_logic;
    -- Testbench
    signal tb_linear_golden       : real := 0.0;
    signal tb_linear_diff_percent : real := 0.0;
begin
    -- ===========================================================================================
    clk <= not clk after clk_period/2;
    -- ===========================================================================================
    log2_to_lin_inst : entity work.log2_to_lin
        generic map(
            G_DATA_WIDTH    => G_DATA_WIDTH,
            G_INPUT_QFORMAT => G_INPUT_QFORMAT,
            G_LUT_QFORMAT   => G_LUT_QFORMAT,
            G_INIT_FILE     => G_INIT_FILE
        )
        port map
        (
            clk      => clk,
            i_tdata  => i_tdata,
            i_tvalid => i_tvalid,
            o_tdata  => o_tdata,
            o_tvalid => o_tvalid
        );
    -- ===========================================================================================
    main : process
        -- ------------------------------------
        variable seed1, seed2 : positive := 999;
        -- 
        impure function rand_slv (
            len : integer
        ) return std_logic_vector is
            variable r   : real;
            variable slv : std_logic_vector(len - 1 downto 0);
        begin
            for i in slv'range loop
                UNIFORM(seed1, seed2, r);
                slv(i) := '1' when (r > 0.5) else
                '0';
            end loop;
            return slv;
        end function;
        -- ------------------------------------
        variable v_input               : std_logic_vector(i_tdata'range) := (others => '0');
        variable v_linear_diff_percent : real                            := 0.0;
        -- ------------------------------------
    begin
        test_runner_setup(runner, runner_cfg);
        if run("auto") then
            wait until clk = '1';
            wait_clock(10, clk_period);
            i_tdata  <= (others => '1');
            i_tvalid <= '1';
            wait_clock(1, clk_period);
            i_tdata             <= (others => '0');
            i_tvalid            <= '0';
            wait until o_tvalid <= '1';
            wait_clock(1, clk_period);

            for i in 0 to 9999 loop
                v_input := rand_slv(v_input'length);
                -- Input
                i_tdata  <= v_input;
                i_tvalid <= '1';
                -- Golden
                tb_linear_golden <= (2.0 ** (real(to_integer(unsigned(v_input(v_input'high downto v_input'low + G_INPUT_QFORMAT)))))) *
                    (2.0 ** (real(to_integer(unsigned(v_input(G_INPUT_QFORMAT - 1 downto 0)))) / (2.0 ** G_INPUT_QFORMAT)));
                wait_clock(1, clk_period);
                i_tdata             <= (others => '0');
                i_tvalid            <= '0';
                wait until o_tvalid <= '1';
                -- Calculate difference in percent 
                v_linear_diff_percent := abs(real(to_integer(unsigned(o_tdata))) - tb_linear_golden) / tb_linear_golden;
                tb_linear_diff_percent <= v_linear_diff_percent;
                -- Checker
                check_equal(
                v_linear_diff_percent,
                0.0,
                "Difference larger than 2%!",
                max_diff => 2.0
                );
                wait_clock(1, clk_period);
            end loop;

        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ===========================================================================================
end;