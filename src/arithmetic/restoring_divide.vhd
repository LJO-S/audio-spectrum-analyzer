----------------------------------------------------------
-- Name: Restoring Divide
-- 
-- Description: Performs restoring division algorithm. Only
--              works on unsigned integers.
----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity restoring_divide is
    generic (
        G_DATA_WIDTH : natural
    );
    port (
        clk : in std_logic;
        -- Input
        i_dividend : in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        i_divisor  : in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        i_valid    : in std_logic;
        o_ready    : out std_logic;
        -- Output
        o_quotient  : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        o_remainder : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        o_valid     : out std_logic
    );
end entity restoring_divide;

architecture rtl of restoring_divide is
    type t_calc_state is (IDLE, CALC);
    signal s_calc_state : t_calc_state                                                   := IDLE;
    signal r_aq         : unsigned(2 * G_DATA_WIDTH downto 0)                            := (others => '0');
    signal r_m          : unsigned(G_DATA_WIDTH downto 0)                                := (others => '0');
    signal r_counter    : unsigned(integer(ceil(log2(real(G_DATA_WIDTH)))) - 1 downto 0) := (others => '0');
    signal r_valid_out  : std_logic                                                      := '0';
begin
    -- ============================================================
    o_ready <= '1' when (s_calc_state = IDLE) else
        '0';
    o_valid     <= r_valid_out;
    o_quotient  <= std_logic_vector(r_aq(G_DATA_WIDTH - 1 downto 0));
    o_remainder <= std_logic_vector(r_aq(2 * G_DATA_WIDTH - 1 downto G_DATA_WIDTH));
    -- ============================================================
    process (clk)
        variable v_shift_aq : UNSIGNED(r_aq'range)            := (others => '0');
        variable v_a        : UNSIGNED(G_DATA_WIDTH downto 0) := (others => '0');
        variable v_diff     : UNSIGNED(G_DATA_WIDTH downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            -- Default
            r_valid_out <= '0';

            -- FSM
            case s_calc_state is
                    -------------------------------------------------
                when IDLE =>
                    r_m                             <= '0' & unsigned(i_divisor);
                    r_aq                            <= (others => '0');
                    r_aq(G_DATA_WIDTH - 1 downto 0) <= unsigned(i_dividend);
                    r_counter                       <= (others => '0');
                    if (i_valid = '1') then
                        s_calc_state <= CALC;
                    end if;
                    -------------------------------------------------
                when CALC =>
                    v_shift_aq := SHIFT_LEFT(r_aq, 1);
                    v_a        := v_shift_aq(v_shift_aq'high downto G_DATA_WIDTH);
                    v_diff     := v_a - r_m;

                    r_aq <= v_shift_aq;
                    if (v_diff(v_diff'high) = '1') then
                        r_aq(0)                             <= '0';
                        r_aq(r_aq'high downto G_DATA_WIDTH) <= v_a;
                    else
                        r_aq(0)                             <= '1';
                        r_aq(r_aq'high downto G_DATA_WIDTH) <= v_diff;
                    end if;

                    -- Increment
                    r_counter <= r_counter + 1;

                    -- Check if done
                    if (r_counter >= G_DATA_WIDTH - 1) then
                        r_valid_out  <= '1';
                        s_calc_state <= IDLE;
                    end if;
                    -------------------------------------------------
                when others =>
                    s_calc_state <= IDLE;
                    -------------------------------------------------
            end case;
        end if;
    end process;
    -- ============================================================
end architecture;