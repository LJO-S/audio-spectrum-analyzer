library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
-- 
use work.project_common_pkg.all;
--
library vunit_lib;
context vunit_lib.vunit_context;

entity trigger_capture_tb is
    generic (
        runner_cfg : string
    );
end;

architecture bench of trigger_capture_tb is
    -- Types
    type t_capture_state is (IDLE, ARMED, CAPTURE, HOLD_OFF);
    type t_testbench_check_state is (INIT, WAIT_1, WAIT_2, COMPARE, INCREMENT_RADDR, FINISH_HOLD_OFF);
    -- Clock period
    constant clk_period : time := 5 ns;
    -- Generics
    constant G_DATA_WIDTH  : natural := 16;
    constant G_DATA_DEPTH  : natural := C_SPECTRUM_X_UPPER;
    constant C_MS_COUNT    : natural := 1000;
    constant C_HOLD_OFF_MS : natural := 10;
    -- Ports
    signal clk            : std_logic := '0';
    signal i_audio_tdata  : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal i_audio_tvalid : std_logic;
    signal i_video_raddr  : std_logic_vector(integer(ceil(log2(real(G_DATA_DEPTH)))) - 1 downto 0);
    signal o_video_rdata  : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    -- Testbench
    signal tb_ms_cnt     : integer := 0;
    signal tb_ms_strobe  : std_logic;
    signal tb_sin_tdata  : signed(G_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal tb_sin_tvalid : std_logic                         := '0';
    -- Sin generator controls: frequency in radians/sample, noise amplitude in [0.0, 1.0]
    signal tb_sin_freq  : real := 1.0;
    signal tb_noise_amp : real := 0.0;
    type t_shadow is array (0 to (2 ** integer(ceil(log2(real(G_DATA_DEPTH))))) - 1) of std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    signal tb_shadow_mem_a        : t_shadow := (others => (others => 'U'));
    signal tb_shadow_mem_b        : t_shadow := (others => (others => 'U'));
    signal tb_capture_state       : t_capture_state;
    signal tb_check_state         : t_testbench_check_state;
    signal tb_holdoff_count       : integer   := 0;
    signal tb_trigger_count       : integer   := 0;
    signal tb_start               : std_logic := '0';
    signal tb_sin_variation_timer : integer   := 0;
    signal tb_video_start_raddr   : std_logic_vector(integer(ceil(log2(real(G_DATA_DEPTH)))) - 1 downto 0);
    -- Procedure
    procedure wait_clock (clk_ticks : integer) is
    begin
        for i in 0 to clk_ticks - 1 loop
            wait until rising_edge(clk);
        end loop;
    end procedure;
begin
    -- ======================================================================
    clk <= not clk after clk_period/2;
    -- ======================================================================
    p_shadow_mem : process (clk)
        alias alias_capture_state is << signal .trigger_capture_tb.trigger_capture_inst.s_capture_state       : t_capture_state >> ;
        alias alias_raddr_start_addr is << signal .trigger_capture_tb.trigger_capture_inst.r_raddr_start_addr : unsigned(integer(ceil(log2(real(G_DATA_DEPTH)))) - 1 downto 0) >> ;
        alias alias_mem_sel is << signal .trigger_capture_tb.trigger_capture_inst.r_mem_sel                   : std_logic >> ;
        alias alias_circ_buf_waddr is << signal .trigger_capture_tb.trigger_capture_inst.r_circ_buf_waddr     : unsigned(integer(ceil(log2(real(G_DATA_DEPTH)))) - 1 downto 0) >> ;
        variable v_raddr                                                                                      : unsigned(integer(ceil(log2(real(G_DATA_DEPTH)))) - 1 downto 0) := (others => '0');
        variable v_expected                                                                                   : std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    begin
        if rising_edge(clk) then
            --------------------------
            -- Shadow Memory Write
            --------------------------
            if (i_audio_tvalid = '1') then
                if (alias_mem_sel = '0') then
                    tb_shadow_mem_a(to_integer(alias_circ_buf_waddr)) <= i_audio_tdata;
                elsif (alias_mem_sel = '1') then
                    tb_shadow_mem_b(to_integer(alias_circ_buf_waddr)) <= i_audio_tdata;
                end if;
            end if;
            --------------------------
            -- Monitor State
            --------------------------
            tb_ms_strobe     <= '0';
            tb_capture_state <= alias_capture_state;
            case tb_check_state is
                when INIT =>
                    i_video_raddr <= tb_video_start_raddr;
                    if (alias_capture_state = HOLD_OFF) and (tb_capture_state = CAPTURE) then
                        -- Capture done!
                        tb_check_state <= WAIT_1;
                    end if;
                when WAIT_1 =>
                    tb_check_state <= WAIT_2;
                when WAIT_2 =>
                    tb_check_state <= COMPARE;
                when COMPARE =>
                    v_raddr := resize(unsigned(i_video_raddr) + alias_raddr_start_addr, v_raddr'length);
                    if (alias_mem_sel = '0') then
                        v_expected := tb_shadow_mem_b(to_integer(v_raddr));
                    else
                        v_expected := tb_shadow_mem_a(to_integer(v_raddr));
                    end if;
                    check(
                    o_video_rdata = v_expected,
                    "Data mismatch! Actual=" &
                    integer'image(to_integer(signed(o_video_rdata))) &
                    " vs Expected=" &
                    integer'image(to_integer(signed(v_expected)))
                    );
                    i_video_raddr  <= std_logic_vector(unsigned(i_video_raddr) + 1);
                    tb_check_state <= INCREMENT_RADDR;
                when INCREMENT_RADDR =>
                    tb_check_state <= WAIT_1;
                    if (unsigned(i_video_raddr) - unsigned(tb_video_start_raddr) >= C_SPECTRUM_X_UPPER) then
                        tb_check_state <= FINISH_HOLD_OFF;
                    end if;
                when FINISH_HOLD_OFF =>
                    -- Generate some ms strobes here
                    tb_ms_cnt <= tb_ms_cnt + 1;
                    if (tb_ms_cnt >= C_MS_COUNT - 1) then
                        tb_ms_cnt        <= 0;
                        tb_ms_strobe     <= '1';
                        tb_holdoff_count <= tb_holdoff_count + 1;
                        if (tb_holdoff_count >= C_HOLD_OFF_MS - 1) then
                            tb_holdoff_count <= 0;
                            tb_trigger_count <= tb_trigger_count + 1;
                            tb_check_state   <= INIT;
                        end if;
                    end if;
                when others =>
                    tb_check_state <= INIT;
            end case;
        end if;
    end process p_shadow_mem;
    -- ======================================================================
    -- Sine Generator
    p_sin_gen : process (clk)
        variable v_sin_phase      : real     := 0.0;
        variable v_noise_seed1    : positive := 1;
        variable v_noise_seed2    : positive := 2;
        variable v_noise          : real     := 0.0;
        variable v_sample         : real     := 0.0;
        variable v_seed1, v_seed2 : integer  := 999;
        impure function f_rand_int (
            min_val : integer;
            max_val : integer
        ) return integer is
            variable v_real : real;
        begin
            uniform(v_seed1, v_seed2, v_real);
            return integer(
            round(v_real * real(max_val - min_val + 1) + real(min_val) - 0.5)
            );
        end function;
    begin
        if rising_edge(clk) then
            v_sin_phase := (v_sin_phase + tb_sin_freq) mod MATH_2_PI;
            uniform(v_noise_seed1, v_noise_seed2, v_noise);
            -- uniform returns [0,1); centre and scale to [-tb_noise_amp, +tb_noise_amp]
            v_sample := sin(v_sin_phase) + (v_noise * 2.0 - 1.0) * tb_noise_amp;
            -- Clamp to [-1, 1] before scaling to avoid overflow
            if v_sample > 1.0 then
                v_sample := 1.0;
            elsif v_sample <- 1.0 then
                v_sample := - 1.0;
            end if;
            tb_sin_tdata  <= to_signed(integer(v_sample * real(2 ** (G_DATA_WIDTH - 1) - 1)), G_DATA_WIDTH);
            tb_sin_tvalid <= tb_start;

            if (tb_start = '1') then
                tb_sin_variation_timer <= tb_sin_variation_timer + 1;
                if (tb_sin_variation_timer >= C_SPECTRUM_X_UPPER / 4 - 1) then
                    tb_sin_variation_timer <= 0;
                    tb_sin_freq            <= real(f_rand_int(1, 99)) / 100.0;
                    tb_noise_amp           <= real(f_rand_int(1, 70)) / 100.0; -- low frequency
                end if;
            end if;
        end if;
    end process p_sin_gen;
    -- ======================================================================
    i_audio_tdata  <= std_logic_vector(tb_sin_tdata);
    i_audio_tvalid <= tb_sin_tvalid;
    -- ======================================================================
    trigger_capture_inst : entity work.trigger_capture
        generic map(
            G_DATA_WIDTH  => G_DATA_WIDTH,
            G_DATA_DEPTH  => G_DATA_DEPTH,
            G_HOLD_OFF_MS => C_HOLD_OFF_MS
        )
        port map
        (
            clk           => clk,
            i_ms_strobe   => tb_ms_strobe,
            i_audio_data  => i_audio_tdata,
            i_audio_valid => i_audio_tvalid,
            i_video_raddr => i_video_raddr,
            o_video_rdata => o_video_rdata
        );
    -- ======================================================================
    main : process
    begin
        test_runner_setup(runner, runner_cfg);
        if run("auto-capture") then
            -- Init
            wait until clk = '1';
            tb_video_start_raddr <= (others => '0');
            tb_start             <= '1';
            wait until tb_trigger_count = 10;
        elsif run("auto-wraparound") then
            -- Init
            wait until clk = '1';
            tb_video_start_raddr <= std_logic_vector(to_unsigned(C_SPECTRUM_X_UPPER/2, tb_video_start_raddr'length));
            tb_start             <= '1';
            wait until tb_trigger_count = 10;
        end if;
        test_runner_cleanup(runner);
    end process main;
    -- ======================================================================
end;