library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
--
use work.tb_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity spectrum_framebuffer_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of spectrum_framebuffer_tb is
    -- Clock period
    constant clk_period     : time    := 5 ns;
    constant C_SCREEN_X_DIM : integer := 640;
    constant C_SCREEN_Y_DIM : integer := 480;
    -- Generics
    constant G_NFFT         : natural := 1024;
    constant G_DATA_WIDTH   : natural := 8;
    constant G_DATA_DEPTH_X : natural := 640;
    constant G_DATA_DEPTH_Y : natural := 480/2;
    -- Ports
    signal clk            : std_logic := '0';
    signal i_waterfall_en : std_logic := '0';
    signal i_tdata        : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal i_tvalid       : std_logic;
    signal i_tlast        : std_logic;
    signal i_rd_addr_X    : std_logic_vector(integer(ceil(log2(real(G_DATA_DEPTH_X)))) - 1 downto 0);
    signal i_rd_addr_Y    : std_logic_vector(integer(ceil(log2(real(G_DATA_DEPTH_Y)))) - 1 downto 0);
    signal o_rd_data      : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    -- Testbench
    signal tb_enable    : boolean                                                          := false;
    signal tb_check_en  : boolean                                                          := false;
    signal tb_data_idx  : integer range 0 to G_NFFT                                        := 0;
    signal tb_X_counter : unsigned(integer(ceil(log2(real(C_SCREEN_X_DIM)))) - 1 downto 0) := (others => '0');
    signal tb_Y_counter : unsigned(integer(ceil(log2(real(C_SCREEN_Y_DIM)))) - 1 downto 0) := (others => '0');

    type t_producer_state is (IDLE, PRODUCING, HOLD);
    signal tb_data_State : t_producer_state := IDLE;

    type t_rd_addr_X_shreg is array (0 to 2) of UNSIGNED(tb_X_counter'range);
    signal tb_rd_addr_X : t_rd_addr_X_shreg := (others => (others => '0'));
begin
    -- ======================================================================
    clk <= not clk after clk_period/2;
    -- ======================================================================
    spectrum_framebuffer_inst : entity work.spectrum_framebuffer
        generic map(
            G_NFFT         => G_NFFT,
            G_DATA_WIDTH   => G_DATA_WIDTH,
            G_DATA_DEPTH_X => G_DATA_DEPTH_X,
            G_DATA_DEPTH_Y => G_DATA_DEPTH_Y
        )
        port map
        (
            clk            => clk,
            i_waterfall_en => i_waterfall_en,
            i_tdata        => i_tdata,
            i_tvalid       => i_tvalid,
            i_tlast        => i_tlast,
            i_rd_addr_X    => i_rd_addr_X,
            i_rd_addr_Y    => i_rd_addr_Y,
            o_rd_data      => o_rd_data
        );
    -- ======================================================================
    -- DATA IN/OUT
    p_data_producer : process (clk)
    begin
        if rising_edge(clk) then
            i_tvalid <= '0';
            i_tdata  <= (others => '1');
            i_tlast  <= '0';
            case tb_data_State is
                when IDLE =>
                    if (tb_enable = true) then
                        tb_data_State <= PRODUCING;
                    end if;
                when PRODUCING =>
                    i_tdata  <= std_logic_vector(unsigned(i_tdata) + 1);
                    i_tvalid <= '1';
                    i_tlast  <= '1' when tb_data_idx = G_NFFT - 2 else
                        '0';
                    if (i_tvalid = '1') then
                        tb_data_idx <= tb_data_idx + 1;
                        if (i_tlast = '1') then
                            -- Zero counter 
                            tb_data_idx   <= 0;
                            i_tvalid      <= '0';
                            tb_data_State <= HOLD;
                        end if;
                    end if;
                when HOLD =>
                    tb_data_State <= IDLE;
                when others =>
                    tb_data_State <= IDLE;
            end case;
        end if;
    end process p_data_producer;

    p_data_consumer : process (clk)
    begin
        if rising_edge(clk) then
            tb_X_counter <= tb_X_counter + 1;
            if (tb_X_counter >= C_SCREEN_X_DIM - 1) then
                tb_X_counter <= (others => '0');
                tb_Y_counter <= tb_Y_counter + 1;
                if (tb_Y_counter >= C_SCREEN_Y_DIM - 1) then
                    tb_Y_counter <= (others => '0');
                end if;
            end if;

            -- Testing
            tb_rd_addr_X <= tb_X_counter & tb_rd_addr_X(tb_rd_addr_X'low to tb_rd_addr_X'high - 1);
            if (tb_check_en = true) then
                check(
                (tb_rd_addr_X(tb_rd_addr_X'high) mod (2**G_DATA_WIDTH)) = unsigned(o_rd_data),
                "Data mismatch! Actual=" &
                integer'image(to_integer(unsigned(o_rd_data))) &
                " vs Expected=" &
                integer'image(to_integer(tb_rd_addr_X(tb_rd_addr_X'high) mod (2**G_DATA_WIDTH)))
                );
            end if;
        end if;
    end process p_data_consumer;
    -- Connect
    i_rd_addr_X <= std_logic_vector(tb_X_counter);
    i_rd_addr_Y <= std_logic_vector(tb_Y_counter(tb_Y_counter'high downto tb_Y_counter'low + 1));
    -- ======================================================================
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        if run("visual") then
            info("Hello world test_alive");
            wait until clk = '1';
            wait_clock(10, clk_period);
            tb_enable <= true;
            for i in 0 to 4 loop
                wait until i_tlast = '1';
                wait_clock(2, clk_period);
            end loop;
            i_waterfall_en <= '1';
            for i in 0 to 4 loop
                wait until i_tlast = '1';
                wait_clock(2, clk_period);
            end loop;
        elsif run("auto") then
            tb_enable <= true;
            wait until clk = '1';
            -- Then we have written to a column
            wait until i_tlast = '1';
            tb_check_en <= true;
            for i in 0 to 25 loop
                wait until i_tlast = '1';
                wait_clock(1, clk_period);
            end loop;
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ======================================================================
end;