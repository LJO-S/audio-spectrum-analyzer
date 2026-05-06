----------------------------------------------------------
-- Name: Tone Generator
-- 
-- Description: Capable of supplying the DDS with specified
-- frequency. Either single-tone or MFSK.
-- 
----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
-- 
use work.sig_gen_pkg.all;
-- 
entity ramp_generator is
    generic (
        G_FREQ_DATA_WIDTH      : natural := 16;
        G_FREQ_DATA_FRAC_WIDTH : natural := 16;
        G_TIME_WIDTH           : natural := 16
    );
    port (
        clk : in std_logic;
        -- Ctrl
        i_en        : in std_logic;
        i_ms_strobe : in std_logic;
        -- Input
        i_cfg_fc_data           : in std_logic_vector(G_FREQ_DATA_WIDTH - 1 downto 0);
        i_cfg_bw_data           : in std_logic_vector(G_FREQ_DATA_WIDTH - 1 downto 0);
        i_cfg_sweep_duration_ms : in std_logic_vector(G_TIME_WIDTH - 1 downto 0);
        i_cfg_valid             : in std_logic;
        -- Output
        o_freq_data  : out std_logic_vector(G_FREQ_DATA_WIDTH - 1 downto 0);
        o_freq_valid : out std_logic
    );
end entity ramp_generator;

architecture rtl of ramp_generator is
    --------------------
    -- Constants
    --------------------
    constant C_TIMEOUT_LIMIT : natural := 1000;
    --------------------
    -- Types
    --------------------
    type t_array_slv is array (natural range <>) of std_logic_vector;
    type t_array_of_array_slv is array (natural range <>) of t_array_slv;
    type t_sweep_rate_state is (IDLE, CALC);

    --------------------
    -- Functions
    --------------------
    --------------------
    -- Signals
    --------------------
    signal s_sweep_rate_state : t_sweep_rate_state                                                := IDLE;
    signal r_cfg_bw_sign      : std_logic                                                         := '0';
    signal r_cfg_fc_data      : std_logic_vector(G_FREQ_DATA_WIDTH - 1 downto 0)                  := (others => '0');
    signal r_cfg_bw_data      : unsigned(G_FREQ_DATA_WIDTH + G_FREQ_DATA_FRAC_WIDTH - 1 downto 0) := (others => '0');
    signal r_cfg_duration_ms  : unsigned(G_FREQ_DATA_WIDTH + G_FREQ_DATA_FRAC_WIDTH - 1 downto 0) := (others => '0');
    signal r_div_valid_in     : std_logic                                                         := '0';
    signal w_div_ready_out    : std_logic;
    signal w_div_quotient     : std_logic_vector(G_FREQ_DATA_WIDTH + G_FREQ_DATA_FRAC_WIDTH - 1 downto 0);
    signal w_div_remainder    : std_logic_vector(G_FREQ_DATA_WIDTH + G_FREQ_DATA_FRAC_WIDTH - 1 downto 0);
    signal w_div_valid_out    : std_logic;
    signal r_timeout_cntr     : unsigned(integer(ceil(log2(real(C_TIMEOUT_LIMIT)))) - 1 downto 0) := (others => '0');

    signal r_cfg_valid                      : std_logic                                                                 := '0';
    signal r_delta_sign                     : std_logic                                                                 := '0';
    signal r_delta_sign_d1, r_delta_sign_d2 : std_logic                                                                 := '0';
    signal r_freq_carrier                   : std_logic_vector(G_FREQ_DATA_WIDTH - 1 downto 0)                          := (others => '0');
    signal r_freq_delta                     : std_logic_vector(G_FREQ_DATA_WIDTH + G_FREQ_DATA_FRAC_WIDTH - 1 downto 0) := (others => '0');

    -- Effectively 1 bit less precision due to sign bit
    signal r_freq_next    : signed(G_FREQ_DATA_WIDTH + G_FREQ_DATA_FRAC_WIDTH downto 0) := (others => '0');
    signal r_freq_current : signed(G_FREQ_DATA_WIDTH + G_FREQ_DATA_FRAC_WIDTH downto 0) := (others => '0');

    signal r_strobe, r_strobe_d1 : std_logic := '0';
    signal r_add_freq            : std_logic := '0';

    signal r_enable, r_enable_d1, r_enable_d2 : std_logic                                                   := '0';
    signal r_neg_limit                        : signed(G_FREQ_DATA_WIDTH + G_FREQ_DATA_FRAC_WIDTH downto 0) := (others => '0');
    signal r_pos_limit                        : signed(G_FREQ_DATA_WIDTH + G_FREQ_DATA_FRAC_WIDTH downto 0) := (others => '0');
begin
    -- ============================================================
    -- Combinatorial
    o_freq_data  <= std_logic_vector(r_freq_current(r_freq_current'high - 1 downto r_freq_current'high - G_FREQ_DATA_WIDTH));
    o_freq_valid <= r_enable_d2;
    -- ============================================================
    p_sweep_rate_fsm : process (clk)
    begin
        if rising_edge(clk) then
            -- Default
            r_cfg_valid    <= '0';
            r_div_valid_in <= '0';
            r_timeout_cntr <= (others => '0');
            case s_sweep_rate_state is
                    ----------------------------------------------
                when IDLE =>
                    r_cfg_fc_data     <= i_cfg_fc_data;
                    r_cfg_bw_sign     <= i_cfg_bw_data(i_cfg_bw_data'high);
                    r_cfg_bw_data     <= shift_left(unsigned(abs(resize(signed(i_cfg_bw_data), r_cfg_bw_data'length))), G_FREQ_DATA_FRAC_WIDTH);
                    r_cfg_duration_ms <= resize(unsigned(i_cfg_sweep_duration_ms), r_cfg_duration_ms'length);
                    if (i_cfg_valid = '1') and (w_div_ready_out = '1') then
                        r_div_valid_in     <= '1';
                        s_sweep_rate_state <= CALC;
                    end if;
                    ----------------------------------------------
                when CALC =>
                    r_timeout_cntr <= r_timeout_cntr + 1;
                    if (w_div_valid_out = '1') then
                        r_cfg_valid        <= '1';
                        r_neg_limit        <= (signed('0' & r_cfg_fc_data) & to_signed(0, G_FREQ_DATA_FRAC_WIDTH)) - signed('0' & r_cfg_bw_data); -- Negative BW limit
                        r_pos_limit        <= (signed('0' & r_cfg_fc_data) & to_signed(0, G_FREQ_DATA_FRAC_WIDTH)) + signed('0' & r_cfg_bw_data); -- Positive BW limit
                        r_delta_sign       <= r_cfg_bw_sign;
                        r_freq_delta       <= w_div_quotient;
                        r_freq_carrier     <= r_cfg_fc_data;
                        s_sweep_rate_state <= IDLE;
                    elsif (r_timeout_cntr >= C_TIMEOUT_LIMIT) then
                        s_sweep_rate_state <= IDLE;
                    end if;
                    ----------------------------------------------
                when others =>
                    s_sweep_rate_state <= IDLE;
                    ----------------------------------------------
            end case;
        end if;
    end process p_sweep_rate_fsm;
    -- ============================================================
    restoring_divide_inst : entity work.restoring_divide
        generic map(
            G_DATA_WIDTH => G_FREQ_DATA_WIDTH + G_FREQ_DATA_FRAC_WIDTH
        )
        port map
        (
            clk         => clk,
            i_dividend  => std_logic_vector(r_cfg_bw_data),
            i_divisor   => std_logic_vector(r_cfg_duration_ms),
            i_valid     => r_div_valid_in,
            o_ready     => w_div_ready_out,
            o_quotient  => w_div_quotient,
            o_remainder => w_div_remainder,
            o_valid     => w_div_valid_out
        );
    -- ============================================================
    -- Note: the following process needs MS strobes to not arrive within 3 cc
    p_calc_freq : process (clk)
    begin
        if rising_edge(clk) then
            ------------------
            -- PIPE 0
            ------------------
            if (i_ms_strobe = '1') then
                if (r_delta_sign = '1') then
                    r_freq_next <= r_freq_current - signed('0' & r_freq_delta);
                else
                    r_freq_next <= r_freq_current + signed('0' & r_freq_delta);
                end if;
            end if;

            -- Configure
            if (r_cfg_valid = '1') then
                r_freq_next <= '0' & signed(r_freq_carrier) & to_signed(0, G_FREQ_DATA_FRAC_WIDTH);
            end if;

            r_strobe        <= i_ms_strobe or r_cfg_valid;
            r_enable        <= i_en;
            r_delta_sign_d1 <= r_delta_sign;

            ------------------
            -- PIPE 1
            ------------------
            r_add_freq <= '0';
            if (r_strobe = '1') then
                if (r_delta_sign_d1 = '1') and (r_freq_next > r_neg_limit) then
                    r_add_freq <= '1';
                elsif (r_delta_sign_d1 = '0') and (r_freq_next < r_pos_limit) then
                    r_add_freq <= '1';
                end if;
            end if;
            r_strobe_d1     <= r_strobe;
            r_enable_d1     <= r_enable;
            r_delta_sign_d2 <= r_delta_sign_d1;
            ------------------
            -- PIPE 2
            ------------------
            r_enable_d2 <= r_enable_d1;
            -- Clip if past threshold
            if (r_strobe_d1 = '1') then
                if (r_add_freq = '1') then
                    r_freq_current <= r_freq_next;
                else
                    r_freq_current <= '0' & signed(r_freq_carrier) & to_signed(0, G_FREQ_DATA_FRAC_WIDTH);
                end if;
            end if;
        end if;
    end process p_calc_freq;
    -- ============================================================
end architecture;
