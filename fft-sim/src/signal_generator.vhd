library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity signal_generator is
    generic (
        G_FFT_BIT_SIZE : natural := 16;
        G_RAM_DEPTH    : natural := 1024;
        G_INIT_FILE    : string  := "../scripts/data/sin_15khz_16bits.txt"
    );
    port (
        clk_50 : in std_logic;
        -- Enable module
        i_start : in std_logic;
        i_reset : in std_logic;
        -- AXI Stream
        i_tready : in std_logic;
        o_tdata  : out std_logic_vector(2 * G_FFT_BIT_SIZE - 1 downto 0);
        o_tvalid : out std_logic;
        o_tlast  : out std_logic
    );
end entity signal_generator;

architecture rtl of signal_generator is
    constant C_BIT_RANGE_1024 : natural                                 := integer(floor(log2(real(1024))));
    signal r_addra            : unsigned(C_BIT_RANGE_1024 - 1 downto 0) := (others => '0');
    signal w_re_data          : std_logic_vector(15 downto 0);
    signal r_tlast            : std_logic;
    signal r_tvalid           : std_logic;

begin
    ----------------------------------------------------------
    ----------------------------------------------------------
    -- tData is 16-bits RE and 16-bits IM in one vector
    -- We do not have any imaginary data.
    o_tdata  <= x"0000" & w_re_data;
    o_tvalid <= r_tvalid;
    o_tlast  <= r_tlast;
    ----------------------------------------------------------
    ----------------------------------------------------------
    p_read_mem : process (clk_50)
    begin
        if rising_edge(clk_50) then
            if (i_reset = '0') then
                r_tlast           <= '0';
                r_tvalid          <= '0';
                r_addra           <= (others => '0');
            else
                ------------------------------------
                if (i_start = '1') then
                    r_tvalid <= '1';
                elsif (r_tlast = '1') then
                    r_tvalid <= '0';
                end if;
                ------------------------------------
                if (i_tready = '1') and (r_tvalid = '1') then
                    r_tlast <= '0';
                    r_addra <= r_addra + 1;
                    if (r_addra = G_RAM_DEPTH - 2) then
                        r_tlast <= '1';
                    end if;
                end if;
                ------------------------------------
            end if;
        end if;
    end process p_read_mem;
    ----------------------------------------------------------
    ----------------------------------------------------------
    SPmem_inst : entity work.SPmem
        generic map(
            G_RAM_WIDTH       => G_FFT_BIT_SIZE,
            G_RAM_DEPTH       => G_RAM_DEPTH,
            G_RAM_PERFORMANCE => "LOW_LATENCY",
            G_INIT_FILE       => G_INIT_FILE
        )
        port map
        (
            clk     => clk_50,
            i_addra => std_logic_vector(r_addra),
            i_dina => (others => '0'),
            i_wea   => '0',
            i_ena   => '1',
            o_douta => w_re_data
        );
    ----------------------------------------------------------
    ----------------------------------------------------------
end architecture;