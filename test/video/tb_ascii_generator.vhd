library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

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
    signal clk_100             : std_logic                     := '0';
    signal i_counter_X         : unsigned(9 downto 0)          := (others => '0');
    signal i_counter_Y         : unsigned(9 downto 0)          := (others => '0');
    signal i_max_freq          : unsigned(16 downto 0)         := (others => '0');
    signal i_capture_on        : std_logic                     := '0';
    signal i_lpf_on            : std_logic                     := '0';
    signal i_lpf_cutoff        : unsigned(16 downto 0)         := (others => '0');
    signal i_bpf_on            : std_logic                     := '0';
    signal i_bpf_cutoff        : unsigned(16 downto 0)         := (others => '0');
    signal i_hpf_on            : std_logic                     := '0';
    signal i_hpf_cutoff        : unsigned(16 downto 0)         := (others => '0');
    signal i_waterfall_on      : std_logic                     := '0';
    signal i_oscilloscope_en   : std_logic                     := '0';
    signal i_decimation_factor : std_logic_vector(1 downto 0)  := (others => '0');
    signal i_frequency_shift   : std_logic_vector(15 downto 0) := (others => '0');
    signal o_freq_lpf_1000s    : unsigned(6 downto 0);
    signal o_freq_hpf_1000s    : unsigned(6 downto 0);
    signal o_glyph_active      : std_logic;
    signal o_video_red         : std_logic_vector(7 downto 0);
    signal o_video_grn         : std_logic_vector(7 downto 0);
    signal o_video_blu         : std_logic_vector(7 downto 0);

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
            clk_100             => clk_100,
            i_ce                => tb_ce,
            i_counter_X         => i_counter_X,
            i_counter_Y         => i_counter_Y,
            i_max_freq          => i_max_freq,
            i_capture_on        => i_capture_on,
            i_lpf_on            => i_lpf_on,
            i_lpf_cutoff        => i_lpf_cutoff,
            i_hpf_on            => i_hpf_on,
            i_hpf_cutoff        => i_hpf_cutoff,
            i_waterfall_on      => i_waterfall_on,
            i_oscilloscope_en   => i_oscilloscope_en,
            i_decimation_factor => i_decimation_factor,
            i_frequency_shift   => i_frequency_shift,
            o_freq_lpf_1000s    => o_freq_lpf_1000s,
            o_freq_hpf_1000s    => o_freq_hpf_1000s,
            o_glyph_active      => o_glyph_active,
            o_video_red         => o_video_red,
            o_video_grn         => o_video_grn,
            o_video_blu         => o_video_blu
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
        --------------------------------------------------
        variable v_seed1, v_seed2 : integer := 999;
        impure function f_rand_int (
            min_val : natural;
            max_val : natural
        ) return integer is
            variable v_real : real;
        begin
            uniform(v_seed1, v_seed2, v_real);
            return integer(
            round(v_real * real(max_val - min_val + 1) + real(min_val) - 0.5)
            );
        end function;
        --------------------------------------------------
        variable v_max_freq   : unsigned(16 downto 0) := (others => '0');
        variable v_lpf_cutoff : unsigned(16 downto 0) := (others => '0');
        variable v_bpf_cutoff : unsigned(16 downto 0) := (others => '0');
        variable v_hpf_cutoff : unsigned(16 downto 0) := (others => '0');
        --------------------------------------------------
        alias tb_bpf_cutoff is << signal ascii_generator_inst.r_freq_bpf_1000s : unsigned(6 downto 0) >> ;
        alias tb_max_freq is << signal ascii_generator_inst.r_freq_max_1000s   : unsigned(6 downto 0) >> ;

    begin
        test_runner_setup(runner, runner_cfg);
        if run("basic") then
            info("== Running BASIC testbench of ASCII_GENERATOR.VHD ==");
            wait until clk_100 = '1';
            wait_clock(4, clk_period);
            wait until tb_VSYNC = '1';
            wait until tb_VSYNC = '0';
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
            i_bpf_on     <= '1';
            i_bpf_cutoff <= TO_UNSIGNED(13_708, i_max_freq'length);
            -- 
            i_hpf_on     <= '1';
            i_hpf_cutoff <= TO_UNSIGNED(5_111, i_max_freq'length);
            -- 
            i_oscilloscope_en <= '1';
            -- 
            i_waterfall_on <= '1';
            -- 
            wait until tb_VSYNC = '1';
            wait until tb_VSYNC = '0';
        elsif run("auto_div-by-1000") then
            wait until clk_100 = '1';
            for i in 0 to 1999 loop
                v_max_freq   := to_unsigned(f_rand_int(0, 30_000), i_lpf_cutoff'length);
                v_lpf_cutoff := to_unsigned(f_rand_int(1, 25) * 1000, i_lpf_cutoff'length);
                v_bpf_cutoff := to_unsigned(f_rand_int(1, 25) * 1000, i_bpf_cutoff'length);
                v_hpf_cutoff := to_unsigned(f_rand_int(1, 25) * 1000, i_hpf_cutoff'length);
                i_max_freq   <= v_max_freq;
                i_lpf_cutoff <= v_lpf_cutoff;
                i_bpf_cutoff <= v_bpf_cutoff;
                i_hpf_cutoff <= v_hpf_cutoff;
                wait until rising_edge(clk_100);
                wait until rising_edge(clk_100);
                -- Check output 
                check(
                to_integer(o_freq_lpf_1000s) = to_integer(v_lpf_cutoff)/1000,
                "Mismatch LPF! Expected=" & integer'image(to_integer(v_lpf_cutoff)/1000) & " vs actual=" & integer'image(to_integer(o_freq_lpf_1000s))
                );
                check(
                to_integer(o_freq_hpf_1000s) = to_integer(v_hpf_cutoff)/1000,
                "Mismatch HPF! Expected=" & integer'image(to_integer(v_hpf_cutoff)/1000) & " vs actual=" & integer'image(to_integer(o_freq_hpf_1000s))
                );
                check(
                to_integer(tb_bpf_cutoff) = to_integer(v_bpf_cutoff)/1000,
                "Mismatch BPF! Expected=" & integer'image(to_integer(v_bpf_cutoff)/1000) & " vs actual=" & integer'image(to_integer(tb_bpf_cutoff))
                );
                check_equal(
                real(to_integer(tb_max_freq)),
                round(real(to_integer(v_max_freq))/1000.0),
                "Mismatch FREQ! Expected=" & integer'image(to_integer(v_max_freq)/1000) & " vs actual=" & integer'image(to_integer(tb_max_freq)),
                max_diff => 1.0
                );
            end loop;
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ===============================================================
end;