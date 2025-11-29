
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
-- 
use std.textio.all;
-- 
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
    -- Constants
    constant clk_period        : time    := 10 ns;
    constant TB_C_MAX_BIT_CNTR : natural := 16;
    -- Generics
    constant G_NBR_OF_TAPS : positive := 101;
    constant G_MEM_SIZE    : positive := 4 * G_NBR_OF_TAPS;
    constant G_QFORMAT     : positive := 15;
    constant G_INPUT_WIDTH : positive := 16;
    constant G_COEFF_WIDTH : positive := 16;
    -- Ports
    signal clk_100                : std_logic := '0';
    signal i_i2c_cfg_done        : std_logic;
    signal i_new_data_strobe_lpf : std_logic;
    signal i_new_data_strobe_hpf : std_logic;
    signal o_updating_coeffs_lpf : std_logic;
    signal o_updating_coeffs_hpf : std_logic;
    signal i_lpf_en              : std_logic := '0';
    signal i_hpf_en              : std_logic := '0';

    signal i_waddr_lpf : std_logic_vector(integer(ceil(log2(real(G_MEM_SIZE)))) - 1 downto 0);
    signal i_wdata_lpf : std_logic_vector(G_COEFF_WIDTH - 1 downto 0);
    signal i_we_lpf    : std_logic;
    signal i_waddr_hpf : std_logic_vector(integer(ceil(log2(real(G_MEM_SIZE)))) - 1 downto 0);
    signal i_wdata_hpf : std_logic_vector(G_COEFF_WIDTH - 1 downto 0);
    signal i_we_hpf    : std_logic;

    signal o_raddr_lpf : unsigned(8 downto 0);
    signal i_rdata_lpf : std_logic_vector(G_COEFF_WIDTH - 1 downto 0);
    signal o_raddr_hpf : unsigned(8 downto 0);
    signal i_rdata_hpf : std_logic_vector(G_COEFF_WIDTH - 1 downto 0);

    signal i_capture_en : std_logic;
    signal i_sdata      : std_logic;
    signal o_mclk       : std_logic;
    signal o_lrclk      : std_logic;
    signal o_bclk       : std_logic;
    signal o_tdata      : std_logic_vector(31 downto 0);
    signal o_tvalid     : std_logic;
    signal o_tlast      : std_logic;
    signal i_tready     : std_logic;

    -- TB signals
    type t_TB_IIS_STATE is (LEFT_INITIAL, LEFT_SEND, LEFT_FINAL, RIGHT_INITIAL, RIGHT_SEND, RIGHT_FINAL);
    signal tb_iis_state       : t_TB_IIS_STATE       := LEFT_SEND;
    signal tb_bit_cntr        : unsigned(4 downto 0) := (others => '0');
    signal tb_serial_value    : std_logic            := '0';
    signal tb_fft_stall       : std_logic            := '0';
    signal tb_tdata_re        : std_logic_vector(15 downto 0);
    signal tb_tready_override : std_logic := '0';

    type t_coefficients is array (natural range 0 to G_NBR_OF_TAPS - 1) of signed(G_COEFF_WIDTH - 1 downto 0);
    signal tb_coefficients_lpf : t_coefficients;
    signal tb_coefficients_hpf : t_coefficients;
    signal tb_input_enable     : boolean := FALSE;

    -- Procedures
    procedure load_coefficients (
        signal we              : out std_logic;
        signal waddr           : out i_waddr_lpf'subtype;
        signal wdata           : out i_wdata_lpf'subtype;
        signal new_data_strobe : out std_logic;
        signal tb_coefficient  : in t_coefficients
    ) is
    begin
        -- Load coefficients
        we <= '1';
        for i in tb_coefficient'range loop
            wdata <= std_logic_vector(tb_coefficient(i));
            waddr <= std_logic_vector(to_unsigned(4 * i, waddr'length));
            wait_clock(1, clk_period);
        end loop;
        -- Stop load and strobe new data flag
        we              <= '0';
        new_data_strobe <= '1';
        wait_clock(1, clk_period);
        new_data_strobe <= '0';
    end procedure;

begin
    /* ---------------------------------------------------------------------- */
    audio_top_inst : entity work.audio_top
        generic map(
            G_NBR_OF_TAPS => G_NBR_OF_TAPS,
            G_QFORMAT     => G_QFORMAT,
            G_INPUT_WIDTH => G_INPUT_WIDTH,
            G_COEFF_WIDTH => G_COEFF_WIDTH
        )
        port map
        (
            clk_100                => clk_100,
            i_i2c_cfg_done        => i_i2c_cfg_done,
            i_new_data_strobe_lpf => i_new_data_strobe_lpf,
            i_new_data_strobe_hpf => i_new_data_strobe_hpf,
            o_updating_coeffs_lpf => o_updating_coeffs_lpf,
            o_updating_coeffs_hpf => o_updating_coeffs_hpf,
            o_raddr_lpf           => o_raddr_lpf,
            i_rdata_lpf           => i_rdata_lpf,
            o_raddr_hpf           => o_raddr_hpf,
            i_rdata_hpf           => i_rdata_hpf,
            i_capture_en          => i_capture_en,
            i_lpf_en              => i_lpf_en,
            i_hpf_en              => i_hpf_en,
            i_sdata               => i_sdata,
            o_mclk                => o_mclk,
            o_lrclk               => o_lrclk,
            o_bclk                => o_bclk,
            o_tdata               => o_tdata,
            o_tvalid              => o_tvalid,
            o_tlast               => o_tlast,
            i_tready              => (i_tready and not(tb_fft_stall))
        );
    /* ---------------------------------------------------------------*/
    lpf_dpmem_dram_inst : entity work.dpmem_bram
        generic map(
            G_RAM_WIDTH      => G_COEFF_WIDTH,
            G_RAM_DEPTH_BITS => integer(ceil(log2(real(G_MEM_SIZE))))
        )
        port map
        (
            clk => clk_100,
            -- Port A (PS)
            i_addra => i_waddr_lpf,
            i_dina  => i_wdata_lpf,
            i_wea   => i_we_lpf,
            o_douta => open,
            -- Port B (RTL)
            i_addrb => std_logic_vector(o_raddr_lpf),
            i_dinb => (others => '0'),
            i_web   => '0',
            o_doutb => i_rdata_lpf);

    hpf_dpmem_dram_inst : entity work.dpmem_bram
        generic map(
            G_RAM_WIDTH      => G_COEFF_WIDTH,
            G_RAM_DEPTH_BITS => integer(ceil(log2(real(G_MEM_SIZE))))
        )
        port map
        (
            clk => clk_100,
            -- Port A (PS)
            i_addra => i_waddr_hpf,
            i_dina  => i_wdata_hpf,
            i_wea   => i_we_hpf,
            o_douta => open,
            -- Port B (RTL)
            i_addrb => std_logic_vector(o_raddr_hpf),
            i_dinb => (others => '0'),
            i_web   => '0',
            o_doutb => i_rdata_hpf);
    /* ---------------------------------------------------------------*/
    -- Read coefficients file
    p_read_coeffs_file : process
        file coeff_file          : text;
        variable v_line          : line;
        variable v_coeffiecients : t_coefficients;
        variable v_rd_idx        : natural := 0;
    begin
        -- LPF
        v_rd_idx := 0;
        -- Default to 23 kHz
        file_open(
        coeff_file,
        "../../../scripts/fir_filter_coefficients/lp/lp_23000hz.coe",
        read_mode);
        while not endfile(coeff_file) loop
            readline(coeff_file, v_line);
            HEX_READ(v_line, v_coeffiecients(v_rd_idx));
            v_rd_idx := v_rd_idx + 1;
        end loop;
        FILE_CLOSE(coeff_file);
        report "LPF coefficient file read!";
        tb_coefficients_lpf <= v_coeffiecients;

        -- HPF
        v_rd_idx := 0;
        -- Default to 1 kHz
        file_open(
        coeff_file,
        "../../../scripts/fir_filter_coefficients/hp/hp_1000hz.coe",
        read_mode);
        while not endfile(coeff_file) loop
            readline(coeff_file, v_line);
            HEX_READ(v_line, v_coeffiecients(v_rd_idx));
            v_rd_idx := v_rd_idx + 1;
        end loop;
        FILE_CLOSE(coeff_file);
        report "HPF coefficient file read!";
        tb_coefficients_hpf <= v_coeffiecients;

        wait;
    end process p_read_coeffs_file;
    /* ---------------------------------------------------------------------- */
    tb_tdata_re <= o_tdata(15 downto 0);
    /* ---------------------------------------------------------------------- */
    clk_100 <= not clk_100 after clk_period/2;
    /* ---------------------------------------------------------------------- */
    -- Let tready from FFT engine only be asserted when someone else initializes
    -- communication
    p_tready : process (clk_100)
        alias tb_audio_buf_raddr is << signal audio_top_inst.audio_buffer_inst.r_addr : unsigned(9 downto 0) >> ;
    begin
        if rising_edge(clk_100) then
            i_tready <= o_tvalid or tb_tready_override;
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
        procedure load_coeffs(
            constant filter_type : in string;
            signal coefficients  : in t_coefficients
        ) is
        begin
            if filter_type = "lp" then
                load_coefficients(
                i_we_lpf,
                i_waddr_lpf,
                i_wdata_lpf,
                i_new_data_strobe_lpf,
                coefficients);
                wait_clock(1, clk_period);
                check(o_updating_coeffs_lpf = '1', "Expected us to update coefficients on LPF!");
                wait until o_updating_coeffs_lpf = '0' for 1000 * clk_period;
                check(o_updating_coeffs_lpf = '0', "LPF is still loading coefficients??");
            elsif filter_type = "hp" then
                load_coefficients(
                i_we_hpf,
                i_waddr_hpf,
                i_wdata_hpf,
                i_new_data_strobe_hpf,
                coefficients);
                wait_clock(1, clk_period);
                check(o_updating_coeffs_hpf = '1', "Expected us to update coefficients on HPF!");
                wait until o_updating_coeffs_hpf = '0' for 1000 * clk_period;
                check(o_updating_coeffs_hpf = '0', "HPF is still loading coefficients??");
            end if;
        end procedure;
    begin
        test_runner_setup(runner, runner_cfg);

        -- Flexing Vunit muscles
        set_stop_level(error);

        -- Load coefficients
        load_coeffs("lp", tb_coefficients_lpf);
        load_coeffs("hp", tb_coefficients_hpf);

        if run("basic") then
            info("Running tb_audio_top-BASIC");
            -- ------------------------------
            wait_clock(5, clk_period);
            wait until clk_100 = '1';
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
            wait until clk_100 = '1';
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
        elsif run("ready-before-valid") then
            info("Running tb_audio_top-READY-BEFORE-VALID");
            -- ------------------------------
            wait_clock(5, clk_period);
            wait until clk_100 = '1';
            -- ------------------------------
            -- Emulate PS configuring i2c interface
            i_capture_en   <= '0';
            i_i2c_cfg_done <= '0';
            wait_clock(5, clk_period);
            i_i2c_cfg_done <= '1';
            wait_clock(5, clk_period);
            -- ------------------------------
            -- User activates capture mode
            i_capture_en       <= '1';
            tb_tready_override <= '1';
            -- ------------------------------
            -- Output 24 samples and then stop capture
            wait until rising_edge(o_tlast);
            wait_clock(1, clk_period);
            -- ------------------------------
            info("Completed tb_audio_top-READY-BEFORE-VALID");
            test_runner_cleanup(runner);
        end if;
    end process main;
    /* ---------------------------------------------------------------------- */
end;