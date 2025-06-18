package sig_gen_pkg is
    type t_preload_string_array is array (0 to 7) of string;
    constant C_PRELOAD_STRING_SRC : t_preload_string_array := (
    "../scripts/data/am_15khz_16bits.txt",
    "../scripts/data/chirp_15khz_16bits.txt",
    "../scripts/data/fm_15khz_16bits.txt",
    "../scripts/data/multi_15khz_16bits.txt",
    "../scripts/data/pink_15khz_16bits.txt",
    "../scripts/data/sin_15khz_16bits.txt",
    "../scripts/data/sinc_15khz_16bits.txt",
    "../scripts/data/square_15khz_16bits.txt"
    );
    constant C_PRELOAD_STRING_TB : t_preload_string_array := (
    "../../../scripts/data/am_15khz_16bits.txt",
    "../../../scripts/data/chirp_15khz_16bits.txt",
    "../../../scripts/data/fm_15khz_16bits.txt",
    "../../../scripts/data/multi_15khz_16bits.txt",
    "../../../scripts/data/pink_15khz_16bits.txt",
    "../../../scripts/data/sin_15khz_16bits.txt",
    "../../../scripts/data/sinc_15khz_16bits.txt",
    "../../../scripts/data/square_15khz_16bits.txt"
    );
end package;