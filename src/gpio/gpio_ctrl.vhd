-- ========================================================================
-- Handles DIP/PB GPIO debouncers and subsequent routing
-- ========================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity gpio_ctrl is
    generic (
        G_DEBOUNCE_LIMIT : natural := 1_000_000;
        G_DEBUG          : boolean := false
    );
    port (
        clk_100        : in std_logic;
        i_pb_vector    : in std_logic_vector(3 downto 0);
        i_dip_vector   : in std_logic_vector(3 downto 0);
        i_uart_gpio_if : in std_logic_vector(31 downto 0);
        -- DDS ctrl
        o_dds_ctrl : out std_logic_vector(3 downto 0);
        -- LPF ctrl
        o_lpf_en   : out std_logic;
        o_lpf_incr : out std_logic;
        o_lpf_decr : out std_logic;
        -- HPF ctrl
        o_hpf_en   : out std_logic;
        o_hpf_incr : out std_logic;
        o_hpf_decr : out std_logic;
        -- Video ctrl
        o_oscilloscope_en : out std_logic;
        o_waterfall_en    : out std_logic;
        o_sel_up_lo       : out std_logic;
        o_capture_en      : out std_logic
    );
end entity gpio_ctrl;

architecture rtl of gpio_ctrl is
    -- Pushbuttons 0-3:
    -- INTERNAL: Used to switch between Signal Generator sources (0,1,2,..,7)
    -- CAPTURE: Used to incr(0,2)/decr(1,3) LPF(0,1)/HPF(2,3) cutoffs
    signal w_pb_debounce  : std_logic_vector(3 downto 0);
    signal w_dip_debounce : std_logic_vector(3 downto 0);

    -- dip0:
    -- INTERNAL: Selects between Signal Generator source 0-3 (LO) or 4-7 (HI) IFF 
    -- CAPTURE:  Enables EMA and Waterfall
    signal w_sel_up_lo    : std_logic;
    signal w_waterfall_en : std_logic;

    -- dip1
    -- INTERNAL: Waterfall
    -- CAPTURE: LPF Enable
    signal w_lpf_en      : std_logic;
    signal w_lpf_incr    : std_logic;
    signal r_lpf_incr    : std_logic := '0';
    signal w_lpf_incr_re : std_logic;
    signal w_lpf_decr    : std_logic;
    signal r_lpf_decr    : std_logic := '0';
    signal w_lpf_decr_re : std_logic;

    -- dip2 
    -- INTERNAL: Waterfall
    -- CAPTURE: HPF Enable
    signal w_hpf_en      : std_logic;
    signal w_hpf_incr    : std_logic;
    signal r_hpf_incr    : std_logic := '0';
    signal w_hpf_incr_re : std_logic;
    signal w_hpf_decr    : std_logic;
    signal r_hpf_decr    : std_logic := '0';
    signal w_hpf_decr_re : std_logic;

    -- dip3:
    -- Enables external CAPTURE mode. 
    signal w_capture_en : std_logic;

    -- UART SLV 0
    signal w_oscilloscope_en : std_logic;

begin
    /* ------------------------------------------------------------------ */ 
    p_gpio_mux : process (clk_100)
    begin
        if rising_edge(clk_100) then
            -- Defaults
            o_dds_ctrl  <= (others => '0');
            o_lpf_en    <= '0';
            o_lpf_incr  <= '0';
            o_lpf_decr  <= '0';
            o_hpf_en    <= '0';
            o_hpf_incr  <= '0';
            o_hpf_decr  <= '0';
            o_sel_up_lo <= '0';

            o_capture_en      <= w_capture_en;
            o_oscilloscope_en <= w_oscilloscope_en;

            if (w_capture_en = '1') then
                -- Mode B: capture 

                -- LPF
                o_lpf_en   <= w_lpf_en;
                o_lpf_incr <= w_lpf_incr_re;
                o_lpf_decr <= w_lpf_decr_re;
                -- HPF
                o_hpf_en   <= w_hpf_en;
                o_hpf_incr <= w_hpf_incr_re;
                o_hpf_decr <= w_hpf_decr_re;
                -- WATERFALL
                o_waterfall_en <= w_waterfall_en;
            else
                -- Mode A: internal
                o_waterfall_en <= w_lpf_en or w_hpf_en;
                -- Signal generator sources
                for i in 0 to 3 loop
                    o_dds_ctrl(i) <= w_pb_debounce(i);
                end loop;
                -- SigGenSrc select upper(0-3)/lower(4-7)  
                o_sel_up_lo <= w_sel_up_lo;
            end if;
        end if;
    end process p_gpio_mux;
    /* ------------------------------------------------------------------ */
    -- Incr/decr stepper. Detects rising edges of GPIO to force user to
    -- click multiple times when incrementing or decrementing values.
    -- 
    --            _   _   _   _
    --  CLK ... _| |_| |_| |_| |_ 
    --                ___________
    --  w_  ... _____|    
    --                    _______
    --  r_  ... _________|
    --                ___
    --  re  ... _____|   |_______
    -- 
    w_lpf_incr_re <= not(r_lpf_incr) and w_lpf_incr;
    w_lpf_decr_re <= not(r_lpf_decr) and w_lpf_decr;

    w_hpf_incr_re <= not(r_hpf_incr) and w_hpf_incr;
    w_hpf_decr_re <= not(r_hpf_decr) and w_hpf_decr;

    p_rising_edge_det : process (clk_100)
    begin
        if rising_edge(clk_100) then
            r_lpf_incr <= w_lpf_incr;
            r_lpf_decr <= w_lpf_decr;
            r_hpf_incr <= w_hpf_incr;
            r_hpf_decr <= w_hpf_decr;
        end if;
    end process p_rising_edge_det;
    /* ------------------------------------------------------------------ */ 
    -- Pushbuttons 0-3
    g_PB_debounce : for i in 0 to 3 generate
        PB_debounce_inst : entity work.PB_debounce
            generic map(
                G_DEBOUNCE_LIMIT => G_DEBOUNCE_LIMIT,
                G_DEBUG          => G_DEBUG
            )
            port map
            (
                i_CLK         => clk_100,
                i_PB          => i_pb_vector(i),
                o_PB_debounce => w_pb_debounce(i)
            );
    end generate;
    w_lpf_incr <= w_pb_debounce(0);
    w_lpf_decr <= w_pb_debounce(1);
    w_hpf_incr <= w_pb_debounce(2);
    w_hpf_decr <= w_pb_debounce(3);
    /* ------------------------------------------------------------------ */ 
    -- DIP Switches 0-3
    g_DIP_debounce : for i in 0 to 3 generate
        DIP_debounce_inst : entity work.PB_debounce
            generic map(
                G_DEBOUNCE_LIMIT => G_DEBOUNCE_LIMIT,
                G_DEBUG          => G_DEBUG
            )
            port map
            (
                i_CLK         => clk_100,
                i_PB          => i_dip_vector(i),
                o_PB_debounce => w_dip_debounce(i)
            );
    end generate;
    w_sel_up_lo    <= w_dip_debounce(0);
    w_waterfall_en <= w_dip_debounce(0);
    w_lpf_en       <= w_dip_debounce(1);
    w_hpf_en       <= w_dip_debounce(2);
    w_capture_en   <= w_dip_debounce(3);
    /* ------------------------------------------------------------------ */ 
    -- UART vector
    w_oscilloscope_en <= i_uart_gpio_if(0);
    /* ------------------------------------------------------------------ */ 
end architecture;