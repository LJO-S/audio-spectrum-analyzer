-- ------------------------------------------------------------------
-- FIR Filter
-- Expects to receive coefficients from external source.
-- Uses a serial FIR structure instead of parallel, minimizing resource
-- usage and leaving DPS48Es untouched. Limits upper clock frequency,
-- but with samples arriving at ~48kHz we are ok.
-- Implements rounding, scaling and clipping.
-- ------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fir_filter is
    generic (
        G_NBR_OF_TAPS : positive := 101;
        G_QFORMAT     : positive := 15;
        G_INPUT_WIDTH : positive := 16;
        G_COEFF_WIDTH : positive := 16
    );
    port (
        clk_25 : in std_logic;

        -- From PS
        i_new_data_strobe : in std_logic;
        o_updating_coeffs : out std_logic;
        i_waddr           : in std_logic_vector(integer(ceil(log2(real(G_NBR_OF_TAPS)))) - 1 downto 0);
        i_wdata           : in std_logic_vector(G_COEFF_WIDTH - 1 downto 0);
        i_we              : in std_logic;

        -- from ADC
        i_tvalid : in std_logic;
        i_tdata  : in std_logic_vector(15 downto 0);

        -- to Audio Buffer
        o_tvalid : out std_logic;
        o_tdata  : out std_logic_vector(15 downto 0)
    );
end entity fir_filter;

architecture rtl of fir_filter is
    -- ----------------------------------
    -- Constants
    -- ----------------------------------
    constant C_BIT_RANGE_TAPS : natural := integer(ceil(log2(real(G_NBR_OF_TAPS))));
    constant C_INPUT_WIDTH    : natural := G_INPUT_WIDTH;
    constant C_COEFF_WIDTH    : natural := G_COEFF_WIDTH;
    constant C_BIT_WIDTH      : natural := (C_COEFF_WIDTH + C_INPUT_WIDTH - 1) + C_BIT_RANGE_TAPS;

    constant C_CLIP_MAX : integer := 2 ** (C_INPUT_WIDTH - 1) - 1;
    constant C_CLIP_MIN : integer := - 2 ** (C_INPUT_WIDTH - 1);
    -- ----------------------------------
    -- Types
    -- ----------------------------------
    type t_fir_fsm is (IDLE, RUNNING);
    type t_read_coefficients is (IDLE, READ_DATA, SETTLE_1CC);
    type t_output_stage is (IDLE, ROUND, SCALE, CLIP);
    type t_coefficients is array (natural range 0 to G_NBR_OF_TAPS - 1) of signed(C_COEFF_WIDTH - 1 downto 0);
    type t_delay_line is array (natural range 0 to G_NBR_OF_TAPS - 1) of signed(C_INPUT_WIDTH - 1 downto 0);

    -- ----------------------------------
    -- Signals
    -- ----------------------------------
    -- FIR
    signal s_FIR_CTRL     : t_fir_fsm                                    := IDLE;
    signal r_coefficients : t_coefficients                               := (t_coefficients'range => (others => '0'));
    signal r_delay_line   : t_delay_line                                 := (others => (others => '0'));
    signal r_tap_cntr     : integer                                      := G_NBR_OF_TAPS - 1;
    signal r_acc_strobe   : std_logic                                    := '0';
    signal r_tdata_in     : std_logic_vector(C_INPUT_WIDTH - 1 downto 0) := (others => '0');
    signal r_tdata_acc    : signed(C_BIT_WIDTH - 1 downto 0)             := (others => '0');
    signal r_accumulator  : signed(C_BIT_WIDTH - 1 downto 0)             := (others => '0');

    -- Output
    signal s_OUTPUT_STATE : t_output_stage                               := IDLE;
    signal r_tdata_round  : signed(C_BIT_WIDTH - 1 downto 0)             := (others => '0');
    signal r_tdata_shift  : signed(C_BIT_WIDTH - G_QFORMAT - 1 downto 0) := (others => '0');
    signal r_tdata_out    : signed(C_INPUT_WIDTH - 1 downto 0)           := (others => '0');
    signal r_tvalid       : std_logic                                    := '0';

    -- Coefficient Read
    signal s_COEFF_READ            : t_read_coefficients := IDLE;
    signal r_raddr                 : unsigned(C_BIT_RANGE_TAPS - 1 downto 0);
    signal r_rdata                 : std_logic_vector(C_COEFF_WIDTH - 1 downto 0);
    signal w_updating_coefficients : std_logic := '0';
    -- Coefficient Write

begin
    -- ================================================================================
    o_tvalid <= r_tvalid;
    o_tdata  <= std_logic_vector(r_tdata_out);
    -- ================================================================================
    p_output_stage : process (clk_25)
    begin
        if rising_edge(clk_25) then
            r_tvalid    <= '0';
            r_tdata_out <= (others => '0');
            case s_OUTPUT_STATE is
                    -- ------------------------------------
                when IDLE =>
                    if (r_acc_strobe = '1') then
                        s_OUTPUT_STATE <= ROUND;
                        r_tdata_round  <= r_tdata_acc;
                    end if;
                    -- ------------------------------------
                when ROUND =>
                    -- Add rounding bias
                    if (r_tdata_round(r_tdata_round'high) = '0') then
                        -- Positive!
                        r_tdata_round <= r_tdata_round + to_signed(2 ** (G_QFORMAT - 1), r_tdata_acc'length);
                    else
                        -- Negative!
                        r_tdata_round <= r_tdata_round - to_signed(2 ** (G_QFORMAT - 1), r_tdata_acc'length);
                    end if;
                    s_OUTPUT_STATE <= SCALE;
                    -- ------------------------------------
                when SCALE =>
                    -- Downscale using given Q-format
                    r_tdata_shift  <= resize(r_tdata_round sra G_QFORMAT, r_tdata_shift'length);
                    s_OUTPUT_STATE <= CLIP;
                    -- ------------------------------------
                when CLIP =>
                    -- Clip top/min values
                    if (r_tdata_shift > C_CLIP_MAX) then
                        r_tdata_out <= to_signed(C_CLIP_MAX, r_tdata_out'length);
                    elsif (r_tdata_shift < C_CLIP_MIN) then
                        r_tdata_out <= to_signed(C_CLIP_MIN, r_tdata_out'length);
                    else
                        r_tdata_out <= resize(r_tdata_shift, r_tdata_out'length);
                    end if;
                    r_tvalid       <= '1';
                    s_OUTPUT_STATE <= IDLE;
                    -- ------------------------------------
                when others =>
                    s_OUTPUT_STATE <= IDLE;
                    -- ------------------------------------
            end case;
        end if;
    end process p_output_stage;
    -- ================================================================================
    p_fir_fsm : process (clk_25)
        variable v_sum         : signed(C_BIT_WIDTH - 1 downto 0) := (others => '0');
        variable v_coeff_debug : real;
    begin
        if rising_edge(clk_25) then
            r_acc_strobe <= '0';
            case s_FIR_CTRL is
                when IDLE =>
                    if (i_tvalid = '1') and (w_updating_coefficients = '0') then
                        r_tdata_in <= i_tdata(15 downto 0);
                        s_FIR_CTRL <= RUNNING;
                    end if;
                when RUNNING =>
                    -- ---------------------------------------------------
                    -- Tap Counter
                    r_tap_cntr     <= r_tap_cntr - 1;
                    if (r_tap_cntr <= 0) then
                        r_tap_cntr     <= G_NBR_OF_TAPS - 1;
                        s_FIR_CTRL     <= IDLE;
                    end if;
                    -- ---------------------------------------------------
                    -- Delay Line Shifter
                    if (r_tap_cntr           <= 0) then
                        r_delay_line(r_tap_cntr) <= signed(r_tdata_in);
                    else
                        r_delay_line(r_tap_cntr) <= r_delay_line(r_tap_cntr - 1);
                    end if;
                    -- ---------------------------------------------------
                    v_coeff_debug := real(to_integer(r_coefficients(r_tap_cntr))) / (2.0 ** 15);
                    -- ---------------------------------------------------
                    v_sum := resize(r_delay_line(r_tap_cntr) * r_coefficients(r_tap_cntr), v_sum'length);
                    r_accumulator  <= r_accumulator + v_sum;
                    if (r_tap_cntr <= 0) then
                        r_accumulator  <= (others => '0');
                        r_tdata_acc    <= r_accumulator + v_sum;
                        r_acc_strobe   <= '1';
                    end if;
                    -- ---------------------------------------------------
                when others =>
                    s_FIR_CTRL <= IDLE;
            end case;
        end if;
    end process p_fir_fsm;
    -- ================================================================================
    -- Detect when PS has written down new coefficient values
    p_read_coefficients : process (clk_25)
    begin
        if rising_edge(clk_25) then
            case s_COEFF_READ is
                when IDLE          =>
                    r_raddr <= (others => '0');
                    -- Strobes when new data has been written
                    if (i_new_data_strobe = '1') then
                        s_COEFF_READ <= SETTLE_1CC;
                    end if;
                when SETTLE_1CC =>
                    s_COEFF_READ <= READ_DATA;
                when READ_DATA =>
                    s_COEFF_READ                        <= SETTLE_1CC;
                    r_coefficients(to_integer(r_raddr)) <= signed(r_rdata);
                    r_raddr                             <= r_raddr + 1;
                    if (r_raddr >= G_NBR_OF_TAPS - 1) then
                        r_raddr      <= (others => '0');
                        s_COEFF_READ <= IDLE;
                    end if;
                when others =>
                    s_COEFF_READ <= IDLE;
            end case;
        end if;
    end process p_read_coefficients;
    w_updating_coefficients <= '1' when (s_COEFF_READ /= IDLE) else
        '0';
    o_updating_coeffs <= w_updating_coefficients;
    -- ================================================================================
    dpmem_dram_inst : entity work.dpmem_bram
        generic map(
            G_RAM_WIDTH      => C_COEFF_WIDTH,
            G_RAM_DEPTH_BITS => C_BIT_RANGE_TAPS
        )
        port map
        (
            clk => clk_25,
            -- Port A (PS)
            i_addra => i_waddr,
            i_dina  => i_wdata,
            i_wea   => i_we,
            o_douta => open,
            -- Port B (RTL)
            i_addrb => std_logic_vector(r_raddr),
            i_dinb => (others => '0'),
            i_web   => '0',
            o_doutb => r_rdata
        );
    -- ================================================================================
end architecture;