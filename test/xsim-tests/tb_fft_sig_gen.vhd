
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- library UNISIM;
-- use UNISIM.VCOMPONENTS.all;
entity top_appl_wrapper_tb is
end;

architecture bench of top_appl_wrapper_tb is
    -- Clock period
    constant clk_period : time := 5 ns;
    -- Generics
    -- Ports
    signal clk_50                      : std_logic := '0';
    signal event_data_in_channel_halt  : std_logic;
    signal event_data_out_channel_halt : std_logic;
    signal event_frame_started         : std_logic;
    signal event_status_channel_halt   : std_logic;
    signal event_tlast_missing         : std_logic;
    signal event_tlast_unexpected      : std_logic;
    signal i_reset                     : std_logic := '0';
    signal i_start                     : std_logic := '0';
    signal m_axis_data_tlast           : std_logic;
    signal m_axis_data_tvalid          : std_logic;
    signal o_BLK_EXP                   : std_logic_vector (7 downto 0);
    signal o_FFT_mag                   : std_logic_vector (31 downto 0);
    signal o_XK_INDEX                  : std_logic_vector (9 downto 0);

    procedure reset_hold (
        signal reset       : inout std_logic;
        constant clk_ticks : in integer
    ) is
    begin
        reset <= '0';
        for i in 0 to clk_ticks loop
            wait for clk_period;
        end loop;
        reset <= '1';
    end procedure;

    procedure wait_clock (
        constant clk_period : in time;
        constant clk_ticks  : in integer
    ) is
    begin
        for i in 0 to clk_ticks loop
            wait for clk_period;
        end loop;
    end procedure;

begin
    clk_50 <= not clk_50 after clk_period/2;

    top_appl_wrapper_inst : entity work.top_appl_wrapper
        port map
        (
            clk_50                      => clk_50,
            event_data_in_channel_halt  => event_data_in_channel_halt,
            event_data_out_channel_halt => event_data_out_channel_halt,
            event_frame_started         => event_frame_started,
            event_status_channel_halt   => event_status_channel_halt,
            event_tlast_missing         => event_tlast_missing,
            event_tlast_unexpected      => event_tlast_unexpected,
            i_reset                     => i_reset,
            i_start                     => i_start,
            m_axis_data_tlast           => m_axis_data_tlast,
            m_axis_data_tvalid          => m_axis_data_tvalid,
            o_BLK_EXP                   => o_BLK_EXP,
            o_FFT_mag                   => o_FFT_mag,
            o_XK_INDEX                  => o_XK_INDEX
        );

    main : process
    begin
        reset_hold(i_reset, 20);
        wait_clock(clk_period, 30);
        reset_hold(i_reset, 20);
        wait_clock(clk_period, 30);
        i_start <= '1';
        wait_clock(clk_period, 2048);
        wait until m_axis_data_tlast = '1' and m_axis_data_tvalid = '1';
        wait until m_axis_data_tlast = '0' and m_axis_data_tvalid = '1';
        wait_clock(clk_period, 10);
        report "Just Kidding.   Test Done!" severity failure;
    end process main;
end;