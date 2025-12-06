-- ====================================================================
-- Asynchronuos FIFO with two (2) clock domains
-- ====================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity async_fifo is
    generic (
        G_DATA_WIDTH : natural := 16;
        G_DATA_DEPTH : natural := 32
    );
    port (
        -- Write (clka)
        i_wr_clk  : in std_logic;
        i_wr_rst  : in std_logic;
        i_wr_en   : in std_logic;
        i_wr_data : in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        o_full    : out std_logic;
        -- Read (clkb)
        i_rd_clk  : in std_logic;
        i_rd_rst  : in std_logic;
        i_rd_en   : in std_logic;
        o_rd_data : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        o_empty   : out std_logic
    );
end entity async_fifo;

architecture rtl of async_fifo is
    -- -------------
    -- Constants
    -- -------------
    constant C_DEPTH_LOG2 : natural := integer(ceil(log2(real(G_DATA_DEPTH))));
    constant C_PTR_WIDTH  : natural := C_DEPTH_LOG2 + 1;
    -- -------------
    -- Types
    -- -------------
    subtype t_ptr_u is unsigned(C_PTR_WIDTH - 1 downto 0);
    type t_mem is array (0 to G_DATA_DEPTH - 1) of std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    -- -------------
    -- Signals
    -- -------------
    -- Will infer to BRAM for reasonable sizes
    signal r_memory : t_mem := (others => (others => '0'));
    -- Local binary pointers
    signal r_wr_ptr_bin : t_ptr_u := (others => '0');
    signal r_rd_ptr_bin : t_ptr_u := (others => '0');
    -- Gray pointers
    signal r_wr_ptr_gray : t_ptr_u := (others => '0');
    signal r_rd_ptr_gray : t_ptr_u := (others => '0');
    -- Sync regs: read pointer into write domain
    signal r_rd_gray_sync_to_wr    : t_ptr_u := (others => '0');
    signal r_rd_gray_sync_to_wr_d1 : t_ptr_u := (others => '0');
    signal r_rd_bin_sync_in_wr     : t_ptr_u := (others => '0');
    -- Sync regs: write pointer into read domain
    signal r_wr_gray_sync_to_rd    : t_ptr_u := (others => '0');
    signal r_wr_gray_sync_to_rd_d1 : t_ptr_u := (others => '0');
    signal r_wr_bin_sync_in_rd     : t_ptr_u := (others => '0');
    -- Status
    signal w_full : std_logic;
    -- -------------
    -- Functions
    -- -------------
    function f_bin2gray (
        binary : t_ptr_u
    ) return t_ptr_u is
        variable v_gray : t_ptr_u := (others => '0');
    begin
        v_gray(v_gray'high) := binary(binary'high);
        for i in binary'high - 1 downto binary'low loop
            v_gray(i) := binary(i + 1) xor binary(i);
        end loop;
        return v_gray;
    end function;

    function f_gray2bin (
        gray : t_ptr_u
    ) return t_ptr_u is
        variable v_binary : t_ptr_u := (others => '0');
    begin
        v_binary(v_binary'high) := gray(gray'high);
        for i in gray'high - 1 downto gray'low loop
            v_binary(i) := v_binary(i + 1) xor gray(i);
        end loop;
        return v_binary;
    end function;
    -- -------------
    -- Attributes
    -- -------------
    attribute ram_style                       : string;
    attribute ram_style of r_memory           : signal is "block";
    attribute keep                            : string;
    attribute keep of r_rd_gray_sync_to_wr    : signal is "true";
    attribute keep of r_rd_gray_sync_to_wr_d1 : signal is "true";
    attribute keep of r_wr_gray_sync_to_rd    : signal is "true";
    attribute keep of r_wr_gray_sync_to_rd_d1 : signal is "true";

begin
    -- ==============================================================================
    -- ------------------------
    -- Write Domain (wr_clk)
    -- ------------------------
    process (i_wr_clk)
        variable v_wr_addr     : integer;
        variable v_next_wr_bin : t_ptr_u;
    begin
        if rising_edge(i_wr_clk) then
            if (i_wr_rst = '1') then
                r_wr_ptr_bin            <= (others => '0');
                r_wr_ptr_gray           <= (others => '0');
                r_rd_gray_sync_to_wr    <= (others => '0');
                r_rd_gray_sync_to_wr_d1 <= (others => '0');
                r_rd_bin_sync_in_wr     <= (others => '0');
            else
                -- Sync rd_gray from read domain (two-stage)
                r_rd_gray_sync_to_wr    <= r_rd_ptr_gray;
                r_rd_gray_sync_to_wr_d1 <= r_rd_gray_sync_to_wr;
                r_rd_bin_sync_in_wr     <= f_gray2bin(r_rd_gray_sync_to_wr_d1);
                if (i_wr_en = '1') then
                    -- Only write if not full
                    if (w_full = '0') then
                        -- Update memory
                        v_wr_addr := to_integer(r_wr_ptr_bin(C_PTR_WIDTH - 2 downto 0));
                        r_memory(v_wr_addr) <= i_wr_data;
                        -- Update write pointers
                        v_next_wr_bin := r_wr_ptr_bin + 1;
                        r_wr_ptr_bin  <= v_next_wr_bin;
                        r_wr_ptr_gray <= f_bin2gray(v_next_wr_bin);
                    end if;
                end if;
            end if;
        end if;
    end process;

    w_full <= '1' when (r_wr_ptr_bin(r_wr_ptr_bin'high) /= r_rd_bin_sync_in_wr(r_rd_bin_sync_in_wr'high)) and
        (r_wr_ptr_bin(r_wr_ptr_bin'high - 1 downto 0) = r_rd_bin_sync_in_wr(r_rd_bin_sync_in_wr'high - 1 downto 0)) else
        '0';
    o_full <= w_full;

    -- ==============================================================================
    -- ------------------------
    -- Read Domain (rd clk)
    -- ------------------------
    process (i_rd_clk)
        variable v_rd_addr     : integer;
        variable v_next_rd_bin : t_ptr_u;
    begin
        if rising_edge(i_rd_clk) then
            if (i_rd_rst = '1') then
                r_rd_ptr_bin            <= (others => '0');
                r_rd_ptr_gray           <= (others => '0');
                r_wr_gray_sync_to_rd    <= (others => '0');
                r_wr_gray_sync_to_rd_d1 <= (others => '0');
                r_wr_bin_sync_in_rd     <= (others => '0');
            else
                -- Sync wr_gray from write domain (two-stage)
                r_wr_gray_sync_to_rd    <= r_wr_ptr_gray;
                r_wr_gray_sync_to_rd_d1 <= r_wr_gray_sync_to_rd;
                r_wr_bin_sync_in_rd     <= f_gray2bin(r_wr_gray_sync_to_rd_d1);
                if (i_rd_en = '1') then
                    -- Only read if not empty
                    if (r_rd_ptr_bin /= r_wr_bin_sync_in_rd) then
                        -- Fetch from memory
                        v_rd_addr := to_integer(r_rd_ptr_bin(C_PTR_WIDTH - 2 downto 0));
                        o_rd_data <= r_memory(v_rd_addr);
                        -- Update read pointer
                        v_next_rd_bin := r_rd_ptr_bin + 1;
                        r_rd_ptr_bin  <= v_next_rd_bin;
                        r_rd_ptr_gray <= f_bin2gray(v_next_rd_bin);
                    end if;
                end if;
            end if;
        end if;
    end process;
    -- ==============================================================================
    o_empty <= '1' when (r_rd_ptr_bin = r_wr_bin_sync_in_rd) else
        '0';
    -- ==============================================================================
end architecture;