package sig_gen_pkg is
    -- Constants
    constant C_INTERNAL_COMP_LIMIT : natural := 2 ** 30;
    constant C_INTERNAL_SUBTRACT   : natural := 22_369_262;

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