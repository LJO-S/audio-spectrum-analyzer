library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
-- 
use std.textio.all;
-- 
library vunit_lib;
context vunit_lib.vunit_context;

entity decimation_bank_tb is
    generic (
        runner_cfg         : string;
        G_MULTIRATE_FACTOR : natural := 2
    );
end;

architecture bench of decimation_bank_tb is
    -- Clock period
    constant clk_period : time := 5 ns;
    -- Generics
    constant G_INPUT_DATA_WIDTH : natural := 16;
    constant G_COEFF_DATA_WIDTH : natural := 16;
    constant G_INIT_FILE        : string  := output_path(runner_cfg) & "../../../../src/zoom/decimate/HBF_16";
    -- Ports
    signal clk                     : std_logic := '0';
    signal i_cfg_decimation_factor : std_logic_vector(3 downto 0);
    signal i_cfg_valid             : std_logic;
    signal i_data_i                : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal i_data_q                : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal i_data_valid            : std_logic;
    signal o_data_i                : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal o_data_q                : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal o_data_valid            : std_logic;
    -- Testbench
    signal tb_auto_set       : boolean := false;
    signal tb_auto_test_done : boolean := false;
    file tb_write_file       : text;
    -- Procedure
    procedure wait_clock (clk_ticks : integer) is
    begin
        for i in 0 to clk_ticks - 1 loop
            wait until rising_edge(clk);
        end loop;
    end procedure;
begin
    -- =========================================================================
    clk <= not clk after clk_period/2;
    -- =========================================================================
    decimation_bank_inst : entity work.decimation_bank
        generic map(
            G_INPUT_DATA_WIDTH => G_INPUT_DATA_WIDTH,
            G_COEFF_DATA_WIDTH => G_COEFF_DATA_WIDTH,
            G_INIT_FILE        => G_INIT_FILE
        )
        port map
        (
            clk                     => clk,
            i_cfg_decimation_factor => i_cfg_decimation_factor,
            i_cfg_valid             => i_cfg_valid,
            i_data_i                => i_data_i,
            i_data_q                => i_data_q,
            i_data_valid            => i_data_valid,
            o_data_i                => o_data_i,
            o_data_q                => o_data_q,
            o_data_valid            => o_data_valid
        );
    -- =========================================================================
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
            i_data_i     <= v_input_slv_i;
            i_data_q     <= v_input_slv_q;
            i_data_valid <= '1';
            wait_clock(1);
            i_data_i     <= (others => '0');
            i_data_q     <= (others => '0');
            i_data_valid <= '0';
            wait_clock(4);
            --   
        end loop;
        file_close(v_read_file);
        tb_auto_test_done <= true;
        i_data_i          <= (others => '0');
        i_data_q          <= (others => '0');
        i_data_valid      <= '0';
        wait;
    end process p_read_file;
    -- =========================================================================
    p_write_file : process
        variable v_line : line;
    begin
        while true loop
            wait until rising_edge(clk);
            if (o_data_valid = '1') then
                write(v_line, o_data_i, right, o_data_i'length + 4);
                write(v_line, o_data_q, right, o_data_q'length + 4);
                writeline(tb_write_file, v_line);
            end if;
        end loop;
        wait;
    end process;
    -- =========================================================================
    main : process
        procedure set_decimate_cfg is
        begin
            if G_MULTIRATE_FACTOR = 2 then
                i_cfg_decimation_factor <= "0001"; -- Decimate by 2
            elsif G_MULTIRATE_FACTOR = 4 then
                i_cfg_decimation_factor <= "0010"; -- Decimate by 4
            elsif G_MULTIRATE_FACTOR = 8 then
                i_cfg_decimation_factor <= "0100"; -- Decimate by 8
            elsif G_MULTIRATE_FACTOR = 16 then
                i_cfg_decimation_factor <= "1000"; -- Decimate by 16
            else
                assert FALSE report "Unsupported decimation factor for testbench!" severity FAILURE;
            end if;
            i_cfg_valid <= '1';
            wait_clock(1);
            i_cfg_decimation_factor <= (others => '0');
            i_cfg_valid             <= '0';
        end procedure;
    begin
        test_runner_setup(runner, runner_cfg);
        if run("auto") then
            file_open(tb_write_file, output_path(runner_cfg) & "/output_data.txt", write_mode);
            wait until clk = '1';
            set_decimate_cfg;
            tb_auto_set <= true;
            wait until tb_auto_test_done = true;
            file_close(tb_write_file);
        elsif run("visual") then
            file_open(tb_write_file, output_path(runner_cfg) & "/output_data.txt", write_mode);
            tb_auto_set <= true;
            ---------------
            -- Bypass
            ---------------
            i_cfg_decimation_factor <= "0000"; -- Bypass
            i_cfg_valid             <= '1';
            wait_clock(1);
            i_cfg_decimation_factor <= (others => '0');
            i_cfg_valid             <= '0';
            wait_clock(100);
            ---------------
            -- Decimate by 2
            ---------------
            i_cfg_decimation_factor <= "0001"; -- Decimate by 2
            i_cfg_valid             <= '1';
            wait_clock(1);
            i_cfg_decimation_factor <= (others => '0');
            i_cfg_valid             <= '0';
            wait_clock(100);
            ---------------
            -- Decimate by 4
            ---------------
            i_cfg_decimation_factor <= "0010"; -- Decimate by 4
            i_cfg_valid             <= '1';
            wait_clock(1);
            i_cfg_decimation_factor <= (others => '0');
            i_cfg_valid             <= '0';
            wait_clock(100);
            ---------------
            -- Decimate by 8
            ---------------
            i_cfg_decimation_factor <= "0100"; -- Decimate by 8
            i_cfg_valid             <= '1';
            wait_clock(1);
            i_cfg_decimation_factor <= (others => '0');
            i_cfg_valid             <= '0';
            wait_clock(100);
            ---------------
            -- Decimate by 16
            ---------------
            i_cfg_decimation_factor <= "1000"; -- Decimate by 16
            i_cfg_valid             <= '1';
            wait_clock(1);
            i_cfg_decimation_factor <= (others => '0');
            i_cfg_valid             <= '0';
            wait_clock(100);
            wait until tb_auto_test_done = true;
            file_close(tb_write_file);
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- =========================================================================
end;