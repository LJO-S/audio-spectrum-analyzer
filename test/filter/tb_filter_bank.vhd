
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

entity filter_bank_tb is
    generic (
        encoded_tb_cfg : string;
        runner_cfg     : string
    );
end;

architecture bench of filter_bank_tb is
    -- Clock period
    constant clk_period : time := 40 ns;
    -- Generics
    constant G_NBR_OF_TAPS : positive := 101;
    constant G_QFORMAT     : positive := 15;
    constant G_INPUT_WIDTH : positive := 16;
    constant G_COEFF_WIDTH : positive := 16;
    -- Ports
    signal clk_25                : std_logic := '0';
    signal i_lpf_en              : std_logic := '0';
    signal i_hpf_en              : std_logic := '0';
    signal i_tvalid              : std_logic;
    signal i_tdata               : std_logic_vector(15 downto 0);
    signal i_new_data_strobe_lpf : std_logic;
    signal o_updating_coeffs_lpf : std_logic;
    signal i_waddr_lpf           : std_logic_vector(integer(ceil(log2(real(G_NBR_OF_TAPS)))) - 1 downto 0);
    signal i_wdata_lpf           : std_logic_vector(G_COEFF_WIDTH - 1 downto 0);
    signal i_we_lpf              : std_logic;
    signal i_new_data_strobe_hpf : std_logic;
    signal o_updating_coeffs_hpf : std_logic;
    signal i_waddr_hpf           : std_logic_vector(integer(ceil(log2(real(G_NBR_OF_TAPS)))) - 1 downto 0);
    signal i_wdata_hpf           : std_logic_vector(G_COEFF_WIDTH - 1 downto 0);
    signal i_we_hpf              : std_logic;
    signal o_tvalid              : std_logic;
    signal o_tdata               : std_logic_vector(15 downto 0);
    -- TB signals
    type t_coefficients is array (natural range 0 to G_NBR_OF_TAPS - 1) of signed(G_COEFF_WIDTH - 1 downto 0);
    type t_input_data is array (natural range 0 to 4095) of i_tdata'subtype;
    signal tb_coefficients_lpf   : t_coefficients;
    signal tb_coefficients_hpf   : t_coefficients;
    signal tb_coefficients_extra : t_coefficients;
    signal tb_tdata              : t_input_data         := (others => (others => '0'));
    signal tb_input_enable       : boolean              := FALSE;
    signal tb_counter            : unsigned(9 downto 0) := (others => '0');
    signal tb_48khz_strobe       : std_logic            := '0';
    signal tb_48khz_strobe_d0    : std_logic            := '0';

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
            waddr <= std_logic_vector(to_unsigned(i, waddr'length));
            wait_clock(1, clk_period);
        end loop;
        -- Stop load and strobe new data flag
        we              <= '0';
        new_data_strobe <= '1';
        wait_clock(1, clk_period);
        new_data_strobe <= '0';
    end procedure;

    -- Vunit config 
    type t_tb_cfg is record
        filter_1 : string;
        fc_1     : string;
        filter_2 : string;
        fc_2     : string;
    end record t_tb_cfg;

    impure function decode (encoded_tb_cfg : string) return t_tb_cfg is
    begin
        return(
        filter_1 => string(get(encoded_tb_cfg, "filter_1")),
        fc_1     => string(get(encoded_tb_cfg, "fc_1")),
        filter_2 => string(get(encoded_tb_cfg, "filter_2")),
        fc_2     => string(get(encoded_tb_cfg, "fc_2"))
        );
    end function decode;

    constant tb_cfg : t_tb_cfg := decode(encoded_tb_cfg);

begin
    /* ---------------------------------------------------------------*/
    clk_25 <= not clk_25 after clk_period/2;
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
        if tb_cfg.filter_1 /= "off" then
            -- Load set defined by generic
            file_open(
            coeff_file,
            "../../../scripts/fir_filter_coefficients/" &
            tb_cfg.filter_1 &
            "/" &
            tb_cfg.filter_1 &
            "_" &
            tb_cfg.fc_1 &
            "hz.coe",
            read_mode);
        else
            -- Default to 1000 Hz
            file_open(
            coeff_file,
            "../../../scripts/fir_filter_coefficients/lp/lp_1000hz.coe",
            read_mode);
        end if;
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
        if tb_cfg.filter_2 /= "off" then
            file_open(
            coeff_file,
            "../../../scripts/fir_filter_coefficients/" &
            tb_cfg.filter_2 &
            "/" &
            tb_cfg.filter_2 &
            "_" &
            tb_cfg.fc_2 &
            "hz.coe",
            read_mode);
        else
            file_open(
            coeff_file,
            "../../../scripts/fir_filter_coefficients/hp/hp_23000hz.coe",
            read_mode);
        end if;
        while not endfile(coeff_file) loop
            readline(coeff_file, v_line);
            HEX_READ(v_line, v_coeffiecients(v_rd_idx));
            v_rd_idx := v_rd_idx + 1;
        end loop;
        FILE_CLOSE(coeff_file);
        report "HPF coefficient file read!";
        tb_coefficients_hpf <= v_coeffiecients;

        -- Extra
        v_rd_idx := 0;
        file_open(
        coeff_file,
        "../../../scripts/fir_filter_coefficients/hp/hp_10000hz.coe",
        read_mode);
        while not endfile(coeff_file) loop
            readline(coeff_file, v_line);
            HEX_READ(v_line, v_coeffiecients(v_rd_idx));
            v_rd_idx := v_rd_idx + 1;
        end loop;
        FILE_CLOSE(coeff_file);
        report "Extra coefficient file read!";
        tb_coefficients_extra <= v_coeffiecients;

        wait;
    end process p_read_coeffs_file;
    /* ---------------------------------------------------------------*/
    -- Read stimuli file
    p_read_stimuli_file : process
        file v_read_file  : text;
        variable v_line   : line;
        variable ok       : boolean;
        variable v_data   : t_input_data;
        variable v_rd_idx : natural := 0;
    begin
        v_rd_idx := 0;
        file_open(
        v_read_file,
        output_path(runner_cfg) & "/" & "input_stimuli.txt",
        read_mode);
        while not endfile(v_read_file) loop
            readline(v_read_file, v_line);
            BINARY_READ(v_line, v_data(v_rd_idx));
            v_rd_idx := v_rd_idx + 1;
        end loop;
        report "Stimuli file read!";
        FILE_CLOSE(v_read_file);
        tb_tdata <= v_data;
        wait;
    end process p_read_stimuli_file;
    /* ---------------------------------------------------------------*/
    -- Write output file
    p_write_output_file : process (clk_25)
        file v_write_file : text open write_mode is output_path(runner_cfg) & "/" & "output_stimuli.txt";
        variable v_line   : line;
        variable ok       : boolean;
        variable v_wr_idx : natural := 0;
    begin
        if rising_edge(clk_25) then
            if (o_tvalid = '1') then
                write(v_line, o_tdata, right, o_tdata'length);
                writeline(v_write_file, v_line);
            end if;
        end if;
    end process p_write_output_file;
    /* ---------------------------------------------------------------*/
    -- Emulate I2C deser data
    process (clk_25)
    begin
        if rising_edge(clk_25) then
            tb_counter <= tb_counter + 1;
        end if;
    end process;
    -- 
    tb_48khz_strobe <= tb_counter(8);
    -- 
    p_tdata_generator : process (clk_25)
        variable v_rd_idx : natural := 0;
    begin
        if rising_edge(clk_25) then
            tb_48khz_strobe_d0 <= tb_48khz_strobe;
            i_tvalid           <= '0';
            i_tdata            <= (others => '0');
            if (tb_48khz_strobe_d0 = '0') and (tb_48khz_strobe = '1') and (tb_input_enable = true) then
                -- Detect rising_edge of new sample
                i_tvalid <= '1';
                i_tdata  <= tb_tdata(v_rd_idx);
                if (v_rd_idx = tb_tdata'length - 1) then
                    v_rd_idx := 0;
                else
                    v_rd_idx := v_rd_idx + 1;
                end if;
            end if;
        end if;
    end process p_tdata_generator;
    /* ---------------------------------------------------------------*/
    filter_bank_inst : entity work.filter_bank
        generic map(
            G_NBR_OF_TAPS => G_NBR_OF_TAPS,
            G_QFORMAT     => G_QFORMAT,
            G_INPUT_WIDTH => G_INPUT_WIDTH,
            G_COEFF_WIDTH => G_COEFF_WIDTH
        )
        port map
        (
            clk_25                => clk_25,
            i_lpf_en              => i_lpf_en,
            i_hpf_en              => i_hpf_en,
            i_tvalid              => i_tvalid,
            i_tdata               => i_tdata,
            i_new_data_strobe_lpf => i_new_data_strobe_lpf,
            o_updating_coeffs_lpf => o_updating_coeffs_lpf,
            i_waddr_lpf           => i_waddr_lpf,
            i_wdata_lpf           => i_wdata_lpf,
            i_we_lpf              => i_we_lpf,
            i_new_data_strobe_hpf => i_new_data_strobe_hpf,
            o_updating_coeffs_hpf => o_updating_coeffs_hpf,
            i_waddr_hpf           => i_waddr_hpf,
            i_wdata_hpf           => i_wdata_hpf,
            i_we_hpf              => i_we_hpf,
            o_tvalid              => o_tvalid,
            o_tdata               => o_tdata
        );
    main : process
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
        while test_suite loop
            -- =========================================================
            info("Directory containing testbench: " & tb_path(runner_cfg));
            info("Test output directory: " & output_path(runner_cfg));

            if run("filter-combos") then
                info("Running filter_bank cfg: " & LF &
                tb_cfg.filter_1 & "@" & tb_cfg.fc_1 & " Hz" & LF &
                tb_cfg.filter_2 & "@" & tb_cfg.fc_2 & " Hz");
                -- set_timeout(runner, 2 ms);

                -- =========================================================
                wait until clk_25 = '1';
                wait_clock(10, clk_period);
                ----------------------------------------------------
                -- Load coefficients based on generic set by run.py
                ----------------------------------------------------
                -- Load LPF
                load_coefficients(
                i_we_lpf,
                i_waddr_lpf,
                i_wdata_lpf,
                i_new_data_strobe_lpf,
                tb_coefficients_lpf);
                wait_clock(1, clk_period);
                check(o_updating_coeffs_lpf = '1', "Expected us to update coefficients on LPF!");
                wait until o_updating_coeffs_lpf = '0' for 1000 * clk_period;
                check(o_updating_coeffs_lpf = '0', "LPF is still loading coefficients??");

                -- Load HPF
                load_coefficients(
                i_we_hpf,
                i_waddr_hpf,
                i_wdata_hpf,
                i_new_data_strobe_hpf,
                tb_coefficients_hpf);
                wait_clock(1, clk_period);
                check(o_updating_coeffs_hpf = '1', "Expected us to update coefficients on HPF!");

                wait until o_updating_coeffs_hpf = '0' for 1000 * clk_period;
                check(o_updating_coeffs_hpf = '0', "HPF is still loading coefficients??");

                -- Enable/disable filters
                if tb_cfg.filter_1 /= "off" then
                    i_lpf_en <= '1';
                else
                    i_lpf_en <= '0';
                end if;
                if tb_cfg.filter_2 /= "off" then
                    i_hpf_en <= '1';
                else
                    i_hpf_en <= '0';
                end if;
                -- Enable input
                tb_input_enable <= true;

                -- Wait for both FIRs to fill up
                for fill in 0 to 1 loop
                    for i in 0 to (G_NBR_OF_TAPS - 1) loop
                        wait until rising_edge(o_tvalid);
                    end loop;
                end loop;

                -- Start spitting out data
                for i in 0 to (tb_tdata'length - 2 * (G_NBR_OF_TAPS - 1)) loop
                    wait until rising_edge(o_tvalid);
                end loop;
                test_runner_cleanup(runner);
                -- =========================================================

            elsif run("filter-incr") then
                -- Read 3rd filter coefficients array
                info("Running filter_bank cfg: " & LF &
                tb_cfg.filter_1 & "@" & tb_cfg.fc_1 & " Hz" & LF &
                tb_cfg.filter_2 & "@" & tb_cfg.fc_2 & " Hz");
                -- set_timeout(runner, 2 ms);

                -- =========================================================
                wait until clk_25 = '1';
                wait_clock(1, clk_period);
                ----------------------------------------------------
                -- Load coefficients based on generic set by run.py
                ----------------------------------------------------
                -- Load LPF
                load_coeffs("lp", tb_coefficients_lpf);

                -- Load HPF
                load_coeffs("hp", tb_coefficients_hpf);

                -- Enable/disable filters
                if tb_cfg.filter_1 /= "off" then
                    i_lpf_en <= '1';
                else
                    i_lpf_en <= '0';
                end if;
                if tb_cfg.filter_2 /= "off" then
                    i_hpf_en <= '1';
                else
                    i_hpf_en <= '0';
                end if;

                -- Enable input
                tb_input_enable <= true;

                -- Wait for both FIRs to fill up
                for fill in 0 to 1 loop
                    for i in 0 to (G_NBR_OF_TAPS - 1) loop
                        wait until rising_edge(o_tvalid);
                    end loop;
                end loop;

                -- 1) Start spitting out half of the data
                for i in 0 to ((tb_tdata'length - 2 * (G_NBR_OF_TAPS - 1))/2) loop
                    wait until rising_edge(o_tvalid);
                end loop;

                -- 2) Load new HP coeffs
                load_coeffs("hp", tb_coefficients_extra);

                -- 3) Spit out the rest of the data
                for i in 0 to ((tb_tdata'length - 2 * (G_NBR_OF_TAPS - 1))/2) loop
                    wait until rising_edge(o_tvalid);
                end loop;
                test_runner_cleanup(runner);
                -- =========================================================
            end if;
        end loop;
    end process main;
end;