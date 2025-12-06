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
        clk_100 : in std_logic;
        -- From PS
        i_new_data_strobe : in std_logic;
        o_updating_coeffs : out std_logic;
        -- To Block Memory
        o_raddr : out unsigned(integer(ceil(log2(real(4 * G_NBR_OF_TAPS)))) - 1 downto 0);
        i_rdata : in std_logic_vector(G_COEFF_WIDTH - 1 downto 0);
        -- From ADC
        i_tvalid : in std_logic;
        i_tdata  : in std_logic_vector(15 downto 0);
        -- To Audio Buffer
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
    type t_read_coefficients is (IDLE, READ_DATA, SETTLE_1CC, SETTLE_2CC);
    type t_output_stage is (IDLE, ROUND, SCALE, CLIP);
    type t_coefficients is array (natural range 0 to G_NBR_OF_TAPS - 1) of signed(C_COEFF_WIDTH - 1 downto 0);
    type t_delay_line is array (natural range 0 to G_NBR_OF_TAPS - 1) of signed(C_INPUT_WIDTH - 1 downto 0);

    -- ----------------------------------
    -- Signals
    -- ----------------------------------
    -- FIR
    signal s_FIR_CTRL : t_fir_fsm := IDLE;
    signal r_coefficients : t_coefficients := (
    x"0008",
    x"0003",
    x"FFF5",
    x"FFF5",
    x"0008",
    x"0016",
    x"0003",
    x"FFE4",
    x"FFEA",
    x"0018",
    x"002C",
    x"FFFD",
    x"FFC5",
    x"FFDE",
    x"0035",
    x"004C",
    x"FFEC",
    x"FF96",
    x"FFD6",
    x"0068",
    x"0073",
    x"FFC8",
    x"FF52",
    x"FFD9",
    x"00BA",
    x"00A1",
    x"FF84",
    x"FEF3",
    x"FFF0",
    x"0137",
    x"00D1",
    x"FF0C",
    x"FE72",
    x"0030",
    x"01FB",
    x"00FD",
    x"FE37",
    x"FDB2",
    x"00C2",
    x"0352",
    x"0122",
    x"FC82",
    x"FC4F",
    x"023B",
    x"0685",
    x"013A",
    x"F6E8",
    x"F71B",
    x"0AE5",
    x"2714",
    x"3474",
    x"2714",
    x"0AE5",
    x"F71B",
    x"F6E8",
    x"013A",
    x"0685",
    x"023B",
    x"FC4F",
    x"FC82",
    x"0122",
    x"0352",
    x"00C2",
    x"FDB2",
    x"FE37",
    x"00FD",
    x"01FB",
    x"0030",
    x"FE72",
    x"FF0C",
    x"00D1",
    x"0137",
    x"FFF0",
    x"FEF3",
    x"FF84",
    x"00A1",
    x"00BA",
    x"FFD9",
    x"FF52",
    x"FFC8",
    x"0073",
    x"0068",
    x"FFD6",
    x"FF96",
    x"FFEC",
    x"004C",
    x"0035",
    x"FFDE",
    x"FFC5",
    x"FFFD",
    x"002C",
    x"0018",
    x"FFEA",
    x"FFE4",
    x"0003",
    x"0016",
    x"0008",
    x"FFF5",
    x"FFF5",
    x"0003",
    x"0008");
    signal r_delay_line  : t_delay_line                                 := (others => (others => '0'));
    signal r_tap_cntr    : integer                                      := G_NBR_OF_TAPS - 1;
    signal r_acc_strobe  : std_logic                                    := '0';
    signal r_tdata_in    : std_logic_vector(C_INPUT_WIDTH - 1 downto 0) := (others => '0');
    signal r_tdata_acc   : signed(C_BIT_WIDTH - 1 downto 0)             := (others => '0');
    signal r_accumulator : signed(C_BIT_WIDTH - 1 downto 0)             := (others => '0');

    -- Output
    signal s_OUTPUT_STATE : t_output_stage                               := IDLE;
    signal r_tdata_round  : signed(C_BIT_WIDTH - 1 downto 0)             := (others => '0');
    signal r_tdata_shift  : signed(C_BIT_WIDTH - G_QFORMAT - 1 downto 0) := (others => '0');
    signal r_tdata_out    : signed(C_INPUT_WIDTH - 1 downto 0)           := (others => '0');
    signal r_tvalid       : std_logic                                    := '0';

    -- Coefficient Read
    signal s_COEFF_READ            : t_read_coefficients := IDLE;
    signal w_updating_coefficients : std_logic           := '0';
    signal r_raddr                 : unsigned(integer(ceil(log2(real(G_NBR_OF_TAPS)))) - 1 downto 0);
    -- Coefficient Write

begin
    -- ================================================================================
    o_tvalid <= r_tvalid;
    o_tdata  <= std_logic_vector(r_tdata_out);
    -- ================================================================================
    p_output_stage : process (clk_100)
    begin
        if rising_edge(clk_100) then
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
    p_fir_fsm : process (clk_100)
        variable v_sum         : signed(C_BIT_WIDTH - 1 downto 0) := (others => '0');
        variable v_coeff_debug : real;
    begin
        if rising_edge(clk_100) then
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
                    --synthesis translate_off
                    v_coeff_debug := real(to_integer(r_coefficients(r_tap_cntr))) / (2.0 ** 15);
                    --synthesis translate_on
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
    p_read_coefficients : process (clk_100)
    begin
        if rising_edge(clk_100) then
            case s_COEFF_READ is
                when IDLE          =>
                    r_raddr <= (others => '0');
                    -- Strobes when new data has been written
                    if (i_new_data_strobe = '1') then
                        s_COEFF_READ <= SETTLE_1CC;
                    end if;
                when SETTLE_1CC =>
                    s_COEFF_READ <= SETTLE_2CC;
                when SETTLE_2CC =>
                    s_COEFF_READ <= READ_DATA;
                when READ_DATA =>
                    s_COEFF_READ                        <= SETTLE_1CC;
                    r_coefficients(to_integer(r_raddr)) <= signed(i_rdata);
                    r_raddr                             <= r_raddr + 1;
                    if (r_raddr >= G_NBR_OF_TAPS - 1) then
                        r_raddr <= (others => '0');
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
    -- x4 due to PS writing to every 4th addr in BRAM
    o_raddr <= r_raddr & "00";
    -- ================================================================================
end architecture;