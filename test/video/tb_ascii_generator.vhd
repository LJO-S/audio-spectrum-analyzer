
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tb_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity ascii_generator_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of ascii_generator_tb is
    -- Clock period
    constant clk_period : time := 10 ns;
    -- Generics
    -- Ports
    signal clk_100        : std_logic             := '0';
    signal i_counter_X    : unsigned(9 downto 0)  := (others => '0');
    signal i_counter_Y    : unsigned(9 downto 0)  := (others => '0');
    signal i_max_freq     : unsigned(16 downto 0) := (others => '0');
    signal i_capture_on   : std_logic             := '0';
    signal i_lpf_on       : std_logic             := '0';
    signal i_lpf_cutoff   : unsigned(16 downto 0) := (others => '0');
    signal i_bpf_on       : std_logic             := '0';
    signal i_bpf_cutoff   : unsigned(16 downto 0) := (others => '0');
    signal i_hpf_on       : std_logic             := '0';
    signal i_hpf_cutoff   : unsigned(16 downto 0) := (others => '0');
    signal i_ema_on       : std_logic             := '0';
    signal o_glyph_active : std_logic;
    signal o_video_red    : std_logic_vector(7 downto 0);
    signal o_video_grn    : std_logic_vector(7 downto 0);
    signal o_video_blu    : std_logic_vector(7 downto 0);

    signal tb_HSYNC         : std_logic;
    signal tb_VSYNC         : std_logic;
    signal tb_screen_active : std_logic;

    signal tb_counter : unsigned(3 downto 0) := (others => '0');
    signal tb_ce      : std_logic;
    signal tb_ce_d1   : std_logic;
begin
    -- ===============================================================
    ascii_generator_inst : entity work.ascii_generator
        port map
        (
            clk_100        => clk_100,
            i_ce           => tb_ce,
            i_counter_X    => i_counter_X,
            i_counter_Y    => i_counter_Y,
            i_max_freq     => i_max_freq,
            i_capture_on   => i_capture_on,
            i_lpf_on       => i_lpf_on,
            i_lpf_cutoff   => i_lpf_cutoff,
            i_bpf_on       => i_bpf_on,
            i_bpf_cutoff   => i_bpf_cutoff,
            i_hpf_on       => i_hpf_on,
            i_hpf_cutoff   => i_hpf_cutoff,
            i_ema_on       => i_ema_on,
            o_glyph_active => o_glyph_active,
            o_video_red    => o_video_red,
            o_video_grn    => o_video_grn,
            o_video_blu    => o_video_blu
        );
    -- ===============================================================
    clk_100 <= not clk_100 after clk_period/2;
    -- ===============================================================
    process (clk_100)
    begin
        if rising_edge(clk_100) then
            tb_counter <= tb_counter + 1;
            tb_ce_d1   <= tb_ce;
        end if;
    end process;
    tb_ce <= tb_counter(1) and not(tb_ce_d1);
    -- ===============================================================
    p_video_draw : process (clk_100)
    begin
        if rising_edge(clk_100) then
            if (tb_ce = '1') then
                -- X:[0,800), Y:[0,525)
                if (i_counter_X = 799) then
                    i_counter_X <= (others => '0');
                    if (i_counter_Y = 524) then
                        i_counter_Y <= (others => '0');
                    else
                        i_counter_Y <= i_counter_Y + 1;
                    end if;
                else
                    i_counter_X <= i_counter_X + 1;
                end if;

                -- Check if within pixel limits
                if (i_counter_X < 640) and (i_counter_Y < 480) then
                    tb_screen_active <= '1';
                else
                    tb_screen_active <= '0';
                end if;

                -- Note: these are inverted compared to VGA HS/VS signals
                -- A HI signal notifies the TMDS_encoder that we're syncing
                -- (instead of turning off the electron beam in a CRT monitor)
                tb_HSYNC <= '1' when ((i_counter_X >= 656) and (i_counter_X < 752)) else
                    '0';
                tb_VSYNC <= '1' when ((i_counter_Y >= 490) and (i_counter_Y < 492)) else
                    '0';
            end if;
        end if;
    end process p_video_draw;
    -- ===============================================================
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            if run("basic") then
                info("== Running BASIC testbench of ASCII_GENERATOR.VHD ==");
                wait until clk_100 = '1';
                wait_clock(4, clk_period);
                wait until tb_VSYNC = '1';
                wait until tb_VSYNC = '0';
                test_runner_cleanup(runner);
            elsif run("active-inputs") then
                info("== Running ACTIVE-INPUTS testbench of ASCII_GENERATOR.VHD ==");
                wait until clk_100 = '1';
                wait_clock(4, clk_period);
                i_capture_on <= '1';
                -- 
                i_max_freq <= TO_UNSIGNED(35_718, i_max_freq'length);
                -- 
                i_lpf_on     <= '1';
                i_lpf_cutoff <= TO_UNSIGNED(23_708, i_max_freq'length);
                -- 
                i_bpf_on <= '1';
                -- TODO this needs fixing
                i_bpf_cutoff <= TO_UNSIGNED(13_708, i_max_freq'length);
                -- 
                i_hpf_on     <= '1';
                i_hpf_cutoff <= TO_UNSIGNED(5_111, i_max_freq'length);
                -- 
                i_ema_on <= '1';
                -- 
                wait until tb_VSYNC = '1';
                wait until tb_VSYNC = '0';
                test_runner_cleanup(runner);
            end if;
        end loop;
    end process main;
    -- ===============================================================
end;