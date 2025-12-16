-- ============================================================================ 
-- Spectrum palette ROM:
-- Maps input data to 8-bit RGB ROM  
-- 
-- 1 cc latency
-- ============================================================================ 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
entity spectrum_palette_rom is
    port (
        clk : in std_logic;
        en  : in std_logic;
        -- In
        i_addr : in std_logic_vector(7 downto 0);
        -- Out
        o_red : out std_logic_vector(7 downto 0);
        o_grn : out std_logic_vector(7 downto 0);
        o_blu : out std_logic_vector(7 downto 0)
    );
end entity spectrum_palette_rom;

architecture rtl of spectrum_palette_rom is
    type t_palette_rom is array (0 to 255) of std_logic_vector(23 downto 0);
    signal r_palette_rom : t_palette_rom := (
    x"0d0887", -- #0d0887
    x"100788", -- #100788
    x"130789", -- #130789
    x"16078a", -- #16078a
    x"19068c", -- #19068c
    x"1b068d", -- #1b068d
    x"1d068e", -- #1d068e
    x"20068f", -- #20068f
    x"220690", -- #220690
    x"240691", -- #240691
    x"260591", -- #260591
    x"280592", -- #280592
    x"2a0593", -- #2a0593
    x"2c0594", -- #2c0594
    x"2e0595", -- #2e0595
    x"2f0596", -- #2f0596
    x"310597", -- #310597
    x"330597", -- #330597
    x"350498", -- #350498
    x"370499", -- #370499
    x"38049a", -- #38049a
    x"3a049a", -- #3a049a
    x"3c049b", -- #3c049b
    x"3e049c", -- #3e049c
    x"3f049c", -- #3f049c
    x"41049d", -- #41049d
    x"43039e", -- #43039e
    x"44039e", -- #44039e
    x"46039f", -- #46039f
    x"48039f", -- #48039f
    x"4903a0", -- #4903a0
    x"4b03a1", -- #4b03a1
    x"4c02a1", -- #4c02a1
    x"4e02a2", -- #4e02a2
    x"5002a2", -- #5002a2
    x"5102a3", -- #5102a3
    x"5302a3", -- #5302a3
    x"5502a4", -- #5502a4
    x"5601a4", -- #5601a4
    x"5801a4", -- #5801a4
    x"5901a5", -- #5901a5
    x"5b01a5", -- #5b01a5
    x"5c01a6", -- #5c01a6
    x"5e01a6", -- #5e01a6
    x"6001a6", -- #6001a6
    x"6100a7", -- #6100a7
    x"6300a7", -- #6300a7
    x"6400a7", -- #6400a7
    x"6600a7", -- #6600a7
    x"6700a8", -- #6700a8
    x"6900a8", -- #6900a8
    x"6a00a8", -- #6a00a8
    x"6c00a8", -- #6c00a8
    x"6e00a8", -- #6e00a8
    x"6f00a8", -- #6f00a8
    x"7100a8", -- #7100a8
    x"7201a8", -- #7201a8
    x"7401a8", -- #7401a8
    x"7501a8", -- #7501a8
    x"7701a8", -- #7701a8
    x"7801a8", -- #7801a8
    x"7a02a8", -- #7a02a8
    x"7b02a8", -- #7b02a8
    x"7d03a8", -- #7d03a8
    x"7e03a8", -- #7e03a8
    x"8004a8", -- #8004a8
    x"8104a7", -- #8104a7
    x"8305a7", -- #8305a7
    x"8405a7", -- #8405a7
    x"8606a6", -- #8606a6
    x"8707a6", -- #8707a6
    x"8808a6", -- #8808a6
    x"8a09a5", -- #8a09a5
    x"8b0aa5", -- #8b0aa5
    x"8d0ba5", -- #8d0ba5
    x"8e0ca4", -- #8e0ca4
    x"8f0da4", -- #8f0da4
    x"910ea3", -- #910ea3
    x"920fa3", -- #920fa3
    x"9410a2", -- #9410a2
    x"9511a1", -- #9511a1
    x"9613a1", -- #9613a1
    x"9814a0", -- #9814a0
    x"99159f", -- #99159f
    x"9a169f", -- #9a169f
    x"9c179e", -- #9c179e
    x"9d189d", -- #9d189d
    x"9e199d", -- #9e199d
    x"a01a9c", -- #a01a9c
    x"a11b9b", -- #a11b9b
    x"a21d9a", -- #a21d9a
    x"a31e9a", -- #a31e9a
    x"a51f99", -- #a51f99
    x"a62098", -- #a62098
    x"a72197", -- #a72197
    x"a82296", -- #a82296
    x"aa2395", -- #aa2395
    x"ab2494", -- #ab2494
    x"ac2694", -- #ac2694
    x"ad2793", -- #ad2793
    x"ae2892", -- #ae2892
    x"b02991", -- #b02991
    x"b12a90", -- #b12a90
    x"b22b8f", -- #b22b8f
    x"b32c8e", -- #b32c8e
    x"b42e8d", -- #b42e8d
    x"b52f8c", -- #b52f8c
    x"b6308b", -- #b6308b
    x"b7318a", -- #b7318a
    x"b83289", -- #b83289
    x"ba3388", -- #ba3388
    x"bb3488", -- #bb3488
    x"bc3587", -- #bc3587
    x"bd3786", -- #bd3786
    x"be3885", -- #be3885
    x"bf3984", -- #bf3984
    x"c03a83", -- #c03a83
    x"c13b82", -- #c13b82
    x"c23c81", -- #c23c81
    x"c33d80", -- #c33d80
    x"c43e7f", -- #c43e7f
    x"c5407e", -- #c5407e
    x"c6417d", -- #c6417d
    x"c7427c", -- #c7427c
    x"c8437b", -- #c8437b
    x"c9447a", -- #c9447a
    x"ca457a", -- #ca457a
    x"cb4679", -- #cb4679
    x"cc4778", -- #cc4778
    x"cc4977", -- #cc4977
    x"cd4a76", -- #cd4a76
    x"ce4b75", -- #ce4b75
    x"cf4c74", -- #cf4c74
    x"d04d73", -- #d04d73
    x"d14e72", -- #d14e72
    x"d24f71", -- #d24f71
    x"d35171", -- #d35171
    x"d45270", -- #d45270
    x"d5536f", -- #d5536f
    x"d5546e", -- #d5546e
    x"d6556d", -- #d6556d
    x"d7566c", -- #d7566c
    x"d8576b", -- #d8576b
    x"d9586a", -- #d9586a
    x"da5a6a", -- #da5a6a
    x"da5b69", -- #da5b69
    x"db5c68", -- #db5c68
    x"dc5d67", -- #dc5d67
    x"dd5e66", -- #dd5e66
    x"de5f65", -- #de5f65
    x"de6164", -- #de6164
    x"df6263", -- #df6263
    x"e06363", -- #e06363
    x"e16462", -- #e16462
    x"e26561", -- #e26561
    x"e26660", -- #e26660
    x"e3685f", -- #e3685f
    x"e4695e", -- #e4695e
    x"e56a5d", -- #e56a5d
    x"e56b5d", -- #e56b5d
    x"e66c5c", -- #e66c5c
    x"e76e5b", -- #e76e5b
    x"e76f5a", -- #e76f5a
    x"e87059", -- #e87059
    x"e97158", -- #e97158
    x"e97257", -- #e97257
    x"ea7457", -- #ea7457
    x"eb7556", -- #eb7556
    x"eb7655", -- #eb7655
    x"ec7754", -- #ec7754
    x"ed7953", -- #ed7953
    x"ed7a52", -- #ed7a52
    x"ee7b51", -- #ee7b51
    x"ef7c51", -- #ef7c51
    x"ef7e50", -- #ef7e50
    x"f07f4f", -- #f07f4f
    x"f0804e", -- #f0804e
    x"f1814d", -- #f1814d
    x"f1834c", -- #f1834c
    x"f2844b", -- #f2844b
    x"f3854b", -- #f3854b
    x"f3874a", -- #f3874a
    x"f48849", -- #f48849
    x"f48948", -- #f48948
    x"f58b47", -- #f58b47
    x"f58c46", -- #f58c46
    x"f68d45", -- #f68d45
    x"f68f44", -- #f68f44
    x"f79044", -- #f79044
    x"f79143", -- #f79143
    x"f79342", -- #f79342
    x"f89441", -- #f89441
    x"f89540", -- #f89540
    x"f9973f", -- #f9973f
    x"f9983e", -- #f9983e
    x"f99a3e", -- #f99a3e
    x"fa9b3d", -- #fa9b3d
    x"fa9c3c", -- #fa9c3c
    x"fa9e3b", -- #fa9e3b
    x"fb9f3a", -- #fb9f3a
    x"fba139", -- #fba139
    x"fba238", -- #fba238
    x"fca338", -- #fca338
    x"fca537", -- #fca537
    x"fca636", -- #fca636
    x"fca835", -- #fca835
    x"fca934", -- #fca934
    x"fdab33", -- #fdab33
    x"fdac33", -- #fdac33
    x"fdae32", -- #fdae32
    x"fdaf31", -- #fdaf31
    x"fdb130", -- #fdb130
    x"fdb22f", -- #fdb22f
    x"fdb42f", -- #fdb42f
    x"fdb52e", -- #fdb52e
    x"feb72d", -- #feb72d
    x"feb82c", -- #feb82c
    x"feba2c", -- #feba2c
    x"febb2b", -- #febb2b
    x"febd2a", -- #febd2a
    x"febe2a", -- #febe2a
    x"fec029", -- #fec029
    x"fdc229", -- #fdc229
    x"fdc328", -- #fdc328
    x"fdc527", -- #fdc527
    x"fdc627", -- #fdc627
    x"fdc827", -- #fdc827
    x"fdca26", -- #fdca26
    x"fdcb26", -- #fdcb26
    x"fccd25", -- #fccd25
    x"fcce25", -- #fcce25
    x"fcd025", -- #fcd025
    x"fcd225", -- #fcd225
    x"fbd324", -- #fbd324
    x"fbd524", -- #fbd524
    x"fbd724", -- #fbd724
    x"fad824", -- #fad824
    x"fada24", -- #fada24
    x"f9dc24", -- #f9dc24
    x"f9dd25", -- #f9dd25
    x"f8df25", -- #f8df25
    x"f8e125", -- #f8e125
    x"f7e225", -- #f7e225
    x"f7e425", -- #f7e425
    x"f6e626", -- #f6e626
    x"f6e826", -- #f6e826
    x"f5e926", -- #f5e926
    x"f5eb27", -- #f5eb27
    x"f4ed27", -- #f4ed27
    x"f3ee27", -- #f3ee27
    x"f3f027", -- #f3f027
    x"f2f227", -- #f2f227
    x"f1f426", -- #f1f426
    x"f1f525", -- #f1f525
    x"f0f724", -- #f0f724
    x"f0f921"  -- #f0f921
    );
begin
    -- ============================================================================ 
    p_conv_data_to_color : process (clk)
        variable v_color : std_logic_vector(23 downto 0);
    begin
        if rising_edge(clk) then
            if (en = '1') then
                v_color := r_palette_rom(to_integer(unsigned(i_addr)));
                o_red <= v_color(23 downto 16);
                o_grn <= v_color(15 downto 8);
                o_blu <= v_color(7 downto 0);
            else
                o_red <= (others => '0');
                o_grn <= (others => '0');
                o_blu <= (others => '0');
            end if;
        end if;
    end process p_conv_data_to_color;
    -- ============================================================================ 
end architecture;