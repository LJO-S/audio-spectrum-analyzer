-------------------------------------------------------------------------------
-- Title      : Generic Block RAM
-- Project    : Audio Spectrum Analyzer
-------------------------------------------------------------------------------
-- File       : generic_bram.vhd

-- Library    : 

-- Author     : Ludvig Snihs

-- Company    : 

-- Created    : 2026-05-14

-- Last update: 

-- Platform   : 

-- Standard   : VHDL-2008

-- Description: Generic Block RAM

-- Known TODOs: 
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity generic_bram is
    generic (
        G_DATA_WIDTH : natural;
        G_DATA_DEPTH : natural;
        G_LATENCY    : natural := 1
    );
    port (
        clk : in std_logic;
        -- Write
        i_we    : in std_logic;
        i_wdata : in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        i_waddr : in std_logic_vector(integer(ceil(log2(real(G_DATA_DEPTH)))) - 1 downto 0);
        -- Read
        i_re     : in std_logic := '1';
        i_raddr  : in std_logic_vector(integer(ceil(log2(real(G_DATA_DEPTH)))) - 1 downto 0);
        o_rdata  : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        o_rvalid : out std_logic
    );
end entity generic_bram;

architecture rtl of generic_bram is
    --------------------
    -- Types
    --------------------
    type t_array_slv is array (natural range <>) of std_logic_vector;
    type t_array_of_array_slv is array (natural range <>) of t_array_slv;
    --------------------
    -- Signals
    --------------------
    signal r_memory                 : t_array_slv(0 to G_DATA_DEPTH - 1)(G_DATA_WIDTH - 1 downto 0);
    signal r_output_data_shreg      : t_array_slv(0 to G_LATENCY - 1)(G_DATA_WIDTH - 1 downto 0) := (others => (others => '0'));
    signal r_output_valid_shreg     : std_logic_vector(G_LATENCY - 1 downto 0)                   := (others => '0');
    signal r_rdata                  : std_logic_vector(G_DATA_WIDTH - 1 downto 0)                := (others => '0');
    signal r_rvalid                 : std_logic                                                  := '0';
    attribute ram_style             : string;
    attribute ram_style of r_memory : signal is "block";
begin
    -- ======================================================================= 
    g_latency_syntax : if (G_LATENCY > 1) generate
        ------------------------------------------------------
        o_rdata <= r_output_data_shreg(r_output_data_shreg'high);
        process (clk)
        begin
            if rising_edge(clk) then
                -- Output shreg
                r_output_data_shreg  <= r_rdata & r_output_data_shreg(r_output_data_shreg'low to r_output_data_shreg'high - 1);
                r_output_valid_shreg <= r_output_valid_shreg(r_output_valid_shreg'high - 1 downto r_output_valid_shreg'low) & r_rvalid;
            end if;
        end process;
        ------------------------------------------------------
    else
        generate
            o_rdata  <= r_rdata;
            o_rvalid <= r_rvalid;
            ------------------------------------------------------
        end generate g_latency_syntax;

        -- ======================================================================= 
        p_bram : process (clk)
        begin
            if rising_edge(clk) then
                -- Write
                if (i_we = '1') then
                    r_memory(to_integer(unsigned(i_waddr))) <= i_wdata;
                end if;
                -- Read
                r_rvalid <= '0';
                if (i_re = '1') then
                    r_rdata  <= r_memory(to_integer(unsigned(i_raddr)));
                    r_rvalid <= '1';
                end if;
            end if;
        end process p_bram;
        -- ======================================================================= 
    end architecture;