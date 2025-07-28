
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tb_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity audio_top_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of audio_top_tb is
    -- Clock period
    constant clk_period        : time    := 40 ns;
    constant TB_C_MAX_BIT_CNTR : natural := 16;
    -- Generics
    -- Ports
    signal clk_25         : std_logic := '0';
    signal i_i2c_cfg_done : std_logic;
    signal i_capture_en   : std_logic;
    signal i_sdata        : std_logic;
    signal o_mclk         : std_logic;
    signal o_lrclk        : std_logic;
    signal o_bclk         : std_logic;
    signal o_tdata        : std_logic_vector(31 downto 0);
    signal o_tvalid       : std_logic;
    signal o_tlast        : std_logic;
    signal i_tready       : std_logic;

    -- TB signals
    type t_TB_IIS_STATE is (LEFT_INITIAL, LEFT_SEND, LEFT_FINAL, RIGHT_INITIAL, RIGHT_SEND, RIGHT_FINAL);
    signal tb_iis_state    : t_TB_IIS_STATE       := LEFT_SEND;
    signal tb_bit_cntr     : unsigned(4 downto 0) := (others => '0');
    signal tb_serial_value : std_logic            := '0';
    signal tb_fft_stall    : std_logic            := '0';
    signal tb_tdata_re     : std_logic_vector(15 downto 0);
begin
    /* ---------------------------------------------------------------------- */
    audio_top_inst : entity work.audio_top
        port map
        (
            clk_25         => clk_25,
            i_i2c_cfg_done => i_i2c_cfg_done,
            i_capture_en   => i_capture_en,
            i_sdata        => i_sdata,
            o_mclk         => o_mclk,
            o_lrclk        => o_lrclk,
            o_bclk         => o_bclk,
            o_tdata        => o_tdata,
            o_tvalid       => o_tvalid,
            o_tlast        => o_tlast,
            i_tready       => (i_tready and not(tb_fft_stall))
        );
    /* ---------------------------------------------------------------------- */
    tb_tdata_re <= o_tdata(15 downto 0);
    /* ---------------------------------------------------------------------- */
    clk_25 <= not clk_25 after clk_period/2; -- 25 MHz
    /* ---------------------------------------------------------------------- */
    -- Let tready from FFT engine only be asserted when someone else initializes
    -- communication
    p_tready : process (clk_25)
        alias tb_audio_buf_raddr is << signal audio_top_inst.audio_buffer_inst.r_addr : unsigned(9 downto 0) >> ;
    begin
        if rising_edge(clk_25) then
            i_tready <= o_tvalid;
            if (i_tready = '1') then
                if (tb_audio_buf_raddr = 1023) then
                    i_tready <= '0';
                end if;
            end if;
        end if;
    end process p_tready;
    /* ---------------------------------------------------------------------- */
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
    /* ---------------------------------------------------------------------- */
    main : process
        alias tb_i2s_ovalid is << signal audio_top_inst.i2s_deser_inst.o_valid  : std_logic >> ;
        alias tb_buf_raddr is << signal audio_top_inst.audio_buffer_inst.r_addr : unsigned(9 downto 0) >> ;
    begin
        test_runner_setup(runner, runner_cfg);
        set_stop_level(error);
        if run("basic") then
            info("Running tb_audio_top-BASIC");
            -- ------------------------------
            wait_clock(5, clk_period);
            wait until clk_25 = '1';
            -- ------------------------------
            -- Emulate PS configuring i2c interface
            i_capture_en   <= '0';
            i_i2c_cfg_done <= '0';
            wait_clock(5, clk_period);
            i_i2c_cfg_done <= '1';
            -- Let the deserializer run for a bit
            for i in 0 to 1 loop
                wait until tb_i2s_ovalid = '1';
                wait until tb_i2s_ovalid = '0';
            end loop;
            -- No buffering should occur
            check(tb_buf_raddr = (tb_buf_raddr'range => '0'), "Somehow the audio_buffer fill address has incremented when module not enabled.");
            wait_clock(5, clk_period);
            -- ------------------------------
            -- Now emulate the user activating capture mode
            i_capture_en <= '1';
            for i in 1 to 2 loop
                wait until o_tlast = '1';
                if (i = 2) then
                    tb_fft_stall <= '1';
                    wait_clock(10, clk_period);
                    -- Hopefully TLAST is held HI while FFT stalled...
                    check(o_tlast = '1', LF & "TLAST not held HI on last sample when FFT stalled." & LF);
                    tb_fft_stall <= '0';
                    wait_clock(10, clk_period);
                    -- ... and releases correctly
                    check(o_tlast = '0', "TLAST held HI after last sample after stopped FFT stalling.");
                else
                    wait until o_tlast = '0';
                end if;
            end loop;
            -- ------------------------------
            -- Observe shut down 
            wait_clock(5, clk_period);
            wait until tb_i2s_ovalid = '1';
            wait until tb_i2s_ovalid = '0';
            i_capture_en <= '0';
            wait_clock(10, clk_period);
            check(tb_buf_raddr = (tb_buf_raddr'range => '0'), "Somehow the audio_buffer fill address has incremented when module not enabled.");
            -- ------------------------------
            info("Completed tb_audio_top-BASIC");
            test_runner_cleanup(runner);
        elsif run("capture-disable") then
            info("Running tb_audio_top-CAPTURE-DISABLE");
            -- ------------------------------
            wait_clock(5, clk_period);
            wait until clk_25 = '1';
            -- ------------------------------
            -- Emulate PS configuring i2c interface
            i_capture_en   <= '0';
            i_i2c_cfg_done <= '0';
            wait_clock(5, clk_period);
            i_i2c_cfg_done <= '1';
            wait_clock(5, clk_period);
            -- ------------------------------
            -- User activates capture mode
            i_capture_en <= '1';
            -- ------------------------------
            -- Output 24 samples and then stop capture
            wait until rising_edge(o_tvalid);
            wait_clock(1, clk_period);
            i_capture_en <= '0';
            -- ------------------------------
            -- Observe shut down 
            wait until o_tlast = '1';
            wait_clock(5, clk_period);
            -- ------------------------------
            info("Completed tb_audio_top-CAPTURE-DISABLE");
            test_runner_cleanup(runner);
        end if;
    end process main;
    /* ---------------------------------------------------------------------- */
end;