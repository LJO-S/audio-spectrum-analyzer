
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tb_pkg.all;

entity project_top_tb is
end;

architecture bench of project_top_tb is
    -- Clock period
    -- 125 MHz
    constant clk_period : time := 8 ns;
    -- Generics
    constant G_FFT_BIT_SIZE   : natural := 16;
    constant G_RAM_DEPTH      : natural := 1024;
    constant G_100MS_CYCLES   : natural := 250_000;
    constant G_DEBOUNCE_LIMIT : natural := 1000;
    constant G_DEBUG          : boolean := true;
    -- Ports
    signal i_sys_clk     : std_logic                    := '0';
    signal i_pbuttons    : std_logic_vector(3 downto 0) := (others => '0');
    signal i_dip_switch0 : std_logic                    := '0';
    signal o_TMDS_clk_p  : std_logic                    := '0';
    signal o_TMDS_clk_n  : std_logic                    := '0';
    signal o_video_0_p   : std_logic                    := '0';
    signal o_video_0_n   : std_logic                    := '0';
    signal o_video_1_p   : std_logic                    := '0';
    signal o_video_1_n   : std_logic                    := '0';
    signal o_video_2_p   : std_logic                    := '0';
    signal o_video_2_n   : std_logic                    := '0';
begin

    i_sys_clk <= not i_sys_clk after clk_period/2;

    project_top_inst : entity work.project_top
        generic map(
            G_FFT_BIT_SIZE   => G_FFT_BIT_SIZE,
            G_RAM_DEPTH      => G_RAM_DEPTH,
            G_100MS_CYCLES   => G_100MS_CYCLES,
            G_DEBOUNCE_LIMIT => G_DEBOUNCE_LIMIT,
            G_DEBUG          => G_DEBUG
        )
        port map
        (
            i_sys_clk     => i_sys_clk,
            i_pbuttons    => i_pbuttons,
            i_dip_switch0 => i_dip_switch0,
            o_TMDS_clk_p  => o_TMDS_clk_p,
            o_TMDS_clk_n  => o_TMDS_clk_n,
            o_video_0_p   => o_video_0_p,
            o_video_0_n   => o_video_0_n,
            o_video_1_p   => o_video_1_p,
            o_video_1_n   => o_video_1_n,
            o_video_2_p   => o_video_2_p,
            o_video_2_n   => o_video_2_n
        );
    p_main : process
    begin
        wait_clock(30, clk_period);
        wait until i_sys_clk = '1';
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
                wait_clock(1001 * 5, clk_period);
                i_pbuttons(j) <= '0';
                -- Start strobe
                wait_clock(G_100MS_CYCLES * 5, clk_period);
                -- Data unload
                wait_clock(1025 * 5, clk_period);
            end loop;
        end loop;
        report "Just Kidding.   Test Done!" severity failure;
    end process p_main;

end;