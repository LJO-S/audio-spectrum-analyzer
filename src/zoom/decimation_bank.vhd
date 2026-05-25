---------------------------------------------------------------------------
-- Title       : Decimation Bank
-- Design      : decimation_bank
-- Author      : Ludvig Snihs
-- Description : Top-level module for multiple decimate-by-2 halfband filters to achieve decimation by 2, 4, 8, or 16.
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity decimation_bank is
    generic (
        G_INPUT_DATA_WIDTH : natural := 16;
        G_COEFF_DATA_WIDTH : natural := 16;
        G_INIT_FILE        : string  := "/mnt/tools/projects/fpga/audio-spectrum-analyzer/src/zoom/decimate/HBF_16"
    );
    port (
        clk : in std_logic;
        -- Configuration
        i_cfg_decimation_factor : in std_logic_vector(3 downto 0); -- 2, 4, 8, 16 (0 = bypass)
        i_cfg_valid             : in std_logic;
        -- Input
        i_data_i     : in std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        i_data_q     : in std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        i_data_valid : in std_logic;
        -- Output
        o_data_i     : out std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        o_data_q     : out std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        o_data_valid : out std_logic
    );
end entity decimation_bank;

architecture rtl of decimation_bank is
    --------------------
    -- Constants
    --------------------

    --------------------
    -- Types
    --------------------
    type t_array_slv is array (natural range <>) of std_logic_vector;

    --------------------
    -- Signals
    --------------------
    signal r_cfg_decimation_factor : std_logic_vector(3 downto 0) := (others => '0');
    -- signal r_decimate_active_slv   : std_logic_vector(3 downto 0) := (others => '0');

    signal w_decimate_data_i_in  : t_array_slv(0 to 4)(G_INPUT_DATA_WIDTH - 1 downto 0) := (others => (others => '0'));
    signal w_decimate_valid_i_in : std_logic_vector(0 to 4)                             := (others => '0');
    signal w_decimate_data_q_in  : t_array_slv(0 to 4)(G_INPUT_DATA_WIDTH - 1 downto 0) := (others => (others => '0'));
    signal w_decimate_valid_q_in : std_logic_vector(0 to 4)                             := (others => '0');

    signal r_decimate_data_i_out : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal r_decimate_data_q_out : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal r_decimate_valid_out  : std_logic                                         := '0';
begin
    -- =========================================================================
    -- Combinatorial
    o_data_i                 <= r_decimate_data_i_out;
    o_data_q                 <= r_decimate_data_q_out;
    o_data_valid             <= r_decimate_valid_out;
    w_decimate_data_i_in(0)  <= i_data_i;
    w_decimate_valid_i_in(0) <= i_data_valid;
    w_decimate_data_q_in(0)  <= i_data_q;
    w_decimate_valid_q_in(0) <= i_data_valid;
    -- =========================================================================
    p_output_mux : process (clk)
    begin
        if rising_edge(clk) then
            -------------------------
            -- Latch configuration
            -------------------------
            if (i_cfg_valid = '1') then
                r_cfg_decimation_factor <= i_cfg_decimation_factor;
            end if;
            -------------------------
            -- Mux
            -------------------------
            case r_cfg_decimation_factor is
                when "0001" =>
                    r_decimate_data_i_out <= w_decimate_data_i_in(1);
                    r_decimate_data_q_out <= w_decimate_data_q_in(1);
                    r_decimate_valid_out  <= w_decimate_valid_i_in(1) and w_decimate_valid_q_in(1);
                    -- r_decimate_active_slv <= "0001";
                when "0010" =>
                    r_decimate_data_i_out <= w_decimate_data_i_in(2);
                    r_decimate_data_q_out <= w_decimate_data_q_in(2);
                    r_decimate_valid_out  <= w_decimate_valid_i_in(2) and w_decimate_valid_q_in(2);
                    -- r_decimate_active_slv <= "0011";
                when "0100" =>
                    r_decimate_data_i_out <= w_decimate_data_i_in(3);
                    r_decimate_data_q_out <= w_decimate_data_q_in(3);
                    r_decimate_valid_out  <= w_decimate_valid_i_in(3) and w_decimate_valid_q_in(3);
                    -- r_decimate_active_slv <= "0111";
                when "1000" =>
                    r_decimate_data_i_out <= w_decimate_data_i_in(4);
                    r_decimate_data_q_out <= w_decimate_data_q_in(4);
                    r_decimate_valid_out  <= w_decimate_valid_i_in(4) and w_decimate_valid_q_in(4);
                    -- r_decimate_active_slv <= "1111";
                when others                      =>
                    r_decimate_data_i_out <= (others => '0');
                    r_decimate_data_q_out <= (others => '0');
                    r_decimate_valid_out  <= '0';
                    -- r_decimate_active_slv <= (others => '0');
            end case;
        end if;
    end process p_output_mux;
    -- =========================================================================
    g_generate_decimators : for i in 0 to 3 generate
        signal w_decimate_data_i_out  : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        signal w_decimate_valid_i_out : std_logic;
        signal w_decimate_data_q_out  : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        signal w_decimate_valid_q_out : std_logic;
    begin
        -- In-phase
        halfband_decimate_i_inst : entity work.halfband_decimate
            generic map(
                G_DATA_WIDTH       => G_INPUT_DATA_WIDTH,
                G_COEFF_WIDTH      => G_COEFF_DATA_WIDTH,
                G_MULTIRATE_FACTOR => 2,
                G_INIT_FILE        => G_INIT_FILE
            )
            port map
            (
                clk     => clk,
                i_data  => w_decimate_data_i_in(i),
                i_valid => w_decimate_valid_i_in(i),
                o_data  => w_decimate_data_i_out,
                o_valid => w_decimate_valid_i_out
            );
        w_decimate_data_i_in(i + 1)  <= w_decimate_data_i_out;
        w_decimate_valid_i_in(i + 1) <= w_decimate_valid_i_out;

        -- Quadrature
        halfband_decimate_q_inst : entity work.halfband_decimate
            generic map(
                G_DATA_WIDTH       => G_INPUT_DATA_WIDTH,
                G_COEFF_WIDTH      => G_COEFF_DATA_WIDTH,
                G_MULTIRATE_FACTOR => 2,
                G_INIT_FILE        => G_INIT_FILE
            )
            port map
            (
                clk     => clk,
                i_data  => w_decimate_data_q_in(i),
                i_valid => w_decimate_valid_q_in(i),
                o_data  => w_decimate_data_q_out,
                o_valid => w_decimate_valid_q_out
            );
        w_decimate_data_q_in(i + 1)  <= w_decimate_data_q_out;
        w_decimate_valid_q_in(i + 1) <= w_decimate_valid_q_out;
    end generate;
    -- =========================================================================
end architecture;
