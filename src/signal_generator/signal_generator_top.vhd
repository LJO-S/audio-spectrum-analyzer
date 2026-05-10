------------------------------------------------------------
------------------------------------------------------------
-- Signal Generator Wrapper
-- Produces 8 different pre-produced patterns from 8 different signal generators
------------------------------------------------------------
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.sig_gen_pkg.all;

entity signal_generator_top is
    generic (
        G_DATA_WIDTH          : natural := 16;
        G_FFT_SIZE            : natural := 1024;
        G_SYS_CLK_FREQ        : natural := 100_000_000;
        G_DDS_FREQ_WIDTH      : natural := 16;
        G_DDS_FREQ_FRAC_WIDTH : natural := 16;
        G_DDS_TIME_WIDTH      : natural := 16;
        G_DDS_INIT_FILE       : string  := "/mnt/tools/projects/fpga/audio-spectrum-analyzer/src/signal_generator/dds/dds_lut.txt"
    );
    port (
        clk : in std_logic;
        -- GPIO
        i_en        : in std_logic;
        i_pbuttons  : in std_logic_vector(3 downto 0);
        i_sel_up_lo : in std_logic;
        -- Misc
        i_fs_clk     : in std_logic;
        o_100ms_strb : out std_logic;
        o_reset      : out std_logic;
        -- FFT
        i_iq_ready : in std_logic;
        o_iq_data  : out std_logic_vector(2 * G_DATA_WIDTH - 1 downto 0);
        o_iq_valid : out std_logic;
        o_iq_last  : out std_logic
    );
end entity signal_generator_top;

architecture rtl of signal_generator_top is
    --------------------
    -- Constants
    --------------------
    constant C_FREQ_FC_DELTA  : unsigned(G_DDS_FREQ_WIDTH - 1 downto 0) := to_unsigned(1000, G_DDS_FREQ_WIDTH);
    constant C_FREQ_BW_DELTA  : unsigned(G_DDS_FREQ_WIDTH - 1 downto 0) := to_unsigned(1000, G_DDS_FREQ_WIDTH);
    constant C_FREQ_DUR_DELTA : unsigned(G_DDS_FREQ_WIDTH - 1 downto 0) := to_unsigned(500, G_DDS_FREQ_WIDTH);
    --------------------
    -- Types
    --------------------
    type t_gpio_state is (IDLE, EVALUATE_GPIO);
    --------------------
    -- Signals
    --------------------
    signal s_gpio_state    : t_gpio_state                                          := IDLE;
    signal r_pbuttons      : std_logic_vector(3 downto 0)                          := (others => '0');
    signal r_100ms_counter : unsigned(integer(ceil(log2(real(100)))) - 1 downto 0) := (others => '0');
    signal r_100ms_strobe  : std_logic                                             := '0';
    signal r_sig_gen_reset : std_logic                                             := '0';

    signal w_ms_strobe : std_logic;
    signal r_fs_clk    : std_logic := '0';

    signal r_sel : std_logic := '0';

    signal r_cfg_valid    : std_logic                               := '0';
    signal r_cfg_fc_data  : unsigned(G_DDS_FREQ_WIDTH - 1 downto 0) := (others => '0');
    signal r_cfg_bw_data  : unsigned(G_DDS_FREQ_WIDTH - 1 downto 0) := (others => '0');
    signal r_cfg_dur_data : unsigned(G_DDS_TIME_WIDTH - 1 downto 0) := (others => '0');

    signal w_ramp_freq_data  : std_logic_vector(G_DDS_FREQ_WIDTH - 1 downto 0) := (others => '0');
    signal w_ramp_freq_valid : std_logic;

    signal w_dds_data_out_i : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal w_dds_data_out_q : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal w_dds_valid_out  : std_logic;

    signal r_dds_output_cntr : unsigned(integer(ceil(log2(real(G_FFT_SIZE)))) - 1 downto 0) := (others => '0');
    signal r_dds_data_out_iq : std_logic_vector(2 * G_DATA_WIDTH - 1 downto 0)              := (others => '0');
    signal r_dds_valid_out   : std_logic                                                    := '0';
    signal r_dds_last_out    : std_logic                                                    := '0';

    --------------------
    -- Functions
    --------------------
begin
    -- =========================================================================
    -- Combinatorial
    o_100ms_strb <= r_100ms_strobe;
    o_reset      <= r_sig_gen_reset;
    o_iq_data    <= r_dds_data_out_iq;
    o_iq_valid   <= r_dds_valid_out;
    o_iq_last    <= r_dds_last_out;
    -- =========================================================================
    p_gpio_ctrl : process (clk)
    begin
        if rising_edge(clk) then
            -- Default
            r_cfg_valid <= '0';
            case s_gpio_state is
                    ---------------------------------------------------------
                when IDLE =>
                    r_pbuttons <= i_pbuttons;
                    r_sel      <= i_sel_up_lo;
                    if ( xor (i_pbuttons) = '1') and (r_pbuttons /= i_pbuttons) then
                        s_gpio_state <= EVALUATE_GPIO;
                    end if;
                    ---------------------------------------------------------
                when EVALUATE_GPIO =>
                    case r_pbuttons is
                        when "0001" =>
                            -- FREQ/BW Incr
                            if (r_sel = '1') then
                                r_cfg_bw_data <= resize(r_cfg_bw_data + C_FREQ_BW_DELTA, r_cfg_bw_data'length);
                            else
                                r_cfg_fc_data <= resize(r_cfg_fc_data + C_FREQ_FC_DELTA, r_cfg_fc_data'length);
                            end if;
                        when "0010" =>
                            -- Freq/BW decr
                            if (r_sel = '1') then
                                r_cfg_bw_data <= resize(r_cfg_bw_data - C_FREQ_BW_DELTA, r_cfg_bw_data'length);
                            else
                                r_cfg_fc_data <= resize(r_cfg_fc_data - C_FREQ_FC_DELTA, r_cfg_fc_data'length);
                            end if;
                        when "0100" =>
                            -- BW incr
                            if (r_sel = '1') then
                                -- Placeholder for Square Wave
                                null;
                            else
                                r_cfg_dur_data <= resize(r_cfg_dur_data + C_FREQ_DUR_DELTA, r_cfg_dur_data'length);
                            end if;
                        when "1000" =>
                            -- BW decr
                            if (r_sel = '1') then
                                -- Placeholder for Square Wave
                                null;
                            else
                                r_cfg_dur_data <= resize(r_cfg_dur_data - C_FREQ_DUR_DELTA, r_cfg_dur_data'length);
                            end if;
                        when others =>
                            assert FALSE report "Ended up in faulty buttons stage" severity failure;
                    end case;
                    r_cfg_valid  <= '1';
                    s_gpio_state <= IDLE;
                    ---------------------------------------------------------
                when others =>
                    s_gpio_state <= IDLE;
                    ---------------------------------------------------------
            end case;
        end if;
    end process p_gpio_ctrl;
    -- =========================================================================
    p_100ms_strobe_gen : process (clk)
    begin
        if rising_edge(clk) then
            r_100ms_strobe <= '0';
            if (w_ms_strobe = '1') then
                r_100ms_counter <= r_100ms_counter + 1;
                if (r_100ms_counter >= 99) then
                    r_100ms_strobe  <= '1';
                    r_100ms_counter <= (others => '0');
                end if;
            end if;
        end if;
    end process p_100ms_strobe_gen;
    -- =========================================================================
    p_startup : process (clk)
    begin
        if rising_edge(clk) then
            if (r_sig_gen_reset = '0') and (r_100ms_counter >= 80) then
                r_sig_gen_reset <= '1';
            end if;
        end if;
    end process p_startup;
    -- =========================================================================
    ms_strobe_generator_inst : entity work.ms_strobe_generator
        generic map(
            G_SYS_CLK_FREQ => G_SYS_CLK_FREQ
        )
        port map
        (
            clk         => clk,
            o_ms_strobe => w_ms_strobe
        );
    -- =========================================================================
    tone_generator_inst : entity work.tone_generator
        generic map(
            G_FREQ_DATA_WIDTH      => G_DDS_FREQ_WIDTH,
            G_FREQ_DATA_FRAC_WIDTH => G_DDS_FREQ_FRAC_WIDTH,
            G_TIME_WIDTH           => G_DDS_TIME_WIDTH
        )
        port map
        (
            clk                     => clk,
            i_en                    => i_en,
            i_ms_strobe             => w_ms_strobe,
            i_cfg_fc_data           => std_logic_vector(r_cfg_fc_data),
            i_cfg_bw_data           => std_logic_vector(r_cfg_bw_data),
            i_cfg_sweep_duration_ms => std_logic_vector(r_cfg_dur_data),
            i_cfg_valid             => r_cfg_valid,
            o_freq_data             => w_ramp_freq_data,
            o_freq_valid            => w_ramp_freq_valid
        );
    -- =========================================================================
    dds_inst : entity work.dds
        generic map(
            G_FREQ_WIDTH        => G_DDS_FREQ_WIDTH,
            G_DATA_WIDTH        => G_DATA_WIDTH,
            G_ACCUMULATOR_WIDTH => 32,
            G_LUT_ADDR_WIDTH    => 10,
            G_SYS_CLK_HZ        => G_SYS_CLK_FREQ,
            G_INIT_FILE         => G_DDS_INIT_FILE
        )
        port map
        (
            clk         => clk,
            i_cfg_freq  => w_ramp_freq_data,
            i_cfg_valid => w_ramp_freq_valid,
            o_data_i    => w_dds_data_out_i,
            o_data_q    => w_dds_data_out_q,
            o_valid     => w_dds_valid_out
        );
    -- =========================================================================
    p_sample_output : process (clk)
    begin
        if rising_edge(clk) then
            r_fs_clk          <= i_fs_clk;
            r_dds_data_out_iq <= w_dds_data_out_q & w_dds_data_out_i;
            r_dds_valid_out   <= w_dds_valid_out and i_fs_clk and not(r_fs_clk);
            r_dds_last_out    <= '0';
            if (i_fs_clk = '1') and (r_fs_clk = '0') then
                r_dds_output_cntr <= r_dds_output_cntr + 1;
                if (r_dds_output_cntr >= G_FFT_SIZE - 2) then
                    r_dds_output_cntr <= (others => '0');
                    r_dds_last_out    <= '1';
                end if;
            end if;
        end if;
    end process p_sample_output;
    -- =========================================================================
end architecture;