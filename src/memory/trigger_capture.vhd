-------------------------------------------------------------------------------
-- Title      : Trigger Captrue
-- Project    : Audio Spectrum Analyzer
-------------------------------------------------------------------------------
-- File       : trigger_capture.vhd
-- Library    : 
-- Author     : Ludvig Snihs
-- Company    : 
-- Created    : 2026-05-14
-- Last update: 
-- Platform   : 
-- Standard   : VHDL-2008
-- Description: Stores G_DATA_DEPTH samples on trigger edge and released storage
--              lock upon completed video frame.
--              Trigger edge = signal rising edge
-- Known TODOs: BRAM, lines, capture
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
-- 
use work.project_common_pkg.all;
-- 
entity trigger_capture is
    generic (
        G_DATA_WIDTH  : natural := 16;
        G_DATA_DEPTH  : natural := C_SPECTRUM_X_UPPER;
        G_HOLD_OFF_MS : natural := 10
    );
    port (
        clk : in std_logic;
        -- Misc
        i_ms_strobe : in std_logic;
        -- Audio data
        i_audio_data  : in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        i_audio_valid : in std_logic;
        -- Video Readout
        i_video_raddr : in std_logic_vector(integer(ceil(log2(real(G_DATA_DEPTH)))) - 1 downto 0) := (others => '0');
        o_video_rdata : out std_logic_vector(G_DATA_WIDTH - 1 downto 0)
    );
end entity trigger_capture;

architecture rtl of trigger_capture is
    --------------------
    -- Constants
    --------------------
    constant C_THRESH_HI             : signed(G_DATA_WIDTH - 1 downto 0) := shift_right(to_signed((2 ** (G_DATA_WIDTH - 1) - 1), G_DATA_WIDTH), (G_DATA_WIDTH - 1) / 2);
    constant C_THRESH_LO             : signed(G_DATA_WIDTH - 1 downto 0) := shift_right(to_signed( - (2 ** (G_DATA_WIDTH - 1)), G_DATA_WIDTH), (G_DATA_WIDTH - 1) / 2);
    constant C_PRE_TRIGGER_COUNT     : natural                           := 10;
    constant C_REQUIRED_SAMPLE_CNT   : natural                           := C_SPECTRUM_X_UPPER - C_PRE_TRIGGER_COUNT;
    constant C_CEIL_DATA_DEPTH_WIDTH : natural                           := integer(ceil(log2(real(G_DATA_DEPTH))));
    constant C_CEIL_DATA_DEPTH       : natural                           := 2 ** C_CEIL_DATA_DEPTH_WIDTH;

    --------------------
    -- Types
    --------------------
    type t_capture_state is (SETUP, ARMED, CAPTURE, HOLD_OFF);

    --------------------
    -- Signals
    --------------------
    signal s_capture_state : t_capture_state := SETUP;

    signal r_audio_valid           : std_logic                                                       := '0';
    signal r_sample_curr           : signed(G_DATA_WIDTH - 1 downto 0)                               := (others => '0');
    signal r_sample_prev           : signed(G_DATA_WIDTH - 1 downto 0)                               := (others => '0');
    signal r_mem_sel               : std_logic                                                       := '0';
    signal r_mem_ready             : std_logic                                                       := '0';
    signal r_trigger_addr          : unsigned(integer(ceil(log2(real(G_DATA_DEPTH)))) - 1 downto 0)  := (others => '0');
    signal r_raddr_start_addr      : unsigned(integer(ceil(log2(real(G_DATA_DEPTH)))) - 1 downto 0)  := (others => '0');
    signal r_circ_buf_waddr        : unsigned(integer(ceil(log2(real(G_DATA_DEPTH)))) - 1 downto 0)  := (others => '0');
    signal r_circ_buf_raddr        : unsigned(integer(ceil(log2(real(G_DATA_DEPTH)))) - 1 downto 0)  := (others => '0');
    signal r_sample_cnt            : unsigned(integer(ceil(log2(real(G_DATA_DEPTH)))) - 1 downto 0)  := (others => '0');
    signal r_ms_cnt                : unsigned(integer(ceil(log2(real(G_HOLD_OFF_MS)))) - 1 downto 0) := (others => '0');
    signal w_circ_buf_a_we         : std_logic;
    signal w_circ_buf_b_we         : std_logic;
    signal r_circ_buf_a_re         : std_logic;
    signal r_circ_buf_b_re         : std_logic;
    signal w_circ_buf_a_rvalid_out : std_logic;
    signal w_circ_buf_b_rvalid_out : std_logic;
    signal r_video_rdata           : std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal w_circ_buf_a_rdata      : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal w_circ_buf_b_rdata      : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
begin
    -- ============================================================================ 
    -- Combinatorial
    o_video_rdata <= r_video_rdata;
    -- ============================================================================ 
    p_trigger_fsm : process (clk)
    begin
        if rising_edge(clk) then
            case s_capture_state is
                    ------------------------------------------------
                when SETUP =>
                    -- Wait for half of display to fill in buffer
                    r_mem_sel   <= '0';
                    r_mem_ready <= '0';
                    if (r_circ_buf_waddr >= C_PRE_TRIGGER_COUNT) then
                        r_mem_ready <= '1';
                    end if;
                    if (r_mem_ready = '1') then
                        s_capture_state <= ARMED;
                    end if;
                    ------------------------------------------------
                when ARMED =>
                    -- Trigger on rising edge /w hysteresis
                    if (r_audio_valid = '1') then
                        if (r_sample_curr > C_THRESH_HI) and (r_sample_prev < C_THRESH_LO) then
                            -- Capture starting point
                            r_trigger_addr  <= resize(r_circ_buf_waddr - C_PRE_TRIGGER_COUNT, r_trigger_addr'length);
                            r_sample_cnt    <= to_unsigned(C_REQUIRED_SAMPLE_CNT, r_sample_cnt'length);
                            s_capture_state <= CAPTURE;
                        end if;
                    end if;
                    ------------------------------------------------
                when CAPTURE =>
                    if (i_audio_valid = '1') then
                        r_sample_cnt <= r_sample_cnt - 1;
                        -- Account for read latency
                        if (r_sample_cnt   <= 0) then
                            r_raddr_start_addr <= r_trigger_addr;
                            r_mem_sel          <= not(r_mem_sel);
                            s_capture_state    <= HOLD_OFF;
                        end if;
                    end if;
                    ------------------------------------------------
                when HOLD_OFF =>
                    -- Prevent immediate new trigger
                    if (i_ms_strobe = '1') then
                        -- Count milliseconds
                        r_ms_cnt <= r_ms_cnt + 1;
                        if (r_ms_cnt >= G_HOLD_OFF_MS - 1) then
                            r_ms_cnt        <= (others => '0');
                            s_capture_state <= ARMED;
                        end if;
                    end if;
                    ------------------------------------------------
                when others =>
                    s_capture_state <= SETUP;
                    ------------------------------------------------
            end case;
        end if;
    end process p_trigger_fsm;
    -- ============================================================================ 
    p_new_input_sample : process (clk)
    begin
        if rising_edge(clk) then
            r_audio_valid <= i_audio_valid;
            if (i_audio_valid = '1') then
                r_sample_curr    <= signed(i_audio_data);
                r_sample_prev    <= r_sample_curr;
                r_circ_buf_waddr <= r_circ_buf_waddr + 1;
            end if;
        end if;
    end process p_new_input_sample;
    -- ============================================================================ 
    -- Write Enable signals
    w_circ_buf_a_we <= i_audio_valid and not(r_mem_sel);
    w_circ_buf_b_we <= i_audio_valid and r_mem_sel;
    -- ============================================================================ 
    -- Circular Buffer A
    circular_bram_inst_0 : entity work.generic_bram
        generic map(
            G_DATA_WIDTH => G_DATA_WIDTH,
            G_DATA_DEPTH => C_CEIL_DATA_DEPTH,
            G_LATENCY    => 1
        )
        port map
        (
            clk => clk,
            -- Wr
            i_we    => w_circ_buf_a_we,
            i_wdata => i_audio_data,
            i_waddr => std_logic_vector(r_circ_buf_waddr),
            -- Rd
            i_re     => r_circ_buf_a_re,
            i_raddr  => std_logic_vector(r_circ_buf_raddr),
            o_rdata  => w_circ_buf_a_rdata,
            o_rvalid => w_circ_buf_a_rvalid_out
        );
    -- ============================================================================ 
    -- Circular Buffer B
    circular_bram_inst_1 : entity work.generic_bram
        generic map(
            G_DATA_WIDTH => G_DATA_WIDTH,
            G_DATA_DEPTH => C_CEIL_DATA_DEPTH,
            G_LATENCY    => 1
        )
        port map
        (
            clk => clk,
            -- Wr
            i_we    => w_circ_buf_b_we,
            i_wdata => i_audio_data,
            i_waddr => std_logic_vector(r_circ_buf_waddr),
            -- Rd
            i_re     => r_circ_buf_b_re,
            i_raddr  => std_logic_vector(r_circ_buf_raddr),
            o_rdata  => w_circ_buf_b_rdata,
            o_rvalid => w_circ_buf_b_rvalid_out
        );
    -- ============================================================================ 
    p_readout : process (clk)
    begin
        if rising_edge(clk) then
            r_circ_buf_raddr <= resize(unsigned(i_video_raddr) + r_raddr_start_addr, r_circ_buf_raddr'length);
            r_circ_buf_a_re  <= r_mem_sel;
            r_circ_buf_b_re  <= not(r_mem_sel);
            if (w_circ_buf_a_rvalid_out = '1') then
                r_video_rdata <= w_circ_buf_a_rdata;
            elsif (w_circ_buf_b_rvalid_out = '1') then
                r_video_rdata <= w_circ_buf_b_rdata;
            end if;
        end if;
    end process p_readout;
    -- ============================================================================ 
end architecture;