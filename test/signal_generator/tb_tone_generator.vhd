library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity tone_generator_tb is
    generic (
        runner_cfg : string
    );
end;

architecture testbench of tone_generator_tb is
    constant clk_period             : time    := 5 ns;
    constant G_FREQ_DATA_WIDTH      : natural := 16;
    constant G_TIME_WIDTH           : natural := 16;
    constant G_FREQ_DATA_FRAC_WIDTH : natural := 16;

    constant G_SYS_CLK_FREQ : natural := 5_000_000;

    signal clk                     : std_logic                                        := '0';
    signal i_en                    : std_logic                                        := '0';
    signal i_cfg_fc_data           : std_logic_vector(G_FREQ_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal i_cfg_bw_data           : std_logic_vector(G_FREQ_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal i_cfg_sweep_duration_ms : std_logic_vector(G_TIME_WIDTH - 1 downto 0)      := (others => '0');
    signal i_cfg_valid             : std_logic                                        := '0';
    signal o_freq_data             : std_logic_vector(G_FREQ_DATA_WIDTH - 1 downto 0);
    signal o_freq_valid            : std_logic;

    signal w_ms_strobe : std_logic;

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
    ms_strobe_generator_inst : entity work.ms_strobe_generator
        generic map(
            G_SYS_CLK_FREQ => G_SYS_CLK_FREQ
        )
        port map
        (
            clk         => clk,
            o_ms_strobe => w_ms_strobe
        );
    -- ================================================================
    tone_generator_inst : entity work.tone_generator
        generic map(
            G_FREQ_DATA_WIDTH      => G_FREQ_DATA_WIDTH,
            G_FREQ_DATA_FRAC_WIDTH => G_FREQ_DATA_FRAC_WIDTH,
            G_TIME_WIDTH           => G_TIME_WIDTH
        )
        port map
        (
            clk                     => clk,
            i_en                    => i_en,
            i_ms_strobe             => w_ms_strobe,
            i_cfg_fc_data           => i_cfg_fc_data,
            i_cfg_bw_data           => i_cfg_bw_data,
            i_cfg_sweep_duration_ms => i_cfg_sweep_duration_ms,
            i_cfg_valid             => i_cfg_valid,
            o_freq_data             => o_freq_data,
            o_freq_valid            => o_freq_valid
        );
    -- ================================================================
    main : process
        variable v_cfg_fc_data           : integer := 0;
        variable v_cfg_bw_data           : integer := 0;
        variable v_cfg_sweep_duration_ms : integer := 0;

        -- Procedures
        procedure configure (
            constant i_p_fc  : integer;
            constant i_p_bw  : integer;
            constant i_p_dur : integer
        ) is
        begin
            i_cfg_fc_data           <= std_logic_vector(to_signed(i_p_fc, G_FREQ_DATA_WIDTH));
            i_cfg_bw_data           <= std_logic_vector(to_signed(i_p_bw, G_FREQ_DATA_WIDTH));
            i_cfg_sweep_duration_ms <= std_logic_vector(to_signed(i_p_dur, G_TIME_WIDTH));
            i_cfg_valid             <= '1';
            wait_clock(1);
            i_cfg_fc_data           <= (others => '0');
            i_cfg_bw_data           <= (others => '0');
            i_cfg_sweep_duration_ms <= (others => '0');
            i_cfg_valid             <= '0';
        end procedure;

        procedure check_output (
            constant i_p_fc_data           : integer;
            constant i_p_bw_data           : integer;
            constant i_p_sweep_duration_ms : integer
        ) is
            variable v_expected_value : real    := 0.0;
            variable v_sample_counter : integer := 0;
            variable v_idx_counter    : integer := 0;
            variable v_freq_delta     : real    := 0.0;
        begin
            wait_clock(64);
            i_en <= '1';
            if (o_freq_valid = '0') then
                wait until o_freq_valid = '1';
            end if;

            if (i_p_sweep_duration_ms = 0) then
                v_freq_delta := 0.0;
            elsif (i_p_bw_data >= 0) then
                -- Mirror hardware: dividend = |BW| << FRAC_WIDTH, divisor = DUR (integer division)
                v_freq_delta := real(i_p_bw_data * (2 ** G_FREQ_DATA_FRAC_WIDTH) / i_p_sweep_duration_ms) / (2.0 ** G_FREQ_DATA_FRAC_WIDTH);
            else
                v_freq_delta := - real(abs(i_p_bw_data) * (2 ** G_FREQ_DATA_FRAC_WIDTH) / i_p_sweep_duration_ms) / (2.0 ** G_FREQ_DATA_FRAC_WIDTH);
            end if;

            v_sample_counter := 0;
            v_idx_counter    := 0;
            while v_sample_counter < (i_p_sweep_duration_ms * 2) - 1 loop
                v_expected_value := real(i_p_fc_data) + (real(v_idx_counter) * v_freq_delta);
                v_idx_counter    := v_idx_counter + 1;
                if ((i_p_bw_data >= 0) and (v_expected_value >= (real(i_p_fc_data) + abs(real(i_p_bw_data))))) or
                    ((i_p_bw_data < 0) and (v_expected_value <= (real(i_p_fc_data) - abs((real(i_p_bw_data)))))) then
                    v_expected_value := real(i_p_fc_data);
                    v_idx_counter    := 1;
                end if;
                check_equal(
                real(to_integer(signed(o_freq_data))),
                v_expected_value,
                "Mismatch value for BW=" &
                integer'image(i_p_bw_data) &
                " DUR=" &
                integer'image(i_p_sweep_duration_ms) &
                " FC=" &
                integer'image(i_p_fc_data) & LF &
                "Expected=" &
                integer'image(integer(v_expected_value)) &
                " vs actual=" &
                integer'image(to_integer(signed(o_freq_data))),
                max_diff => 1.0 * round(real(v_idx_counter)) + 1.0
                );
                wait until rising_edge(w_ms_strobe);
                -- Arbitrary wait so new value takes place
                wait_clock(32);
                v_sample_counter := v_sample_counter + 1;
            end loop;
            i_en <= '0';
            wait_clock(32);
        end procedure;
        variable v_seed1, v_seed2 : integer := 999;
        impure function f_rand_int (
            min_val : integer;
            max_val : integer
        ) return integer is
            variable v_real : real;
        begin
            uniform(v_seed1, v_seed2, v_real);
            return integer(
            round(v_real * real(max_val - min_val + 1) + real(min_val) - 0.5)
            );
        end function;
    begin
        test_runner_setup(runner, runner_cfg);
        if run("positive_sweeps") then
            info("Ramp generator test started");
            wait until clk = '1';
            -----------------
            -- Testcases 1
            -----------------
            for i in 0 to 9 loop
                v_cfg_fc_data           := f_rand_int(10, 2 ** (G_FREQ_DATA_WIDTH - 2) - 1);
                v_cfg_bw_data           := f_rand_int(10, 2 ** (G_FREQ_DATA_WIDTH - 2) - 1);
                v_cfg_sweep_duration_ms := f_rand_int(1, 100);
                configure(v_cfg_fc_data, v_cfg_bw_data, v_cfg_sweep_duration_ms);
                check_output(v_cfg_fc_data, v_cfg_bw_data, v_cfg_sweep_duration_ms);
            end loop;
            -----------------
            -- Testcase 2
            -----------------
            v_cfg_fc_data           := f_rand_int(10, 2 ** (G_FREQ_DATA_WIDTH - 2) - 1);
            v_cfg_bw_data           := 0;
            v_cfg_sweep_duration_ms := f_rand_int(1, 2);
            configure(v_cfg_fc_data, v_cfg_bw_data, v_cfg_sweep_duration_ms);
            check_output(v_cfg_fc_data, v_cfg_bw_data, v_cfg_sweep_duration_ms);
            -----------------
            -- Testcase 2
            -----------------
            v_cfg_fc_data           := f_rand_int(10, 2 ** (G_FREQ_DATA_WIDTH - 2) - 1);
            v_cfg_bw_data           := f_rand_int(1, 100);
            v_cfg_sweep_duration_ms := 0;
            configure(v_cfg_fc_data, v_cfg_bw_data, v_cfg_sweep_duration_ms);
            check_output(v_cfg_fc_data, v_cfg_bw_data, v_cfg_sweep_duration_ms);

            wait_clock(1);
        elsif run("negative_sweep") then
            info("Ramp generator test started");
            wait until clk = '1';
            -----------------
            -- Testcases 1
            -----------------
            for i in 0 to 9 loop
                v_cfg_fc_data           := f_rand_int(10, 2 ** (G_FREQ_DATA_WIDTH - 2) - 1);
                v_cfg_bw_data           := f_rand_int(-10, -2 ** (G_FREQ_DATA_WIDTH - 2) - 1);
                v_cfg_sweep_duration_ms := f_rand_int(1, 100);
                configure(v_cfg_fc_data, v_cfg_bw_data, v_cfg_sweep_duration_ms);
                check_output(v_cfg_fc_data, v_cfg_bw_data, v_cfg_sweep_duration_ms);
            end loop;
            -----------------
            -- Testcase 2
            -----------------
            v_cfg_fc_data           := f_rand_int(10, 2 ** (G_FREQ_DATA_WIDTH - 2) - 1);
            v_cfg_bw_data           := 0;
            v_cfg_sweep_duration_ms := f_rand_int(1, 2);
            configure(v_cfg_fc_data, v_cfg_bw_data, v_cfg_sweep_duration_ms);
            check_output(v_cfg_fc_data, v_cfg_bw_data, v_cfg_sweep_duration_ms);
            -----------------
            -- Testcase 2
            -----------------
            v_cfg_fc_data           := f_rand_int(10, 2 ** (G_FREQ_DATA_WIDTH - 2) - 1);
            v_cfg_bw_data           := f_rand_int(-1, 100);
            v_cfg_sweep_duration_ms := 0;
            configure(v_cfg_fc_data, v_cfg_bw_data, v_cfg_sweep_duration_ms);
            check_output(v_cfg_fc_data, v_cfg_bw_data, v_cfg_sweep_duration_ms);

            wait_clock(1);
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ================================================================
end;
