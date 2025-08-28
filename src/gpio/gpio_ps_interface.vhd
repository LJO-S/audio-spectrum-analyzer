library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity gpio_ps_interface is
    port (
        clk_25 : in std_logic;
        -- From GPIO Ctrl
        i_lpf_incr : in std_logic;
        i_lpf_decr : in std_logic;
        i_hpf_incr : in std_logic;
        i_hpf_decr : in std_logic;
        -- From FIR Filters
        i_updating_coeffs_lpf : std_logic;
        i_updating_coeffs_hpf : std_logic;
        -- From AXI GPIO
        i_ps_ack : in std_logic;
        -- To AXI GPIO
        o_fir_ctrl : out std_logic_vector(3 downto 0));
end entity gpio_ps_interface;

architecture rtl of gpio_ps_interface is
    type t_fir_ctrl_state is (IDLE, WAIT_FOR_ACK);
    signal s_STATE          : t_fir_ctrl_state             := IDLE;
    signal r_fir_ctrl_latch : std_logic_vector(3 downto 0) := (others => '0');
    signal w_fir_ctrl       : std_logic_vector(3 downto 0) := (others => '0');
begin
    -- Only register button pushes when not updating coefficients
    w_fir_ctrl <= (
        3 => i_hpf_incr and not(i_updating_coeffs_hpf),
        2 => i_hpf_decr and not(i_updating_coeffs_hpf),
        1 => i_lpf_incr and not(i_updating_coeffs_lpf),
        0 => i_lpf_decr and not(i_updating_coeffs_lpf)
        );
    o_fir_ctrl <= r_fir_ctrl_latch;
    process (clk_25)
    begin
        if rising_edge(clk_25) then
            case s_STATE is
                when IDLE                   =>
                    r_fir_ctrl_latch <= (others => '0');
                    if (xor_reduce(w_fir_ctrl) = '1') then
                        r_fir_ctrl_latch <= w_fir_ctrl;
                        s_STATE          <= WAIT_FOR_ACK;
                    end if;
                when WAIT_FOR_ACK =>
                    if (i_ps_ack = '1') then
                        r_fir_ctrl_latch <= (others => '0');
                        s_STATE <= IDLE;
                    end if;
                when others =>
                    s_STATE <= IDLE;
            end case;
        end if;
    end process;
end architecture;
