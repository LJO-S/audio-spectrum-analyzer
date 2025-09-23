library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_ser is
    port (
        clk_25 : in std_logic;
        -- I2S Timing
        i_pbclk : in std_logic;
        i_bclk  : in std_logic;
        -- Data word
        i_tdata  : in std_logic_vector(15 downto 0);
        i_tvalid : in std_logic;
        -- Enable
        i_en : in std_logic;
        -- Serialized Data
        o_pbdat : out std_logic
    );
end entity i2s_ser;

architecture rtl of i2s_ser is
    constant C_BIT_CNTR_MAX : natural := 16;

    type t_serial_fsm is (IDLE, WAIT_LEFT, SKIP_LEFT, WRITE_LEFT, WAIT_RIGHT, SKIP_RIGHT, WRITE_RIGHT);
    signal s_ser_state : t_serial_fsm := IDLE;

    signal r_pbclk : std_logic;
    signal r_bclk  : std_logic;

    signal w_left    : std_logic;
    signal w_right   : std_logic;
    signal w_bclk_re : std_logic;
    signal w_bclk_fe : std_logic;

    signal r_bit_cntr : unsigned(7 downto 0) := (others => '0');

    signal r_data_pending : std_logic_vector(15 downto 0) := (others => '0');
    signal r_data         : std_logic_vector(15 downto 0) := (others => '0');
    -- signal r_ldata        : std_logic                     := '0';
    -- signal r_rdata        : std_logic                     := '0';
    signal r_sdata : std_logic := '0';
begin
    -- ==================================================================
    w_left    <= r_pbclk and not(i_pbclk);
    w_right   <= i_pbclk and not(r_pbclk);
    w_bclk_re <= i_bclk and not(r_bclk);
    w_bclk_fe <= r_bclk and not(i_bclk);

    o_pbdat <= r_sdata;
    -- ==================================================================
    p_pipeline : process (clk_25)
    begin
        if rising_edge(clk_25) then
            r_bclk  <= i_bclk;
            r_pbclk <= i_pbclk;
        end if;
    end process p_pipeline;
    -- ==================================================================
    p_fetch_data : process (clk_25)
    begin
        if rising_edge(clk_25) then
            if (i_tvalid = '1') then
                r_data_pending <= i_tdata;
            end if;
        end if;
    end process p_fetch_data;
    -- ==================================================================
    p_serializer_fsm : process (clk_25)
    begin
        if rising_edge(clk_25) then
            case s_ser_state is
                    -- -----------------------------------
                when IDLE =>
                    s_ser_state <= WAIT_LEFT;
                    -- -----------------------------------
                when WAIT_LEFT =>
                    if (w_left = '1') then
                        s_ser_state <= SKIP_LEFT;
                    end if;
                    -- -----------------------------------
                when SKIP_LEFT =>
                    -- Skip first BCLK cycle
                    if (w_bclk_re = '1') then
                        s_ser_state <= WRITE_LEFT;
                    end if;
                    -- -----------------------------------
                when WRITE_LEFT =>
                    if (r_bit_cntr >= C_BIT_CNTR_MAX) then
                        s_ser_state <= WAIT_RIGHT;
                    end if;
                    -- -----------------------------------
                when WAIT_RIGHT =>
                    if (w_right = '1') then
                        s_ser_state <= SKIP_RIGHT;
                    end if;
                    -- -----------------------------------
                when SKIP_RIGHT =>
                    -- Skip first BCLK cycle
                    if (w_bclk_re = '1') then
                        s_ser_state <= WRITE_RIGHT;
                    end if;
                    -- -----------------------------------
                when WRITE_RIGHT =>
                    if (r_bit_cntr >= C_BIT_CNTR_MAX) then
                        s_ser_state <= WAIT_LEFT;
                    end if;
                    -- -----------------------------------
                when others =>
                    s_ser_state <= IDLE;
                    -- -----------------------------------
            end case;
            -------
            if (i_en = '0') then
                s_ser_state <= IDLE;
            end if;
            --------
        end if;
    end process p_serializer_fsm;
    -- ==================================================================
    p_bclk_bit_counter : process (clk_25)
    begin
        if rising_edge(clk_25) then
            if (s_ser_state = WRITE_LEFT) or (s_ser_state = WRITE_RIGHT) then
                if (w_bclk_fe = '1') then
                    r_bit_cntr <= r_bit_cntr + 1;
                end if;
            else
                r_bit_cntr <= (others => '0');
            end if;
        end if;
    end process p_bclk_bit_counter;
    -- ==================================================================
    -- 
    p_serializer : process (clk_25)
    begin
        if rising_edge(clk_25) then
            if (s_ser_state = WAIT_LEFT) then
                r_data <= r_data_pending;
            elsif (s_ser_state = WRITE_LEFT) or (s_ser_state = WRITE_RIGHT) then
                if (w_bclk_fe = '1') then
                    r_data  <= r_data(r_data'high - 1 downto 0) & r_data(r_data'high);
                    r_sdata <= r_data(r_data'high);
                end if;
            end if;

            if (i_en = '0') then
                r_sdata <= '0';
            end if;
        end if;
    end process p_serializer;
    -- ==================================================================
end architecture;
