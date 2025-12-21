library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TMDS_top is
    port (
        i_clk_25  : in std_logic;
        i_clk_100 : in std_logic;
        i_clk_250 : in std_logic;
        -- CE
        i_25m_ce : in std_logic;
        -- Video IF
        i_HSYNC     : in std_logic;
        i_VSYNC     : in std_logic;
        i_draw      : in std_logic;
        i_video_red : in std_logic_vector(7 downto 0);
        i_video_grn : in std_logic_vector(7 downto 0);
        i_video_blu : in std_logic_vector(7 downto 0);
        -- TMDS out
        o_TMDS     : out std_logic_vector(2 downto 0);
        o_TMDS_clk : out std_logic;
        o_HDMI_HPD : out std_logic
    );
end entity TMDS_top;

architecture rtl of TMDS_top is

    -- TMDS encoding
    signal w_TMDS_red : std_logic_vector(9 downto 0) := (others => '0');
    signal w_TMDS_grn : std_logic_vector(9 downto 0) := (others => '0');
    signal w_TMDS_blu : std_logic_vector(9 downto 0) := (others => '0');

    -- TMDS Out
    signal r_TMDS_mod10      : unsigned(3 downto 0)         := (others => '0');
    signal r_TMDS_shift_red  : std_logic_vector(9 downto 0) := (others => '0');
    signal r_TMDS_shift_grn  : std_logic_vector(9 downto 0) := (others => '0');
    signal r_TMDS_shift_blu  : std_logic_vector(9 downto 0) := (others => '0');
    signal r_TMDS_shift_load : std_logic                    := '0';

    -- FIFO
    signal w_fifo_full    : std_logic;
    signal w_fifo_empty   : std_logic;
    signal r_fifo_wr_en   : std_logic := '0';
    signal r_fifo_rd_en   : std_logic := '0';
    signal w_fifo_wr_data : std_logic_vector(29 downto 0);
    signal w_fifo_rd_data : std_logic_vector(29 downto 0);

    signal r_sync_TMDS_red : std_logic_vector(9 downto 0) := (others => '0');
    signal r_sync_TMDS_grn : std_logic_vector(9 downto 0) := (others => '0');
    signal r_sync_TMDS_blu : std_logic_vector(9 downto 0) := (others => '0');
begin
    -- ===========================================================================================
    -- TMDS encoders
    TMDS_encoder_inst_0 : entity work.TMDS_encoder
        port map
        (
            clk          => i_clk_100,
            ce           => i_25m_ce,
            i_video_en   => i_draw,
            i_CD         => "00",
            i_video_data => std_logic_vector(i_video_red),
            o_TMDS       => w_TMDS_red
        );

    TMDS_encoder_inst_1 : entity work.TMDS_encoder
        port map
        (
            clk          => i_clk_100,
            ce           => i_25m_ce,
            i_video_en   => i_draw,
            i_CD         => "00",
            i_video_data => std_logic_vector(i_video_grn),
            o_TMDS       => w_TMDS_grn
        );

    TMDS_encoder_inst_2 : entity work.TMDS_encoder
        port map
        (
            clk          => i_clk_100,
            ce           => i_25m_ce,
            i_video_en   => i_draw,
            i_CD         => i_VSYNC & i_HSYNC,
            i_video_data => std_logic_vector(i_video_blu),
            o_TMDS       => w_TMDS_blu
        );
    -- ===========================================================================================
    p_fifo_wr_en : process (i_clk_100)
    begin
        if rising_edge(i_clk_100) then
            r_fifo_wr_en <= i_25m_ce;
        end if;
    end process p_fifo_wr_en;
    -- Save as RGB
    w_fifo_wr_data <= w_TMDS_red & w_TMDS_grn & w_TMDS_blu;
    -- ===========================================================================================
    async_fifo_inst : entity work.async_fifo
        generic map(
            G_DATA_WIDTH => 30,
            G_DATA_DEPTH => 64
        )
        port map
        (
            -- Write
            i_wr_clk  => i_clk_100,
            i_wr_rst  => '0',
            i_wr_en   => r_fifo_wr_en,
            i_wr_data => w_fifo_wr_data,
            o_full    => w_fifo_full,
            -- Read
            i_rd_clk  => i_clk_250,
            i_rd_rst  => '0',
            i_rd_en   => r_fifo_rd_en,
            o_rd_data => w_fifo_rd_data,
            o_empty   => w_fifo_empty
        );
    -- ===========================================================================================
    -- Read from FIFO
    r_fifo_rd_en <= not(w_fifo_empty);

    p_synchronize : process (i_clk_250)
    begin
        if rising_edge(i_clk_250) then
            r_sync_TMDS_red <= w_fifo_rd_data(29 downto 20);
            r_sync_TMDS_grn <= w_fifo_rd_data(19 downto 10);
            r_sync_TMDS_blu <= w_fifo_rd_data(9 downto 0);
        end if;
    end process p_synchronize;
    -- ===========================================================================================
    -- TMDS shift-out registers
    process (i_clk_250)
    begin
        if rising_edge(i_clk_250) then
            if (r_TMDS_mod10 = 9) then
                r_TMDS_shift_load <= '1';
                r_TMDS_mod10      <= (others => '0');
            else
                r_TMDS_shift_load <= '0';
                r_TMDS_mod10      <= r_TMDS_mod10 + 1;
            end if;

            if (r_TMDS_shift_load = '1') then
                r_TMDS_shift_red <= r_sync_TMDS_red;
                r_TMDS_shift_grn <= r_sync_TMDS_grn;
                r_TMDS_shift_blu <= r_sync_TMDS_blu;
            else
                r_TMDS_shift_red <= '0' & r_TMDS_shift_red(9 downto 1);
                r_TMDS_shift_grn <= '0' & r_TMDS_shift_grn(9 downto 1);
                r_TMDS_shift_blu <= '0' & r_TMDS_shift_blu(9 downto 1);
            end if;
        end if;
    end process;
    -- ===========================================================================================
    -- Combinatorial
    o_HDMI_HPD <= '1';
    o_TMDS_clk <= i_clk_25;
    o_TMDS(2)  <= r_TMDS_shift_red(0);
    o_TMDS(1)  <= r_TMDS_shift_grn(0);
    o_TMDS(0)  <= r_TMDS_shift_blu(0);
    -- ===========================================================================================
end architecture;