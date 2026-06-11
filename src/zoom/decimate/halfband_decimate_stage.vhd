library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
-- 
use std.textio.all;
-- 
use work.polyphase_pkg.all;
-- 
entity halfband_decimate_stage is
    generic (
        G_DATA_WIDTH     : natural := 16;
        G_COEFF_WIDTH    : natural := 16;
        G_NUM_TAPS_UPPER : natural := 8;
        G_NUM_TAPS_LOWER : natural := 2;
        G_INIT_FILE      : string
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
end entity halfband_decimate_stage;

architecture rtl of halfband_decimate_stage is
    --------------------
    -- Constants
    --------------------
    constant C_COEFF_FRAC_WIDTH : natural                           := G_COEFF_WIDTH - 1;
    constant C_BIT_GROWTH       : natural                           := integer(ceil(log2(real(G_NUM_TAPS_UPPER))));
    constant C_CLIP_MAX_SIGNED  : signed(G_DATA_WIDTH - 1 downto 0) := (G_DATA_WIDTH - 1 => '0', others => '1');
    constant C_CLIP_MIN_SIGNED  : signed(G_DATA_WIDTH - 1 downto 0) := (G_DATA_WIDTH - 1 => '1', others => '0');
    --------------------
    -- Functions
    --------------------
    -- The following code either initializes the memory values to a specified file or to all zeros to match hardware
    impure function init_ram_from_file return t_array_slv is
        file v_read_file : text open read_mode is G_INIT_FILE;
        variable v_line  : line;
        variable v_slv   : std_logic_vector(G_COEFF_WIDTH - 1 downto 0);
        variable v_ram   : t_array_slv(0 to (G_NUM_TAPS_UPPER/2) - 1)(G_COEFF_WIDTH - 1 downto 0);
        variable v_idx   : natural := 0;
    begin
        v_idx := 0;
        for i in 0 to (G_NUM_TAPS_UPPER/2) - 1 loop
            readline(v_read_file, v_line);
            read(v_line, v_slv);
            v_ram(v_idx) := v_slv;
            v_idx        := v_idx + 1;
        end loop;
        return v_ram;
    end function;
    --------------------
    -- Signals
    --------------------
    signal coefficient_memory                       : t_array_slv(0 to (G_NUM_TAPS_UPPER/2) - 1)(G_COEFF_WIDTH - 1 downto 0)                           := init_ram_from_file;
    signal r_data_upper                             : std_logic_vector(G_DATA_WIDTH - 1 downto 0)                                                      := (others => '0');
    signal r_data_lower                             : std_logic_vector(G_DATA_WIDTH - 1 downto 0)                                                      := (others => '0');
    signal r_sel                                    : std_logic                                                                                        := '0';
    signal r_valid                                  : std_logic                                                                                        := '0';
    signal r_delay_line_upper                       : t_array_slv(0 to G_NUM_TAPS_UPPER - 1)(G_DATA_WIDTH + G_COEFF_WIDTH + C_BIT_GROWTH - 1 downto 0) := (others => (others => '0'));
    signal r_delay_line_lower                       : t_array_slv(0 to G_NUM_TAPS_LOWER)(G_DATA_WIDTH - 1 downto 0)                                    := (others => (others => '0'));
    signal r_dlyline_valid                          : std_logic                                                                                        := '0';
    signal r_acc_upper                              : std_logic_vector(G_DATA_WIDTH + G_COEFF_WIDTH + C_BIT_GROWTH - 1 downto 0)                       := (others => '0');
    signal r_acc_lower                              : std_logic_vector(G_DATA_WIDTH - 1 downto 0)                                                      := (others => '0');
    signal r_acc_shifted                            : signed(G_DATA_WIDTH + C_BIT_GROWTH downto 0)                                                     := (others => '0');
    signal r_postproc_valid                         : std_logic                                                                                        := '0';
    signal r_postproc_valid_d1, r_postproc_valid_d2 : std_logic                                                                                        := '0';
    signal r_acc_clip                               : std_logic_vector(G_DATA_WIDTH - 1 downto 0)                                                      := (others => '0');
begin
    -- ================================================================
    -- Combinatorial r_data_lower_d2
    o_data  <= r_acc_clip;
    o_valid <= r_postproc_valid_d2;
    -- ================================================================
    p_register_input : process (clk)
    begin
        if rising_edge(clk) then
            r_valid <= '0';
            if (i_valid = '1') then
                r_sel <= not(r_sel);
                -- Valid is high every other sample to implement decimation by 2
                if (r_sel = '1') then
                    r_data_upper <= i_data;
                    r_valid      <= '1';
                else
                    r_data_lower <= i_data;
                end if;
            end if;
        end if;
    end process p_register_input;
    -- ================================================================
    p_mac_and_delay_line_upper : process (clk)
        variable v_result : signed(G_DATA_WIDTH + G_COEFF_WIDTH - 1 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            -- Note: this implements a Transposed filter
            if (r_valid = '1') then
                ------------------
                -- MAC & Delay Line
                ------------------
                -- UPPER
                for tap in 0 to (G_NUM_TAPS_UPPER/2) - 1 loop
                    -- Multiply
                    v_result := signed(coefficient_memory(tap)) * signed(r_data_upper);
                    -- Accumulate delay line
                    if (tap = 0) then
                        r_delay_line_upper(tap)                     <= std_logic_vector(resize(v_result, r_delay_line_upper(0)'length));
                        r_delay_line_upper(r_delay_line_upper'high) <= std_logic_vector(resize(signed(r_delay_line_upper(r_delay_line_upper'high - 1)) + v_result, r_delay_line_upper(0)'length));
                    else
                        r_delay_line_upper(tap)                           <= std_logic_vector(resize(signed(r_delay_line_upper(tap - 1)) + v_result, r_delay_line_upper(0)'length));
                        r_delay_line_upper(r_delay_line_upper'high - tap) <= std_logic_vector(resize(signed(r_delay_line_upper(r_delay_line_upper'high - tap - 1)) + v_result, r_delay_line_upper(0)'length));
                    end if;
                end loop;
                -- LOWER
                r_delay_line_lower <= r_data_lower & r_delay_line_lower(r_delay_line_lower'low to r_delay_line_lower'high - 1);
            end if;
            r_dlyline_valid <= r_valid;
        end if;
    end process p_mac_and_delay_line_upper;
    -- ================================================================
    p_saturate_and_ovf : process (clk)
    begin
        if rising_edge(clk) then
            ------------------
            -- PIPE 0
            -- Fetch value
            ------------------
            r_acc_upper      <= r_delay_line_upper(r_delay_line_upper'high);
            r_acc_lower      <= r_delay_line_lower(r_delay_line_lower'high);
            r_postproc_valid <= r_dlyline_valid;
            ------------------
            -- PIPE 1
            -- Add & Scale
            ------------------
            -- Shift right by 1 implements the implicit 0.5 coefficient for the lower branch
            r_acc_shifted <= resize(
                shift_right(signed(r_acc_upper), C_COEFF_FRAC_WIDTH) + shift_right(signed(r_acc_lower), 1),
                r_acc_shifted'length
                );
            r_postproc_valid_d1 <= r_postproc_valid;
            ------------------
            -- PIPE 2
            -- Clip
            ------------------
            if (r_acc_shifted > C_CLIP_MAX_SIGNED) then
                r_acc_clip <= std_logic_vector(C_CLIP_MAX_SIGNED);
            elsif (r_acc_shifted < C_CLIP_MIN_SIGNED) then
                r_acc_clip <= std_logic_vector(C_CLIP_MIN_SIGNED);
            else
                r_acc_clip <= std_logic_vector(resize(r_acc_shifted, G_DATA_WIDTH));
            end if;
            r_postproc_valid_d2 <= r_postproc_valid_d1;
        end if;
    end process p_saturate_and_ovf;
    -- ================================================================
end architecture;