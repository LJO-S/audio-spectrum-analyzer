
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
    constant clk_period : time := 10 ns;
    -- Generics
    -- Ports
    signal clk_100               : std_logic := '0';
    signal i_lpf_incr            : std_logic := '0';
    signal i_lpf_decr            : std_logic := '0';
    signal i_hpf_incr            : std_logic := '0';
    signal i_hpf_decr            : std_logic := '0';
    signal i_updating_coeffs_lpf : std_logic := '0';
    signal i_updating_coeffs_hpf : std_logic := '0';
    signal i_ps_ack              : std_logic := '0';
    signal o_fir_ctrl            : std_logic_vector(3 downto 0);

    signal o_lpf_incr            : std_logic;
    signal o_lpf_decr            : std_logic;
    signal o_hpf_incr            : std_logic;
    signal o_hpf_decr            : std_logic;
    signal o_new_data_strobe_lpf : std_logic;
    signal o_new_data_strobe_hpf : std_logic;
    signal i_new_data_strobe_lpf : std_logic := '0';
    signal i_new_data_strobe_hpf : std_logic := '0';
begin
    -- ========================================================================
    clk_100 <= not clk_100 after clk_period/2;
    -- ========================================================================
    gpio_ps_interface_inst : entity work.gpio_ps_interface
        port map
        (
            clk_100 => clk_100,
            -- GPIO PB Presses
            i_lpf_incr => i_lpf_incr,
            i_lpf_decr => i_lpf_decr,
            i_hpf_incr => i_hpf_incr,
            i_hpf_decr => i_hpf_decr,
            -- Successful incr/decr to video
            o_lpf_incr => o_lpf_incr,
            o_lpf_decr => o_lpf_decr,
            o_hpf_incr => o_hpf_incr,
            o_hpf_decr => o_hpf_decr,
            -- To Filters
            o_new_data_strobe_lpf => o_new_data_strobe_lpf,
            o_new_data_strobe_hpf => o_new_data_strobe_hpf,
            -- Busy signals from filters
            i_updating_coeffs_lpf => i_updating_coeffs_lpf,
            i_updating_coeffs_hpf => i_updating_coeffs_hpf,
            -- From PS
            i_new_data_strobe_lpf => i_new_data_strobe_lpf,
            i_new_data_strobe_hpf => i_new_data_strobe_hpf,
            i_ps_ack              => i_ps_ack,
            -- To PS
            o_fir_ctrl => o_fir_ctrl
        );

    -- ========================================================================
    main : process
        procedure ps_ack(
            constant nbr_cycles : in natural
        ) is
        begin
            i_ps_ack <= '1';
            wait_clock(nbr_cycles, clk_period);
            i_ps_ack <= '0';
            wait_clock(1, clk_period);
        end procedure;
        procedure new_data_lpf(
            constant nbr_cycles : in natural
        ) is
        begin
            i_new_data_strobe_lpf <= '1';
            wait_clock(nbr_cycles, clk_period);
            i_new_data_strobe_lpf <= '0';
            wait_clock(1, clk_period);
        end procedure;
        procedure new_data_hpf(
            constant nbr_cycles : in natural
        ) is
        begin
            i_new_data_strobe_hpf <= '1';
            wait_clock(nbr_cycles, clk_period);
            i_new_data_strobe_hpf <= '0';
            wait_clock(1, clk_period);
        end procedure;
        procedure updating_lpf(
            constant nbr_cycles : in natural
        ) is
        begin
            i_updating_coeffs_lpf <= '1';
            wait_clock(nbr_cycles, clk_period);
            i_updating_coeffs_lpf <= '0';
            wait_clock(1, clk_period);
        end procedure;
        procedure updating_hpf(
            constant nbr_cycles : in natural
        ) is
        begin
            i_updating_coeffs_hpf <= '1';
            wait_clock(nbr_cycles, clk_period);
            i_updating_coeffs_hpf <= '0';
            wait_clock(1, clk_period);
        end procedure;
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("sequential-requests") then
                wait until clk_100 = '1';
                wait_clock(1, clk_period);

                -- Sequential write
                -- LPF++
                i_lpf_incr <= '1';
                wait_clock(1, clk_period);
                i_lpf_incr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = "0010", "Output to PS not held high until ACK!");
                ps_ack(5);
                check(o_fir_ctrl = x"0", "Output to PS still high after ACK!");

                wait_clock(10, clk_period);
                new_data_lpf(5);
                updating_lpf(5);

                -- LPF--
                i_lpf_decr <= '1';
                wait_clock(1, clk_period);
                i_lpf_decr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = "0001", "Output to PS not held high until ACK!");
                ps_ack(5);
                check(o_fir_ctrl = x"0", "Output to PS still high after ACK!");

                wait_clock(10, clk_period);
                new_data_lpf(5);
                updating_lpf(5);

                -- HPF++
                i_hpf_incr <= '1';
                wait_clock(1, clk_period);
                i_hpf_incr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = "1000", "Output to PS not held high until ACK!");
                ps_ack(5);
                check(o_fir_ctrl = x"0", "Output to PS still high after ACK!");

                wait_clock(10, clk_period);
                new_data_hpf(5);
                updating_hpf(5);

                -- HPF--
                i_hpf_decr <= '1';
                wait_clock(1, clk_period);
                i_hpf_decr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = "0100", "Output to PS not held high until ACK!");
                ps_ack(5);
                check(o_fir_ctrl = x"0", "Output to PS still high after ACK!");

                wait_clock(10, clk_period);
                new_data_hpf(5);
                updating_hpf(5);

                test_runner_cleanup(runner);
            elsif run("clashing-requests") then
                wait until clk_100 = '1';
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
                ps_ack(5);
                wait_clock(10, clk_period);
                new_data_lpf(5);
                updating_lpf(5);

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
                ps_ack(5);
                wait_clock(10, clk_period);
                new_data_hpf(5);
                updating_hpf(5);
                test_runner_cleanup(runner);
            elsif run("clashing-with-updates") then
                wait until clk_100 = '1';
                wait_clock(1, clk_period);

                -- Clashing write
                -- LPF++
                i_lpf_incr <= '1';
                wait_clock(1, clk_period);
                i_lpf_incr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = "0010", "Output to PS not held high until ACK!");
                ps_ack(5);
                wait_clock(10, clk_period);
                new_data_lpf(5);
                -- Updating coeffs
                wait_clock(1, clk_period);
                i_updating_coeffs_lpf <= '1';

                -- LPF++ (clashing)
                i_lpf_incr <= '1';
                wait_clock(1, clk_period);
                i_lpf_incr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = x"0", "Output active when it should clash with update!");
                i_updating_coeffs_lpf <= '0';
                wait_clock(1, clk_period);

                -- HPF--
                i_hpf_decr <= '1';
                wait_clock(1, clk_period);
                i_hpf_decr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = "0100", "Output to PS not held high until ACK!");
                ps_ack(5);
                wait_clock(10, clk_period);
                new_data_hpf(5);
                -- Now also updating HPF
                i_updating_coeffs_hpf <= '1';

                -- HPF--
                i_hpf_decr <= '1';
                wait_clock(1, clk_period);
                i_hpf_decr <= '0';
                wait_clock(10, clk_period);

                check(o_fir_ctrl = x"0", "Output active when it should clash with update!");
                wait_clock(1, clk_period);
                i_updating_coeffs_hpf <= '1';
                wait_clock(1, clk_period);
                test_runner_cleanup(runner);
            end if;
        end loop;
    end process main;
    -- ========================================================================
end;