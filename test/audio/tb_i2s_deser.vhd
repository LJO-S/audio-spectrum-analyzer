
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
use work.tb_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity i2s_deser_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of i2s_deser_tb is
    -- Clock period
    constant clk_period        : time    := 10 ns;
    constant TB_C_MAX_BIT_CNTR : natural := 16;
    -- Generics
    -- Ports
    signal clk_100       : std_logic := '0';
    signal i_lrclk       : std_logic := '1';
    signal i_bclk        : std_logic := '0';
    signal i_serial_data : std_logic;
    signal o_data        : std_logic_vector(15 downto 0);
    signal o_valid       : std_logic;

    signal tb_counter : unsigned(15 downto 0) := (others => '0');
    signal tb_enable  : std_logic             := '0';
    type t_TB_IIS_STATE is (LEFT_INITIAL, LEFT_SEND, LEFT_FINAL, RIGHT_INITIAL, RIGHT_SEND, RIGHT_FINAL);
    signal tb_iis_state    : t_TB_IIS_STATE        := LEFT_SEND;
    signal tb_bit_cntr     : unsigned(4 downto 0)  := (others => '0');
    signal tb_serial_value : std_logic             := '0';
    signal tb_bit_tracker  : natural range 0 to 16 := 0;
begin
    i2s_deser_inst : entity work.i2s_deser
        port map
        (
            clk_100       => clk_100,
            i_lrclk       => i_lrclk,
            i_bclk        => i_bclk,
            i_serial_data => i_serial_data,
            i_en          => tb_enable,
            o_data        => o_data,
            o_valid       => o_valid
        );

    clk_100 <= not clk_100 after clk_period/2; -- 25 MHz
    i_lrclk <= tb_counter(10);                 -- /2048 ~ 48 kHz
    i_bclk  <= tb_counter(4);                  -- /32 = 3.125 MHz

    p_subclk_generator : process (clk_100)
    begin
        if rising_edge(clk_100) then
            tb_counter <= tb_counter + 1;
        end if;
    end process p_subclk_generator;

    p_i2s_data : process (i_bclk)
    begin
        if falling_edge(i_bclk) then
            i_serial_data <= 'X';
            case tb_iis_state is
                    -- ----------------------------------------
                    -- ----------------------------------------
                when LEFT_INITIAL =>
                    if (i_lrclk = '0') then
                        tb_iis_state <= LEFT_SEND;
                    end if;
                    -- ----------------------------------------
                    -- ----------------------------------------
                when LEFT_SEND =>
                    i_serial_data <= tb_serial_value;
                    -- tb_dummy      <= not tb_dummy;
                    tb_bit_cntr <= tb_bit_cntr + 1;
                    if (tb_bit_cntr >= TB_C_MAX_BIT_CNTR) then
                        tb_iis_state  <= RIGHT_INITIAL;
                        i_serial_data <= 'X';
                        tb_bit_cntr   <= (others => '0');
                    end if;
                    -- ----------------------------------------
                    -- ----------------------------------------
                when RIGHT_INITIAL =>
                    if (i_lrclk = '1') then
                        tb_iis_state <= RIGHT_SEND;
                    end if;
                    -- ----------------------------------------
                    -- ----------------------------------------
                when RIGHT_SEND =>
                    i_serial_data <= not tb_serial_value;
                    tb_bit_cntr   <= tb_bit_cntr + 1;
                    if (tb_bit_cntr >= TB_C_MAX_BIT_CNTR) then
                        tb_iis_state    <= LEFT_INITIAL;
                        i_serial_data   <= 'X';
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

    main : process
        alias ldata is << signal i2s_deser_inst.r_ldata : std_logic_vector(15 downto 0) >> ;
        alias rdata is << signal i2s_deser_inst.r_rdata : std_logic_vector(15 downto 0) >> ;
    begin
        test_runner_setup(runner, runner_cfg);
        if run("auto") then
            info("Running tb_i2s_deser-AUTO");
            tb_enable <= '0';
            wait_clock(25, clk_period);
            wait until clk_100 = '1';
            tb_enable <= '1';
            for i in 0 to 3 loop
                wait until o_valid = '1';
                assert ldata = (ldata'range => tb_serial_value)
                report "ldata took on unexpected value:" &
                    "Expected all " & std_logic'image(tb_serial_value) &
                    " but got ldata=" & std_logic'image(ldata(0))
                    severity error;
                assert rdata = (rdata'range => not(tb_serial_value))
                report "rdata took on unexpected value."
                    severity error;
            end loop;
            wait_clock(25, clk_period);
            info("Complete tb_i2s_deser-AUTO");
            test_runner_cleanup(runner);
        end if;
    end process main;
end;