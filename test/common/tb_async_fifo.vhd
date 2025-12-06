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

    signal tb_wr_data    : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal tb_wr_data_d1 : std_logic_vector(G_DATA_WIDTH - 1 downto 0);

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
    p_25m_strb : process (i_wr_clk)
    begin
        if rising_edge(i_wr_clk) then
            tb_counter_100m_25m <= tb_counter_100m_25m + 1;
            tb_100m_25m_strb_d1 <= tb_100m_25m_strb;
        end if;
    end process p_25m_strb;
    tb_100m_25m_strb <= tb_counter_100m_25m(1) and not(tb_100m_25m_strb_d1);

    -- Generate input data
    p_producer : process (i_wr_clk)
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

                tb_wr_data    <= v_data_seg1 & v_data_seg2 & v_data_seg3;
                tb_wr_data_d1 <= tb_wr_data;
            end if;
        end if;
    end process p_producer;

    -- 250 MHz consumer
    p_consumer : process (i_rd_clk)
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
    end process p_consumer;
    i_rd_en <= tb_250m_25m_strb;
    -- ===============================================================
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        if run("auto") then
            for i in 0 to 499 loop
                -- Wait until writing data
                wait until i_wr_en = '1';
                wait_clock(1, clk_period_wr);

                -- If reading now we dont know what data we're getting
                if (i_rd_en = '1') then
                    wait until i_rd_en = '0';
                end if;

                -- Fetch previous write if non-empty
                wait until i_rd_en = '1';
                if (o_empty = '0') then
                    wait_clock(2, clk_period_rd);
                    check(
                    o_rd_data = tb_wr_data_d1,
                    "Data mismatch! Actual=0b" &
                    to_bstring(o_rd_data) &
                    " vs Expected=0b" &
                    to_bstring(tb_wr_data)
                    );
                end if;
            end loop;
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ===============================================================
end;