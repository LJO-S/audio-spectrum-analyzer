library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity audio_buffer is
    port (
        clk_25 : in std_logic;
        -- From CTRL logic
        i_capture_en : in std_logic;
        -- I2S Deser I/F
        i_pdata : in std_logic_vector(15 downto 0);
        i_valid : in std_logic;
        -- FFT I/F
        o_tdata  : out std_logic_vector(15 downto 0);
        o_tvalid : out std_logic;
        o_tlast  : out std_logic;
        i_tready : in std_logic
    );
end entity audio_buffer;

architecture rtl of audio_buffer is
    constant C_MAX_MEM_IDX : natural := 1023;

    type t_fill_drain is (IDLE, FILLING, DRAINING);
    signal s_buffer_state : t_fill_drain := IDLE;

    signal r_addr   : unsigned(9 downto 0)          := (others => '0');
    signal r_tvalid : std_logic                     := '0';
    signal r_tlast  : std_logic                     := '0';
    signal r_we     : std_logic                     := '0';
    signal r_din    : std_logic_vector(15 downto 0) := (others => 'X');
    signal w_tdata  : std_logic_vector(15 downto 0);

begin
    /* ------------------------------------------------------------- */
    process (clk_25)
    begin
        if rising_edge(clk_25) then
            r_tvalid <= '0';
            r_we     <= '0';
            case s_buffer_state is
                    -- ---------------------------------------------------------------
                when IDLE =>
                    r_tlast <= '0';
                    r_addr  <= (others => '0');
                    if (i_capture_en = '1') then
                        s_buffer_state <= FILLING;
                    end if;
                    -- ---------------------------------------------------------------
                when FILLING =>
                    -- Should strobe @ 48 kHz
                    if (i_valid = '1') then
                        r_we  <= '1';
                        r_din <= i_pdata;
                    end if;
                    -- Incr write address
                    if (r_we = '1') then
                        r_addr <= r_addr + 1;
                        -- If r_addr = 1023 memory is filled
                        if (r_addr >= C_MAX_MEM_IDX) then
                            r_addr         <= (others => '0');
                            s_buffer_state <= DRAINING;
                        end if;
                    end if;
                    -- ---------------------------------------------------------------
                when DRAINING =>
                    r_tvalid <= '1';
                    -- Only incr address if both MASTR is valid and SLAVE is ready 
                    if (r_tvalid = '1') and (i_tready = '1') then
                        r_addr <= r_addr + 1;
                        if (r_addr >= C_MAX_MEM_IDX) then
                            r_tvalid       <= '0';
                            r_tlast        <= '0';
                            r_addr         <= (others => '0');
                            s_buffer_state <= FILLING;
                        elsif (r_addr >= C_MAX_MEM_IDX - 1) then
                            r_tlast <= '1';
                        end if;
                    end if;
                    -- ---------------------------------------------------------------
                when others =>
                    s_buffer_state <= IDLE;
            end case;
            if (i_capture_en = '0') then
                s_buffer_state <= IDLE;
            end if;
        end if;
    end process;
    /* ------------------------------------------------------------- */
    -- p_output : process (clk_25)
    -- begin
    -- if rising_edge(clk_25) then
    -- o_tdata  <= w_tdata;
    -- o_tvalid <= r_tvalid;
    -- o_tlast  <= r_tlast;
    -- end if;
    -- end process p_output;
    o_tdata  <= w_tdata;
    o_tvalid <= r_tvalid;
    o_tlast  <= r_tlast;
    /* ------------------------------------------------------------- */
    -- Single Port RAM (vivado infers BlockRAM)
    /* ------------------------------------------------------------- */
    SPmem_inst : entity work.SPmem
        generic map(
            G_RAM_WIDTH       => 16,
            G_RAM_DEPTH       => 1024,
            G_RAM_PERFORMANCE => "LOW_LATENCY",
            G_DO_NOT_PRELOAD  => '1'
        )
        port map
        (
            clk     => clk_25,
            i_addra => std_logic_vector(r_addr),
            i_dina  => r_din,
            i_wea   => r_we,
            o_douta => w_tdata
        );
    /* ------------------------------------------------------------- */
end architecture;