
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
use std.textio.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity window_function_time_tb is
    generic (
        runner_cfg          : string;
        G_INPUT_DATA_WIDTH  : natural;
        G_INPUT_DATA_DEPTH  : natural;
        G_WINDOW_DATA_WIDTH : natural
    );
end;

architecture bench of window_function_time_tb is
    -- Clock period
    constant clk_period : time := 5 ns;
    -- Generics
    constant G_INIT_FILE : string := output_path(runner_cfg) & "/window_coefficients.txt";
    -- Ports
    signal clk     : std_logic;
    signal i_data  : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal i_valid : std_logic;
    signal i_last  : std_logic;
    signal o_ready : std_logic;
    signal o_data  : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal o_valid : std_logic;
    signal o_last  : std_logic;
    -- Testbench
    signal tb_auto_set       : boolean := false;
    signal tb_auto_test_done : boolean := false;
    -- Procedure
    procedure wait_clock (clk_ticks : integer) is
    begin
        for i in 0 to clk_ticks - 1 loop
            wait until rising_edge(clk);
        end loop;
    end procedure;
begin
    -- ================================================================
    clk <= not clk after clk_period/2;
    -- ================================================================
    p_read_file : process
        file v_read_file     : text;
        variable v_line      : line;
        variable v_input_slv : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    begin
        tb_auto_test_done <= false;
        wait until tb_auto_set = true;
        file_open(v_read_file, output_path(runner_cfg) & "/input_data.txt", read_mode);
        while not endfile(v_read_file) loop
            wait_clock(1);
            readline(v_read_file, v_line);
            BINARY_READ(v_line, v_input_slv);
            -- Ready
            if (o_ready = '0') then
                wait until o_ready = '1';
            end if;
            i_data  <= v_input_slv;
            i_valid <= '1';
            wait_clock(1);
            i_data  <= (others => '0');
            i_valid <= '0';
            --   
        end loop;
        file_close(v_read_file);
        tb_auto_test_done <= true;
        wait;
    end process p_read_file;
    -- ================================================================
    p_write_file : process
        file v_write_file : text open write_mode is output_path(runner_cfg) & "/output_data.txt";
        variable v_line   : line;
    begin
        while true loop
            wait until rising_edge(clk);
            if (o_valid = '1') then
                write(v_line, o_data, right, o_data'length + 4);
                writeline(v_write_file, v_line);
            end if;
        end loop;
        wait;
    end process;
    -- ================================================================
    window_function_time_inst : entity work.window_function_time
        generic map(
            G_INPUT_DATA_WIDTH  => G_INPUT_DATA_WIDTH,
            G_INPUT_DATA_DEPTH  => G_INPUT_DATA_DEPTH,
            G_WINDOW_DATA_WIDTH => G_WINDOW_DATA_WIDTH,
            G_INIT_FILE         => G_INIT_FILE
        )
        port map
        (
            clk     => clk,
            i_data  => i_data,
            i_valid => i_valid,
            i_last  => i_last,
            o_ready => o_ready,
            o_data  => o_data,
            o_valid => o_valid,
            o_last  => o_last
        );
    -- ================================================================
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        if run("auto") then
            wait until clk = '1';
            tb_auto_set <= true;
            wait until tb_auto_test_done = true;
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ================================================================
end;