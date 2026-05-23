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
        G_INIT_FILE         : string
    );
    port (
        clk : in std_logic;
        -- Input
        i_data  : in std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        i_valid : in std_logic;
        i_last  : in std_logic;
        o_ready : out std_logic;
        -- Ouput
        o_data  : out std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        o_valid : out std_logic;
        o_last  : out std_logic
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
    function init_from_file return t_array_slv is
        file ramfile      : text;
        variable v_line   : line;
        variable v_slv    : std_logic_vector(G_INPUT_DATA_WIDTH - 1 downto 0);
        variable v_memory : t_array_slv(0 to G_INPUT_DATA_DEPTH - 1)(G_INPUT_DATA_WIDTH - 1 downto 0);
        variable v_idx    : natural := 0;
    begin
        file_open(ramfile, G_INIT_FILE, read_mode);
        while not endfile(ramfile) loop
            readline(ramfile, v_line);
            read(v_line, v_slv);
            v_memory(v_idx) := v_slv;
            v_idx           := v_idx + 1;
        end loop;
        file_close(ramfile);
        return v_memory;
    end function;
    --------------------
    -- Signals
    --------------------
    signal r_window_mem              : t_array_slv(0 to G_INPUT_DATA_DEPTH - 1)(G_INPUT_DATA_WIDTH - 1 downto 0)    := init_from_file;
    signal r_data_ready_out          : std_logic                                                                    := '0';
    signal r_window_product          : signed(G_INPUT_DATA_WIDTH + G_WINDOW_DATA_WIDTH - 1 downto 0)                := (others => '0');
    signal r_window_product_shifted  : signed(G_INPUT_DATA_WIDTH - 1 downto 0)                                      := (others => '0');
    signal r_window_value            : std_logic_vector(G_WINDOW_DATA_WIDTH - 1 downto 0)                           := (others => '0');
    signal r_window_product_valid    : std_logic                                                                    := '0';
    signal r_window_product_valid_d1 : std_logic                                                                    := '0';
    signal r_window_raddr            : unsigned(integer(ceil(log2(real(G_INPUT_DATA_DEPTH)))) - 1 downto 0) := (others => '0');
begin
    -- =======================================================================
    -- Combinatorial
    o_data  <= std_logic_vector(r_window_product_shifted);
    o_valid <= r_window_product_valid_d1;
    o_ready <= r_data_ready_out;
    -- =======================================================================
    -- Apply window coefficient and shift
    -- Note: BRAM has 1cc read latency
    p_apply_window : process (clk)
    begin
        if rising_edge(clk) then
            ----------------
            -- PIPE 0
            ----------------
            r_data_ready_out       <= not(i_valid); -- handle 1cc read latency
            r_window_product       <= resize(signed(i_data) * signed(r_window_value), r_window_product'length);
            r_window_product_valid <= i_valid and r_data_ready_out;
            ----------------
            -- PIPE 1
            ----------------
            -- Shift
            r_window_product_shifted  <= resize(shift_right(r_window_product, G_WINDOW_DATA_WIDTH), r_window_product_shifted'length);
            r_window_product_valid_d1 <= r_window_product_valid;
        end if;
    end process p_apply_window;
    -- =======================================================================
    p_addr_generator : process (clk)
    begin
        if rising_edge(clk) then
            if (i_valid = '1') then
                r_window_raddr <= r_window_raddr + 1;
                if (i_last = '1') or (r_window_raddr >= G_INPUT_DATA_DEPTH - 1) then
                    r_window_raddr <= (others => '0');
                end if;
            end if;
        end if;
    end process p_addr_generator;
    -- =======================================================================
    p_dp_bram : process (clk)
    begin
        if rising_edge(clk) then
            r_window_value <= r_window_mem(to_integer(r_window_raddr));
        end if;
    end process p_dp_bram;
    -- =======================================================================
end architecture;