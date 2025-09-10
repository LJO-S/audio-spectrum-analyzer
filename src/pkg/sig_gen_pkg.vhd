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
    constant C_EXTERNAL_COMP_LIMIT : natural := 2 ** 26;
    constant C_EXTERNAL_SUBTRACT   : natural := natural(floor(real(C_EXTERNAL_COMP_LIMIT / (C_SPECTRUM_Y_UPPER + 1))));
    -- constant C_EXTERNAL_SUBTRACT   : natural := 0;

    -- Filter
    constant C_MAX_FILTER_CUTOFF : natural := 23000;
    constant C_MIN_FILTER_CUTOFF : natural := 1000;
    constant C_FILTER_STEP       : natural := 1000;
    --===============================================================================
    -- Ascii Text
    constant C_WORD_X_LEFT : natural := 512;

    type t_tilemap_long is array (0 to 7) of natural range 0 to 63;
    type t_tilemap_short is array (0 to 3) of natural range 0 to 63;
    type t_tilemap_minimal is array (0 to 1) of natural range 0 to 63;

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
    4 => 30, -- T
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

    constant C_TILEMAP_10 : t_tilemap_minimal := (
    0 => 37, -- 0
    1 => 5  -- 5
    );
    constant C_TILEMAP_20 : t_tilemap_minimal := (
    0 => 1, -- 1
    1 => 0  -- 0
    );
    constant C_TILEMAP_30 : t_tilemap_minimal := (
    0 => 5, -- 1
    1 => 1  -- 5
    );
    constant C_TILEMAP_40 : t_tilemap_minimal := (
    0 => 2, -- 2
    1 => 0  -- 0
    );

    type t_font_glyph is array (0 to 15) of std_logic_vector(7 downto 0);
    type t_font_rom is array(0 to 38) of t_font_glyph;

    constant C_FONT_ROM : t_font_rom := (
    0  => (x"00", x"00", x"00", x"18", x"24", x"42", x"42", x"42", x"42", x"42", x"42", x"42", x"24", x"18", x"00", x"00"), -- 0 
    1  => (x"00", x"00", x"00", x"10", x"70", x"10", x"10", x"10", x"10", x"10", x"10", x"10", x"10", x"7C", x"00", x"00"), -- 1 
    2  => (x"00", x"00", x"00", x"3C", x"42", x"42", x"42", x"04", x"04", x"08", x"10", x"20", x"42", x"7E", x"00", x"00"), -- 2 
    3  => (x"00", x"00", x"00", x"3C", x"42", x"42", x"04", x"18", x"04", x"02", x"02", x"42", x"44", x"38", x"00", x"00"), -- 3 
    4  => (x"00", x"00", x"00", x"04", x"0C", x"14", x"24", x"24", x"44", x"44", x"7E", x"04", x"04", x"1E", x"00", x"00"), -- 4 
    5  => (x"00", x"00", x"00", x"7E", x"40", x"40", x"40", x"58", x"64", x"02", x"02", x"42", x"44", x"38", x"00", x"00"), -- 5 
    6  => (x"00", x"00", x"00", x"1C", x"24", x"40", x"40", x"58", x"64", x"42", x"42", x"42", x"24", x"18", x"00", x"00"), -- 6 
    7  => (x"00", x"00", x"00", x"7E", x"44", x"44", x"08", x"08", x"10", x"10", x"10", x"10", x"10", x"10", x"00", x"00"), -- 7 
    8  => (x"00", x"00", x"00", x"3C", x"42", x"42", x"42", x"24", x"18", x"24", x"42", x"42", x"42", x"3C", x"00", x"00"), -- 8 
    9  => (x"00", x"00", x"00", x"18", x"24", x"42", x"42", x"42", x"26", x"1A", x"02", x"02", x"24", x"38", x"00", x"00"), -- 9 
    10 => (x"00", x"00", x"00", x"00", x"00", x"00", x"18", x"18", x"00", x"00", x"00", x"00", x"18", x"18", x"00", x"00"), -- : 
    11 => (x"00", x"00", x"00", x"10", x"10", x"18", x"28", x"28", x"24", x"3C", x"44", x"42", x"42", x"E7", x"00", x"00"), -- A 
    12 => (x"00", x"00", x"00", x"F8", x"44", x"44", x"44", x"78", x"44", x"42", x"42", x"42", x"44", x"F8", x"00", x"00"), -- B 
    13 => (x"00", x"00", x"00", x"3E", x"42", x"42", x"80", x"80", x"80", x"80", x"80", x"42", x"44", x"38", x"00", x"00"), -- C 
    14 => (x"00", x"00", x"00", x"F8", x"44", x"42", x"42", x"42", x"42", x"42", x"42", x"42", x"44", x"F8", x"00", x"00"), -- D 
    15 => (x"00", x"00", x"00", x"FC", x"42", x"48", x"48", x"78", x"48", x"48", x"40", x"42", x"42", x"FC", x"00", x"00"), -- E 
    16 => (x"00", x"00", x"00", x"FC", x"42", x"48", x"48", x"78", x"48", x"48", x"40", x"40", x"40", x"E0", x"00", x"00"), -- F 
    17 => (x"00", x"00", x"00", x"3C", x"44", x"44", x"80", x"80", x"80", x"8E", x"84", x"44", x"44", x"38", x"00", x"00"), -- G 
    18 => (x"00", x"00", x"00", x"E7", x"42", x"42", x"42", x"42", x"7E", x"42", x"42", x"42", x"42", x"E7", x"00", x"00"), -- H 
    19 => (x"00", x"00", x"00", x"7C", x"10", x"10", x"10", x"10", x"10", x"10", x"10", x"10", x"10", x"7C", x"00", x"00"), -- I 
    20 => (x"00", x"00", x"00", x"3E", x"08", x"08", x"08", x"08", x"08", x"08", x"08", x"08", x"08", x"08", x"88", x"F0"), -- J 
    21 => (x"00", x"00", x"00", x"EE", x"44", x"48", x"50", x"70", x"50", x"48", x"48", x"44", x"44", x"EE", x"00", x"00"), -- K 
    22 => (x"00", x"00", x"00", x"E0", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"40", x"42", x"FE", x"00", x"00"), -- L 
    23 => (x"00", x"00", x"00", x"EE", x"6C", x"6C", x"6C", x"6C", x"54", x"54", x"54", x"54", x"54", x"D6", x"00", x"00"), -- M 
    24 => (x"00", x"00", x"00", x"C7", x"62", x"62", x"52", x"52", x"4A", x"4A", x"4A", x"46", x"46", x"E2", x"00", x"00"), -- N 
    25 => (x"00", x"00", x"00", x"38", x"44", x"82", x"82", x"82", x"82", x"82", x"82", x"82", x"44", x"38", x"00", x"00"), -- O 
    26 => (x"00", x"00", x"00", x"FC", x"42", x"42", x"42", x"42", x"7C", x"40", x"40", x"40", x"40", x"E0", x"00", x"00"), -- P 
    27 => (x"00", x"00", x"00", x"38", x"44", x"82", x"82", x"82", x"82", x"82", x"B2", x"CA", x"4C", x"38", x"06", x"00"), -- Q 
    28 => (x"00", x"00", x"00", x"FC", x"42", x"42", x"42", x"7C", x"48", x"48", x"44", x"44", x"42", x"E3", x"00", x"00"), -- R 
    29 => (x"00", x"00", x"00", x"3E", x"42", x"42", x"40", x"20", x"18", x"04", x"02", x"42", x"42", x"7C", x"00", x"00"), -- S 
    30 => (x"00", x"00", x"00", x"FE", x"92", x"10", x"10", x"10", x"10", x"10", x"10", x"10", x"10", x"38", x"00", x"00"), -- T 
    31 => (x"00", x"00", x"00", x"E7", x"42", x"42", x"42", x"42", x"42", x"42", x"42", x"42", x"42", x"3C", x"00", x"00"), -- U 
    32 => (x"00", x"00", x"00", x"E7", x"42", x"42", x"44", x"24", x"24", x"28", x"28", x"18", x"10", x"10", x"00", x"00"), -- V 
    33 => (x"00", x"00", x"00", x"D6", x"92", x"92", x"92", x"92", x"AA", x"AA", x"6C", x"44", x"44", x"44", x"00", x"00"), -- W 
    34 => (x"00", x"00", x"00", x"E7", x"42", x"24", x"24", x"18", x"18", x"18", x"24", x"24", x"42", x"E7", x"00", x"00"), -- X 
    35 => (x"00", x"00", x"00", x"EE", x"44", x"44", x"28", x"28", x"10", x"10", x"10", x"10", x"10", x"38", x"00", x"00"), -- Y 
    36 => (x"00", x"00", x"00", x"7E", x"84", x"04", x"08", x"08", x"10", x"20", x"20", x"42", x"42", x"FC", x"00", x"00"), -- Z
    37 => (x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"), -- " "
    38 => (x"00", x"00", x"00", x"38", x"44", x"5A", x"AA", x"AA", x"AA", x"AA", x"B4", x"42", x"44", x"38", x"00", x"00")  -- @ 
    );
    --===============================================================================
    -- SpMem initializations
    type t_preload_string_array is array (0 to 7) of string;
    constant C_PRELOAD_STRING_SRC : t_preload_string_array := (
    "../../scripts/data/multi_10khz_16bits.txt ",
    "../../scripts/data/am_10khz_16bits.txt    ",
    "../../scripts/data/chirp_10khz_16bits.txt ",
    "../../scripts/data/fm_10khz_16bits.txt    ",
    "../../scripts/data/pink_10khz_16bits.txt  ",
    "../../scripts/data/sin_10khz_16bits.txt   ",
    "../../scripts/data/sinc_10khz_16bits.txt  ",
    "../../scripts/data/square_10khz_16bits.txt"
    );
    constant C_PRELOAD_STRING_TB : t_preload_string_array := (
    "../../../scripts/data/multi_10khz_16bits.txt ",
    "../../../scripts/data/am_10khz_16bits.txt    ",
    "../../../scripts/data/chirp_10khz_16bits.txt ",
    "../../../scripts/data/fm_10khz_16bits.txt    ",
    "../../../scripts/data/pink_10khz_16bits.txt  ",
    "../../../scripts/data/sin_10khz_16bits.txt   ",
    "../../../scripts/data/sinc_10khz_16bits.txt  ",
    "../../../scripts/data/square_10khz_16bits.txt"
    );
end package;