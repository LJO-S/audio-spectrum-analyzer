
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--
use work.tb_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity ring_buffer_fifo_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of ring_buffer_fifo_tb is
    -- Clock period
    constant clk_period : time := 5 ns;
    -- Generics
    constant G_DEPTH           : natural := 9;
    constant G_WIDTH           : natural := 32;
    constant C_HALF_FULL_POINT : natural := integer(floor(real(G_DEPTH/2)));
    constant C_FULL_POINT      : natural := G_DEPTH - 1;
    -- Ports
    signal clk          : std_logic                              := '0';
    signal reset        : std_logic                              := '0';
    signal i_wr_en      : std_logic                              := '0';
    signal i_wr_data    : std_logic_vector(G_WIDTH - 1 downto 0) := (others => '0');
    signal i_rd_en      : std_logic                              := '0';
    signal o_rd_data    : std_logic_vector(G_WIDTH - 1 downto 0);
    signal o_rd_valid   : std_logic;
    signal o_empty      : std_logic;
    signal o_empty_next : std_logic;
    signal o_full       : std_logic;
    signal o_full_next  : std_logic;

    -- TB
    type t_tb_compare_data_array is array (0 to C_FULL_POINT - 1) of std_logic_vector(i_wr_data'range);
    signal tb_compare_data_arr : t_tb_compare_data_array;
begin
    -- ===============================================================
    clk <= not clk after clk_period/2;
    -- ===============================================================
    ring_buffer_fifo_inst : entity work.ring_buffer_fifo
        generic map(
            G_DEPTH => G_DEPTH,
            G_WIDTH => G_WIDTH
        )
        port map
        (
            clk          => clk,
            reset        => reset,
            i_wr_en      => i_wr_en,
            i_wr_data    => i_wr_data,
            i_rd_en      => i_rd_en,
            o_rd_data    => o_rd_data,
            o_rd_valid   => o_rd_valid,
            o_empty      => o_empty,
            o_empty_next => o_empty_next,
            o_full       => o_full,
            o_full_next  => o_full_next
        );
    -- ===============================================================
    main : process
        -- ----------
        variable seed1, seed2 : positive := 999;
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
        -- ----------
        alias tb_fill_count is << signal ring_buffer_fifo_inst.w_fill_count : integer range G_DEPTH - 1 downto 0 >> ;
        -- ----------
    begin
        test_runner_setup(runner, runner_cfg);
        if run("fill-and-empty") then
            info("Running tb_sync_fifo-BASIC");

            wait until clk = '1';
            wait_clock(10, clk_period);

            for i in 0 to 1 loop
                -- Write 1/2
                for i in 0 to C_HALF_FULL_POINT - 1 loop
                    i_wr_data <= rand_slv(i_wr_data'length);
                    i_wr_en   <= '1';
                    wait_clock(1, clk_period);
                    i_wr_en                <= '0';
                    tb_compare_data_arr(i) <= i_wr_data;
                    wait_clock(1, clk_period);
                end loop;

                check(
                tb_fill_count = C_HALF_FULL_POINT,
                "Expected tb_fill_count=" & integer'image(C_HALF_FULL_POINT) & " but got (" & integer'image(tb_fill_count) & ")");

                -- Write 2/2
                for i in C_HALF_FULL_POINT to C_FULL_POINT - 1 loop
                    i_wr_data <= rand_slv(i_wr_data'length);
                    i_wr_en   <= '1';
                    wait_clock(1, clk_period);
                    i_wr_en                <= '0';
                    tb_compare_data_arr(i) <= i_wr_data;
                    wait_clock(1, clk_period);
                    if (i = C_FULL_POINT - 2) then
                        check(
                        o_full_next = '1',
                        "FULL_NEXT does not indicate correctly!");
                    end if;
                end loop;

                -- Write Checks 
                check(
                tb_fill_count = C_FULL_POINT,
                "Expected tb_fill_count=" & integer'image(C_FULL_POINT) & " but got (" & integer'image(tb_fill_count) & ")");
                check(
                o_full = '1',
                "FULL does not indicate correctly!");

                -- Read 1/2
                for j in 0 to C_HALF_FULL_POINT - 1 loop
                    i_rd_en <= '1';
                    wait_clock(1, clk_period);
                    i_rd_en <= '0';
                    wait until o_rd_valid = '1';
                    check(
                    o_rd_data = tb_compare_data_arr(j),
                    "Read wrong data! Exepcted (" & to_binary_string(tb_compare_data_arr(j)) & ") but got (" & to_binary_string(o_rd_data) & ")");
                    wait_clock(1, clk_period);
                end loop;

                check(
                tb_fill_count = C_HALF_FULL_POINT,
                "Expected tb_fill_count=" & integer'image(C_HALF_FULL_POINT) & " but got (" & integer'image(tb_fill_count) & ")");

                -- Read 2/2
                for j in C_HALF_FULL_POINT to C_FULL_POINT - 1 loop
                    i_rd_en <= '1';
                    wait_clock(1, clk_period);
                    i_rd_en <= '0';
                    wait until o_rd_valid = '1';
                    check(
                    o_rd_data = tb_compare_data_arr(j),
                    "Read wrong data! Exepcted (" & to_binary_string(tb_compare_data_arr(j)) & ") but got (" & to_binary_string(o_rd_data) & ")");
                    wait_clock(1, clk_period);
                    if (j = C_FULL_POINT - 2) then
                        check(
                        o_empty_next = '1',
                        "FULL_NEXT does not indicate correctly!");
                    end if;
                end loop;

                -- Read Checks
                check(
                tb_fill_count = 0,
                "Expected tb_fill_count=" & integer'image(C_FULL_POINT) & " but got (" & integer'image(tb_fill_count) & ")");
                check(
                o_empty = '1',
                "FULL does not indicate correctly!");

                wait_clock(5, clk_period);
            end loop;

            info("Completing tb_sync_fifo-BASIC");

        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ===============================================================
end;