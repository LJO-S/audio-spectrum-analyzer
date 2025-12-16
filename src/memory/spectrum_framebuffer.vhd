-- ---------------------------------------------------------------------------------
-- Holds 640x(480/C)xB output samples from the FFT
-- * C: divisor needed to fit all data in a Zybo
-- * B: bytes of data
-- 
-- This data is read out either to form a 1D FFT plot or a 2D waterfall.
-- 
-- Latency: 2 cc
-- ---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity spectrum_framebuffer is
    generic (
        G_DATA_WIDTH   : natural := 8;
        G_DATA_DEPTH_X : natural := 640;
        G_DATA_DEPTH_Y : natural := 480/2
    );
    port (
        clk : in std_logic;
        -- Control IF
        i_waterfall_en : std_logic;
        -- FFT IF
        i_tdata  : in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        i_tvalid : in std_logic;
        i_tlast  : in std_logic;
        -- VIDEO IF
        i_rd_addr_X : in std_logic_vector(integer(ceil(log2(real(G_DATA_DEPTH_X)))) - 1 downto 0);
        i_rd_addr_Y : in std_logic_vector(integer(ceil(log2(real(G_DATA_DEPTH_Y)))) - 1 downto 0);
        o_rd_data   : out std_logic_vector(G_DATA_WIDTH - 1 downto 0)
    );
end entity spectrum_framebuffer;

architecture rtl of spectrum_framebuffer is
    constant C_DATA_DEPTH_X_UNS : unsigned(integer(ceil(log2(real(G_DATA_DEPTH_X)))) - 1 downto 0) := to_unsigned(G_DATA_DEPTH_X, integer(ceil(log2(real(G_DATA_DEPTH_X)))));
    constant C_DATA_DEPTH_Y_UNS : unsigned(integer(ceil(log2(real(G_DATA_DEPTH_Y)))) - 1 downto 0) := to_unsigned(G_DATA_DEPTH_Y, integer(ceil(log2(real(G_DATA_DEPTH_Y)))));

    -- Y
    signal r_wr_row_head      : unsigned(integer(ceil(log2(real(G_DATA_DEPTH_Y)))) - 1 downto 0) := (others => '0'); --to_unsigned(237, integer(ceil(log2(real(G_DATA_DEPTH_Y)))));
    signal r_wr_row_head_prev : unsigned(integer(ceil(log2(real(G_DATA_DEPTH_Y)))) - 1 downto 0) := (others => '0'); --to_unsigned(236, integer(ceil(log2(real(G_DATA_DEPTH_Y)))));
    -- X
    signal r_wr_col_head : unsigned(integer(ceil(log2(real(G_DATA_DEPTH_X)))) - 1 downto 0) := (others => '0');

    -- Write
    signal r_wr_addr : unsigned(integer(ceil(log2(real(G_DATA_DEPTH_X * G_DATA_DEPTH_Y)))) - 1 downto 0);
    signal r_wr_data : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal w_wr_en   : std_logic := '0';
    signal r_wr_en   : std_logic := '0';

    -- Read
    signal r_rd_row  : unsigned(integer(ceil(log2(real(G_DATA_DEPTH_Y)))) - 1 downto 0);
    signal r_rd_addr : unsigned(integer(ceil(log2(real(G_DATA_DEPTH_X * G_DATA_DEPTH_Y)))) - 1 downto 0);
    signal w_rd_data : std_logic_vector(G_DATA_WIDTH - 1 downto 0);

    -- Control
    signal r_update_row_strobe : std_logic := '0';

    -- Pipeline
    signal r_rd_addr_X           : std_logic_vector(integer(ceil(log2(real(G_DATA_DEPTH_X)))) - 1 downto 0);
    signal r_wr_row_head_prev_d1 : unsigned(integer(ceil(log2(real(G_DATA_DEPTH_Y)))) - 1 downto 0) := (others => '0');
begin
    -- ==============================================================================
    -- INPUT
    -- Rasterized writes
    w_wr_en <= i_tvalid when (r_wr_col_head < C_DATA_DEPTH_X_UNS) else
        '0';
    p_wr_mem : process (clk)
    begin
        if rising_edge(clk) then
            r_update_row_strobe <= '0';
            r_wr_en             <= '0';
            --------------------------------------------------------------------
            if (i_tvalid = '1') then
                r_wr_en   <= w_wr_en;
                r_wr_data <= i_tdata;
                r_wr_addr <= resize(
                    (r_wr_row_head * C_DATA_DEPTH_X_UNS) + r_wr_col_head,
                    r_wr_addr'length
                    );

                -- Update address
                r_wr_col_head <= r_wr_col_head + 1;

                -- Check TLAST
                if (i_tlast = '1') then
                    r_update_row_strobe <= '1';
                end if;
            end if;
            --------------------------------------------------------------------
            -- Misc
            if (r_update_row_strobe = '1') then
                r_wr_col_head      <= (others => '0');
                r_wr_row_head      <= r_wr_row_head + 1;
                r_wr_row_head_prev <= r_wr_row_head;
                if (r_wr_row_head >= G_DATA_DEPTH_Y - 1) then
                    r_wr_row_head <= (others => '0');
                end if;
            end if;
            --------------------------------------------------------------------
        end if;
    end process p_wr_mem;
    -- ==============================================================================
    -- Pipe signals to minimize logic clusters plus match latencies
    p_pipeline : process (clk)
    begin
        if rising_edge(clk) then
            r_rd_addr_X           <= i_rd_addr_X;
            r_wr_row_head_prev_d1 <= r_wr_row_head_prev;
        end if;
    end process p_pipeline;
    -- ==============================================================================
    -- OUTPUT
    -- Waterfall     => Read/write separate rasterized
    -- Non-waterfall => Read chasing Write 
    p_rd_mem : process (clk)
    begin
        if rising_edge(clk) then
            if (i_waterfall_en = '1') then
                -- Make sure that row_head_prev is always at the top
                if (r_wr_row_head_prev >= unsigned(i_rd_addr_Y)) then
                    r_rd_row <= r_wr_row_head_prev - unsigned(i_rd_addr_Y);
                else
                    -- Note: cant always do (prev - Y) due to number of rows /= power of two
                    r_rd_row <= C_DATA_DEPTH_Y_UNS + r_wr_row_head_prev - unsigned(i_rd_addr_Y);
                end if;
                r_rd_addr <= resize(
                    (r_rd_row * C_DATA_DEPTH_X_UNS) + unsigned(r_rd_addr_X),
                    r_rd_addr'length
                    );
            else
                -- Note: row_head_prev is piped to match above latency
                r_rd_addr <= resize(
                    (r_wr_row_head_prev_d1 * C_DATA_DEPTH_X_UNS) + unsigned(r_rd_addr_X),
                    r_rd_addr'length
                    );
            end if;
        end if;
    end process p_rd_mem;
    -- Connect
    o_rd_data <= w_rd_data;
    -- ==============================================================================
    dpmem_bram_inst : entity work.dpmem_bram
        generic map(
            G_RAM_WIDTH      => G_DATA_WIDTH,
            G_RAM_DEPTH_BITS => integer(ceil(log2(real(G_DATA_DEPTH_X * G_DATA_DEPTH_Y))))
        )
        port map
        (
            clk     => clk,
            i_addra => std_logic_vector(r_wr_addr),
            i_dina  => r_wr_data,
            i_wea   => r_wr_en,
            o_douta => open,
            i_addrb => std_logic_vector(r_rd_addr),
            i_dinb => (G_DATA_WIDTH - 1 downto 0 => '0'),
            i_web   => '0',
            o_doutb => w_rd_data
        );
    -- ==============================================================================
end architecture;