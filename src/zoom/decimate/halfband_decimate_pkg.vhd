
--================================================================================================
-- Generated via Jinja2 Template through ../scripts/synth_and_test/halfband_filter.py
--================================================================================================
library ieee;
use ieee.std_logic_1164.all;

package halfband_decimate_filter_pkg is

    -- Unique Filter Orders (N) for each stage
    constant C_NUM_STAGES : natural := 1;
    type t_halfband_tap_number is array (0 to C_NUM_STAGES - 1) of integer;
    constant C_NUM_TAPS_UPPER : t_halfband_tap_number := (
    0 => 16 -- Stage 0
    );

    -- The index of the center tap (0.5) in the lower branch 
    -- This represents the number of delay registers before the '1'
    constant C_NUM_TAPS_LOWER : t_halfband_tap_number := (
    0 => 7 -- Stage 0
    );

end package;