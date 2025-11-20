library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--
use work.tb_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity ping_pong_memory_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of ping_pong_memory_tb is
    -- Clock period
    constant clk_period   : time    := 5 ns;
    constant C_RD_LATENCY : natural := 5;
    constant C_NFFT       : natural := 1024;
    constant C_LOG2_NFFT  : integer := integer(ceil(log2(real(C_NFFT))));
    -- Generics
    -- Ports
    signal clk_25           : std_logic                               := '0';
    signal i_fft_data_magn  : std_logic_vector(31 downto 0)           := (others => '0');
    signal i_fft_data_last  : std_logic                               := '0';
    signal i_fft_data_valid : std_logic                               := '0';
    signal i_xk_index       : std_logic_vector(C_LOG2_DEPTH downto 0) := (others => '0');
    signal i_rd_addr        : std_logic_vector(C_LOG2_DEPTH downto 0) := (others => '0');
    signal o_rd_data        : std_logic_vector(31 downto 0);
    -- Helper signals
    signal tb_enable           : std_logic := '0';
    signal tb_clk_strobe       : std_logic := '0';
    signal tb_use_slow_readout : std_logic := '1';
    signal tb_latency_cntr     : integer   := 0;
    signal tb_latency_done     : std_logic := '0';

begin
    -- ======================================================================
    clk_25 <= not clk_25 after clk_period/2;
    -- ======================================================================

    ping_pong_memory_inst : entity work.ping_pong_memory
        port map
        (
            clk_25           => clk_25,
            i_fft_data_magn  => i_fft_data_magn,
            i_fft_data_last  => i_fft_data_last,
            i_fft_data_valid => i_fft_data_valid,
            i_xk_index       => i_xk_index,
            i_rd_addr        => i_rd_addr,
            o_rd_data        => o_rd_data
        );
    -- ======================================================================
    p_input_data : process (clk_25)
    begin
        if rising_edge(clk_25) then
            if (tb_enable = '1') then
                i_fft_data_magn  <= std_logic_vector(resize(unsigned(i_xk_index), i_fft_data_magn'length));
                i_fft_data_valid <= '1';

                i_fft_data_last <= '0';
                if (i_xk_index = C_NFFT - 1) then
                    i_xk_index      <= 0;
                    i_fft_data_last <= '1';
                else
                    i_xk_index <= i_xk_index + 1;
                end if;
            end if;
        end if;
    end process p_input_data;
    -- ======================================================================
    p_rd_addr : process (clk_25)
    begin
        if rising_edge(clk_25) then
            if (tb_use_slow_readout = '1') then
                tb_clk_strobe <= not tb_clk_strobe;
            else
                tb_clk_strobe <= '1';
            end if;
            if (tb_enable = '1') and (tb_clk_strobe = '1') then
                i_rd_addr <= std_logic_vector(unsigned(i_rd_addr) + 1);
            end if;
        end if;
    end process p_rd_addr;
    -- ======================================================================
    p_check_output : process (clk)
    begin
        if rising_edge(clk) then
            if (tb_enable = '1') then
                -- ---------------------
                -- Latency Cntr
                if tb_latency_cntr < C_RD_LATENCY then
                    tb_latency_cntr <= tb_latency_cntr + 1;
                else
                    tb_latency_done <= '1';
                end if;
                -- ---------------------'
                if (tb_latency_done = '1') then
                    -- TODO check so that every i_rd_addr gets matched at its output, always!!
                    null;
                end if;
            else
                tb_latency_cntr <= 0;
                tb_latency_done <= '0';
            end if;
        end if;
    end process p_check_output;
    -- ======================================================================

    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            -----------------------------------------------------
            if run("slow-readout") then
                info("Running test of ping_pong memory SLOW readout!");
                tb_use_slow_readout <= '1';
                wait until (clk_25 = '1');
                wait_clock(10, clk_period);
                tb_enable <= '1';
                wait_clock(2 * C_NFFT + 10, clk_period);
                test_runner_cleanup(runner);
                -----------------------------------------------------
            elsif run("fast-readout-auto") then
                info("Running tb_ping_pong-fast-readout-auto!");
                tb_use_slow_readout <= '0';
                wait until (clk_25 = '1');
                wait_clock(10, clk_period);
                tb_enable <= '1';
                wait_clock(2 * C_NFFT + 10, clk_period);
                test_runner_cleanup(runner);
                -----------------------------------------------------
            elsif run("stuck-at-tlast") then
                null;
                -----------------------------------------------------
            elsif run("auto") then
                null;
                -----------------------------------------------------
            end if;
        end loop;
    end process main;
    -- ======================================================================
end;