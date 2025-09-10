library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity gpio_ps_interface is
    port (
        clk_25 : in std_logic;
        -- From GPIO Ctrl
        i_lpf_incr : in std_logic;
        i_lpf_decr : in std_logic;
        i_hpf_incr : in std_logic;
        i_hpf_decr : in std_logic;
        -- To Video
        o_lpf_incr : out std_logic;
        o_lpf_decr : out std_logic;
        o_hpf_incr : out std_logic;
        o_hpf_decr : out std_logic;
        -- To Audio
        o_new_data_strobe_lpf : out std_logic;
        o_new_data_strobe_hpf : out std_logic;
        -- From FIR Filters
        i_updating_coeffs_lpf : std_logic;
        i_updating_coeffs_hpf : std_logic;
        -- From AXI GPIO
        i_new_data_strobe_lpf : in std_logic;
        i_new_data_strobe_hpf : in std_logic;
        i_ps_ack              : in std_logic; -- TODO
        -- To AXI GPIO
        o_fir_ctrl : out std_logic_vector(3 downto 0));
end entity gpio_ps_interface;

architecture rtl of gpio_ps_interface is
    type t_fir_ctrl_state is (IDLE, WAIT_FOR_ACK, WAIT_FOR_DATA_STROBE, WAIT_FOR_BUSY, WAIT_FOR_READY);
    signal s_STATE            : t_fir_ctrl_state             := IDLE;
    signal w_fir_ctrl         : std_logic_vector(3 downto 0) := (others => '0');
    signal r_fir_ctrl_request : std_logic_vector(3 downto 0) := (others => '0');
    signal r_fir_ctrl_store   : std_logic_vector(3 downto 0) := (others => '0');
    signal r_fir_ctrl_video   : std_logic_vector(3 downto 0) := (others => '0');

    -- Rising Edge detection
    signal w_ps_ack_strobe       : std_logic := '0';
    signal r_ps_ack              : std_logic := '0';
    signal w_new_data_strobe_lpf : std_logic := '0';
    signal r_new_data_strobe_lpf : std_logic := '0';
    signal w_new_data_strobe_hpf : std_logic := '0';
    signal r_new_data_strobe_hpf : std_logic := '0';
begin
    -- ==================================================================
    -- Strobe PS signals by detecting rising edges
    --            _   _   _   _
    --  CLK ... _| |_| |_| |_| |_ 
    --                ___________
    --  w_  ... _____|    
    --                    _______
    --  r_  ... _________|
    --                ___
    --  re  ... _____|   |_______
    p_re_det : process (clk_25)
    begin
        if rising_edge(clk_25) then
            r_ps_ack              <= i_ps_ack;
            r_new_data_strobe_lpf <= i_new_data_strobe_lpf;
            r_new_data_strobe_hpf <= i_new_data_strobe_hpf;
        end if;
    end process p_re_det;

    w_ps_ack_strobe       <= i_ps_ack and not(r_ps_ack);
    w_new_data_strobe_lpf <= i_new_data_strobe_lpf and not(r_new_data_strobe_lpf);
    w_new_data_strobe_hpf <= i_new_data_strobe_hpf and not(r_new_data_strobe_hpf);

    -- ==================================================================
    -- From GPIO & Audio Top
    -- Only register button pushes when not updating coefficients
    w_fir_ctrl <= (
        3 => i_hpf_incr and not(i_updating_coeffs_hpf),
        2 => i_hpf_decr and not(i_updating_coeffs_hpf),
        1 => i_lpf_incr and not(i_updating_coeffs_lpf),
        0 => i_lpf_decr and not(i_updating_coeffs_lpf)
        );

    -- To Filters
    o_new_data_strobe_lpf <= w_new_data_strobe_lpf;
    o_new_data_strobe_hpf <= w_new_data_strobe_hpf;

    -- To Video
    o_hpf_incr <= r_fir_ctrl_video(3);
    o_hpf_decr <= r_fir_ctrl_video(2);
    o_lpf_incr <= r_fir_ctrl_video(1);
    o_lpf_decr <= r_fir_ctrl_video(0);

    -- To PS
    o_fir_ctrl <= r_fir_ctrl_request;
    -- ==================================================================
    p_send_request_to_ps : process (clk_25)
    begin
        if rising_edge(clk_25) then
            r_fir_ctrl_video <= (others => '0');
            case s_STATE is
                when IDLE                     =>
                    r_fir_ctrl_store   <= (others => '0');
                    r_fir_ctrl_request <= (others => '0');
                    if (xor_reduce(w_fir_ctrl) = '1') then
                        r_fir_ctrl_request <= w_fir_ctrl;
                        s_STATE            <= WAIT_FOR_ACK;
                    end if;
                when WAIT_FOR_ACK =>
                    -- Wait for PS to acknowledge request
                    if (w_ps_ack_strobe = '1') then
                        -- Clear request
                        r_fir_ctrl_request <= (others => '0');
                        -- Store request for later
                        r_fir_ctrl_store <= r_fir_ctrl_request;
                        s_STATE          <= WAIT_FOR_DATA_STROBE;
                    end if;
                when WAIT_FOR_DATA_STROBE =>
                    -- Wait for PS to fill memory
                    if (w_new_data_strobe_hpf = '1') or (w_new_data_strobe_lpf = '1') then
                        s_STATE <= WAIT_FOR_BUSY;
                    end if;
                when WAIT_FOR_BUSY =>
                    -- Wait for filters to start reading data
                    if (i_updating_coeffs_lpf = '1') or (i_updating_coeffs_hpf = '1') then
                        s_STATE <= WAIT_FOR_READY;
                    end if;
                when WAIT_FOR_READY =>
                    -- Wait for filters to be done reading data
                    if (i_updating_coeffs_lpf = '0') and (i_updating_coeffs_hpf = '0') then
                        r_fir_ctrl_video <= r_fir_ctrl_store;
                        s_STATE          <= IDLE;
                    end if;
                when others =>
                    s_STATE <= IDLE;
            end case;
        end if;
    end process p_send_request_to_ps;
    -- ==================================================================

end architecture;
