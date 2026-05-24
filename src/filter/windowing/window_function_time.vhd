library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
-- 
use std.textio.all;
-- 
entity window_function_time is
    generic (
        G_INPUT_DATA_WIDTH  : natural := 16;
        G_INPUT_DATA_DEPTH  : natural := 1024;
        G_WINDOW_DATA_WIDTH : natural := 16;
        G_INIT_FILE         : string  := "/mnt/tools/projects/fpga/audio-spectrum-analyzer/src/filter/windowing/window_coefficients.txt"
    );
    port (
        clk : in std_logic;
        -- Input
        i_data_i : in std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        i_data_q : in std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        i_valid  : in std_logic;
        o_ready  : out std_logic;
        -- Ouput
        o_data_i : out std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        o_data_q : out std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        o_valid  : out std_logic;
        o_last   : out std_logic;
        i_ready  : in std_logic
    );
end entity window_function_time;

architecture rtl of window_function_time is
    --------------------
    -- Constants
    --------------------
    --------------------
    -- Types
    --------------------
    type t_array_slv is array (natural range <>) of std_logic_vector;
    --------------------
    -- Functions
    --------------------
    -- The following code either initializes the memory values to a specified file or to all zeros to match hardware
    impure function f_init_from_file return t_array_slv is
        file v_file       : text;
        variable v_line   : line;
        variable v_slv    : std_logic_vector(G_WINDOW_DATA_WIDTH - 1 downto 0);
        variable v_memory : t_array_slv(0 to G_INPUT_DATA_DEPTH - 1)(G_WINDOW_DATA_WIDTH - 1 downto 0);
        variable v_idx    : natural := 0;
    begin
        file_open(v_file, G_INIT_FILE, read_mode);
        v_idx := 0;
        while not endfile(v_file) loop
            readline(v_file, v_line);
            read(v_line, v_slv);
            v_memory(v_idx) := v_slv;
            v_idx           := v_idx + 1;
        end loop;
        file_close(v_file);
        return v_memory;
    end function;
    --------------------
    -- Signals
    --------------------
    signal r_window_mem               : t_array_slv(0 to G_INPUT_DATA_DEPTH - 1)(G_WINDOW_DATA_WIDTH - 1 downto 0) := f_init_from_file;
    signal w_ready_out                : std_logic                                                                  := '0';
    signal r_window_product_i         : signed(G_INPUT_DATA_WIDTH + G_WINDOW_DATA_WIDTH - 1 downto 0)              := (others => '0');
    signal r_window_product_q         : signed(G_INPUT_DATA_WIDTH + G_WINDOW_DATA_WIDTH - 1 downto 0)              := (others => '0');
    signal r_window_product_shifted_i : signed(G_INPUT_DATA_WIDTH - 1 downto 0)                                    := (others => '0');
    signal r_window_product_shifted_q : signed(G_INPUT_DATA_WIDTH - 1 downto 0)                                    := (others => '0');
    signal r_window_value             : std_logic_vector(G_WINDOW_DATA_WIDTH - 1 downto 0)                         := (others => '0');
    signal r_window_product_valid     : std_logic                                                                  := '0';
    signal r_window_product_valid_d1  : std_logic                                                                  := '0';
    signal r_data_last                : std_logic                                                                  := '0';
    signal r_data_last_d1             : std_logic                                                                  := '0';
    signal r_window_raddr             : unsigned(integer(ceil(log2(real(G_INPUT_DATA_DEPTH)))) - 1 downto 0)       := (others => '0');
begin
    -- =======================================================================
    -- Combinatorial
    o_data_i <= std_logic_vector(r_window_product_shifted_i);
    o_data_q <= std_logic_vector(r_window_product_shifted_q);
    o_valid  <= r_window_product_valid_d1;
    o_last   <= r_data_last_d1;
    o_ready  <= w_ready_out;
    -- =======================================================================
    -- Apply window coefficient and shift
    -- Note: BRAM has 1cc read latency
    w_ready_out <= i_ready and not(r_window_product_valid) and not(r_window_product_valid_d1);
    p_apply_window : process (clk)
    begin
        if rising_edge(clk) then
            ----------------
            -- PIPE 1
            ----------------
            r_window_product_i     <= resize(signed(i_data_i) * signed(r_window_value), r_window_product_i'length);
            r_window_product_q     <= resize(signed(i_data_q) * signed(r_window_value), r_window_product_q'length);
            r_window_product_valid <= i_valid and w_ready_out;
            ----------------
            -- PIPE 2
            ----------------
            -- Shift
            r_window_product_shifted_i <= resize(shift_right(r_window_product_i, G_WINDOW_DATA_WIDTH - 1), r_window_product_shifted_i'length);
            r_window_product_shifted_q <= resize(shift_right(r_window_product_q, G_WINDOW_DATA_WIDTH - 1), r_window_product_shifted_q'length);
            r_window_product_valid_d1  <= r_window_product_valid;
            r_data_last_d1             <= r_data_last;
        end if;
    end process p_apply_window;
    -- =======================================================================
    p_addr_generator : process (clk)
    begin
        if rising_edge(clk) then
            r_data_last <= '0';
            if (i_valid = '1') and (w_ready_out = '1') then
                r_window_raddr <= r_window_raddr + 1;
                if (r_window_raddr >= G_INPUT_DATA_DEPTH - 1) then
                    r_data_last    <= '1';
                    r_window_raddr <= (others => '0');
                end if;
            end if;
        end if;
    end process p_addr_generator;
    -- =======================================================================
    p_bram : process (clk)
    begin
        if rising_edge(clk) then
            r_window_value <= r_window_mem(to_integer(r_window_raddr));
        end if;
    end process p_bram;
    -- =======================================================================
end architecture;