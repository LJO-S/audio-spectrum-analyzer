
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- 
use work.tb_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity gpio_ps_interface_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of gpio_ps_interface_tb is
    -- Clock period
    constant clk_period : time := 5 ns;
    -- Generics
    -- Ports
    signal clk_25                : std_logic := '0';
    signal i_lpf_incr            : std_logic := '0';
    signal i_lpf_decr            : std_logic := '0';
    signal i_hpf_incr            : std_logic := '0';
    signal i_hpf_decr            : std_logic := '0';
    signal i_updating_coeffs_lpf : std_logic := '0';
    signal i_updating_coeffs_hpf : std_logic := '0';
    signal i_ps_ack              : std_logic;
    signal o_fir_ctrl            : std_logic_vector(3 downto 0);
begin
    -- ========================================================================
    clk_25 <= not clk_25 after clk_period/2;
    -- ========================================================================
    gpio_ps_interface_inst : entity work.gpio_ps_interface
        port map
        (
            clk_25                => clk_25,
            i_lpf_incr            => i_lpf_incr,
            i_lpf_decr            => i_lpf_decr,
            i_hpf_incr            => i_hpf_incr,
            i_hpf_decr            => i_hpf_decr,
            i_updating_coeffs_lpf => i_updating_coeffs_lpf,
            i_updating_coeffs_hpf => i_updating_coeffs_hpf,
            i_ps_ack              => i_ps_ack,
            o_fir_ctrl            => o_fir_ctrl
        );
    -- ========================================================================
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("sequential-requests") then
                wait until clk_25 = '1';
                wait_clock(1, clk_period);

                -- Sequential write
                -- LPF++
                i_lpf_incr <= '1';
                wait_clock(1, clk_period);
                i_lpf_incr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = "0010", "Output to PS not held high until ACK!");
                i_ps_ack <= '1';
                wait_clock(1, clk_period);
                i_ps_ack <= '0';

                wait_clock(1, clk_period);

                -- LPF--
                i_lpf_decr <= '1';
                wait_clock(1, clk_period);
                i_lpf_decr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = "0001", "Output to PS not held high until ACK!");
                i_ps_ack <= '1';
                wait_clock(1, clk_period);
                i_ps_ack <= '0';

                -- HPF++
                i_hpf_incr <= '1';
                wait_clock(1, clk_period);
                i_hpf_incr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = "1000", "Output to PS not held high until ACK!");
                i_ps_ack <= '1';
                wait_clock(1, clk_period);
                i_ps_ack <= '0';

                -- HPF--
                i_hpf_decr <= '1';
                wait_clock(1, clk_period);
                i_hpf_decr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = "0100", "Output to PS not held high until ACK!");
                i_ps_ack <= '1';
                wait_clock(1, clk_period);
                i_ps_ack <= '0';

                test_runner_cleanup(runner);
            elsif run("clashing-requests") then
                wait until clk_25 = '1';
                wait_clock(1, clk_period);

                -- Clashing write
                -- LPF++/LPF--
                i_lpf_incr <= '1';
                i_lpf_decr <= '1';
                wait_clock(1, clk_period);
                i_lpf_incr <= '0';
                i_lpf_decr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = x"0", "Output to PS active even though clashing requests!");

                -- LPF++
                i_lpf_incr <= '1';
                wait_clock(1, clk_period);
                i_lpf_incr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = "0010", "Output to PS not held high until ACK!");
                i_ps_ack <= '1';
                wait_clock(1, clk_period);
                i_ps_ack <= '0';

                -- HPF++/HPF--
                i_hpf_incr <= '1';
                i_hpf_decr <= '1';
                wait_clock(1, clk_period);
                i_hpf_incr <= '0';
                i_hpf_decr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = x"0", "Output to PS active even though clashing requests!");

                -- HPF--
                i_hpf_decr <= '1';
                wait_clock(1, clk_period);
                i_hpf_decr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = "0100", "Output to PS not held high until ACK!");
                i_ps_ack <= '1';
                wait_clock(1, clk_period);
                i_ps_ack <= '0';

                test_runner_cleanup(runner);
            elsif run("clashing-with-updates") then
                wait until clk_25 = '1';
                wait_clock(1, clk_period);

                -- Clashing write
                -- LPF++
                i_lpf_incr <= '1';
                wait_clock(1, clk_period);
                i_lpf_incr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = "0010", "Output to PS not held high until ACK!");
                i_ps_ack <= '1';
                wait_clock(1, clk_period);
                i_ps_ack <= '0';

                -- Updating coeffs
                wait_clock(1, clk_period);
                i_updating_coeffs_lpf <= '1';

                -- LPF++
                i_lpf_incr <= '1';
                wait_clock(1, clk_period);
                i_lpf_incr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = x"0", "Output active when it should clash with update!");

                -- HPF--
                i_hpf_decr <= '1';
                wait_clock(1, clk_period);
                i_hpf_decr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = "0100", "Output to PS not held high until ACK!");
                i_ps_ack <= '1';
                wait_clock(1, clk_period);
                i_ps_ack <= '0';

                -- Now also updating HPF
                i_updating_coeffs_hpf <= '1';

                -- HPF--
                i_hpf_decr <= '1';
                wait_clock(1, clk_period);
                i_hpf_decr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = x"0", "Output active when it should clash with update!");

                test_runner_cleanup(runner);
            end if;
        end loop;
    end process main;
    -- ========================================================================
end;