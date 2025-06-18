
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.tb_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity signal_generator_wrapper_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of signal_generator_wrapper_tb is
    -- Clock period
    constant clk_period : time := 20 ns;
    -- Generics
    constant G_FFT_BIT_SIZE : natural := 16;
    constant G_RAM_DEPTH    : natural := 1024;
    constant G_100MS_CYCLES : natural := 3000;
    -- Ports
    signal clk_25          : std_logic                    := '0';
    signal i_pbuttons      : std_logic_vector(3 downto 0) := (others => '0');
    signal i_dip_switch0   : std_logic                    := '0';
    signal o_reset         : std_logic;
    signal i_s_axis_tready : std_logic;
    signal o_m_axis_tdata  : std_logic_vector(2 * G_FFT_BIT_SIZE - 1 downto 0);
    signal o_m_axis_tvalid : std_logic;
    signal o_m_axis_tlast  : std_logic;
begin

    signal_generator_wrapper_inst : entity work.signal_generator_wrapper
        generic map(
            G_100MS_CYCLES => G_100MS_CYCLES
        )
        port map
        (
            clk_25          => clk_25,
            i_pbuttons      => i_pbuttons,
            i_dip_switch0   => i_dip_switch0,
            o_reset         => o_reset,
            i_s_axis_tready => i_s_axis_tready,
            o_m_axis_tdata  => o_m_axis_tdata,
            o_m_axis_tvalid => o_m_axis_tvalid,
            o_m_axis_tlast  => o_m_axis_tlast
        );
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("sequential-push-buttons") then
                wait_clock(100, clk_period);
                wait until clk_25 = '1';
                for i in 0 to 1 loop
                    if (i = 0) then
                        i_dip_switch0 <= '0';
                    else
                        i_dip_switch0 <= '1';
                    end if;
                    for j in 0 to 3 loop
                        i_pbuttons    <= (others => '0');
                        i_pbuttons(j) <= '1';
                        -- Debounce
                        wait_clock(1001, clk_period);
                        i_pbuttons(j) <= '0';
                        -- Start strobe
                        wait_clock(G_100MS_CYCLES, clk_period);
                        -- Data offload
                        wait_clock(1025, clk_period);
                    end loop;
                end loop;
                test_runner_cleanup(runner);
                -- =============================================
            elsif run("simultaneous-push-buttons") then
                test_runner_cleanup(runner);
                -- =============================================
            end if;

        end loop;
    end process main;

    clk_25 <= not clk_25 after clk_period/2;
end;