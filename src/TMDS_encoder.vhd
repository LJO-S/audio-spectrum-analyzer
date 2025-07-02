library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TMDS_encoder is
    port (
        clk : in std_logic;

        i_video_en   : in std_logic;
        i_CD         : in std_logic_vector(1 downto 0);
        i_video_data : in std_logic_vector(7 downto 0) := (others => '0');

        o_TMDS : out std_logic_vector(9 downto 0)
    );
end entity TMDS_encoder;

architecture rtl of TMDS_encoder is
    signal w_XNOR             : std_logic                    := '0';
    signal w_qm               : std_logic_vector(8 downto 0) := (others => '0');
    signal w_invert_qm        : std_logic                    := '0';
    signal w_invert_qm_vec    : std_logic_vector(7 downto 0) := (others => '0');
    signal w_balance          : signed(4 downto 0)           := (others => '0');
    signal w_balance_sign_eq  : std_logic                    := '0';
    signal w_balance_acc      : signed(4 downto 0)           := (others => '0');
    signal w_balance_acc_incr : signed(4 downto 0)           := (others => '0');
    signal w_balance_acc_new  : signed(4 downto 0)           := (others => '0');
    signal w_TMDS_data        : std_logic_vector(9 downto 0) := (others => '0');
    signal w_balance_zero     : std_logic                    := '0';
    signal w_C1_C0            : std_logic_vector(1 downto 0) := (others => '0');

begin
    --------------------------------------------------------------------
    -- 1. Counting 1s
    p_XOR_XNOR : process (all)
        variable v_number_of_ones : unsigned(3 downto 0) := (others => '0');
    begin
        v_number_of_ones := (others => '0');
        for i in i_video_data'range loop
            v_number_of_ones := v_number_of_ones + i_video_data(i);
        end loop;

        if (v_number_of_ones > 4) or ((v_number_of_ones = 4) and i_video_data(0) = '0') then
            w_XNOR <= '1';
        else
            w_XNOR <= '0';
        end if;
    end process p_XOR_XNOR;
    --------------------------------------------------------------------
    -- 2. Encode 
    p_qm : process (all)
    begin
        if (w_XNOR = '1') then
            w_qm <= '0' & (w_qm(6 downto 0) xnor i_video_data(7 downto 1)) & i_video_data(0);
        else
            w_qm <= '1' & (w_qm(6 downto 0) xor i_video_data(7 downto 1)) & i_video_data(0);
        end if;
    end process p_qm;
    --------------------------------------------------------------------
    -- 3. Need to check DC bias
    p_DC_bias : process (all)
        variable v_balance : signed(4 downto 0) := (others => '0');
    begin
        ----------------------------------------------
        v_balance := "00000" - to_signed(4, v_balance'length); -- 4 zeros, 4 ones
        -- if balance == 0 : balanced
        --    balance > 0  : more 1s
        --    balance < 0  : more 0s
        for i in 0 to 7 loop
            v_balance := v_balance + w_qm(i);
        end loop;
        w_balance <= v_balance;
        ----------------------------------------------
        if (w_balance = 0) or (w_balance_acc = 0) then
            w_invert_qm    <= not w_qm(8);
            w_balance_zero <= '1';
        else
            w_invert_qm    <= w_balance_sign_eq;
            w_balance_zero <= '0';
        end if;
        ----------------------------------------------
    end process p_DC_bias;
    --------------------------------------------------------------------
    -- if cnt(t-1) > 0 --> w_balance_acc > 0 --> w_balance_acc(4) = '0'
    -- if N1 > N0      --> w_balance > 0     --> w_balance(3)     = '0'
    --
    w_balance_sign_eq <= '1' when (w_balance(w_balance'high) = w_balance_acc(w_balance_acc'high)) else
        '0';
    --------------------------------------------------------------------
    -- Four cases
    -- 1. Cnt(t-1)=0 or N1=N0  and w_qm(8)='1':         incr =  (N1 - N0)
    -- 2. Cnt(t-1)=0 or N1=N0  and w_qm(8)='0':         incr = -(N1 - N0)
    -- 3. Cnt(t-1)>0 & N1>N0  or  Cnt(t-1)<0 & N1<N0:   incr = -(N1 - N0) + 2 * w_qm(8)
    -- 4. Else:                                         incr =  (N1 - N0) - 2 * ~w_qm(8)
    -- 
    w_balance_acc_incr <= w_balance - ((w_qm(8) xor (not w_balance_sign_eq)) and not w_balance_zero);

    -- Case 2/3 occurs when w_invert_qm='1' (w_qm(8)='0' or w_balance_sign_eq='1')
    -- Case 1/4 occurs when w_invert_qm='0' (w_qm(8)='1' or w_balance_sign_eq='0')
    w_balance_acc_new <= (w_balance_acc - w_balance_acc_incr) when (w_invert_qm = '1') else
        (w_balance_acc + w_balance_acc_incr);
    --------------------------------------------------------------------
    -- Three cases:
    -- 1. Cnt(t-1)=0 or N1=N0 
    --      --> w_invert_qm <= ~w_qm(8)
    --      --> PSEUDO: q_out(0:7)  = w_qm(0:7) IF w_qm(8)='1' ELSE ~w_qm(0:7)
    --      --> q_out(0:7) <= w_qm(0:7) XOR ~w_qm(8)
    --
    -- 2A. Cnt(t-1)>0 & N1>N0   or    Cnt(t-1)<0 & N1<N0
    --      --> w_invert_qm <= w_balance_sign ('1')
    --      --> PSEUDO: q_out(0:7)  = ~w_qm(0:7)

    -- 2B. None, e.g., Cnt(t-1)<0 & N1>N0
    --      --> w_invert_qm <= w_balance_sign ('0')
    --      --> PSEUDO: q_out(0:7)  = w_qm(0:7)
    --      --> q_out(0:7) <= w_qm(0:7) XOR w_balance_sign;
    --
    w_invert_qm_vec <= (others => w_invert_qm);
    w_TMDS_data     <= w_invert_qm & w_qm(8) & (w_qm(7 downto 0) xor w_invert_qm_vec);
    --------------------------------------------------------------------
    -- 4. Output (clocked)
    p_output : process (clk)
    begin
        if rising_edge(clk) then
            if (i_video_en = '1') then
                o_TMDS <= w_TMDS_data;

                -- Cnt(t-1)
                w_balance_acc <= w_balance_acc_new;
            else
                w_balance_acc <= (others => '0');
                w_C1_C0 <= i_CD;
                case w_C1_C0 is
                    when "00" =>
                        o_TMDS <= "1101010100";
                    when "01" =>
                        o_TMDS <= "0010101011";
                    when "10" =>
                        o_TMDS <= "0101010100";
                    when "11" =>
                        o_TMDS <= "1010101011";
                    when others =>
                        -- 00 case
                        o_TMDS <= "1101010100";
                end case;
            end if;
        end if;
    end process p_output;
    --------------------------------------------------------------------
end architecture;