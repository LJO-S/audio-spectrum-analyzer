
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
    constant clk_period : time := 20 ns;
    -- Generics
    -- Ports
    signal clk_50           : std_logic                     := '0';
    signal i_fft_data_magn  : std_logic_vector(31 downto 0) := (others => '0');
    signal i_fft_data_last  : std_logic                     := '0';
    signal i_fft_data_valid : std_logic                     := '0';
    signal i_xk_index       : std_logic_vector(9 downto 0)  := (others => '0');
    signal i_rd_addr        : std_logic_vector(9 downto 0)  := (others => '0');
    signal o_rd_data        : std_logic_vector(31 downto 0);
    signal o_rd_valid       : std_logic;
    -- Helper signals
    signal tb_fft_data_d1      : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_fft_data_d2      : std_logic_vector(31 downto 0) := (others => '0');
    signal tb_start_data       : std_logic                     := '0';
    signal tb_rd_addr          : unsigned(9 downto 0)          := TO_UNSIGNED(512, 10);
    signal tb_clk_strobe       : std_logic                     := '0';
    signal tb_use_slow_readout : std_logic                     := '1';

begin
    --------------------------------------------------
    clk_50 <= not clk_50 after clk_period/2;
    --------------------------------------------------
    ping_pong_memory_inst : entity work.ping_pong_memory
        port map
        (
            clk_50           => clk_50,
            i_fft_data_magn  => i_fft_data_magn,
            i_fft_data_last  => i_fft_data_last,
            i_fft_data_valid => i_fft_data_valid,
            i_xk_index       => i_xk_index,
            i_rd_addr        => i_rd_addr,
            o_rd_data        => o_rd_data,
            o_rd_valid       => o_rd_valid
        );
    --------------------------------------------------
    p_data_gen : process (clk_50)
        variable v_dummy_value : natural := 0;
    begin
        if rising_edge(clk_50) then
            if (tb_start_data = '1') then
                tb_fft_data_d1 <= std_logic_vector(
                    to_unsigned(
                    v_dummy_value + 3000, tb_fft_data_d1'length
                    ));
                tb_fft_data_d2  <= tb_fft_data_d1;
                i_fft_data_magn <= tb_fft_data_d2;
                i_xk_index      <= std_logic_vector(
                    to_unsigned(
                    v_dummy_value, i_xk_index'length
                    ));
                i_fft_data_valid <= '1';

                i_fft_data_last <= '0';
                if (v_dummy_value = 1023) then
                    v_dummy_value := 0;
                    i_fft_data_last <= '1';
                else
                    v_dummy_value := v_dummy_value + 1;
                end if;
            end if;
        end if;
    end process p_data_gen;
    --------------------------------------------------
    i_rd_addr <= std_logic_vector(tb_rd_addr);
    p_read_data : process (clk_50)
        variable v_dummy_value : natural := 0;
    begin
        if rising_edge(clk_50) then
            if (tb_use_slow_readout = '1') then
                tb_clk_strobe <= not tb_clk_strobe;
            else
                tb_clk_strobe <= '1';
            end if;
            if (tb_start_data = '1') and (tb_clk_strobe = '1') then
                tb_rd_addr <= tb_rd_addr + 1;
            end if;
        end if;
    end process p_read_data;
    --------------------------------------------------
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("slow-readout") then
                info("Running test of ping_pong memory SLOW readout!");
                tb_use_slow_readout <= '1';
                wait until (clk_50 = '1');
                wait_clock(10, clk_period);
                tb_start_data <= '1';
                wait_clock(2058, clk_period);
                test_runner_cleanup(runner);
            elsif run("fast-readout") then
                info("Running test of ping_pong memory FAST readout!");
                tb_use_slow_readout <= '0';
                wait until (clk_50 = '1');
                wait_clock(10, clk_period);
                tb_start_data <= '1';
                wait_clock(2058, clk_period);
                test_runner_cleanup(runner);
            end if;
        end loop;
    end process main;
end;