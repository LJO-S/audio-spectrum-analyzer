library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TMDS_top is
    port (
        i_TMDS_clk : in std_logic;
        i_pixclk   : in std_logic;

        i_HSYNC     : in std_logic;
        i_VSYNC     : in std_logic;
        i_draw      : in std_logic;
        i_video_red : in std_logic_vector(7 downto 0);
        i_video_grn : in std_logic_vector(7 downto 0);
        i_video_blu : in std_logic_vector(7 downto 0);

        temp : out std_logic;

        o_TMDS     : out std_logic_vector(2 downto 0);
        o_TMDS_clk : out std_logic;
        o_HDMI_HPD : out std_logic
    );
end entity TMDS_top;

architecture rtl of TMDS_top is

    signal w_TMDS_red : std_logic_vector(9 downto 0) := (others => '0');
    signal w_TMDS_grn : std_logic_vector(9 downto 0) := (others => '0');
    signal w_TMDS_blu : std_logic_vector(9 downto 0) := (others => '0');

    signal r_TMDS_mod10      : unsigned(3 downto 0)         := (others => '0');
    signal r_TMDS_shift_red  : std_logic_vector(9 downto 0) := (others => '0');
    signal r_TMDS_shift_grn  : std_logic_vector(9 downto 0) := (others => '0');
    signal r_TMDS_shift_blu  : std_logic_vector(9 downto 0) := (others => '0');
    signal r_TMDS_shift_load : std_logic                    := '0';
begin
    --**************************************************************************************************
    --**************************************************************************************************
    temp <= i_VSYNC;
    --**************************************************************************************************
    --**************************************************************************************************
    -- TMDS encoders
    TMDS_encoder_inst_0 : entity work.TMDS_encoder
        port map
        (
            clk          => i_pixclk,
            i_video_en   => i_draw,
            i_CD         => "00",
            i_video_data => std_logic_vector(i_video_red),
            o_TMDS       => w_TMDS_red
        );

    TMDS_encoder_inst_1 : entity work.TMDS_encoder
        port map
        (
            clk          => i_pixclk,
            i_video_en   => i_draw,
            i_CD         => "00",
            i_video_data => std_logic_vector(i_video_grn),
            o_TMDS       => w_TMDS_grn
        );

    TMDS_encoder_inst_2 : entity work.TMDS_encoder
        port map
        (
            clk          => i_pixclk,
            i_video_en   => i_draw,
            i_CD         => i_VSYNC & i_HSYNC,
            i_video_data => std_logic_vector(i_video_blu),
            o_TMDS       => w_TMDS_blu
        );
    --**************************************************************************************************
    --**************************************************************************************************
    -- TMDS shift-out registers
    process (i_TMDS_clk)
    begin
        if rising_edge(i_TMDS_clk) then
            if (r_TMDS_mod10 = 9) then
                r_TMDS_shift_load <= '1';
                r_TMDS_mod10      <= (others => '0');
            else
                r_TMDS_shift_load <= '0';
                r_TMDS_mod10      <= r_TMDS_mod10 + 1;
            end if;

            if (r_TMDS_shift_load = '1') then
                r_TMDS_shift_red <= w_TMDS_red;
                r_TMDS_shift_grn <= w_TMDS_grn;
                r_TMDS_shift_blu <= w_TMDS_blu;
            else
                r_TMDS_shift_red <= '0' & r_TMDS_shift_red(9 downto 1);
                r_TMDS_shift_grn <= '0' & r_TMDS_shift_grn(9 downto 1);
                r_TMDS_shift_blu <= '0' & r_TMDS_shift_blu(9 downto 1);
            end if;
        end if;
    end process;
    --**************************************************************************************************
    --**************************************************************************************************
    -- Combinatorial
    o_HDMI_HPD <= '1';
    o_TMDS_clk <= i_pixclk;
    o_TMDS(2)  <= r_TMDS_shift_red(0);
    o_TMDS(1)  <= r_TMDS_shift_grn(0);
    o_TMDS(0)  <= r_TMDS_shift_blu(0);
    --**************************************************************************************************
    --**************************************************************************************************
end architecture;