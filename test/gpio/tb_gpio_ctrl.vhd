
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
library vunit_lib;
context vunit_lib.vunit_context;
--
use work.tb_pkg.all;
-- 
entity gpio_ctrl_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of gpio_ctrl_tb is
    -- Clock period
    constant clk_period : time := 10 ns;
    -- Generics
    constant G_DEBOUNCE_LIMIT : natural := 25;
    constant G_DEBUG          : boolean := true;
    -- Ports
    signal clk_100           : std_logic := '0';
    signal i_pb_vector       : std_logic_vector(3 downto 0);
    signal i_dip_vector      : std_logic_vector(3 downto 0);
    signal i_uart_gpio_if    : std_logic_vector(31 downto 0);
    signal o_dds_ctrl        : std_logic_vector(3 downto 0);
    signal o_lpf_en          : std_logic;
    signal o_lpf_incr        : std_logic;
    signal o_lpf_decr        : std_logic;
    signal o_hpf_en          : std_logic;
    signal o_hpf_incr        : std_logic;
    signal o_hpf_decr        : std_logic;
    signal o_waterfall_en    : std_logic;
    signal o_oscilloscope_en : std_logic;
    signal o_sel_up_lo       : std_logic;
    signal o_capture_en      : std_logic;
begin
    /* ---------------------------------------------------------- */
    clk_100 <= not clk_100 after clk_period/2;

    gpio_ctrl_inst : entity work.gpio_ctrl
        generic map(
            G_DEBOUNCE_LIMIT => G_DEBOUNCE_LIMIT,
            G_DEBUG          => G_DEBUG
        )
        port map
        (
            clk_100           => clk_100,
            i_pb_vector       => i_pb_vector,
            i_dip_vector      => i_dip_vector,
            i_uart_gpio_if    => i_uart_gpio_if,
            o_dds_ctrl        => o_dds_ctrl,
            o_lpf_en          => o_lpf_en,
            o_lpf_incr        => o_lpf_incr,
            o_lpf_decr        => o_lpf_decr,
            o_hpf_en          => o_hpf_en,
            o_hpf_incr        => o_hpf_incr,
            o_hpf_decr        => o_hpf_decr,
            o_waterfall_en    => o_waterfall_en,
            o_oscilloscope_en => o_oscilloscope_en,
            o_sel_up_lo       => o_sel_up_lo,
            o_capture_en      => o_capture_en
        );
    /* ---------------------------------------------------------- */
    -- dip0: up/lo select
    -- dip1: lpf en
    -- dip2: hpf en
    -- dip3: capture en
    -- 
    -- pb0: src 0/4 OR lpf++
    -- pb1: src 1/5 OR lpf--
    -- pb2: src 2/6 OR hpf++
    -- pb3: src 3/7 OR hpf--
    /* ---------------------------------------------------------- */
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(error);
        if run("auto") then
            info("Running tb_gpio_ctrl-auto");
            -- ---------------------------
            -- Default
            i_pb_vector  <= "0000";
            i_dip_vector <= "0000";
            -- ---------------------------
            -- Testing mode A(internal) + up/lo selector;
            for i in 0 to 1 loop
                if i = 1 then
                    i_dip_vector(0) <= '1';
                    wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
                    check(o_sel_up_lo = '1', "Expected SigGen source UP/LO to be active");
                end if;
                for j in 0 to 3 loop
                    i_pb_vector    <= "0000";
                    i_pb_vector(j) <= '1';
                    wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
                    check(o_dds_ctrl(j) = '1', "Expected SigGen source " & integer'image(j) & " to be active");
                end loop;
            end loop;
            i_pb_vector  <= x"0";
            i_dip_vector <= 4b"0"; -- some vhdl-2008 syntax
            wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
            check(o_dds_ctrl = (o_dds_ctrl'range => '0'), "Expected SigGen sources to be all zeros");
            check(o_sel_up_lo = '0', "Expected UP/LO selector to be zero");
            -- ---------------------------
            -- Testing mode B(capture):

            -- Enable capture
            i_dip_vector(3) <= '1';
            wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
            check(o_capture_en = '1', "Expected capture enabled");

            -- Enable Waterfall
            i_dip_vector(0) <= '1';
            wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
            check(o_waterfall_en = '1', "Expected WATERFALL enabled");

            -- Enable LPF
            i_dip_vector(1) <= '1';
            wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
            check(o_lpf_en = '1', "Expected LPF enabled");

            -- Enable HPF
            i_dip_vector(2) <= '1';
            wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
            check(o_hpf_en = '1', "Expected HPF enabled");
            -- ---------------------------
            -- Test incr/decr filters

            -- LPF++
            i_pb_vector(0) <= '1';
            wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
            check(o_lpf_incr = '1', "Expected LPF incr strobe HI");
            wait_clock(1, clk_period);
            check(o_lpf_incr = '0', "Expected LPF incr strobe LO");
            i_pb_vector(0) <= '0';

            -- LPF--
            i_pb_vector(1) <= '1';
            wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
            check(o_lpf_decr = '1', "Expected LPF decr strobe HI");
            wait_clock(1, clk_period);
            check(o_lpf_decr = '0', "Expected LPF decr strobe LO");
            i_pb_vector(1) <= '0';

            -- HPF++
            i_pb_vector(2) <= '1';
            wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
            check(o_hpf_incr = '1', "Expected HPF incr strobe HI");
            wait_clock(1, clk_period);
            check(o_hpf_incr = '0', "Expected HPF incr strobe LO");
            i_pb_vector(2) <= '0';

            -- HPF--
            i_pb_vector(3) <= '1';
            wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
            check(o_hpf_decr = '1', "Expected HPF decr strobe HI");
            wait_clock(1, clk_period);
            check(o_hpf_decr = '0', "Expected HPF decr strobe LO");
            i_pb_vector(3) <= '0';
            -- ---------------------------
            -- Test capture off (including the rest turning off)
            i_dip_vector(3) <= '0';
            wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
            check(o_sel_up_lo = '1', "Expected on: sel up/lo");
            check(o_lpf_en = '0', "Expected off: lpf");
            check(o_lpf_incr = '0', "Expected off: lpf++");
            check(o_lpf_decr = '0', "Expected off : lpf--");
            check(o_hpf_en = '0', "Expected off: hpf");
            check(o_hpf_incr = '0', "Expected off: hpf++");
            check(o_hpf_decr = '0', "Expected off : hpf--");
            check(o_capture_en = '0', "Expected off : capture");
            -- ---------------------------
            -- Test UART
            i_uart_gpio_if(0) <= '1';
            wait_clock(1, clk_period);
            check(o_oscilloscope_en = '1', "Expected on : oscilloscope");
            i_uart_gpio_if(0) <= '0';
            wait_clock(1, clk_period);
            check(o_oscilloscope_en = '0', "Expected off : oscilloscope");
            -- ---------------------------
            info("Successfully ran tb_gpio_ctrl-BASIC!");
            test_runner_cleanup(runner);
        end if;
    end process main;
    /* ---------------------------------------------------------- */
end;