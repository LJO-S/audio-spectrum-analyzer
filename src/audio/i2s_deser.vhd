library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_deser is
    port (
        clk_25           : in std_logic;
        i_lrclk       : in std_logic;
        i_bclk        : in std_logic;
        i_serial_data : in std_logic;

        i_en : in std_logic;

        o_data  : out std_logic_vector(15 downto 0);
        o_valid : out std_logic
    );
end entity i2s_deser;

architecture rtl of i2s_deser is
    constant C_BIT_CNTR_MAX : natural := 16;

    type t_deserial_fsm is (IDLE, WAIT_LEFT, SKIP_LEFT, READ_LEFT, WAIT_RIGHT, SKIP_RIGHT, READ_RIGHT);
    signal s_deser_state : t_deserial_fsm := IDLE;

    signal r_lrclk : std_logic;
    signal r_bclk  : std_logic;

    signal w_left    : std_logic;
    signal w_right   : std_logic;
    signal w_bclk_re : std_logic;

    signal r_bit_cntr : unsigned(7 downto 0) := (others => '0');

    signal r_ldata : std_logic_vector(15 downto 0) := (others => '0');
    signal r_rdata : std_logic_vector(15 downto 0) := (others => '0');
begin
    -- ==================================================================
    -- Combinatorial assignments
    w_left    <= r_lrclk and not(i_lrclk); -- falling edge lrclk
    w_right   <= not(r_lrclk) and i_lrclk; -- rising edge lrclk
    w_bclk_re <= not(r_bclk) and i_bclk; -- rising_edge bclk

    o_data  <= r_ldata;
    o_valid <= '1' when (s_deser_state = READ_RIGHT) and (r_bit_cntr >= C_BIT_CNTR_MAX) else
        '0';
    -- ==================================================================
    -- Pipe input logic
    p_pipeline : process (clk_25)
    begin
        if rising_edge(clk_25) then
            r_lrclk <= i_lrclk;
            r_bclk  <= i_bclk;
        end if;
    end process p_pipeline;
    -- ==================================================================
    -- This process implements the I2S protocol as described in the 
    -- SSM2603 datasheet. The LRCLK @ (1/fs) decides on Left vs Right 
    -- channel output. The BCLK (bitCLK perhaps?) clocks out N bits,
    -- where N is set by the I2C setup. Notice that in the datasheet
    -- the 1st bit clocked out after LRCLK toggles is INVALID, so we
    -- skip the 1st BCLK bit.
    p_deserializer_fsm : process (clk_25)
    begin
        if rising_edge(clk_25) then
            case s_deser_state is
                    -- --------------------------------------------
                when IDLE =>
                    s_deser_state <= WAIT_LEFT;
                    -- --------------------------------------------
                when WAIT_LEFT =>
                    if (w_left = '1') then
                        s_deser_state <= SKIP_LEFT;
                    end if;
                    -- --------------------------------------------
                when SKIP_LEFT =>
                    -- Skip 1 bit of data
                    if (w_bclk_re = '1') then
                        s_deser_state <= READ_LEFT;
                    end if;
                    -- --------------------------------------------
                when READ_LEFT =>
                    if (r_bit_cntr >= C_BIT_CNTR_MAX) then
                        s_deser_state <= WAIT_RIGHT;
                    end if;
                    -- --------------------------------------------
                when WAIT_RIGHT =>
                    if (w_right = '1') then
                        s_deser_state <= SKIP_RIGHT;
                    end if;
                    -- --------------------------------------------
                when SKIP_RIGHT =>
                    -- Skip 1 bit of data
                    if (w_bclk_re = '1') then
                        s_deser_state <= READ_RIGHT;
                    end if;
                    -- --------------------------------------------
                when READ_RIGHT =>
                    if (r_bit_cntr >= C_BIT_CNTR_MAX) then
                        s_deser_state <= WAIT_LEFT;
                    end if;
                    -- --------------------------------------------
                when others =>
                    s_deser_state <= IDLE;
                    -- --------------------------------------------
            end case;

            if (i_en = '0') then
                s_deser_state <= IDLE;
            end if;

        end if;
    end process p_deserializer_fsm;
    -- ==================================================================
    -- Counts the number of bits as per BCLK rising edges
    p_bclk_bit_counter : process (clk_25)
    begin
        if rising_edge(clk_25) then
            if (s_deser_state = READ_LEFT) or (s_deser_state = READ_RIGHT) then
                if (w_bclk_re = '1') then
                    r_bit_cntr <= r_bit_cntr + 1;
                end if;
            else
                r_bit_cntr <= (others => '0');
            end if;
        end if;
    end process p_bclk_bit_counter;
    -- ==================================================================
    -- Left shifts serial data into vector
    p_output : process (clk_25)
    begin
        if rising_edge(clk_25) then
            if (s_deser_state = READ_LEFT) then
                -- Fill LEFT ch data
                if (w_bclk_re = '1') then
                    r_ldata(15 downto 1) <= r_ldata(14 downto 0);
                    r_ldata(0)           <= i_serial_data;
                end if;
            elsif (s_deser_state = READ_RIGHT) then
                -- Fill RIGHT ch data
                if (w_bclk_re = '1') then
                    r_rdata(15 downto 1) <= r_rdata(14 downto 0);
                    r_rdata(0)           <= i_serial_data;
                end if;
            end if;
        end if;
    end process p_output;
    -- ==================================================================
end architecture;