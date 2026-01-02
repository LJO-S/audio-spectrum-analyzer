library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--
use work.tb_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity ping_pong_memory_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of ping_pong_memory_tb is
    -- Clock period
    constant clk_period   : time    := 10 ns;
    constant C_RD_LATENCY : natural := 4;
    constant C_NFFT       : natural := 2048;
    constant C_LOG2_NFFT  : integer := integer(ceil(log2(real(C_NFFT))));
    -- Generics
    -- Ports
    signal clk_100          : std_logic                                  := '0';
    signal i_fft_data_magn  : std_logic_vector(31 downto 0)              := (others => '0');
    signal i_fft_data_last  : std_logic                                  := '0';
    signal i_fft_data_valid : std_logic                                  := '0';
    signal i_xk_index       : std_logic_vector(C_LOG2_NFFT - 1 downto 0) := (others => '0');
    signal i_rd_addr        : std_logic_vector(C_LOG2_NFFT - 1 downto 0) := std_logic_vector(to_unsigned(C_NFFT/3, C_LOG2_NFFT));
    signal o_rd_data        : std_logic_vector(31 downto 0);
    -- Helper signals
    signal tb_enable           : std_logic := '0';
    signal tb_clk_strobe       : std_logic := '0';
    signal tb_use_slow_readout : std_logic := '1';
    signal tb_latency_cntr     : integer   := 0;

    type t_input_data_state is (IDLE, GENERATING);
    signal tb_input_data_state : t_input_data_state := IDLE;
    type t_output_check is (IDLE, CHECKING_VALID);
    signal tb_out_check_state : t_output_check := IDLE;
    type t_rd_addr_shreg is array (0 to C_RD_LATENCY - 1) of std_logic_vector(i_rd_addr'range);
    signal tb_rd_addr_shreg : t_rd_addr_shreg                             := (others => (others => '0'));
    signal tb_mem_sel_shreg : std_logic_vector(C_RD_LATENCY - 1 downto 0) := (others => '0');

    type t_check_array is array (0 to C_NFFT - 1) of std_logic_vector(i_fft_data_magn'range);
    type t_check_array_of_array is array (0 to 1) of t_check_array;
    signal tb_golden_ref : t_check_array_of_array := (others => (others => (others => '0')));
    signal tb_mem_sel    : std_logic              := '0';

    signal tb_tlast_force : std_logic := '0';

begin
    -- ======================================================================
    clk_100 <= not clk_100 after clk_period/2;
    -- ======================================================================

    ping_pong_memory_inst : entity work.ping_pong_memory
        port map
        (
            clk_100          => clk_100,
            i_fft_data_magn  => i_fft_data_magn,
            i_fft_data_last  => i_fft_data_last,
            i_fft_data_valid => i_fft_data_valid,
            i_xk_index       => i_xk_index,
            i_rd_addr        => i_rd_addr,
            o_rd_data        => o_rd_data
        );
    -- ======================================================================
    p_input_data : process (clk_100)
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

            case tb_input_data_state is
                when IDLE =>
                    -- ---------------------
                    if (tb_enable = '1') then
                        i_fft_data_valid    <= '1';
                        tb_input_data_state <= GENERATING;
                    end if;
                    -- ---------------------
                when GENERATING =>
                    -- Data 
                    i_fft_data_magn <= rand_slv(i_fft_data_magn'length);

                    -- Assuming wraparound for pow-of-2 NFFTs
                    i_xk_index <= std_logic_vector(unsigned(i_xk_index) + 1);

                    -- Last
                    if (unsigned(i_xk_index) = C_NFFT - 2) then
                        i_fft_data_last <= '1';
                    else
                        i_fft_data_last <= tb_tlast_force;
                    end if;
                    -- ---------------------
            end case;
            if (tb_enable = '0') then
                i_fft_data_valid    <= '0';
                tb_input_data_state <= IDLE;
            end if;
        end if;
    end process p_input_data;
    -- ======================================================================
    p_rd_addr : process (clk_100)
    begin
        if rising_edge(clk_100) then
            if (tb_use_slow_readout = '1') then
                tb_clk_strobe <= not tb_clk_strobe;
            else
                tb_clk_strobe <= '1';
            end if;
            if (tb_enable = '1') and (tb_clk_strobe = '1') then
                i_rd_addr <= std_logic_vector(unsigned(i_rd_addr) + 1);
            end if;
        end if;
    end process p_rd_addr;
    -- ======================================================================
    p_check_output : process (clk_100)
    begin
        if rising_edge(clk_100) then
            tb_rd_addr_shreg <= i_rd_addr & tb_rd_addr_shreg(tb_rd_addr_shreg'low to tb_rd_addr_shreg'high - 1);
            tb_mem_sel_shreg <= tb_mem_sel_shreg(tb_mem_sel_shreg'high - 1 downto 0) & tb_mem_sel;

            -- Keep track of data
            if (i_fft_data_valid = '1') then
                if (tb_mem_sel = '1') then
                    tb_golden_ref(1)(to_integer(unsigned(i_xk_index))) <= i_fft_data_magn;
                else
                    tb_golden_ref(0)(to_integer(unsigned(i_xk_index))) <= i_fft_data_magn;
                end if;
            end if;

            if (i_fft_data_last = '1') then
                tb_mem_sel <= not(tb_mem_sel);
            end if;

            -- Check data
            case tb_out_check_state is
                    -- ---------------------
                when IDLE =>
                    tb_latency_cntr <= 0;
                    if (tb_enable = '1') then
                        tb_out_check_state <= CHECKING_VALID;
                    end if;
                    -- ---------------------
                    -- ---------------------
                when CHECKING_VALID =>
                    -- Latency Cntr
                    if tb_latency_cntr < C_RD_LATENCY then
                        tb_latency_cntr <= tb_latency_cntr + 1;
                    else
                        -- if (tb_rd_addr_shreg(tb_rd_addr_shreg'high) = (i_rd_addr'range => XXX)) then
                        if (tb_mem_sel_shreg(tb_mem_sel_shreg'high) /= tb_mem_sel_shreg(tb_mem_sel_shreg'high - 1)) then
                            null;
                        else
                            if (tb_mem_sel_shreg(tb_mem_sel_shreg'high - 1) = '1') then
                                -- Wr Mem 1, Rd Mem 0
                                check(
                                o_rd_data = tb_golden_ref(0)(to_integer(unsigned(tb_rd_addr_shreg(tb_rd_addr_shreg'high)))),
                                "Mismatch between readout and expected data. Actual=" &
                                integer'image(to_integer(unsigned(o_rd_data))) &
                                " vs expected=" &
                                integer'image(to_integer(unsigned(tb_golden_ref(0)(to_integer(unsigned(tb_rd_addr_shreg(tb_rd_addr_shreg'high)))))))
                                );
                            else
                                -- Wr Mem 0, Rd Mem 1
                                check(
                                o_rd_data = tb_golden_ref(1)(to_integer(unsigned(tb_rd_addr_shreg(tb_rd_addr_shreg'high)))),
                                "Mismatch between readout and expected data. Actual=" &
                                integer'image(to_integer(unsigned(o_rd_data))) &
                                " vs expected=" &
                                integer'image(to_integer(unsigned(tb_golden_ref(1)(to_integer(unsigned(tb_rd_addr_shreg(tb_rd_addr_shreg'high)))))))
                                );
                            end if;
                        end if;
                    end if;
                    -- ---------------------
            end case;
        end if;
    end process p_check_output;
    -- ======================================================================

    main : process
        variable v_last_ping_pong                                        : std_logic;
        alias tb_ping_pong is << signal ping_pong_memory_inst.r_pingpong : std_logic >> ;
    begin
        test_runner_setup(runner, runner_cfg);
        while test_suite loop
            -----------------------------------------------------
            if run("slow-readout-auto") then
                info("Running test of ping_pong memory SLOW readout!");
                tb_use_slow_readout <= '1';
                wait until (clk_100 = '1');
                wait_clock(10, clk_period);
                tb_enable <= '1';
                for i in 0 to 9 loop
                    wait until i_fft_data_last = '1';
                end loop;
                -----------------------------------------------------
            elsif run("fast-readout-auto") then
                info("Running tb_ping_pong-fast-readout-auto!");
                tb_use_slow_readout <= '0';
                wait until (clk_100 = '1');
                wait_clock(10, clk_period);
                tb_enable <= '1';
                for i in 0 to 9 loop
                    wait until i_fft_data_last = '1';
                end loop;
                -----------------------------------------------------
            elsif run("stuck-at-tlast") then
                info("Running tb_ping_pong-fast-readout-auto!");
                tb_use_slow_readout <= '0';
                wait until (clk_100 = '1');
                wait_clock(10, clk_period);
                tb_enable <= '1';
                wait until i_fft_data_last = '1';
                tb_tlast_force <= '1';
                v_last_ping_pong := tb_ping_pong;
                for i in 0 to 99 loop
                    check(v_last_ping_pong = tb_ping_pong, "Ping pong changed when TLAST was stuck!");
                    wait_clock(1, clk_period);
                end loop;
                -----------------------------------------------------
            end if;
            test_runner_cleanup(runner);
        end loop;
    end process main;
    -- ======================================================================
end;