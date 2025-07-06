library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package sig_gen_pkg is
    --===============================================================================
    -- Spectrum
    constant C_SPECTRUM_X_UPPER : natural := 480;
    constant C_SPECTRUM_Y_UPPER : natural := 400;

    constant C_CHAR_WIDTH          : natural := 8;
    constant C_CHAR_HEIGHT         : natural := 16;
    constant C_INTERNAL_COMP_LIMIT : natural := 2 ** 30;
    constant C_INTERNAL_SUBTRACT   : natural := natural(floor(real(C_INTERNAL_COMP_LIMIT / (C_SPECTRUM_Y_UPPER + 1))));
    --===============================================================================
    -- Ascii Text
    constant C_WORD_X_LEFT : natural := 512;

    type t_tilemap_long is array (0 to 7) of natural range 0 to 63;
    type t_tilemap_short is array (0 to 3) of natural range 0 to 63;

    -- Tilemaps 
    -- "CAPTURE"
    constant C_TILEMAP_CAPTURE : t_tilemap_long := (
    0 => 13, -- C
    1 => 11, -- A
    2 => 26, -- P
    3 => 30, -- T
    4 => 31, -- U
    5 => 28, -- R
    6 => 15, -- E 
    7 => 37  -- 
    );

    -- "INTERNAL"
    constant C_TILEMAP_INTERNAL : t_tilemap_long := (
    0 => 19, -- I
    1 => 24, -- N
    2 => 30, -- T
    3 => 15, -- E
    4 => 28, -- R
    5 => 24, -- N
    6 => 11, -- A
    7 => 22  -- L
    );

    -- "CREATOR:"
    constant C_TILEMAP_CREATOR : t_tilemap_long := (
    0 => 13, -- C
    1 => 28, -- R
    2 => 15, -- E
    3 => 11, -- A
    4 => 39, -- T
    5 => 25, -- O
    6 => 28, -- R
    7 => 10  -- :
    );

    -- "MAX: "
    constant C_TILEMAP_LJOS : t_tilemap_short := (
    0 => 22, -- L
    1 => 20, -- J
    2 => 25, -- O
    3 => 29  -- S
    );

    -- "MAX: "
    constant C_TILEMAP_MAX : t_tilemap_short := (
    0 => 23, -- M
    1 => 11, -- A
    2 => 34, -- X
    3 => 10  -- :
    );

    -- " KHZ"
    -- TODO ayo what the hell vvv?
    constant C_TILEMAP_KHZ : t_tilemap_short := (
    0 => 37, -- 
    1 => 21, -- K
    2 => 18, -- H 
    3 => 36  -- Z
    );

    -- "LPF"
    constant C_TILEMAP_LPF : t_tilemap_short := (
    0 => 22, -- L
    1 => 26, -- P
    2 => 16, -- F
    3 => 10  -- :
    );

    -- "BPF"
    constant C_TILEMAP_BPF : t_tilemap_short := (
    0 => 12, -- B
    1 => 26, -- P
    2 => 16, -- F
    3 => 10  -- :
    );

    -- "HPF"
    constant C_TILEMAP_HPF : t_tilemap_short := (
    0 => 18, -- H
    1 => 26, -- P
    2 => 16, -- F
    3 => 10  -- :
    );
    -- "EMA"
    constant C_TILEMAP_EMA : t_tilemap_short := (
    0 => 15, -- E
    1 => 23, -- M
    2 => 11, -- A
    3 => 10  -- :
    );

    type t_font_glyph is array (0 to 15) of std_logic_vector(7 downto 0);
    type t_font_rom is array(0 to 38) of t_font_glyph;

    constant C_FONT_ROM : t_font_rom := (
    0  => (x"00", x"E0", x"10", x"08", x"08", x"10", x"E0", x"00", x"00", x"0F", x"10", x"20", x"20", x"10", x"0F", x"00"), -- 0 
    1  => (x"00", x"10", x"10", x"F8", x"00", x"00", x"00", x"00", x"00", x"20", x"20", x"3F", x"20", x"20", x"00", x"00"), -- 1 
    2  => (x"00", x"70", x"08", x"08", x"08", x"88", x"70", x"00", x"00", x"30", x"28", x"24", x"22", x"21", x"30", x"00"), -- 2 
    3  => (x"00", x"30", x"08", x"88", x"88", x"48", x"30", x"00", x"00", x"18", x"20", x"20", x"20", x"11", x"0E", x"00"), -- 3 
    4  => (x"00", x"00", x"C0", x"20", x"10", x"F8", x"00", x"00", x"00", x"07", x"04", x"24", x"24", x"3F", x"24", x"00"), -- 4 
    5  => (x"00", x"F8", x"08", x"88", x"88", x"08", x"08", x"00", x"00", x"19", x"21", x"20", x"20", x"11", x"0E", x"00"), -- 5 
    6  => (x"00", x"E0", x"10", x"88", x"88", x"18", x"00", x"00", x"00", x"0F", x"11", x"20", x"20", x"11", x"0E", x"00"), -- 6 
    7  => (x"00", x"38", x"08", x"08", x"C8", x"38", x"08", x"00", x"00", x"00", x"00", x"3F", x"00", x"00", x"00", x"00"), -- 7 
    8  => (x"00", x"70", x"88", x"08", x"08", x"88", x"70", x"00", x"00", x"1C", x"22", x"21", x"21", x"22", x"1C", x"00"), -- 8 
    9  => (x"00", x"E0", x"10", x"08", x"08", x"10", x"E0", x"00", x"00", x"00", x"31", x"22", x"22", x"11", x"0F", x"00"), -- 9 
    10 => (x"00", x"00", x"00", x"C0", x"C0", x"00", x"00", x"00", x"00", x"00", x"00", x"30", x"30", x"00", x"00", x"00"), -- : 
    11 => (x"00", x"00", x"C0", x"38", x"E0", x"00", x"00", x"00", x"20", x"3C", x"23", x"02", x"02", x"27", x"38", x"20"), -- A 
    12 => (x"08", x"F8", x"88", x"88", x"88", x"70", x"00", x"00", x"20", x"3F", x"20", x"20", x"20", x"11", x"0E", x"00"), -- B 
    13 => (x"C0", x"30", x"08", x"08", x"08", x"08", x"38", x"00", x"07", x"18", x"20", x"20", x"20", x"10", x"08", x"00"), -- C 
    14 => (x"08", x"F8", x"08", x"08", x"08", x"10", x"E0", x"00", x"20", x"3F", x"20", x"20", x"20", x"10", x"0F", x"00"), -- D 
    15 => (x"08", x"F8", x"88", x"88", x"E8", x"08", x"10", x"00", x"20", x"3F", x"20", x"20", x"23", x"20", x"18", x"00"), -- E 
    16 => (x"08", x"F8", x"88", x"88", x"E8", x"08", x"10", x"00", x"20", x"3F", x"20", x"00", x"03", x"00", x"00", x"00"), -- F 
    17 => (x"C0", x"30", x"08", x"08", x"08", x"38", x"00", x"00", x"07", x"18", x"20", x"20", x"22", x"1E", x"02", x"00"), -- G 
    18 => (x"08", x"F8", x"08", x"00", x"00", x"08", x"F8", x"08", x"20", x"3F", x"21", x"01", x"01", x"21", x"3F", x"20"), -- H 
    19 => (x"00", x"08", x"08", x"F8", x"08", x"08", x"00", x"00", x"00", x"20", x"20", x"3F", x"20", x"20", x"00", x"00"), -- I 
    20 => (x"00", x"00", x"08", x"08", x"F8", x"08", x"08", x"00", x"C0", x"80", x"80", x"80", x"7F", x"00", x"00", x"00"), -- J 
    21 => (x"08", x"F8", x"88", x"C0", x"28", x"18", x"08", x"00", x"20", x"3F", x"20", x"01", x"26", x"38", x"20", x"00"), -- K 
    22 => (x"08", x"F8", x"08", x"00", x"00", x"00", x"00", x"00", x"20", x"3F", x"20", x"20", x"20", x"20", x"30", x"00"), -- L 
    23 => (x"08", x"F8", x"F8", x"00", x"F8", x"F8", x"08", x"00", x"20", x"3F", x"00", x"3F", x"00", x"3F", x"20", x"00"), -- M 
    24 => (x"08", x"F8", x"30", x"C0", x"00", x"08", x"F8", x"08", x"20", x"3F", x"20", x"00", x"07", x"18", x"3F", x"00"), -- N 
    25 => (x"E0", x"10", x"08", x"08", x"08", x"10", x"E0", x"00", x"0F", x"10", x"20", x"20", x"20", x"10", x"0F", x"00"), -- O 
    26 => (x"08", x"F8", x"08", x"08", x"08", x"08", x"F0", x"00", x"20", x"3F", x"21", x"01", x"01", x"01", x"00", x"00"), -- P 
    27 => (x"E0", x"10", x"08", x"08", x"08", x"10", x"E0", x"00", x"0F", x"18", x"24", x"24", x"38", x"50", x"4F", x"00"), -- Q 
    28 => (x"08", x"F8", x"88", x"88", x"88", x"88", x"70", x"00", x"20", x"3F", x"20", x"00", x"03", x"0C", x"30", x"20"), -- R 
    29 => (x"00", x"70", x"88", x"08", x"08", x"08", x"38", x"00", x"00", x"38", x"20", x"21", x"21", x"22", x"1C", x"00"), -- S 
    30 => (x"18", x"08", x"08", x"F8", x"08", x"08", x"18", x"00", x"00", x"00", x"20", x"3F", x"20", x"00", x"00", x"00"), -- T 
    31 => (x"08", x"F8", x"08", x"00", x"00", x"08", x"F8", x"08", x"00", x"1F", x"20", x"20", x"20", x"20", x"1F", x"00"), -- U 
    32 => (x"08", x"78", x"88", x"00", x"00", x"C8", x"38", x"08", x"00", x"00", x"07", x"38", x"0E", x"01", x"00", x"00"), -- V 
    33 => (x"F8", x"08", x"00", x"F8", x"00", x"08", x"F8", x"00", x"03", x"3C", x"07", x"00", x"07", x"3C", x"03", x"00"), -- W 
    34 => (x"08", x"18", x"68", x"80", x"80", x"68", x"18", x"08", x"20", x"30", x"2C", x"03", x"03", x"2C", x"30", x"20"), -- X 
    35 => (x"08", x"38", x"C8", x"00", x"C8", x"38", x"08", x"00", x"00", x"00", x"20", x"3F", x"20", x"00", x"00", x"00"), -- Y 
    36 => (x"10", x"08", x"08", x"08", x"C8", x"38", x"08", x"00", x"20", x"38", x"26", x"21", x"20", x"20", x"18", x"00"), -- Z
    37 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"), -- " "
    38 => (x"C0", x"30", x"C8", x"28", x"E8", x"10", x"E0", x"00", x"07", x"18", x"27", x"24", x"23", x"14", x"0B", x"00")  -- @ 
    );

    --===============================================================================
    -- SpMem initializations
    type t_preload_string_array is array (0 to 7) of string;
    constant C_PRELOAD_STRING_SRC : t_preload_string_array := (
    "../scripts/data/multi_15khz_16bits.txt ",
    "../scripts/data/am_15khz_16bits.txt    ",
    "../scripts/data/chirp_15khz_16bits.txt ",
    "../scripts/data/fm_15khz_16bits.txt    ",
    "../scripts/data/pink_15khz_16bits.txt  ",
    "../scripts/data/sin_15khz_16bits.txt   ",
    "../scripts/data/sinc_15khz_16bits.txt  ",
    "../scripts/data/square_15khz_16bits.txt"
    );
    constant C_PRELOAD_STRING_TB : t_preload_string_array := (
    "../../../scripts/data/multi_15khz_16bits.txt ",
    "../../../scripts/data/am_15khz_16bits.txt    ",
    "../../../scripts/data/chirp_15khz_16bits.txt ",
    "../../../scripts/data/fm_15khz_16bits.txt    ",
    "../../../scripts/data/pink_15khz_16bits.txt  ",
    "../../../scripts/data/sin_15khz_16bits.txt   ",
    "../../../scripts/data/sinc_15khz_16bits.txt  ",
    "../../../scripts/data/square_15khz_16bits.txt"
    );
end package;