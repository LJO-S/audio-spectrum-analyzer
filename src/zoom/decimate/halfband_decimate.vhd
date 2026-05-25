-------------------------------------------------------------------------------
-- Implements a Transposed Halfband Decimator
-- 
-- Pros:
--      > Allows for full stream processing of input samples
-- Cons:
--      > 
-- 
-- 
-- Example: Decimate-by-8
--       ____      ______       ____      ______       ____      ______ 
--      |    |    |Alias |     |    |    |Alias |     |    |    |Alias |
--      | v2 |--->|Filter|---->| v2 |--->|Filter|---->| v2 |--->|Filter|---> y(m)
--      |____|    |______|     |____|    |______|     |____|    |______|
--      \________________/
--           1 substage
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
-- 
use std.textio.all;
-- 
use work.polyphase_pkg.all;
use work.halfband_decimate_filter_pkg.all;
-- 
entity halfband_decimate is
    generic (
        G_DATA_WIDTH       : natural := 16;
        G_COEFF_WIDTH      : natural := 16;
        G_MULTIRATE_FACTOR : natural := 32;
        G_INIT_FILE        : string  := "/mnt/tools/projects/fpga/audio-spectrum-analyzer/src/zoom/decimate/HBF_16"
    );
    port (
        clk : in std_logic;
        -- Input
        i_data  : in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        i_valid : in std_logic;
        -- Output
        o_data  : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        o_valid : out std_logic
    );
end entity halfband_decimate;

architecture rtl of halfband_decimate is
    --------------------
    -- Constants
    --------------------
    constant C_NUM_STAGES : natural := integer(ceil(log2(real(G_MULTIRATE_FACTOR))));
    --------------------
    -- Signals
    --------------------
    signal w_stage_data_in  : t_array_slv(0 to C_NUM_STAGES)(G_DATA_WIDTH - 1 downto 0) := (others => (others => '0'));
    signal w_stage_valid_in : std_logic_vector(C_NUM_STAGES downto 0)                   := (others => '0');
begin
    -- ================================================================
    -- Combinatorial
    o_data              <= w_stage_data_in(w_stage_data_in'high);
    o_valid             <= w_stage_valid_in(w_stage_valid_in'high);
    w_stage_data_in(0)  <= i_data;
    w_stage_valid_in(0) <= i_valid;
    -- ================================================================
    -- Error generation for unsupported configurations
    g_ready_output_error : if C_NUM_STAGES = 0 generate
        assert FALSE report "No stages?!" severity FAILURE;
    end generate;
    -- ================================================================
    g_generate_decimate_stage : for i in 0 to C_NUM_STAGES - 1 generate
        constant C_INIT_FILE     : string := G_INIT_FILE & "_" & integer'image(i) & ".txt";
        signal w_stage_data_out  : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        signal w_stage_valid_out : std_logic;
    begin
        ---------------------------------------------------
        halfband_decimate_stage_inst : entity work.halfband_decimate_stage
            generic map(
                G_DATA_WIDTH     => G_DATA_WIDTH,
                G_COEFF_WIDTH    => G_COEFF_WIDTH,
                G_NUM_TAPS_UPPER => C_NUM_TAPS_UPPER(i),
                G_NUM_TAPS_LOWER => C_NUM_TAPS_LOWER(i),
                G_INIT_FILE      => C_INIT_FILE
            )
            port map
            (
                clk     => clk,
                i_data  => w_stage_data_in(i),
                i_valid => w_stage_valid_in(i),
                o_data  => w_stage_data_out,
                o_valid => w_stage_valid_out
            );
        -- Output bridging to next stage
        w_stage_data_in(i + 1)  <= w_stage_data_out;
        w_stage_valid_in(i + 1) <= w_stage_valid_out;
        ---------------------------------------------------
    end generate;
    -- ================================================================
end architecture;