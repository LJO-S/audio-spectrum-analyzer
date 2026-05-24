
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
    signal clk      : std_logic := '0';
    signal i_data_i : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal i_data_q : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal i_valid  : std_logic := '0';
    signal o_data_i : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal o_data_q : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal o_valid  : std_logic;
    signal o_ready  : std_logic;
    signal i_ready  : std_logic;
    signal o_last   : std_logic;
    -- Testbench
    signal tb_auto_set       : boolean := false;
    signal tb_auto_test_done : boolean := false;
    signal tb_output_cntr    : integer := 0;
    file tb_write_file       : text;
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
        file v_read_file       : text;
        variable v_line        : line;
        variable v_input_slv_i : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        variable v_input_slv_q : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        variable v_idx         : natural := 0;
    begin
        tb_auto_test_done <= false;
        wait until tb_auto_set = true;
        file_open(v_read_file, output_path(runner_cfg) & "/input_data.txt", read_mode);
        while not endfile(v_read_file) loop
            readline(v_read_file, v_line);
            BINARY_READ(v_line, v_input_slv_i);
            BINARY_READ(v_line, v_input_slv_q);
            i_data_i <= v_input_slv_i;
            i_data_q <= v_input_slv_q;
            i_valid  <= '1';
            if o_ready = '0' then
                wait until o_ready = '1';
            end if;
            if (v_idx = G_INPUT_DATA_DEPTH - 1) then
                v_idx := 0;
            else
                v_idx := v_idx + 1;
            end if;
            wait_clock(1);
            i_data_i <= (others => '0');
            i_data_q <= (others => '0');
            i_valid  <= '0';
            wait_clock(13);
            --   
        end loop;
        file_close(v_read_file);
        tb_auto_test_done <= true;
        i_data_i          <= (others => '0');
        i_data_q          <= (others => '0');
        i_valid           <= '0';
        wait;
    end process p_read_file;
    -- ================================================================
    process
        variable v_idx : natural := 0;
    begin
        while true loop
            wait until rising_edge(clk);
            i_ready <= '1';
            if (o_valid = '1') then
                v_idx := v_idx + 1;
            end if;
            -- Mimic i_ready hiccups
            if (v_idx = G_INPUT_DATA_DEPTH - 1) then
                v_idx := 0;
                i_ready <= '0';
                wait_clock(100);
            end if;
        end loop;
    end process;
    -- ================================================================
    p_write_file : process
        variable v_line : line;
    begin
        while true loop
            wait until rising_edge(clk);
            if (o_valid = '1') then
                write(v_line, o_data_i, right, o_data_i'length + 4);
                write(v_line, o_data_q, right, o_data_q'length + 4);
                writeline(tb_write_file, v_line);
            end if;
        end loop;
        wait;
    end process;
    -- ================================================================
    p_last_assert : process (clk)
    begin
        if rising_edge(clk) then
            if (o_valid = '1') then
                tb_output_cntr <= tb_output_cntr + 1;
                if (tb_output_cntr >= G_INPUT_DATA_DEPTH - 1) then
                    tb_output_cntr <= 0;
                    assert o_last = '1' report "o_last should be '1' at the last output sample" severity error;
                end if;
            end if;
        end if;
    end process p_last_assert;
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
            clk      => clk,
            i_data_i => i_data_i,
            i_data_q => i_data_q,
            i_valid  => i_valid,
            o_ready  => o_ready,
            o_data_i => o_data_i,
            o_data_q => o_data_q,
            o_valid  => o_valid,
            i_ready  => i_ready,
            o_last   => o_last
        );
    -- ================================================================
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        if run("auto") then
            file_open(tb_write_file, output_path(runner_cfg) & "/output_data.txt", write_mode);
            wait until clk = '1';
            tb_auto_set <= true;
            wait until tb_auto_test_done = true;
            file_close(tb_write_file);
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ================================================================
end;