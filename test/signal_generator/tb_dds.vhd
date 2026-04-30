library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--
use std.textio.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity dds_tb is
    generic (
        runner_cfg          : string;
        G_FREQ_WIDTH        : natural;
        G_DATA_WIDTH        : natural;
        G_ACCUMULATOR_WIDTH : natural;
        G_LUT_ADDR_WIDTH    : natural;
        G_SYS_CLK_HZ        : natural;
        G_INIT_FILE         : string
    );
end;

architecture bench of dds_tb is
    -- Clock period
    constant clk_period : time := 5 ns;
    -- Generics
    constant TB_INIT_FILE : string := output_path(runner_cfg) & "/" & G_INIT_FILE;
    -- Ports
    signal clk         : std_logic := '0';
    signal i_cfg_freq  : std_logic_vector(G_FREQ_WIDTH - 1 downto 0);
    signal i_cfg_valid : std_logic;
    signal o_data_i    : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal o_data_q    : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal o_valid     : std_logic;
    -- Testbench
    signal auto_freq_input        : std_logic_vector(G_FREQ_WIDTH - 1 downto 0);
    signal auto_freq_valid        : std_logic;
    signal tb_output_data_i_float : real    := 0.0;
    signal tb_output_data_q_float : real    := 0.0;
    signal tb_auto_set            : boolean := false;
    signal tb_auto_set_done       : boolean := false;
    signal tb_auto_test_done      : boolean := false;
    signal tb_nbr_of_samples      : integer := 0;

    file tb_write_file : text;
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
    p_read_input_file : process
        file v_read_file      : text open read_mode is output_path(runner_cfg) & "/" & "input_freqs.txt";
        variable v_line       : line;
        variable v_freq_input : std_logic_vector(G_FREQ_WIDTH - 1 downto 0);
    begin
        tb_auto_test_done <= false;
        wait until tb_auto_set = TRUE;
        while not endfile(v_read_file) loop
            readline(v_read_file, v_line);
            BINARY_READ(v_line, v_freq_input);
            auto_freq_input   <= v_freq_input;
            auto_freq_valid   <= '1';
            tb_nbr_of_samples <= integer(real(G_SYS_CLK_HZ) / abs(real(to_integer(signed(v_freq_input))))); -- Capture 1 period of the output signal
            wait until tb_auto_set_done = true;
            wait_clock(1);
            auto_freq_valid <= '0';
            wait_clock(1);
        end loop;
        auto_freq_input   <= (others => '0');
        auto_freq_valid   <= '0';
        tb_auto_test_done <= true;
        wait;
    end process p_read_input_file;
    -- ================================================================
    i_cfg_freq  <= auto_freq_input;
    i_cfg_valid <= auto_freq_valid;
    -- ================================================================
    p_write_output_file : process
        variable v_line           : line;
        variable v_freq_idx       : integer := 0;
        variable v_sample_counter : integer := 0;
    begin
        -- Wait until the main test starts so tb_nbr_of_samples is valid before first capture
        wait until tb_auto_set = TRUE;
        while not tb_auto_test_done loop
            -- Wait for the reader to present a new frequency before opening the next file
            wait until (auto_freq_valid = '1') or (tb_auto_test_done = true);
            exit when tb_auto_test_done;
            file_open(tb_write_file, "output_data_" & integer'image(v_freq_idx) & ".txt", write_mode);
            while (v_sample_counter < tb_nbr_of_samples) loop
                wait until rising_edge(clk);
                if (o_valid = '1') then
                    write(v_line, o_data_i, right, o_data_i'length + 4);
                    write(v_line, o_data_q, right, o_data_q'length + 4);
                    writeline(tb_write_file, v_line);
                    v_sample_counter := v_sample_counter + 1;
                end if;
            end loop;
            v_freq_idx       := v_freq_idx + 1;
            v_sample_counter := 0;
            file_close(tb_write_file);
            tb_auto_set_done <= true;
            -- Wait for the reader to deassert valid before resetting the handshake
            wait until auto_freq_valid = '0';
            tb_auto_set_done <= false;
        end loop;
    end process p_write_output_file;
    -- ================================================================
    dds_inst : entity work.dds
        generic map(
            G_FREQ_WIDTH        => G_FREQ_WIDTH,
            G_DATA_WIDTH        => G_DATA_WIDTH,
            G_ACCUMULATOR_WIDTH => G_ACCUMULATOR_WIDTH,
            G_LUT_ADDR_WIDTH    => G_LUT_ADDR_WIDTH,
            G_SYS_CLK_HZ        => G_SYS_CLK_HZ,
            G_INIT_FILE         => TB_INIT_FILE
        )
        port map
        (
            clk         => clk,
            i_cfg_freq  => i_cfg_freq,
            i_cfg_valid => i_cfg_valid,
            o_data_i    => o_data_i,
            o_data_q    => o_data_q,
            o_valid     => o_valid
        );
    -- ================================================================
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        if run("auto") then
            info("Hello world!");
            wait until clk = '1';
            wait_clock(1);
            tb_auto_set <= true;
            wait until tb_auto_test_done = true;
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ================================================================
    tb_output_data_i_float <= real(to_integer(signed(o_data_i))) / (2.0 ** (G_DATA_WIDTH - 2));
    tb_output_data_q_float <= real(to_integer(signed(o_data_q))) / (2.0 ** (G_DATA_WIDTH - 2));
    -- ================================================================
end;
