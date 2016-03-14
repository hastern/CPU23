library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;

entity T_ALU_TEST is
end entity;

architecture Test of T_ALU_TEST is

    constant PERIOD : time := 20 ps;
    signal CLOCK : std_logic;
    signal RESET : std_logic;

    signal OP : OpCode23;
    signal REG_A : Word23;
    signal REG_B : Word23;
    signal REG_D : Word23;
    signal CST   : Constant23;
    signal FLAG_O : std_logic;
    signal FLAG_U : std_logic;
    signal FLAG_Z : std_logic;
    signal FLAG_T : std_logic;
    signal FLAG_C : std_logic;
    signal FLAG_E : std_logic;
    signal FLAG_L : std_logic;
    signal FLAG_G : std_logic;

begin

    DUT: ENTITY work.E_ALU_CORE(A_ALU_CORE)
        port map(
            op => OP,
            a => REG_A,
            b => REG_B,
            c => CST,
            result => REG_D,
            flag_overflow  => FLAG_O,
            flag_underflow => FLAG_U,
            flag_zero      => FLAG_Z,
            flag_true      => FLAG_T,
            flag_carry     => FLAG_C,
            flag_equal     => FLAG_E,
            flag_lesser    => FLAG_L,
            flag_greater   => FLAG_G,
            clk => CLOCK,
            rst => RESET
        );

    generateclock : process
    begin
        CLOCK <= '0';
        wait for PERIOD/2;
        CLOCK <= '1';
        wait for PERIOD/2;
    end process;

    function_test: process
    begin
        RESET <= '0';
        wait for PERIOD;
        report "Operation CPR";
        OP <= "00011";
        REG_A <= "001001001001100010011101";
        REG_B <= "000100110010011100011000";
        CST <= "000000000011";
        wait for PERIOD;
        assert REG_D = "001001001001100010011101"
            report "CPR Failed";
        report "Operation SET";
        OP <= "00100";
        REG_A <= "001001001001100010011101";
        REG_B <= "000100110010011100011000";
        CST <= "000000000011";
        wait for PERIOD;
        assert REG_D = "000000000000000000000011"
            report "SET Failed";
        report "Operation BIT";
        OP <= "00101";
        REG_A <= "001001001001100010011101";
        REG_B <= "000100110010011100011000";
        CST <= "000000100101";
        wait for PERIOD;
        assert REG_D = "001001001001100010111101"
            report "BIT (1) Failed";
        REG_A <= "001001001001100010011101";
        REG_B <= "000100110010011100011000";
        CST <= "000000000011";
        wait for PERIOD;
        assert REG_D = "001001001001100010010101"
            report "BIT (2) Failed";
        report "Operation ADD";
        OP <= "00110";
        REG_A <= "001001001001100010011101";
        REG_B <= "000100110010011100011000";
        CST <= "000000000011";
        wait for PERIOD;
        assert REG_D = "001101111011111110110101"
            report "ADD Failed";
        report "Operation SUB";
        OP <= "00111";
        REG_A <= "001001001001100010011101";
        REG_B <= "000100110010011100011000";
        CST <= "000000000011";
        wait for PERIOD;
        assert REG_D = "000100010111000110000101"
            report "SUB Failed";
        report "Operation LSL";
        OP <= "01000";
        REG_A <= "001001001001100010011101";
        REG_B <= "000100110010011100011000";
        CST <= "000000000011";
        wait for PERIOD;
        assert REG_D = "001001001100010011101000"
            report "LSL Failed";
        report "Operation LSR";
        OP <= "01001";
        REG_A <= "001001001001100010011101";
        REG_B <= "000100110010011100011000";
        CST <= "000000000011";
        wait for PERIOD;
        assert REG_D = "000001001001001100010011"
            report "LSR Failed";
        report "Operation AND";
        OP <= "01010";
        REG_A <= "001001001001100010011101";
        REG_B <= "000100110010011100011000";
        CST <= "000000000011";
        wait for PERIOD;
        assert REG_D = "000000000000000000011000"
            report "AND Failed";
        report "Operation OR";
        OP <= "01011";
        REG_A <= "001001001001100010011101";
        REG_B <= "000100110010011100011000";
        CST <= "000000000011";
        wait for PERIOD;
        assert REG_D = "001101111011111110011101"
            report "OR Failed";
        report "Operation XOR";
        OP <= "01100";
        REG_A <= "001001001001100010011101";
        REG_B <= "000100110010011100011000";
        CST <= "000000000011";
        wait for PERIOD;
        assert REG_D = "001101111011111110000101"
            report "XOR Failed";
        report "Operation NOT";
        OP <= "01101";
        REG_A <= "001001001001100010011101";
        REG_B <= "000100110010011100011000";
        CST <= "000000000011";
        wait for PERIOD;
        assert REG_D = "110110110110011101100010"
            report "NOT FAILED";
        report "Operation CMP";
        OP <= "01110";

        wait;
    end process;

end;