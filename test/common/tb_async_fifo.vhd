library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
-- 
use work.tb_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity async_fifo_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of async_fifo_tb is
    -- Clock period
    constant clk_period_wr : time := 10 ns;
    constant clk_period_rd : time := 4 ns;
    -- Generics
    constant G_DATA_WIDTH : natural := 30;
    constant G_DATA_DEPTH : natural := 8;
    -- Ports
    signal i_wr_clk  : std_logic := '0';
    signal i_wr_rst  : std_logic;
    signal i_wr_en   : std_logic;
    signal i_wr_data : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal o_full    : std_logic;
    signal i_rd_clk  : std_logic := '0';
    signal i_rd_rst  : std_logic;
    signal i_rd_en   : std_logic;
    signal o_rd_data : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal o_empty   : std_logic;

    -- TB 
    signal tb_external         : boolean              := false;
    signal tb_counter_100m_25m : unsigned(1 downto 0) := (others => '0');
    signal tb_counter_250m_25m : unsigned(3 downto 0) := (others => '0');
    signal tb_100m_25m_strb    : std_logic;
    signal tb_100m_25m_strb_d1 : std_logic;
    signal tb_250m_25m_strb    : std_logic;
    signal tb_250m_25m_strb_d1 : std_logic;

    signal tb_wr_data : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal tb_wr_en   : std_logic;
    signal tb_rd_data : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal tb_rd_en   : std_logic;

begin
    -- ===============================================================
    i_wr_clk <= not i_wr_clk after clk_period_wr/2;
    i_rd_clk <= not i_rd_clk after clk_period_rd/2;
    -- ===============================================================
    async_fifo_inst : entity work.async_fifo
        generic map(
            G_DATA_WIDTH => G_DATA_WIDTH,
            G_DATA_DEPTH => G_DATA_DEPTH
        )
        port map
        (
            -- Write
            i_wr_clk  => i_wr_clk,
            i_wr_rst  => i_wr_rst,
            i_wr_en   => i_wr_en,
            i_wr_data => i_wr_data,
            o_full    => o_full,
            -- Read
            i_rd_clk  => i_rd_clk,
            i_rd_rst  => i_rd_rst,
            i_rd_en   => i_rd_en,
            o_rd_data => o_rd_data,
            o_empty   => o_empty
        );
    -- ===============================================================
    -- 100 MHz producer

    -- 25 MHz CE Strobe
    process (i_wr_clk)
    begin
        if rising_edge(i_wr_clk) then
            tb_counter_100m_25m <= tb_counter_100m_25m + 1;
            tb_100m_25m_strb_d1 <= tb_100m_25m_strb;
        end if;
    end process;
    tb_100m_25m_strb <= tb_counter_100m_25m(1) and not(tb_100m_25m_strb_d1);

    -- Generate input data
    process (i_wr_clk)
        variable v_data_seg1 : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(0, 10));
        variable v_data_seg2 : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(10, 10));
        variable v_data_seg3 : std_logic_vector(9 downto 0) := std_logic_vector(to_unsigned(100, 10));
    begin
        if rising_edge(i_wr_clk) then
            i_wr_en <= '0';
            if (tb_100m_25m_strb = '1') then
                v_data_seg1 := std_logic_vector(unsigned(v_data_seg1) + 1);
                v_data_seg2 := std_logic_vector(unsigned(v_data_seg2) + 1);
                v_data_seg3 := std_logic_vector(unsigned(v_data_seg3) + 1);
                i_wr_data <= v_data_seg1 & v_data_seg2 & v_data_seg3;
                i_wr_en   <= '1';
            end if;
        end if;
    end process;

    -- 250 MHz consumer
    process (i_rd_clk)
    begin
        if rising_edge(i_rd_clk) then
            tb_250m_25m_strb_d1 <= tb_250m_25m_strb;
            if (tb_counter_250m_25m = 9) then
                tb_250m_25m_strb    <= '1';
                tb_counter_250m_25m <= (others => '0');
            else
                tb_250m_25m_strb    <= '0';
                tb_counter_250m_25m <= tb_counter_250m_25m + 1;
            end if;
        end if;
    end process;
    i_rd_en <= tb_250m_25m_strb;

    process (i_rd_clk)
    begin
        if rising_edge(i_rd_clk) then
            if (tb_250m_25m_strb_d1 = '1') then
                if o_empty = '0' then
                    tb_rd_data <= o_rd_data;
                else
                    tb_rd_data <= (others => '0');
                end if;
            end if;
        end if;
    end process;
    -- ===============================================================
    main : process
        variable seed1, seed2 : positive := 999;
        -- 
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
        test_runner_setup(runner, runner_cfg);
        if run("auto") then
            -- TODO make this auto
            wait_clock(100, clk_period_wr);
        elsif run("auto-full-empty") then
            null;
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ===============================================================
end;