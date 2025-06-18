------------------------------------------------------------
------------------------------------------------------------
-- Signal Generator Wrapper
-- Should be able to produce 8 different pre-produced patterns
-- from 8 different signal generators
------------------------------------------------------------
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sig_gen_pkg.all;

entity signal_generator_top is
    generic (
        G_FFT_BIT_SIZE : natural := 16;
        G_RAM_DEPTH    : natural := 1024;
        G_100MS_CYCLES : natural := 2_500_000
    );
    port (
        clk_25 : in std_logic;
        -- GPIO
        i_pbuttons    : in std_logic_vector(3 downto 0);
        i_dip_switch0 : in std_logic;
        -- Misc
        o_reset : out std_logic;
        -- AXIS
        i_s_axis_tready : in std_logic;
        o_m_axis_tdata  : out std_logic_vector(2 * G_FFT_BIT_SIZE - 1 downto 0);
        o_m_axis_tvalid : out std_logic;
        o_m_axis_tlast  : out std_logic
    );
end entity signal_generator_top;

architecture rtl of signal_generator_top is
    -- Constants
    constant C_PRELOAD_STRING_SRC : t_preload_string_array := C_PRELOAD_STRING_SRC;
    constant C_PRELOAD_STRING_TB  : t_preload_string_array := C_PRELOAD_STRING_TB;
    -- Internals
    type t_gpio_state is (s_IDLE, s_REQ_PENDING);
    signal r_STATE_GPIO : t_gpio_state := s_IDLE;

    signal r_100ms_counter       : unsigned(22 downto 0) := (others => '0');
    signal r_sig_gen_reset       : std_logic             := '0';
    signal r_start_strobe        : std_logic             := '0';
    signal r_start_strobe_d1     : std_logic             := '0';
    signal r_tlast_pending       : std_logic             := '0';
    signal w_sig_gen_tvalid      : std_logic             := '0';
    signal w_sig_gen_tlast       : std_logic             := '0';
    signal w_sig_gen_tdata       : std_logic_vector(2 * G_FFT_BIT_SIZE - 1 downto 0);
    signal r_sig_gen_idx         : UNSIGNED(2 downto 0) := (others => '0');
    signal r_sig_gen_idx_pending : UNSIGNED(2 downto 0) := (others => '0');
    -- Signal Generators wiring
    type t_tdata_array is array (0 to 7) of std_logic_vector(31 downto 0);
    signal w_tdata_array   : t_tdata_array                := (others => (others => '0'));
    signal w_start_vector  : std_logic_vector(7 downto 0) := (others => '0');
    signal w_tready_vector : std_logic_vector(7 downto 0);
    signal w_tvalid_vector : std_logic_vector(7 downto 0) := (others => '0');
    signal w_tlast_vector  : std_logic_vector(7 downto 0) := (others => '0');
begin
    -------------------------------------------------------------
    -- Outputs
    o_reset         <= r_sig_gen_reset;
    o_m_axis_tdata  <= w_sig_gen_tdata;
    o_m_axis_tvalid <= w_sig_gen_tvalid;
    o_m_axis_tlast  <= w_sig_gen_tlast;
    -------------------------------------------------------------
    p_100ms_cntr : process (clk_25)
    begin
        if rising_edge(clk_25) then
            --------------------------------------
            --------------------------------------
            case r_STATE_GPIO is
                    -- 
                when s_IDLE =>
                    for i in 0 to 3 loop
                        if (xor i_pbuttons = '1') and (i_pbuttons(i) = '1') then
                            if (i_dip_switch0 = '1') then
                                r_sig_gen_idx_pending <= to_unsigned(4 + i, r_sig_gen_idx_pending'length);
                            else
                                r_sig_gen_idx_pending <= to_unsigned(i, r_sig_gen_idx_pending'length);
                            end if;
                            r_STATE_GPIO <= s_REQ_PENDING;
                        end if;
                    end loop;
                    -- 
                when s_REQ_PENDING =>
                    if (r_tlast_pending = '0') then
                        r_sig_gen_idx <= r_sig_gen_idx_pending;
                        r_STATE_GPIO  <= s_IDLE;
                    end if;
                    -- 
                when others =>
                    r_STATE_GPIO <= s_IDLE;
            end case;
            --------------------------------------
            --------------------------------------
            if (r_100ms_counter >= G_100MS_CYCLES) then
                r_start_strobe  <= '1';
                r_100ms_counter <= (others => '0');
            else
                r_start_strobe  <= '0';
                r_100ms_counter <= r_100ms_counter + 1;
            end if;
            r_start_strobe_d1 <= r_start_strobe;
            -- Wait for sig_gen to load 1024 samples into FFT
            if (r_start_strobe_d1 = '1') and (w_sig_gen_tvalid = '1') then
                r_tlast_pending <= '1';
            elsif (r_tlast_pending = '1') and (w_sig_gen_tlast = '1') then
                r_tlast_pending <= '0';
            end if;
            --------------------------------------
            --------------------------------------
        end if;
    end process p_100ms_cntr;
    -------------------------------------------------------------
    p_data_mux : process (
        r_start_strobe,
        w_tvalid_vector,
        w_tlast_vector,
        w_tdata_array,
        r_sig_gen_idx
        )
    begin
        w_start_vector                            <= (others => '0');
        w_start_vector(to_integer(r_sig_gen_idx)) <= r_start_strobe;
        w_sig_gen_tvalid                          <= w_tvalid_vector(to_integer(r_sig_gen_idx));
        w_sig_gen_tlast                           <= w_tlast_vector(to_integer(r_sig_gen_idx));
        w_sig_gen_tdata                           <= w_tdata_array(to_integer(r_sig_gen_idx));
    end process p_data_mux;
    -------------------------------------------------------------
    p_startup : process (clk_25)
    begin
        if rising_edge(clk_25) then
            if (r_sig_gen_reset = '0') and (r_100ms_counter >= 20) then
                r_sig_gen_reset <= '1';
            end if;
        end if;
    end process p_startup;
    -------------------------------------------------------------
    -- TODO
    gen_signal_generators : for i in 0 to 7 generate
        -- TODO 
        signal_generator_inst : entity work.signal_generator
            generic map(
                G_FFT_BIT_SIZE => G_FFT_BIT_SIZE,
                G_RAM_DEPTH    => G_RAM_DEPTH,
                G_INIT_FILE    => C_PRELOAD_STRING_TB(i)
            )
            port map
            (
                clk_25   => clk_25,
                i_start  => w_start_vector(i),
                i_reset  => r_sig_gen_reset,
                i_tready => i_s_axis_tready,
                o_tdata  => w_tdata_array(i),
                o_tvalid => w_tvalid_vector(i),
                o_tlast  => w_tlast_vector(i)
            );
    end generate;
    -------------------------------------------------------------
end architecture;