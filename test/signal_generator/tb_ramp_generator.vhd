library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--
use std.textio.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity tb_ramp_generator is
    generic (
        runner_cfg     : string;
        G_FREQ_WIDTH   : natural := 16;
        G_TIME_WIDTH   : natural := 16;
        G_SYS_CLK_FREQ : natural := 100_000_000
    );
end;

architecture bench of tb_ramp_generator is
    constant clk_period : time := 5 ns;
    -- The divider operates on G_FREQ_WIDTH + C_FRAC_WIDTH = 32-bit data, taking 32 cycles.
    -- Wait 64 cycles to be safe.
    constant C_DIV_WAIT_CYCLES : natural := 64;
    constant C_FRAC_WIDTH      : natural := 16;
    -- Number of ms to capture per test case (enough to see at least one sweep reset)
    constant C_N_MS        : natural := 10;
    constant C_CLKS_PER_MS : natural := G_SYS_CLK_FREQ / 1000;

    signal clk                     : std_logic                                   := '0';
    signal i_en                    : std_logic                                   := '0';
    signal i_cfg_fc_data           : std_logic_vector(G_FREQ_WIDTH - 1 downto 0) := (others => '0');
    signal i_cfg_bw_data           : std_logic_vector(G_FREQ_WIDTH - 1 downto 0) := (others => '0');
    signal i_cfg_sweep_duration_ms : std_logic_vector(G_TIME_WIDTH - 1 downto 0) := (others => '0');
    signal i_cfg_valid             : std_logic                                   := '0';
    signal o_freq_data             : std_logic_vector(G_FREQ_WIDTH - 1 downto 0);
    signal o_freq_valid            : std_logic;

    signal tb_cfg_set   : boolean := false;
    signal tb_test_done : boolean := false;

    file tb_write_file : text;

    procedure wait_clock (clk_ticks : integer) is
    begin
        for i in 0 to clk_ticks - 1 loop
            wait until rising_edge(clk);
        end loop;
    end procedure;
begin
    -- ================================================================
    clk <= not clk after clk_period / 2;
    -- ================================================================
    p_read_and_write_file : process
        file v_read_file    : text open read_mode is output_path(runner_cfg) & "/" & "input_cfg.txt";
        variable v_line     : line;
        variable v_fc_data  : std_logic_vector(G_FREQ_WIDTH - 1 downto 0);
        variable v_bw_data  : std_logic_vector(G_FREQ_WIDTH - 1 downto 0);
        variable v_dur_data : std_logic_vector(G_TIME_WIDTH - 1 downto 0);
        variable v_cfg_idx  : integer := 0;
        variable v_smpl_cnt : integer := 0;
    begin
        tb_test_done <= false;
        wait until tb_cfg_set = true;

        while not endfile(v_read_file) loop
            -- Read one config line: fc_binary, bw_binary, duration_binary
            readline(v_read_file, v_line);
            BINARY_READ(v_line, v_fc_data);
            BINARY_READ(v_line, v_bw_data);
            BINARY_READ(v_line, v_dur_data);

            -- Drive config for one cycle
            wait until rising_edge(clk);
            i_cfg_fc_data           <= v_fc_data;
            i_cfg_bw_data           <= v_bw_data;
            i_cfg_sweep_duration_ms <= v_dur_data;
            i_cfg_valid             <= '1';
            wait until rising_edge(clk);
            i_cfg_valid <= '0';

            -- Wait for restoring divider to complete
            wait_clock(C_DIV_WAIT_CYCLES);

            -- Enable output
            i_en <= '1';

            -- Open output file and capture C_N_MS * C_CLKS_PER_MS valid samples
            file_open(tb_write_file, output_path(runner_cfg) & "/" & "output_freq_" & integer'image(v_cfg_idx) & ".txt", write_mode);
            v_smpl_cnt := 0;
            while v_smpl_cnt < C_N_MS * C_CLKS_PER_MS loop
                wait until rising_edge(clk);
                v_smpl_cnt := v_smpl_cnt + 1;
            end loop;
            i_en <= '0';
            v_cfg_idx := v_cfg_idx + 1;
            if (o_freq_valid = '1') then
                wait until o_freq_valid = '0';
            end if;
            file_close(tb_write_file);
        end loop;

        tb_test_done <= true;
        wait;
    end process p_read_and_write_file;
    -- ================================================================
    p_write_file : process
        variable v_line : line;
    begin
        while true loop
            wait until rising_edge(clk);
            if (o_freq_valid = '1') then
                write(v_line, o_freq_data, right, o_freq_data'length + 4);
                writeline(tb_write_file, v_line);
            end if;
        end loop;
        wait;
    end process p_write_file;
    -- ================================================================
    ramp_generator_inst : entity work.ramp_generator
        generic map(
            G_FREQ_WIDTH   => G_FREQ_WIDTH,
            G_TIME_WIDTH   => G_TIME_WIDTH,
            G_SYS_CLK_FREQ => G_SYS_CLK_FREQ
        )
        port map
        (
            clk                     => clk,
            i_en                    => i_en,
            i_cfg_fc_data           => i_cfg_fc_data,
            i_cfg_bw_data           => i_cfg_bw_data,
            i_cfg_sweep_duration_ms => i_cfg_sweep_duration_ms,
            i_cfg_valid             => i_cfg_valid,
            o_freq_data             => o_freq_data,
            o_freq_valid            => o_freq_valid
        );
    -- ================================================================
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        if run("postive_sweep") then
            info("Ramp generator test started");
            wait until clk = '1';
            wait_clock(1);
            tb_cfg_set <= true;
            wait until tb_test_done = true;
        elsif run("negative_sweep") then
            null;
        elsif run("no_sweep") then
            null;
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ================================================================
end;
