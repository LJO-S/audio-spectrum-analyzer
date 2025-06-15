library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ping_pong_memory is
    port (
        clk_50 : in std_logic;

        -- FFT input data
        i_fft_data_magn  : in std_logic_vector(31 downto 0);
        i_fft_data_last  : in std_logic;
        i_fft_data_valid : in std_logic;
        i_xk_index       : in std_logic_vector(9 downto 0);
        -- Memory input data
        i_rd_addr : in std_logic_vector(9 downto 0);
        -- Memory output data
        o_rd_data  : out std_logic_vector(31 downto 0);
        o_rd_valid : out std_logic
    );
end entity ping_pong_memory;

architecture rtl of ping_pong_memory is
    signal r_pingpong : std_logic := '0';

    signal r_addr_bram0    : std_logic_vector(9 downto 0)  := (others => '0');
    signal r_addr_bram1    : std_logic_vector(9 downto 0)  := (others => '0');
    signal r_rd_data_bram0 : std_logic_vector(31 downto 0) := (others => '0');
    signal r_rd_data_bram1 : std_logic_vector(31 downto 0) := (others => '0');
    signal r_wr_data_bram0 : std_logic_vector(31 downto 0) := (others => '0');
    signal r_wr_data_bram1 : std_logic_vector(31 downto 0) := (others => '0');
    signal r_wr_en_bram0   : std_logic                     := '0';
    signal r_wr_en_bram1   : std_logic                     := '0';

    signal r_xk_index          : std_logic_vector(9 downto 0) := (others => '0');
    signal r_xk_index_d1       : std_logic_vector(9 downto 0) := (others => '0');
    signal r_fft_data_valid    : std_logic                    := '0';
    signal r_fft_data_valid_d1 : std_logic                    := '0';
    signal r_fft_data_last     : std_logic                    := '0';
    signal r_fft_data_last_d1  : std_logic                    := '0';
    signal r_pingpong_d1       : std_logic                    := '0';
    signal r_pingpong_d2       : std_logic                    := '0';
begin
    -- ----------------------------------------------------
    --       _____              _____
    --      |     |-->0   RD<--|     |   
    --      |  0  |    \ /     |  1  |   
    --      |     |    / \     |     |   
    --      |_____|<--WR   0-->|_____|
    -- 
    -- The module writes to one memory while reading from the other.
    -- Once the other memory is filled with new data, the module reads
    -- from that memory and writes to the previous. Hence "ping-pong"

    -- The video driver keeps reading from the same memory until the FFT
    -- has written 1024 new values. Therefore, the ping-pong driver is the
    -- FFT which in turn is driven by the sampler.
    -- ----------------------------------------------------
    p_main : process (clk_50)
    begin
        if rising_edge(clk_50) then
            r_xk_index    <= i_xk_index;
            r_xk_index_d1 <= r_xk_index;

            r_fft_data_valid    <= i_fft_data_valid;
            r_fft_data_valid_d1 <= r_fft_data_valid;

            r_fft_data_last    <= i_fft_data_last;
            r_fft_data_last_d1 <= r_fft_data_last;

            r_pingpong_d1 <= r_pingpong;
            r_pingpong_d2 <= r_pingpong_d1;

            if (r_pingpong = '0') then
                -- BRAM0 read, BRAM1 write
                -- o_rd_data       <= r_rd_data_bram0;
                r_addr_bram0    <= i_rd_addr;
                r_wr_en_bram0   <= '0';
                r_wr_data_bram0 <= (others => '0');

                r_addr_bram1    <= r_xk_index_d1;
                r_wr_en_bram1   <= r_fft_data_valid_d1;
                r_wr_data_bram1 <= i_fft_data_magn;
            else
                -- BRAM1 read, BRAM0 write
                -- o_rd_data       <= r_rd_data_bram1;
                r_addr_bram1    <= i_rd_addr;
                r_wr_en_bram1   <= '0';
                r_wr_data_bram1 <= (others => '0');

                r_addr_bram0    <= r_xk_index_d1;
                r_wr_en_bram0   <= r_fft_data_valid_d1;
                r_wr_data_bram0 <= i_fft_data_magn;
                null;
            end if;

            if (r_fft_data_last_d1 = '1') and (r_fft_data_last = '0') and (r_fft_data_valid_d1 = '1') then
                r_pingpong <= not r_pingpong;
            end if;
        end if;
    end process p_main;
    ----------------------------------------------------
    p_output_mux : process (
        r_pingpong,
        r_pingpong_d1,
        r_pingpong_d2,
        r_rd_data_bram0,
        r_rd_data_bram1
        )
    begin
        -- if (r_pingpong = '0') then
        if (r_pingpong_d2 = '0') then
            o_rd_data <= r_rd_data_bram0;
        else
            o_rd_data <= r_rd_data_bram1;
        end if;
    end process p_output_mux;
    ----------------------------------------------------
    BRAM0_inst : entity work.SPmem
        generic map(
            G_RAM_WIDTH       => 32,
            G_RAM_DEPTH       => 1024,
            G_RAM_PERFORMANCE => "LOW_LATENCY",
            G_DO_NOT_PRELOAD  => '1'
        )
        port map
        (
            clk     => clk_50,
            i_addra => r_addr_bram0,
            i_dina  => r_wr_data_bram0,
            i_wea   => r_wr_en_bram0,
            o_douta => r_rd_data_bram0
        );
    ----------------------------------------------------
    BRAM1_inst : entity work.SPmem
        generic map(
            G_RAM_WIDTH       => 32,
            G_RAM_DEPTH       => 1024,
            G_RAM_PERFORMANCE => "LOW_LATENCY",
            G_DO_NOT_PRELOAD  => '1'
        )
        port map
        (
            clk     => clk_50,
            i_addra => r_addr_bram1,
            i_dina  => r_wr_data_bram1,
            i_wea   => r_wr_en_bram1,
            o_douta => r_rd_data_bram1
        );
end architecture;