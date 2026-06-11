---------------------------------------------------------------------------
-- Title       : Audio Zoom Top-Level Module
-- Design      : zoom_top
-- Author      : Ludvig Snihs
-- Description : Top-level module for audio zoom and decimation. This module takes in I/Q data, applies a configurable frequency shift and decimation, and outputs the processed I/Q data.
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity zoom_top is
    generic (
        G_INPUT_DATA_WIDTH : positive := 16;
        G_COEFF_DATA_WIDTH : positive := 16;
        G_INIT_FILE        : string   := "/mnt/tools/projects/fpga/audio-spectrum-analyzer/src/zoom/decimate/HBF_16";
        G_DDS_INIT_FILE    : string   := "/mnt/tools/projects/fpga/audio-spectrum-analyzer/src/signal_generator/dds/dds_lut.txt"
    );
    port (
        clk : in std_logic;
        -------------------------
        -- Input configuration
        -------------------------
        i_cfg_decimation_factor : in std_logic_vector(1 downto 0); -- 2, 4 (0 = bypass)
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
end entity zoom_top;

architecture rtl of zoom_top is
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
    signal r_cfg_decimation_factor : std_logic_vector(1 downto 0)  := (others => '0');
    signal r_cfg_frequency_shift   : std_logic_vector(15 downto 0) := (others => '0');
    signal r_cfg_valid             : std_logic                     := '0';
    -- Control signals for mixer and decimator
    signal r_mixer_active    : std_logic := '0';
    signal r_decimate_active : std_logic := '0';
    signal r_mixer_en        : std_logic := '0';
    signal r_decimate_en     : std_logic := '0';
    -- Latched DDS frequency word: persists after the one-shot config pulse so the
    -- DDS can run continuously (one accumulator step per clock) as a free-running NCO.
    signal r_dds_freq_latch : std_logic_vector(15 downto 0) := (others => '0');
    -- Input data registers
    signal r_input_data_i     : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal r_input_data_q     : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal r_input_data_valid : std_logic                                         := '0';
    -- Data registers for pipelining and timing alignment
    signal r_input_valid_d1 : std_logic := '0';
    signal r_input_valid_d2 : std_logic := '0';
    signal r_input_valid_d3 : std_logic := '0';
    signal r_input_valid_d4 : std_logic := '0';
    signal r_input_valid_d5 : std_logic := '0';
    -- Mixer output registers (full-width from complex_mult: G_WIDTH_A+G_WIDTH_B downto 0 = 33 bits)
    signal w_mixer_data_i_out : std_logic_vector(G_INPUT_DATA_WIDTH * 2 downto 0);
    signal w_mixer_data_q_out : std_logic_vector(G_INPUT_DATA_WIDTH * 2 downto 0);
    signal r_mixer_mux_data_i : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal r_mixer_mux_data_q : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal r_mixer_mux_valid  : std_logic                                         := '0';
    -- Decimator output registers
    signal w_decimate_data_i_out     : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal w_decimate_data_q_out     : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal w_decimate_data_valid_out : std_logic;
    signal r_decimate_mux_data_i     : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal r_decimate_mux_data_q     : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal r_decimate_mux_valid      : std_logic                                         := '0';
    -- DDS
    signal w_dds_data_i_out : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal w_dds_data_q_out : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
    signal r_dds_data_i_out : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal r_dds_data_q_out : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal w_dds_valid_out  : std_logic;
begin
    -- ============================================================================
    -- Combinatorial 
    o_data_i     <= r_decimate_mux_data_i;
    o_data_q     <= r_decimate_mux_data_q;
    o_data_valid <= r_decimate_mux_valid;
    -- ============================================================================
    -- configuration logic for bypass, decimation factor and frequency shift
    p_configuration : process (clk)
    begin
        if rising_edge(clk) then
            -------------------
            -- PIPE 0
            -------------------
            r_mixer_active <= '1' when ( or (i_cfg_frequency_shift) = '1') else
                '0'; -- Bypass mixer if frequency shift is 0
            r_decimate_active <= '1' when ( or (i_cfg_decimation_factor) = '1') else
                '0'; -- Bypass decimator if decimation factor is 0
            r_cfg_frequency_shift   <= i_cfg_frequency_shift;
            r_cfg_decimation_factor <= i_cfg_decimation_factor;
            r_cfg_valid             <= i_cfg_valid;
            -------------------
            -- PIPE 1
            -------------------
            -- Latch enables on the config pulse so they persist across samples
            if (r_cfg_valid = '1') then
                r_mixer_en    <= r_mixer_active and r_decimate_active;
                r_decimate_en <= r_decimate_active;
                -- Latch the frequency word so the DDS can run continuously after
                -- the one-shot config pulse clears.
                if (r_mixer_active = '1') then
                    r_dds_freq_latch <= std_logic_vector(-signed(r_cfg_frequency_shift));
                end if;
            end if;
        end if;
    end process p_configuration;
    -- ============================================================================
    dds_inst : entity work.dds
        generic map(
            G_FREQ_WIDTH        => C_DDS_FREQ_WIDTH,
            G_DATA_WIDTH        => G_INPUT_DATA_WIDTH,
            G_ACCUMULATOR_WIDTH => C_DDS_ACCUMULATOR_WIDTH,
            G_LUT_ADDR_WIDTH    => C_DDS_LUT_ADDR_WIDTH,
            G_SYS_CLK_HZ        => 100_000_000, -- 100 MHz
            G_INIT_FILE         => G_DDS_INIT_FILE
        )
        port map
        (
            clk => clk,
            -- Configuration: r_dds_freq_latch holds the frequency word indefinitely;
            -- r_mixer_en is a sticky enable so the DDS runs every clock after config.
            i_cfg_freq  => r_dds_freq_latch,
            i_cfg_valid => r_mixer_en,
            -- I/Q output for mixing with input signal
            o_data_i => w_dds_data_i_out,
            o_data_q => w_dds_data_q_out,
            o_valid  => w_dds_valid_out
        );
    -- ============================================================================
    -- Latch the input data to align with the DDS output for the complex multiplication
    p_data_input_latch : process (clk)
    begin
        if rising_edge(clk) then
            -- Input
            r_input_data_valid <= '0';
            if (i_data_valid = '1') then
                r_input_data_i     <= i_data_i;
                r_input_data_q     <= i_data_q;
                r_input_data_valid <= '1';
            end if;
            -- Output: latch every clock so complex_mult sees registered DDS inputs
            r_dds_data_i_out <= w_dds_data_i_out;
            r_dds_data_q_out <= w_dds_data_q_out;

            -- Pipe for bypass
            -------------------
            -- PIPE 1
            -------------------
            r_input_valid_d1 <= r_input_data_valid;
            -------------------
            -- PIPE 2
            -------------------
            r_input_valid_d2 <= r_input_valid_d1;
            -------------------
            -- PIPE 3
            -------------------
            r_input_valid_d3 <= r_input_valid_d2;
            -------------------
            -- PIPE 4
            -------------------
            r_input_valid_d4 <= r_input_valid_d3;
            -------------------
            -- PIPE 5
            -------------------
            r_input_valid_d5 <= r_input_valid_d4;
        end if;
    end process p_data_input_latch;
    -- ============================================================================
    -- Complex Multiplier (for frequency shift)
    complex_mult_inst : entity work.complex_mult
        generic map(
            G_WIDTH_A => G_INPUT_DATA_WIDTH,
            G_WIDTH_B => G_INPUT_DATA_WIDTH
        )
        port map
        (
            clk => clk,
            -- Input A
            i_ar => r_input_data_i,
            i_ai => r_input_data_q,
            -- Input B
            i_br => r_dds_data_i_out,
            i_bi => r_dds_data_q_out,
            -- Output
            o_pr => w_mixer_data_i_out,
            o_pi => w_mixer_data_q_out
        );
    -- ============================================================================
    p_mixer_output_mux : process (clk)
    begin
        if rising_edge(clk) then
            if (r_mixer_en = '1') then
                -- Fetch from DDS; truncate Q30 product to Q14 by keeping top 16 bits [31:16]
                r_mixer_mux_data_i <= w_mixer_data_i_out(G_INPUT_DATA_WIDTH * 2 - 1 downto G_INPUT_DATA_WIDTH);
                r_mixer_mux_data_q <= w_mixer_data_q_out(G_INPUT_DATA_WIDTH * 2 - 1 downto G_INPUT_DATA_WIDTH);
                r_mixer_mux_valid  <= r_input_valid_d5;
            else
                -- Bypass
                r_mixer_mux_data_i <= r_input_data_i;
                r_mixer_mux_data_q <= r_input_data_q;
                r_mixer_mux_valid  <= r_input_data_valid;
            end if;
        end if;
    end process p_mixer_output_mux;
    -- ============================================================================
    -- Polyphase Filter Bank 
    decimation_bank_inst : entity work.decimation_bank
        generic map(
            G_INPUT_DATA_WIDTH => G_INPUT_DATA_WIDTH,
            G_COEFF_DATA_WIDTH => G_COEFF_DATA_WIDTH,
            G_INIT_FILE        => G_INIT_FILE
        )
        port map
        (
            clk                     => clk,
            i_cfg_decimation_factor => i_cfg_decimation_factor,
            i_cfg_valid             => i_cfg_valid,
            -- Input from mixer or bypass
            i_data_i     => r_mixer_mux_data_i,
            i_data_q     => r_mixer_mux_data_q,
            i_data_valid => r_mixer_mux_valid,
            -- Output
            o_data_i     => w_decimate_data_i_out,
            o_data_q     => w_decimate_data_q_out,
            o_data_valid => w_decimate_data_valid_out
        );
    -- ============================================================================
    -- Output mux
    p_decimate_mux : process (clk)
    begin
        if rising_edge(clk) then
            if (r_decimate_en = '1') then
                r_decimate_mux_data_i <= w_decimate_data_i_out;
                r_decimate_mux_data_q <= w_decimate_data_q_out;
                r_decimate_mux_valid  <= w_decimate_data_valid_out;
            else
                -- Bypass
                r_decimate_mux_data_i <= r_mixer_mux_data_i;
                r_decimate_mux_data_q <= r_mixer_mux_data_q;
                r_decimate_mux_valid  <= r_mixer_mux_valid;
            end if;
        end if;
    end process p_decimate_mux;
    -- ============================================================================
end architecture;