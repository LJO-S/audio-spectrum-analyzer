---------------------------------------------------------------------------
-- Title       : Audio Zoom Top-Level Module
-- Design      : audio_zoom_top
-- Author      : Ludvig Snihs
-- Description : Top-level module for audio zoom and decimation. This module takes in I/Q data, applies a configurable frequency shift and decimation, and outputs the processed I/Q data.
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity audio_zoom_top is
    generic (
        G_NBR_OF_TAPS      : positive := 101;
        G_INPUT_DATA_WIDTH : positive := 16;
        G_COEFF_DATA_WIDTH : positive := 16;
        G_COEFF_FRAC_WIDTH : positive := 15
    );
    port (
        clk : in std_logic;
        -------------------------
        -- Input configuration
        -------------------------
        i_cfg_decimation_factor : in std_logic_vector(3 downto 0); -- 1, 2, 4, 8, 16 (0 = bypass)
        i_cfg_frequency_shift   : in std_logic_vector(15 downto 0);
        i_cfg_valid             : in std_logic;
        -------------------------
        -- Input data
        -------------------------
        i_data_i     : in std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        i_data_q     : in std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        i_data_valid : in std_logic;
        -------------------------
        -- Output        
        -------------------------
        o_data_i     : out std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        o_data_q     : out std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        o_data_valid : out std_logic
    );
end entity audio_zoom_top;

architecture rtl of audio_zoom_top is
    --------------------
    -- Constants
    --------------------
    constant C_DDS_ACCUMULATOR_WIDTH : positive := 32;
    constant C_DDS_LUT_ADDR_WIDTH    : positive := 10; -- 1024 entries in the LUT
    constant C_DDS_FREQ_WIDTH        : positive := 16; -- 16 bits for frequency control @ 100 MHz => ~1.5 Hz resolution
    --------------------
    -- Types
    --------------------
    --------------------
    -- Signals
    --------------------
    -- Configuration registers
    signal r_decimation_factor   : std_logic_vector(3 downto 0)  := (others => '0');
    signal r_cfg_frequency_shift : std_logic_vector(15 downto 0) := (others => '0');
    signal r_cfg_frequency_valid : std_logic                     := '0';
    -- I/Q data after frequency shift and before decimation
    signal w_freq_shifted_data_i : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal w_freq_shifted_data_q : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal w_freq_shifted_valid  : std_logic;
    -- I/Q data after decimation
    signal w_decimated_data_i : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal w_decimated_data_q : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal w_decimated_valid  : std_logic;
    -- DDS
    signal w_dds_data_i_out : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal w_dds_data_q_out : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal w_dds_valid_out  : std_logic;
begin
    -- ============================================================================
    -- Combinatorial 
    -- ============================================================================
    process (clk)
    begin
        if rising_edge(clk) then
            null;
        end if;
    end process;
    -- ============================================================================
    -- Configuration logic for bypass, decimation factor and frequency shift
    -- p_configuration : process (clk)
    -- begin
    --     if rising_edge(clk) then
    --         -- Default
    --         r_cfg_frequency_valid <= '0';

    --         -------------------
    --         -- PIPE 0
    --         -------------------
    --         -- Latch the configuration inputs
    --         r_mixer_active <= '1' when ( or (i_cfg_frequency_shift) = '1') else
    --             '0'; -- Bypass mixer if frequency shift is 0
    --         r_decimate_active <= '1' when ( or (i_cfg_decimation_factor) = '1') else
    --             '0'; -- Bypass decimator if decimation factor is 0
    --         r_cfg_frequency_shift   <= i_cfg_frequency_shift;
    --         r_cfg_decimation_factor <= i_cfg_decimation_factor;
    --         r_cfg_valid             <= i_cfg_valid;
    --         -------------------
    --         -- PIPE 1
    --         -------------------
    --         -- Only enable mixer if frequency + decimation is active, otherwise bypass everything 
    --         r_mixer_en                 <= r_cfg_valid and r_mixer_active and r_decimate_active;
    --         r_decimate_en              <= r_cfg_valid and r_decimate_active;
    --         r_cfg_frequency_valid      <= r_cfg_valid and r_mixer_active;
    --         r_cfg_frequency_shift_d1   <= r_cfg_frequency_shift;
    --         r_cfg_decimation_factor_d1 <= r_cfg_decimation_factor;
    --     end if;
    -- end process p_configuration;
    -- -- ============================================================================
    -- dds_inst : entity work.dds
    --     generic map(
    --         G_FREQ_WIDTH        => C_DDS_FREQ_WIDTH,
    --         G_DATA_WIDTH        => G_INPUT_DATA_WIDTH,
    --         G_ACCUMULATOR_WIDTH => C_DDS_ACCUMULATOR_WIDTH,
    --         G_LUT_ADDR_WIDTH    => C_DDS_LUT_ADDR_WIDTH,
    --         G_SYS_CLK_HZ        => 100_000_000, -- 100 MHz
    --         G_INIT_FILE         => "dds_init.txt"
    --     )
    --     port map
    --     (
    --         clk => clk,
    --         -- Configuration
    --         i_cfg_freq  => r_cfg_frequency_shift,
    --         i_cfg_valid => r_cfg_frequency_valid,
    --         -- I/Q output for mixing with input signal
    --         o_data_i => w_dds_data_i_out,
    --         o_data_q => w_dds_data_q_out,
    --         o_valid  => w_dds_valid_out
    --     );
    -- -- ============================================================================
    -- -- Latch the input data to align with the DDS output for the complex multiplication
    -- p_data_input_latch : process (clk)
    -- begin
    --     if rising_edge(clk) then
    --         -- Input
    --         if (i_data_valid = '1') then
    --             r_input_data_i <= i_data_i;
    --             r_input_data_q <= i_data_q;
    --         end if;
    --         -- Output
    --         if (w_dds_valid_out = '1') then
    --             r_dds_data_i_out <= w_dds_data_i_out;
    --             r_dds_data_q_out <= w_dds_data_q_out;
    --         end if;

    --         -- Pipe for bypass
    --         -------------------
    --         -- PIPE 1
    --         -------------------
    --         r_input_data_i_d1 <= i_data_i;
    --         r_input_data_q_d1 <= i_data_q;
    --         r_input_valid_d1  <= i_data_valid;
    --         -------------------
    --         -- PIPE 2
    --         -------------------
    --         r_input_valid_d2 <= r_input_valid_d1;
    --         -------------------
    --         -- PIPE 3
    --         -------------------
    --         r_input_valid_d3 <= r_input_valid_d2;
    --         -------------------
    --         -- PIPE 4
    --         -------------------
    --         r_input_valid_d4 <= r_input_valid_d3;
    --         -------------------
    --         -- PIPE 5
    --         -------------------
    --         r_input_valid_d5 <= r_input_valid_d4;
    --         -------------------
    --         -- PIPE 6
    --         -------------------
    --         r_input_valid_d6 <= r_input_valid_d5;
    --     end if;
    -- end process p_data_input_latch;
    -- -- ============================================================================
    -- w_mixer_input_ar <= r_input_data_i;
    -- w_mixer_input_ai <= r_input_data_q;
    -- -- Complex Multiplier (for frequency shift)
    -- complex_mult_inst : entity work.complex_mult
    --     generic map(
    --         G_WIDTH_A => G_INPUT_DATA_WIDTH,
    --         G_WIDTH_B => G_INPUT_DATA_WIDTH
    --     )
    --     port map
    --     (
    --         clk => clk,
    --         -- Input A
    --         i_ar => r_input_data_i,
    --         i_ai => r_input_data_q,
    --         -- Input B
    --         i_br => r_dds_data_i_out,
    --         i_bi => r_dds_data_q_out,
    --         -- Output
    --         o_pr => w_mixer_data_i_out,
    --         o_pi => w_mixer_data_q_out
    --     );
    -- -- ============================================================================
    -- p_mixer_output_mux : process (clk)
    -- begin
    --     if rising_edge(clk) then
    --         if (r_mixer_en = '1') then
    --             -- Fetch from DDS
    --             r_mixer_out_data_i <= w_mixer_data_i_out;
    --             r_mixer_out_data_q <= w_mixer_data_q_out;
    --             r_mixer_out_valid  <= r_input_valid_d6; -- TODO double check latency
    --         else
    --             -- Bypass
    --             r_mixer_out_data_i <= r_input_data_i;
    --             r_mixer_out_data_q <= r_input_data_q;
    --             r_mixer_out_valid  <= r_input_valid;
    --         end if;
    --     end if;
    -- end process p_mixer_output_mux;
    -- -- ============================================================================
    -- -- Polyphase Filter Bank 
    -- decimation_bank_inst : entity work.decimation_bank
    --     generic map(
    --         G_DATA_WIDTH  => G_DATA_WIDTH,
    --         G_COEFF_WIDTH => G_COEFF_WIDTH,
    --         G_INIT_DIR    => G_INIT_DIR
    --     )
    --     port map
    --     (
    --         clk                     => clk,
    --         i_cfg_decimation_factor => i_cfg_decimation_factor,
    --         i_cfg_valid             => i_cfg_valid,
    --         i_data_i                => i_data_i,
    --         i_data_q                => i_data_q,
    --         i_data_valid            => i_data_valid,
    --         o_data_i                => o_data_i,
    --         o_data_q                => o_data_q,
    --         o_data_valid            => o_data_valid
    --     );
    -- -- ============================================================================
    -- -- Output mux
    -- p_decimate_mux : process (clk)
    -- begin
    --     if rising_edge(clk) then
    --         if (r_decimate_en = '1') then
    --             r_zoom_output_i     <= w_decimate_data_i_out;
    --             r_zoom_output_q     <= w_decimate_data_q_out;
    --             r_zoom_output_valid <= w_decimate_valid_out;
    --         else
    --             -- Bypass
    --             r_zoom_output_i     <= w_decimate_data_i_out;
    --             r_zoom_output_q     <= w_decimate_data_q_out;
    --             r_zoom_output_valid <= w_decimate_valid_out;
    --         end if;
    --     end if;
    -- end process p_decimate_mux;
    -- ============================================================================
end architecture;