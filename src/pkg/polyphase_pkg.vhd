library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package polyphase_pkg is
    type t_array_slv is array (natural range<>) of std_logic_vector;
    type t_array_of_array_slv is array (natural range<>) of t_array_slv;
    
end package;