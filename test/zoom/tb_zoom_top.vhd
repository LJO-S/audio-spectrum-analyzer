library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--
use std.textio.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity zoom_top_tb is
    generic (
        runner_cfg         : string;
        G_MULTIRATE_FACTOR : natural := 2;
        -- Signed frequency word passed to the DDS (Hz at 100 MHz clock).
        -- Use a negative value to downmix a complex tone at |G_MIXER_FREQUENCY_SHIFT| Hz to DC.
        G_MIXER_FREQUENCY_SHIFT : integer := - 15000
    );
end;

architecture bench of zoom_top_tb is
    -- Clock period
    constant clk_period : time := 5 ns;
    -- Generics
    constant G_INPUT_DATA_WIDTH : positive := 16;
    constant G_COEFF_DATA_WIDTH : positive := 16;
    constant G_INIT_FILE        : string   := output_path(runner_cfg) & "../../../../src/zoom/decimate/HBF_16";
    constant G_DDS_INIT_FILE    : string   := output_path(runner_cfg) & "../../../../src/signal_generator/dds/dds_lut.txt";
    -- Ports
    signal clk                     : std_logic                                         := '0';
    signal i_cfg_decimation_factor : std_logic_vector(1 downto 0)                      := (others => '0');
    signal i_cfg_frequency_shift   : std_logic_vector(15 downto 0)                     := (others => '0');
    signal i_cfg_valid             : std_logic                                         := '0';
    signal i_data_i                : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal i_data_q                : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal i_data_valid            : std_logic                                         := '0';
    signal o_data_i                : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal o_data_q                : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal o_data_valid            : std_logic;
    -- Testbench
    signal tb_auto_set       : boolean := false;
    signal tb_auto_test_done : boolean := false;
    file tb_write_file       : text;
    -- Procedure
    procedure wait_clock (clk_ticks : integer) is
    begin
        for i in 0 to clk_ticks - 1 loop
            wait until rising_edge(clk);
        end loop;
    end procedure;
begin
    -- =========================================================================
    clk <= not clk after clk_period/2;
    -- =========================================================================
    zoom_top_inst : entity work.zoom_top
        generic map(
            G_INPUT_DATA_WIDTH => G_INPUT_DATA_WIDTH,
            G_COEFF_DATA_WIDTH => G_COEFF_DATA_WIDTH,
            G_INIT_FILE        => G_INIT_FILE,
            G_DDS_INIT_FILE    => G_DDS_INIT_FILE
        )
        port map
        (
            clk => clk,
            -- Config
            i_cfg_decimation_factor => i_cfg_decimation_factor,
            i_cfg_frequency_shift   => i_cfg_frequency_shift,
            i_cfg_valid             => i_cfg_valid,
            -- Input
            i_data_i     => i_data_i,
            i_data_q     => i_data_q,
            i_data_valid => i_data_valid,
            -- Output
            o_data_i     => o_data_i,
            o_data_q     => o_data_q,
            o_data_valid => o_data_valid
        );
    -- =========================================================================
    p_read_file : process
        file v_read_file       : text;
        variable v_line        : line;
        variable v_input_slv_i : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        variable v_input_slv_q : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    begin
        tb_auto_test_done <= false;
        wait until tb_auto_set = true;
        file_open(v_read_file, output_path(runner_cfg) & "/input_data.txt", read_mode);
        while not endfile(v_read_file) loop
            readline(v_read_file, v_line);
            BINARY_READ(v_line, v_input_slv_i);
            BINARY_READ(v_line, v_input_slv_q);
            i_data_i     <= v_input_slv_i;
            i_data_q     <= v_input_slv_q;
            i_data_valid <= '1';
            wait_clock(1);
            i_data_i     <= (others => '0');
            i_data_q     <= (others => '0');
            i_data_valid <= '0';
            wait_clock(1);
        end loop;
        file_close(v_read_file);
        -- Wait for the pipeline (halfband filter bank + mixer latency) to flush
        wait_clock(300);
        tb_auto_test_done <= true;
        wait;
    end process p_read_file;
    -- =========================================================================
    p_write_file : process
        variable v_line : line;
    begin
        while true loop
            wait until rising_edge(clk);
            if (o_data_valid = '1') then
                write(v_line, o_data_i, right, o_data_i'length + 4);
                write(v_line, o_data_q, right, o_data_q'length + 4);
                writeline(tb_write_file, v_line);
            end if;
        end loop;
        wait;
    end process;
    -- =========================================================================
    main : process
        -- Apply decimation factor and frequency shift in a single config pulse so both
        -- sticky enables (r_mixer_en, r_decimate_en) latch correctly inside zoom_top.
        procedure set_zoom_cfg is
        begin
            if G_MULTIRATE_FACTOR = 2 then
                i_cfg_decimation_factor <= "01";
            elsif G_MULTIRATE_FACTOR = 4 then
                i_cfg_decimation_factor <= "10";
            else
                assert FALSE report "Unsupported decimation factor for testbench!" severity FAILURE;
            end if;
            i_cfg_frequency_shift <= std_logic_vector(to_signed(G_MIXER_FREQUENCY_SHIFT, i_cfg_frequency_shift'length));
            i_cfg_valid           <= '1';
            wait_clock(1);
            i_cfg_decimation_factor <= (others => '0');
            i_cfg_frequency_shift   <= (others => '0');
            i_cfg_valid             <= '0';
        end procedure;
    begin
        test_runner_setup(runner, runner_cfg);
        if run("auto") then
            file_open(tb_write_file, output_path(runner_cfg) & "/output_data.txt", write_mode);
            wait until clk = '1';
            set_zoom_cfg;
            -- Allow the DDS tuning-word pipeline (3 stages) to settle before first sample
            wait_clock(20);
            tb_auto_set <= true;
            wait until tb_auto_test_done = true;
            file_close(tb_write_file);
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- =========================================================================
end;
