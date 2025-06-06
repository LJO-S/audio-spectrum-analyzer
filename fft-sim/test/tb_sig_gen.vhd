
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity signal_generator_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of signal_generator_tb is
    -- Clock period
    constant clk_period : time := 20 ns;
    -- Generics
    constant G_FFT_BIT_SIZE : natural := 16;
    constant G_RAM_DEPTH    : natural := 1024;
    constant G_INIT_FILE    : string  := "../../../scripts/data/multi_15khz_16bits.txt";
    -- Ports
    signal clk_50   : std_logic := '0';
    signal i_start  : std_logic := '0';
    signal i_reset  : std_logic := '0';
    signal i_tready : std_logic := '0';
    signal o_tdata  : std_logic_vector(2 * G_FFT_BIT_SIZE - 1 downto 0);
    signal o_tvalid : std_logic;
    signal o_tlast  : std_logic;

    procedure reset_hold (
        signal reset       : inout std_logic;
        constant clk_ticks : in integer
    ) is
    begin
        reset <= '1';
        for i in 0 to clk_ticks loop
            wait for clk_period;
        end loop;
        reset <= '0';
    end procedure;

begin
    signal_generator_inst : entity work.signal_generator
        generic map(
            G_FFT_BIT_SIZE => G_FFT_BIT_SIZE,
            G_RAM_DEPTH    => G_RAM_DEPTH,
            G_INIT_FILE    => G_INIT_FILE
        )
        port map
        (
            clk_50   => clk_50,
            i_start  => i_start,
            i_reset  => i_reset,
            i_tready => i_tready,
            o_tdata  => o_tdata,
            o_tvalid => o_tvalid,
            o_tlast  => o_tlast
        );

    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("main") then
                reset_hold(i_reset, 50);
                wait for clk_period;
                i_start <= '1';
                wait until o_tvalid = '1';
                wait for 10 * clk_period;
                wait for 8 ns;
                i_tready <= '1';
                wait for 553 * clk_period;
                i_tready <= '0';
                wait for 10 * clk_period;
                i_tready <= '1';
                wait for 2 * 1025 * clk_period;
                wait for 13 * clk_period;
                i_start <= '0';
                wait until o_tlast = '1';
                i_tready <= '0';
                wait for 20 * clk_period;
                i_start  <= '1';
                i_tready <= '1';
                wait until o_tlast = '1';
                test_runner_cleanup(runner);
            end if;
        end loop;
    end process main;

    clk_50 <= not clk_50 after clk_period/2;

end;