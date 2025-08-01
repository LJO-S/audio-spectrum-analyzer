-- 
-- Currently has support for generator and capture IF. No filters
-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tb_pkg.all;

entity project_top_tb is
end;

architecture bench of project_top_tb is
    -- Clock period
    constant clk_period        : time    := 8 ns; --125 Mhz
    constant TB_C_MAX_BIT_CNTR : natural := 16;
    -- Generics
    constant G_FFT_BIT_SIZE   : natural := 16;
    constant G_RAM_DEPTH      : natural := 1024;
    constant G_100MS_CYCLES   : natural := 25_000;
    constant G_DEBOUNCE_LIMIT : natural := 25;
    constant G_DEBUG          : boolean := true;
    -- Ports
    signal i_sys_clk    : std_logic                    := '0';
    signal i_pb_vector  : std_logic_vector(3 downto 0) := (others => '0');
    signal i_dip_vector : std_logic_vector(3 downto 0) := (others => '0');
    signal i_sdata      : std_logic;
    signal o_mclk       : std_logic;
    signal o_lrclk      : std_logic;
    signal o_bclk       : std_logic;
    signal o_TMDS_clk_p : std_logic;
    signal o_TMDS_clk_n : std_logic;
    signal o_video_0_p  : std_logic;
    signal o_video_0_n  : std_logic;
    signal o_video_1_p  : std_logic;
    signal o_video_1_n  : std_logic;
    signal o_video_2_p  : std_logic;
    signal o_video_2_n  : std_logic;
    -- TB signals
    type t_TB_IIS_STATE is (LEFT_INITIAL, LEFT_SEND, LEFT_FINAL, RIGHT_INITIAL, RIGHT_SEND, RIGHT_FINAL);
    signal tb_iis_state    : t_TB_IIS_STATE       := LEFT_SEND;
    signal tb_bit_cntr     : unsigned(4 downto 0) := (others => '0');
    signal tb_serial_value : std_logic            := '0';
    signal tb_fft_stall    : std_logic            := '0';
    signal tb_tdata_re     : std_logic_vector(15 downto 0);
begin
    /* ------------------------------------------------------------------- */
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
            i_sys_clk    => i_sys_clk,
            i_pb_vector  => i_pb_vector,
            i_dip_vector => i_dip_vector,
            i_sdata      => i_sdata,
            o_mclk       => o_mclk,
            o_lrclk      => o_lrclk,
            o_bclk       => o_bclk,
            o_TMDS_clk_p => o_TMDS_clk_p,
            o_TMDS_clk_n => o_TMDS_clk_n,
            o_video_0_p  => o_video_0_p,
            o_video_0_n  => o_video_0_n,
            o_video_1_p  => o_video_1_p,
            o_video_1_n  => o_video_1_n,
            o_video_2_p  => o_video_2_p,
            o_video_2_n  => o_video_2_n
        );
    /* ------------------------------------------------------------------- */
    i_sys_clk <= not i_sys_clk after clk_period/2;
    /* ------------------------------------------------------------------- */
    -- Generate i2s data according to SSM2603 i2s datasheet with 1 leading and 
    -- >=1 trailing invalid bits
    p_i2s_data : process (o_bclk)
    begin
        if falling_edge(o_bclk) then
            i_sdata <= 'X';
            case tb_iis_state is
                    -- ----------------------------------------
                    -- ----------------------------------------
                when LEFT_INITIAL =>
                    if (o_lrclk = '0') then
                        tb_iis_state <= LEFT_SEND;
                    end if;
                    -- ----------------------------------------
                    -- ----------------------------------------
                when LEFT_SEND =>
                    i_sdata     <= tb_serial_value;
                    tb_bit_cntr <= tb_bit_cntr + 1;
                    if (tb_bit_cntr >= TB_C_MAX_BIT_CNTR) then
                        tb_iis_state <= RIGHT_INITIAL;
                        i_sdata      <= 'X';
                        tb_bit_cntr  <= (others => '0');
                    end if;
                    -- ----------------------------------------
                    -- ----------------------------------------
                when RIGHT_INITIAL =>
                    if (o_lrclk = '1') then
                        tb_iis_state <= RIGHT_SEND;
                    end if;
                    -- ----------------------------------------
                    -- ----------------------------------------
                when RIGHT_SEND =>
                    i_sdata     <= not tb_serial_value;
                    tb_bit_cntr <= tb_bit_cntr + 1;
                    if (tb_bit_cntr >= TB_C_MAX_BIT_CNTR) then
                        tb_iis_state    <= LEFT_INITIAL;
                        i_sdata         <= 'X';
                        tb_bit_cntr     <= (others => '0');
                        tb_serial_value <= not(tb_serial_value);
                    end if;
                    -- ----------------------------------------
                    -- ----------------------------------------
                when others =>
                    null;
            end case;
        end if;
    end process p_i2s_data;
    /* ------------------------------------------------------------------- */
    p_main : process
    begin
        --------------------------------------------
        i_pb_vector  <= 4b"0";
        i_dip_vector <= 4b"0";
        wait_clock(30, clk_period);
        wait until i_sys_clk = '1';
        --------------------------------------------
        -- Test mode A (internal)
        for i in 0 to 1 loop
            if (i = 0) then
                i_dip_vector(0) <= '0';
            else
                i_dip_vector(0) <= '1';
            end if;
            for j in 0 to 3 loop
                -- Change internal source
                i_pb_vector    <= (others => '0');
                i_pb_vector(j) <= '1';
                wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
                i_pb_vector(j) <= '0';
                -- Wait for start strobe and let it offload.
                wait_clock(G_100MS_CYCLES, clk_period);
                -- Data unload
                wait_clock(1025, clk_period);
            end loop;
        end loop;
        --------------------------------------------
        -- Testing mode B(capture):
        -- Note: i2c_cfg_done is hard-wired HI atm

        -- Enable capture
        i_dip_vector(3) <= '1';
        wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
        -- TODO we need to wait a good fucking while to capture 1024 48 khz values
        -- Observe what happens in the FFT engine
        for i in 0 to 1023 loop
            wait until rising_edge(o_lrclk);
        end loop;
        wait_clock(1024, clk_period);
        -- ---------------------------
        -- Test some peripherals
        -- Enable EMA
        i_dip_vector(0) <= '1';
        wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);

        -- Enable LPF
        i_dip_vector(1) <= '1';
        wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);

        -- Enable HPF
        i_dip_vector(2) <= '1';
        wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
        -- ---------------------------
        -- Test incr/decr filters

        -- LPF++
        i_pb_vector(0) <= '1';
        wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
        wait_clock(1, clk_period);
        i_pb_vector(0) <= '0';

        -- LPF--
        i_pb_vector(1) <= '1';
        wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
        wait_clock(1, clk_period);
        i_pb_vector(1) <= '0';

        -- HPF++
        i_pb_vector(2) <= '1';
        wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
        wait_clock(1, clk_period);
        i_pb_vector(2) <= '0';

        -- HPF--
        i_pb_vector(3) <= '1';
        wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
        wait_clock(1, clk_period);
        i_pb_vector(3) <= '0';
        -- ---------------------------
        -- Test capture off (including the rest turning off)
        i_dip_vector(3) <= '0';
        wait_clock(G_DEBOUNCE_LIMIT + 1, clk_period);
        report "Just Kidding.   Test Done!" severity failure;
    end process p_main;
    /* ------------------------------------------------------------------- */
end;