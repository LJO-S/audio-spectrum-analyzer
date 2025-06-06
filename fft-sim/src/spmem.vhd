
--  Xilinx Single Port No Change RAM
--  This code implements a parameterizable single-port no-change memory where when data is written
--  to the memory, the output remains unchanged.  This is the most power efficient write mode.
--  If a reset or enable is not necessary, it may be tied off or removed from the code.
--  Modify the parameters for the desired RAM characteristics.

-- Following libraries have to be used
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity SPmem is
    generic (
        G_RAM_WIDTH       : integer := 8;               -- Specify RAM data width
        G_RAM_DEPTH       : integer := 64;              -- Specify RAM depth (number of entries)
        G_RAM_PERFORMANCE : string  := "LOW_LATENCY";   -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        G_INIT_FILE       : string  := "sin_15khz_16bits.txt" -- Specify name/location of RAM initialization file if using one (leave blank if not)
    );
    port (
        clk     : in std_logic;
        i_addra : in std_logic_vector(9 downto 0);
        i_dina  : in std_logic_vector(G_RAM_WIDTH - 1 downto 0);
        i_wea   : in std_logic;
        i_ena   : in std_logic;

        o_douta : out std_logic_vector(G_RAM_WIDTH - 1 downto 0)
    );
end entity;

architecture rtl of SPmem is
    -- Note :
    -- If the chosen width and depth values are low, Synthesis will infer Distributed RAM.
    -- C_RAM_DEPTH should be a power of 2
    constant C_RAM_WIDTH       : integer := G_RAM_WIDTH;
    constant C_RAM_DEPTH       : integer := G_RAM_DEPTH;
    constant C_RAM_PERFORMANCE : string  := G_RAM_PERFORMANCE;
    constant C_INIT_FILE       : string  := G_INIT_FILE;
    type ram_type is array (0 to C_RAM_DEPTH - 1) of std_logic_vector (C_RAM_WIDTH - 1 downto 0); -- 2D Array Declaration for RAM signal
    ------------------------------------------------------------------------
    -- The following function calculates the address width based on specified RAM depth
    function clogb2(depth : natural) return integer is
        variable temp         : integer := depth;
        variable ret_val      : integer := 0;
    begin
        while temp > 1 loop
            ret_val := ret_val + 1;
            temp    := temp / 2;
        end loop;
        return ret_val;
    end function;

    ------------------------------------------------------------------------
    -- The following code either initializes the memory values to a specified file or to all zeros to match hardware
    function initramfromfile (ramfilename : in string) return ram_type is
        file ramfile                          : text is in ramfilename;
        variable ramfileline                  : line;
        variable ram_name                     : ram_type;
        variable bitvec                       : bit_vector(C_RAM_WIDTH - 1 downto 0);
    begin
        for i in ram_type'range loop
            readline (ramfile, ramfileline);
            read (ramfileline, bitvec);
            ram_name(i) := to_stdlogicvector(bitvec);
        end loop;
        return ram_name;
    end function;

    ------------------------------------------------------------------------
    function init_from_file_or_zeroes(ramfile : string) return ram_type is
    begin
        if ramfile = C_INIT_FILE then
            return InitRamFromFile(ramfile);
        else
            return (others => (others => '0'));
        end if;
    end;
    ------------------------------------------------------------------------

    signal addra     : std_logic_vector(clogb2(C_RAM_DEPTH) - 1 downto 0);            -- Address bus, width determined from RAM_DEPTH
    signal dina      : std_logic_vector(C_RAM_WIDTH - 1 downto 0);                    -- RAM input data
    signal wea       : std_logic;                                                     -- Write enable
    signal ena       : std_logic;                                                     -- RAM Enable, for additional power savings, disable port when not in use
    signal regcea    : std_logic := '1';                                              -- Output register enable
    signal douta     : std_logic_vector(C_RAM_WIDTH - 1 downto 0);                    -- RAM output data
    signal douta_reg : std_logic_vector(C_RAM_WIDTH - 1 downto 0) := (others => '0'); -- RAM output data when RAM_PERFORMANCE = HIGH_PERFORMANCE
    signal ram_data  : std_logic_vector(C_RAM_WIDTH - 1 downto 0);
    -- Define RAM
    signal ram_data_array : ram_type := init_from_file_or_zeroes(C_INIT_FILE);

begin
    ------------------------------------------------------------------------
    o_douta <= douta;
    dina    <= i_dina;
    addra   <= i_addra;
    wea     <= i_wea;
    ena     <= i_ena;
    ------------------------------------------------------------------------
    process (clk)
    begin
        if rising_edge(clk) then
            if (ena = '1') then
                if (wea = '1') then
                    ram_data_array(to_integer(unsigned(addra))) <= dina;
                else
                    ram_data <= ram_data_array(to_integer(unsigned(addra)));
                end if;
            end if;
        end if;
    end process;
    ------------------------------------------------------------------------

    --  Following code generates LOW_LATENCY (no output register)
    --  Following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
    no_output_register : if C_RAM_PERFORMANCE = "LOW_LATENCY" generate
        douta <= ram_data;
    end generate;
    ------------------------------------------------------------------------

    --  Following code generates HIGH_PERFORMANCE (use output register)
    --  Following is a 2 clock cycle read latency with improved clock-to-out timing
    output_register : if C_RAM_PERFORMANCE = "HIGH_PERFORMANCE" generate
        process (clk)
        begin
            if rising_edge(clk) then
                if (regcea = '1') then
                    douta_reg <= ram_data;
                end if;
            end if;
        end process;
        douta <= douta_reg;
    end generate;
    ------------------------------------------------------------------------
end architecture;
