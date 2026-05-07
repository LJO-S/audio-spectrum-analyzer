---------------------------------------------------------------------------
-- Title       : Direct Digital Synthesizer (DDS)
-- Design      : dds
-- Description : Implements a Direct Digital Synthesizer (DDS) that generates sine waveforms based on the input frequency and amplitude. 
--               The DDS uses a phase accumulator and a sine lookup table (LUT) to produce the output waveforms.
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity dds is
    generic (
        G_FREQ_WIDTH        : natural := 22;
        G_DATA_WIDTH        : natural := 16;
        G_ACCUMULATOR_WIDTH : natural := 32;
        G_LUT_ADDR_WIDTH    : natural := 10;
        G_SYS_CLK_HZ        : natural := 100_000_000; -- System clock frequency in Hz
        G_INIT_FILE         : string  := "/mnt/tools/projects/fpga/audio-spectrum-analyzer/test/vunit_out/test_output/lib.dds_tb.multiple_freqs.auto_4ad541caeccf4f04928dc3259fd0cbb8dcddd140/dds_lut.txt"
    );
    port (
        clk : in std_logic;
        -- Input
        i_cfg_freq  : in std_logic_vector(G_FREQ_WIDTH - 1 downto 0);
        i_cfg_valid : in std_logic;
        -- Output
        o_data_i : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        o_data_q : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        o_valid  : out std_logic
    );
end entity dds;

architecture rtl of dds is
    --------------------
    -- Constants
    --------------------
    constant C_LUT_SIZE               : natural                                                          := 2 ** G_LUT_ADDR_WIDTH;
    constant C_QUADRATURE_PHASE_SHIFT : unsigned(G_ACCUMULATOR_WIDTH - 1 downto 0)                       := (G_ACCUMULATOR_WIDTH - 2 => '1', others => '0');
    constant C_TUNING_FRAC_WIDTH      : integer                                                          := 14;
    constant C_TUNING_FACTOR          : unsigned(G_ACCUMULATOR_WIDTH + C_TUNING_FRAC_WIDTH - 1 downto 0) := to_unsigned(
    integer(round((2.0 ** G_ACCUMULATOR_WIDTH) * (2.0 ** C_TUNING_FRAC_WIDTH) / real(G_SYS_CLK_HZ))),
    G_ACCUMULATOR_WIDTH + C_TUNING_FRAC_WIDTH
    );
    --------------------
    -- Types
    --------------------
    type t_array_slv is array (natural range <>) of std_logic_vector;
    type t_array_of_array_slv is array (natural range <>) of t_array_slv;
    --------------------
    -- Functions
    --------------------

    -- Maps the LUT index based on the quadrant of the phase accumulator
    function f_lut_idx_map (
        i_quadrant : unsigned(1 downto 0);
        i_index    : unsigned(G_LUT_ADDR_WIDTH - 1 downto 0)
    ) return unsigned is
        variable v_index_effective : unsigned(G_LUT_ADDR_WIDTH - 1 downto 0);
    begin
        case to_integer(i_quadrant) is
            when 0 | 2 =>
                v_index_effective := i_index;
            when 1 | 3 =>
                v_index_effective := to_unsigned(C_LUT_SIZE - 1, v_index_effective'length) - i_index;
            when others                  =>
                v_index_effective := (others => '0');
        end case;
        return v_index_effective;
    end function;

    -- Maps the LUT output data based on the quadrant of the phase accumulator to produce the correct sign for the in-phase and quadrature outputs
    function f_lut_data_map (
        i_quadrant : unsigned(1 downto 0);
        i_data     : signed(G_DATA_WIDTH - 1 downto 0)
    ) return signed is
        variable v_data_effective : signed(G_DATA_WIDTH - 1 downto 0);
    begin
        case to_integer(i_quadrant) is
            when 0 | 1 =>
                v_data_effective := i_data;
            when 2 | 3 =>
                v_data_effective := - i_data;
            when others                 =>
                v_data_effective := (others => '0');
        end case;
        return v_data_effective;
    end function;

    --------------------
    -- Signals
    --------------------
    signal r_cfg_freq               : std_logic_vector(G_FREQ_WIDTH - 1 downto 0)                    := (others => '0');
    signal r_cfg_valid              : std_logic                                                      := '0';
    signal r_cfg_valid_d1           : std_logic                                                      := '0';
    signal r_cfg_valid_d2           : std_logic                                                      := '0';
    signal r_cfg_valid_d3           : std_logic                                                      := '0';
    signal r_tuning_word_product    : signed(G_ACCUMULATOR_WIDTH + C_TUNING_FRAC_WIDTH - 1 downto 0) := (others => '0');
    signal r_tuning_word_product_d1 : signed(G_ACCUMULATOR_WIDTH + C_TUNING_FRAC_WIDTH - 1 downto 0) := (others => '0');
    signal r_tuning_word_shifted    : signed(G_ACCUMULATOR_WIDTH - 1 downto 0)                       := (others => '0');
    signal r_phase_accumulator      : unsigned(G_ACCUMULATOR_WIDTH - 1 downto 0)                     := (others => '0');
    signal r_phase_accumulator_q    : unsigned(G_ACCUMULATOR_WIDTH - 1 downto 0)                     := (others => '0');
    signal r_phase_acc_valid        : std_logic                                                      := '0';
    signal r_quadrant_sel_i         : unsigned(1 downto 0)                                           := (others => '0');
    signal r_quadrant_sel_q         : unsigned(1 downto 0)                                           := (others => '0');
    signal r_lut_addr_i             : unsigned(G_LUT_ADDR_WIDTH - 1 downto 0)                        := (others => '0');
    signal r_lut_addr_q             : unsigned(G_LUT_ADDR_WIDTH - 1 downto 0)                        := (others => '0');
    signal r_lut_addr_valid         : std_logic                                                      := '0';
    signal r_lut_addr_i_d1          : unsigned(G_LUT_ADDR_WIDTH - 1 downto 0)                        := (others => '0');
    signal r_quadrant_sel_i_d1      : unsigned(1 downto 0)                                           := (others => '0');
    signal r_quadrant_sel_q_d1      : unsigned(1 downto 0)                                           := (others => '0');
    signal r_quadrant_sel_i_d2      : unsigned(1 downto 0)                                           := (others => '0');
    signal r_quadrant_sel_q_d2      : unsigned(1 downto 0)                                           := (others => '0');
    signal r_lut_addr_i_effective   : unsigned(G_LUT_ADDR_WIDTH - 1 downto 0)                        := (others => '0');
    signal r_lut_addr_q_effective   : unsigned(G_LUT_ADDR_WIDTH - 1 downto 0)                        := (others => '0');
    signal r_lut_addr_valid_d1      : std_logic                                                      := '0';
    signal r_lut_addr_valid_d2      : std_logic                                                      := '0';
    signal r_quadrant_sel_i_d3      : unsigned(1 downto 0)                                           := (others => '0');
    signal r_quadrant_sel_q_d3      : unsigned(1 downto 0)                                           := (others => '0');
    signal r_quadrant_sel_i_d4      : unsigned(1 downto 0)                                           := (others => '0');
    signal w_lut_data_out_i         : std_logic_vector(G_DATA_WIDTH - 1 downto 0)                    := (others => '0');
    signal w_lut_data_out_q         : std_logic_vector(G_DATA_WIDTH - 1 downto 0)                    := (others => '0');
    signal w_lut_valid_out_i        : std_logic                                                      := '0';
    signal r_valid_out              : std_logic                                                      := '0';
    signal r_data_out_i             : std_logic_vector(G_DATA_WIDTH - 1 downto 0)                    := (others => '0');
    signal r_data_out_q             : std_logic_vector(G_DATA_WIDTH - 1 downto 0)                    := (others => '0');

    -- (Optional) Forces the multiply @ 'r_tuning_word_product' to use a DSP48
    -- Pros: Higher Fmax
    -- Cons: Consume DSP48
    -- Set "no" to use shifts-&-adds
    attribute use_dsp                          : string;
    attribute use_dsp of r_tuning_word_product : signal is "yes";
begin
    -- =======================================================================
    -- Combinatorial
    o_valid  <= r_valid_out;
    o_data_i <= r_data_out_i;
    o_data_q <= r_data_out_q;
    -- =======================================================================
    -- Calculate the tuning word based on the input frequency
    p_calc_tuning_word : process (clk)
    begin
        if rising_edge(clk) then
            -- Calculate tuning word as: 
            -- tuning_word = (input_frequency * 2^accumulator_width) / sampling_frequency
            -- Implemented as a multiplication followed by a right shift to avoid using a divider in hardware
            -----------------
            -- PIPE 0
            -----------------
            r_cfg_valid <= i_cfg_valid;
            r_cfg_freq  <= i_cfg_freq;
            -----------------
            -- PIPE 1
            -----------------
            r_tuning_word_product <= resize(
                signed(r_cfg_freq) * signed(C_TUNING_FACTOR),
                r_tuning_word_product'length
                );
            r_cfg_valid_d1 <= r_cfg_valid;
            -----------------
            -- PIPE 2
            -----------------
            r_tuning_word_product_d1 <= r_tuning_word_product;
            r_cfg_valid_d2           <= r_cfg_valid_d1;
            -----------------
            -- PIPE 3
            -----------------
            r_tuning_word_shifted <= resize(shift_right(r_tuning_word_product_d1, C_TUNING_FRAC_WIDTH), r_tuning_word_shifted'length);
            r_cfg_valid_d3        <= r_cfg_valid_d2;
        end if;
    end process p_calc_tuning_word;
    -- =======================================================================
    -- Phase Accumulator
    p_phase_acc : process (clk)
    begin
        if rising_edge(clk) then
            r_phase_acc_valid <= r_cfg_valid_d3;
            if (r_cfg_valid_d3 = '1') then
                r_phase_accumulator <= r_phase_accumulator + unsigned(r_tuning_word_shifted);
            end if;
        end if;
    end process p_phase_acc;
    -- =======================================================================
    -- Address logic
    p_lut_addresses : process (clk)
    begin
        if rising_edge(clk) then
            -- Calculate the lookup table addresses based on the phase accumulator
            -----------------
            -- PIPE 0
            -----------------
            -- In-phase address and quadrature address are derived from the phase accumulator
            -- The quadrature address is offset by 90 degrees (1/4 of the LUT size) to produce the quadrature output
            r_quadrant_sel_i      <= r_phase_accumulator(r_phase_accumulator'high downto r_phase_accumulator'high - 1);
            r_lut_addr_i          <= r_phase_accumulator(r_phase_accumulator'high - 2 downto r_phase_accumulator'high - 2 - G_LUT_ADDR_WIDTH + 1);
            r_phase_accumulator_q <= r_phase_accumulator - C_QUADRATURE_PHASE_SHIFT; -- Shift phase by 90 degrees for quadrature
            r_lut_addr_valid      <= r_phase_acc_valid;
            -----------------
            -- PIPE 1
            -----------------
            -- Get quadrature index
            r_lut_addr_i_d1     <= r_lut_addr_i;
            r_quadrant_sel_i_d1 <= r_quadrant_sel_i;
            r_quadrant_sel_q    <= r_phase_accumulator_q(r_phase_accumulator_q'high downto r_phase_accumulator_q'high - 1);
            r_lut_addr_q        <= r_phase_accumulator_q(r_phase_accumulator_q'high - 2 downto r_phase_accumulator_q'high - 2 - G_LUT_ADDR_WIDTH + 1);
            r_lut_addr_valid_d1 <= r_lut_addr_valid;
            -----------------
            -- PIPE 2
            -----------------
            -- Map the LUT addresses based on the quadrant to get the effective LUT address for sine values
            r_quadrant_sel_i_d2    <= r_quadrant_sel_i_d1;
            r_quadrant_sel_q_d1    <= r_quadrant_sel_q;
            r_lut_addr_i_effective <= f_lut_idx_map(r_quadrant_sel_i_d1, r_lut_addr_i_d1);
            r_lut_addr_q_effective <= f_lut_idx_map(r_quadrant_sel_q, r_lut_addr_q);
            r_lut_addr_valid_d2    <= r_lut_addr_valid_d1;
            -----------------
            -- PIPE 3
            -----------------
            -- Pass the quadrant selection through additional pipeline stages to align with the LUT read latency
            r_quadrant_sel_i_d3 <= r_quadrant_sel_i_d2;
            r_quadrant_sel_q_d2 <= r_quadrant_sel_q_d1;
            -----------------
            -- PIPE 4
            -----------------
            -- -//-
            r_quadrant_sel_i_d4 <= r_quadrant_sel_i_d3;
            r_quadrant_sel_q_d3 <= r_quadrant_sel_q_d2;
        end if;
    end process p_lut_addresses;
    -- =======================================================================
    -- Sine LUT (In-Phase)
    dds_lut_inst : entity work.dds_lut
        generic map(
            G_DATA_WIDTH => G_DATA_WIDTH,
            G_DATA_DEPTH => C_LUT_SIZE,
            G_INIT_FILE  => G_INIT_FILE
        )
        port map
        (
            clk => clk,
            -- Port A
            i_raddr_a => std_logic_vector(r_lut_addr_i_effective),
            i_valid_a => r_lut_addr_valid_d2,
            o_data_a  => w_lut_data_out_i,
            o_valid_a => w_lut_valid_out_i,
            -- Port B
            i_raddr_b => std_logic_vector(r_lut_addr_q_effective),
            i_valid_b => r_lut_addr_valid_d2,
            o_data_b  => w_lut_data_out_q,
            o_valid_b => open
        );
    -- =======================================================================
    p_map_output : process (clk)
    begin
        if rising_edge(clk) then
            r_valid_out  <= w_lut_valid_out_i;
            r_data_out_i <= std_logic_vector(f_lut_data_map(r_quadrant_sel_i_d4, signed(w_lut_data_out_i)));
            r_data_out_q <= std_logic_vector(f_lut_data_map(r_quadrant_sel_q_d3, signed(w_lut_data_out_q)));
        end if;
    end process p_map_output;
    -- =======================================================================
end architecture;