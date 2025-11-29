
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

entity fir_filter_tb is
    generic (
        encoded_tb_cfg : string;
        runner_cfg     : string
    );
end;

architecture bench of fir_filter_tb is
    -- Clock period
    constant clk_period : time := 10 ns;
    -- Generics
    constant G_NBR_OF_TAPS : positive := 101;
    constant G_MEM_SIZE    : positive := 4 * G_NBR_OF_TAPS; -- *4 due to PS write incr being +4
    constant G_QFORMAT     : positive := 15;
    constant G_INPUT_WIDTH : positive := 16;
    constant G_COEFF_WIDTH : positive := 16;
    -- Why *4 below? Because PS incr by +4 with each write (0x...0, 0x...4, 0x...8, 0x...C). 
    -- The FIR filter then reads out in increments of 4.
    constant C_MEM_SIZE_LOG2 : integer := integer(ceil(log2(real(G_MEM_SIZE))));
    type t_tb_cfg is record
        filter_type   : string;
        filter_cutoff : string;
    end record t_tb_cfg;
    -- Ports
    signal clk_100           : std_logic := '0';
    signal i_new_data_strobe : std_logic;
    signal o_updating_coeffs : std_logic;

    signal i_waddr : std_logic_vector(C_MEM_SIZE_LOG2 - 1 downto 0);
    signal i_wdata : std_logic_vector(G_COEFF_WIDTH - 1 downto 0);
    signal i_we    : std_logic;
    signal w_raddr : unsigned(integer(ceil(log2(real(G_MEM_SIZE)))) - 1 downto 0);
    signal w_rdata : std_logic_vector(G_COEFF_WIDTH - 1 downto 0);

    signal i_tvalid : std_logic;
    signal i_tdata  : std_logic_vector(15 downto 0);
    signal o_tvalid : std_logic;
    signal o_tdata  : std_logic_vector(15 downto 0);

    -- TB signals
    type t_coefficients is array (natural range 0 to G_NBR_OF_TAPS - 1) of signed(G_COEFF_WIDTH - 1 downto 0);
    type t_input_data is array (natural range 0 to 4095) of i_tdata'subtype;
    signal tb_coefficients      : t_coefficients;
    signal tb_tdata             : t_input_data          := (others => (others => '0'));
    signal tb_enable_input_data : boolean               := FALSE;
    signal tb_counter           : unsigned(11 downto 0) := (others => '0');
    signal tb_48khz_strobe      : std_logic             := '0';
    signal tb_48khz_strobe_d0   : std_logic             := '0';

    impure function decode (encoded_tb_cfg : string) return t_tb_cfg is
    begin
        return(
        filter_type   => string(get(encoded_tb_cfg, "filter_type")),
        filter_cutoff => string(get(encoded_tb_cfg, "filter_cutoff"))
        );
    end function decode;

    constant tb_cfg : t_tb_cfg := decode(encoded_tb_cfg);
    /* ---------------------------------------------------------------*/
    procedure load_coefficients (
        signal we              : out std_logic;
        signal waddr           : out i_waddr'subtype;
        signal wdata           : out i_wdata'subtype;
        signal new_data_strobe : out std_logic
    ) is
    begin
        -- Load coefficients
        we <= '1';
        for i in tb_coefficients'range loop
            wdata <= std_logic_vector(tb_coefficients(i));
            -- Increment by 4 because that's how PS writes to BRAM via AXI BRAM Controller
            waddr <= std_logic_vector(to_unsigned(4 * i, waddr'length));
            wait_clock(1, clk_period);
        end loop;
        -- Stop load and strobe new data flag
        we              <= '0';
        new_data_strobe <= '1';
        wait_clock(1, clk_period);
        new_data_strobe <= '0';
    end procedure;
    /* ---------------------------------------------------------------*/
begin
    /* ---------------------------------------------------------------*/
    -- Read coefficients file
    p_read_coeffs_file : process
        file coeff_file          : text;
        variable v_line          : line;
        variable v_coeffiecients : t_coefficients;
        variable v_rd_idx        : natural := 0;
    begin
        v_rd_idx := 0;
        file_open(
        coeff_file,
        "../../../scripts/fir_filter_coefficients/" &
        tb_cfg.filter_type &
        "/" &
        tb_cfg.filter_type &
        "_" &
        tb_cfg.filter_cutoff &
        "hz.coe",
        read_mode);
        while not endfile(coeff_file) loop
            -- Fetch data
            readline(coeff_file, v_line);
            HEX_READ(v_line, v_coeffiecients(v_rd_idx));
            v_rd_idx := v_rd_idx + 1;
        end loop;
        FILE_CLOSE(coeff_file);
        report "Coefficient file read!";
        tb_coefficients <= v_coeffiecients;
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
    p_write_output_file : process (clk_100)
        file v_write_file : text open write_mode is output_path(runner_cfg) & "/" & "output_stimuli.txt";
        variable v_line   : line;
        variable ok       : boolean;
        variable v_wr_idx : natural := 0;
    begin
        if rising_edge(clk_100) then
            if (o_tvalid = '1') then
                write(v_line, o_tdata, right, o_tdata'length);
                writeline(v_write_file, v_line);
            end if;
        end if;
    end process p_write_output_file;
    /* ---------------------------------------------------------------*/
    clk_100 <= not clk_100 after clk_period/2;
    /* ---------------------------------------------------------------*/
    -- DUT
    fir_filter_inst : entity work.fir_filter
        generic map(
            G_NBR_OF_TAPS => G_NBR_OF_TAPS,
            G_QFORMAT     => G_QFORMAT,
            G_INPUT_WIDTH => G_INPUT_WIDTH,
            G_COEFF_WIDTH => G_COEFF_WIDTH
        )
        port map
        (
            clk_100           => clk_100,
            i_new_data_strobe => i_new_data_strobe,
            o_updating_coeffs => o_updating_coeffs,
            o_raddr           => w_raddr,
            i_rdata           => w_rdata,
            i_tvalid          => i_tvalid,
            i_tdata           => i_tdata,
            o_tvalid          => o_tvalid,
            o_tdata           => o_tdata
        );
    /* ---------------------------------------------------------------*/
    dpmem_dram_inst : entity work.dpmem_bram
        generic map(
            G_RAM_WIDTH      => G_COEFF_WIDTH,
            G_RAM_DEPTH_BITS => C_MEM_SIZE_LOG2
        )
        port map
        (
            clk => clk_100,
            -- Port A (PS)
            i_addra => i_waddr,
            i_dina  => i_wdata,
            i_wea   => i_we,
            o_douta => open,
            -- Port B (RTL)
            i_addrb => std_logic_vector(w_raddr),
            i_dinb => (others => '0'),
            i_web   => '0',
            o_doutb => w_rdata);
    /* ---------------------------------------------------------------*/
    -- Emulate I2C deser data
    p_48khz_strobe : process (clk_100)
    begin
        if rising_edge(clk_100) then
            tb_counter <= tb_counter + 1;
        end if;
    end process p_48khz_strobe;
    -- 
    tb_48khz_strobe <= tb_counter(10);
    -- 
    p_tdata_generator : process (clk_100)
        variable v_rd_idx : natural := 0;
    begin
        if rising_edge(clk_100) then
            tb_48khz_strobe_d0 <= tb_48khz_strobe;
            i_tvalid           <= '0';
            i_tdata            <= (others => '0');
            if (tb_48khz_strobe_d0 = '0') and (tb_48khz_strobe = '1') then
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
    -- Actual testbench
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            -- ===========================================
            wait until clk_100 = '1';
            wait for 10 * clk_period;
            -- Load coefficients based on generic set by run.py
            load_coefficients(
            i_we,
            i_waddr,
            i_wdata,
            i_new_data_strobe
            );
            -- ===========================================

            info("Directory containing testbench: " & tb_path(runner_cfg));
            info("Test output directory: " & output_path(runner_cfg));

            if run("filter-cutoffs") then
                info("Running fir_filter " & tb_cfg.filter_type & "-" & tb_cfg.filter_cutoff);
                -- set_timeout(runner, 2 ms);

                wait_clock(1, clk_period);
                check(o_updating_coeffs = '1', "Expected us to update coefficients!");
                wait until o_updating_coeffs = '0';

                -- Wait for FIR to fill up
                for i in 0 to (G_NBR_OF_TAPS - 1) loop
                    wait until rising_edge(o_tvalid);
                end loop;

                -- Start spitting out data
                for i in 0 to (tb_tdata'length - G_NBR_OF_TAPS - 1) loop
                    wait until rising_edge(o_tvalid);
                end loop;
                test_runner_cleanup(runner);
                -- ===========================================
            end if;
        end loop;
    end process main;
    -- test_runner_watchdog(runner, 10 ms);
    /* ---------------------------------------------------------------*/
end;