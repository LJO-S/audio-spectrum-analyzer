
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- 
use work.tb_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;
-- 
entity i2s_ser_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of i2s_ser_tb is
    -- Clock period
    constant clk_period        : time    := 10 ns;
    constant TB_C_TIMEOUT      : time    := 100 ms;
    constant TB_C_MAX_BIT_CNTR : natural := 16;

    -- Generics
    -- Ports
    signal clk_100  : std_logic := '0';
    signal i_pbclk : std_logic := '0';
    signal i_bclk  : std_logic := '0';
    signal i_en    : std_logic := '0';
    signal o_pbdat : std_logic := '0';

    signal o_deser_tdata  : std_logic_vector(15 downto 0) := (others => '0');
    signal o_deser_tvalid : std_logic                     := '0';

    -- TB
    signal tb_tdata    : std_logic_vector(15 downto 0) := (others => '0');
    signal tb_tvalid   : std_logic                     := '0';
    signal tb_counter  : unsigned(15 downto 0)         := (others => '0');
    signal tb_bclk     : std_logic                     := '0';
    signal tb_bclk_d1  : std_logic                     := '0';
    signal tb_bclk_d2  : std_logic                     := '0';
    signal tb_pbclk    : std_logic                     := '0';
    signal tb_pbclk_d1 : std_logic                     := '0';
    signal tb_pbclk_d2 : std_logic                     := '0';
    signal tb_pbclk_fe : std_logic                     := '0';
begin
    -- ===============================================================
    clk_100 <= not clk_100 after clk_period/2;
    -- ===============================================================
    p_subclk_generator : process (clk_100)
    begin
        if rising_edge(clk_100) then
            tb_counter <= tb_counter + 1;
        end if;
    end process p_subclk_generator;
    i_pbclk <= tb_counter(10); -- /2048 ~ 48 kHz
    i_bclk  <= tb_counter(4); -- /32 = 3.125 MHz
    -- ===============================================================
    process (clk_100)
        variable seed1, seed2 : positive := 999;
        impure function rand_slv (
            len : integer
        ) return std_logic_vector is
            variable r   : real;
            variable slv : std_logic_vector(len - 1 downto 0);
        begin
            for i in slv'range loop
                UNIFORM(seed1, seed2, r);
                slv(i) := '1' when (r > 0.5) else
                '0';
            end loop;
            return slv;
        end function;
    begin
        if rising_edge(clk_100) then
            tb_tvalid <= '0';
            if (tb_pbclk_fe = '1') then
                tb_tdata  <= rand_slv(tb_tdata'length);
                tb_tvalid <= '1';
            end if;
        end if;
    end process;

    tb_pbclk_fe <= tb_pbclk and not(i_pbclk);
    process (clk_100)
    begin
        if rising_edge(clk_100) then
            tb_pbclk    <= i_pbclk;
            tb_pbclk_d1 <= tb_pbclk;
            tb_pbclk_d2 <= tb_pbclk_d1;
            tb_bclk     <= i_bclk;
            tb_bclk_d1  <= tb_bclk;
            tb_bclk_d2  <= tb_bclk_d1;
        end if;
    end process;
    -- ===============================================================
    i2s_ser_inst : entity work.i2s_ser
        port map
        (
            clk_100   => clk_100,
            i_pbclk  => tb_pbclk_d2,
            i_bclk   => tb_bclk_d2,
            i_tdata  => tb_tdata,
            i_tvalid => tb_tvalid,
            i_en     => '1',
            o_pbdat  => o_pbdat
        );
    -- ===============================================================
    i2s_deser_inst : entity work.i2s_deser
        port map
        (
            clk_100        => clk_100,
            i_lrclk       => tb_pbclk_d2,
            i_bclk        => tb_bclk_d2,
            i_serial_data => o_pbdat,
            i_en          => '1',
            o_data        => o_deser_tdata,
            o_valid       => o_deser_tvalid
        );
    -- ===============================================================
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        if run("basic") then

            info("Running tb_i2s_ser-BASIC");

            wait until clk_100 = '1';
            wait_clock(10, clk_period);

            for i in 0 to 15 loop

                wait until tb_tvalid = '1' for TB_C_TIMEOUT;

                -- Wait until LEFT CHANNEL starts
                wait until falling_edge(tb_pbclk_d2);

                -- Listen for all output bits
                for j in tb_tdata'range loop
                    wait until falling_edge(tb_bclk_d2);
                    wait_clock(2, clk_period);
                    check(
                    o_pbdat = tb_tdata(j),
                    "The serialized output didn't match the requested word!" & LF &
                    "Got {" & std_logic'image(o_pbdat) & "}" & LF &
                    "Expected {" & std_logic'image(tb_tdata(j)) & "}" & LF &
                    "at index: " & integer'image(j)
                    );
                end loop;

            end loop;
            info("Done tb_i2s_ser-BASIC");
        elsif run("deserializer") then

            info("Running tb_i2s_ser-DESERIALIZER");

            wait until clk_100 = '1';
            wait_clock(10, clk_period);

            for i in 0 to 15 loop

                wait until tb_tvalid = '1' for TB_C_TIMEOUT;
                -- Wait until LEFT CHANNEL starts
                wait until o_deser_tvalid = '1';

                -- Listen for all output bits
                check(o_deser_tdata = tb_tdata,
                "The deserialized output didn't match the requested word!" & LF &
                "Got {" & to_binary_string(o_deser_tdata) & "}" & LF &
                "Expected {" & to_binary_string(tb_tdata) & "}" & LF &
                "at index: " & integer'image(i));

            end loop;
            info("Done tb_i2s_ser-BASIC");
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ===============================================================
end;