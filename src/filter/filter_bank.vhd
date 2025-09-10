-- ------------------------------------------------------------------
-- FIR Filter bank
-- Holds a LPF and a HPF that can be used together or separately.
-- The filter coefficients are written down to PL from the PS.
--                                                            
--                            IP                     IP            IP
--                      +--------------+           +-----+       +-----+               
--    +-----+         +---------------+|           |LPF  |       |HPF  |                                       
--    |     |========>| AXI BRAM ctrl | =======>   |BRAM |       |BRAM |                                                     
--    | PS  |         +---------------+            +-----+       +-----+                                  
--    |     |         +----------+                    |            |                  
--    |     |<========| AXI GPIO |-+             +----|------------|------+    
--    |     |         +----------+ |             |    V   Filters  V      |            
--    +-----+           +----------+             | +-----+       +-----+  |             
--                        /\                     | |FIR  |======>|FIR  |=======>            
--                        || LPF incr/decr       | +-----+       +-----+  | 
--                        || HPF incr/decr       +------------------------+           
-- ------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity filter_bank is
    generic (
        G_NBR_OF_TAPS : positive := 101;
        G_QFORMAT     : positive := 15;
        G_INPUT_WIDTH : positive := 16;
        G_COEFF_WIDTH : positive := 16
    );
    port (
        clk_25 : in std_logic;
        -----------------------------------------
        -- RTL Ctrl
        i_lpf_en : in std_logic;
        i_hpf_en : in std_logic;
        -----------------------------------------
        -- from ADC
        i_tvalid : in std_logic;
        i_tdata  : in std_logic_vector(15 downto 0);
        --------------------------------------
        -- PS-to-PL
        -- LPF
        i_new_data_strobe_lpf : in std_logic;
        o_updating_coeffs_lpf : out std_logic;
        o_raddr_lpf           : out unsigned(6 downto 0);
        i_rdata_lpf           : in std_logic_vector(G_COEFF_WIDTH - 1 downto 0);
        -- HPF
        i_new_data_strobe_hpf : in std_logic;
        o_updating_coeffs_hpf : out std_logic;
        o_raddr_hpf           : out unsigned(6 downto 0);
        i_rdata_hpf           : in std_logic_vector(G_COEFF_WIDTH - 1 downto 0);
        -----------------------------------------
        -- to Audio Buffer
        o_tvalid : out std_logic;
        o_tdata  : out std_logic_vector(15 downto 0)
    );
end entity filter_bank;

architecture rtl of filter_bank is
    signal w_tvalid_lpf_in  : std_logic;
    signal w_tdata_lpf_in   : std_logic_vector(15 downto 0);
    signal w_tvalid_lpf_out : std_logic;
    signal w_tdata_lpf_out  : std_logic_vector(15 downto 0);

    signal w_tvalid_connector_0 : std_logic;
    signal w_tdata_connector_0  : std_logic_vector(15 downto 0);

    signal w_tvalid_hpf_in  : std_logic;
    signal w_tdata_hpf_in   : std_logic_vector(15 downto 0);
    signal w_tvalid_hpf_out : std_logic;
    signal w_tdata_hpf_out  : std_logic_vector(15 downto 0);
begin
    -- ==============================================================
    -- Mux between processes
    -- 
    --            lpf_en='0'                   hpf_en='0'
    --         ---------------              ---------------  
    --        /               \            /               \   
    -- -->>--X                 X----------X                 X-->>-- 
    --        \    +-----+    /            \    +-----+    /    
    --         ----| LPF |----              ----| HPF |----
    --             +-----+                      +-----+
    --            lpf_en='1'                    hpf_en='1'                          
    -- 
    -- 
    p_path_selector : process (clk_25)
    begin
        if rising_edge(clk_25) then
            -- LPF path
            if (i_lpf_en = '1') then
                w_tvalid_lpf_in      <= i_tvalid;
                w_tdata_lpf_in       <= i_tdata;
                w_tvalid_connector_0 <= w_tvalid_lpf_out;
                w_tdata_connector_0  <= w_tdata_lpf_out;
            else
                w_tvalid_lpf_in      <= '0';
                w_tdata_lpf_in       <= (others => 'X');
                w_tvalid_connector_0 <= i_tvalid;
                w_tdata_connector_0  <= i_tdata;
            end if;

            -- HPF path
            if (i_hpf_en = '1') then
                w_tvalid_hpf_in <= w_tvalid_connector_0;
                w_tdata_hpf_in  <= w_tdata_connector_0;
                o_tvalid        <= w_tvalid_hpf_out;
                o_tdata         <= w_tdata_hpf_out;
            else
                w_tvalid_hpf_in <= '0';
                w_tdata_hpf_in  <= (others => 'X');
                o_tvalid        <= w_tvalid_connector_0;
                o_tdata         <= w_tdata_connector_0;
            end if;
        end if;
    end process p_path_selector;
    -- ==============================================================
    lpf_inst : entity work.fir_filter
        generic map(
            G_NBR_OF_TAPS => G_NBR_OF_TAPS,
            G_QFORMAT     => G_QFORMAT,
            G_INPUT_WIDTH => G_INPUT_WIDTH,
            G_COEFF_WIDTH => G_COEFF_WIDTH
        )
        port map
        (
            clk_25            => clk_25,
            i_new_data_strobe => i_new_data_strobe_lpf,
            o_updating_coeffs => o_updating_coeffs_lpf,
            o_raddr           => o_raddr_lpf,
            i_rdata           => i_rdata_lpf,
            i_tvalid          => w_tvalid_lpf_in,
            i_tdata           => w_tdata_lpf_in,
            o_tvalid          => w_tvalid_lpf_out,
            o_tdata           => w_tdata_lpf_out
        );
    -- ==============================================================
    hpf_inst : entity work.fir_filter
        generic map(
            G_NBR_OF_TAPS => G_NBR_OF_TAPS,
            G_QFORMAT     => G_QFORMAT,
            G_INPUT_WIDTH => G_INPUT_WIDTH,
            G_COEFF_WIDTH => G_COEFF_WIDTH
        )
        port map
        (
            clk_25            => clk_25,
            i_new_data_strobe => i_new_data_strobe_hpf,
            o_updating_coeffs => o_updating_coeffs_hpf,
            o_raddr           => o_raddr_hpf,
            i_rdata           => i_rdata_hpf,
            i_tvalid          => w_tvalid_hpf_in,
            i_tdata           => w_tdata_hpf_in,
            o_tvalid          => w_tvalid_hpf_out,
            o_tdata           => w_tdata_hpf_out
        );
    -- ==============================================================
end architecture;
