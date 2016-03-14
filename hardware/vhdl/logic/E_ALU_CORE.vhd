library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_ALU_CORE is

    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
        -- operation
        op     : in  OpCode23;
        a      : in  Word23;
        b      : in  Word23;
        c      : in  Constant23;
        result : out Word23;
        -- flags
        flag_overflow : out std_logic;
        flag_underflow: out std_logic;
        flag_zero     : out std_logic;
        flag_true     : out std_logic;
        flag_carry    : out std_logic;
        flag_equal    : out std_logic;
        flag_lesser   : out std_logic;
        flag_greater  : out std_logic
    );

end entity;

architecture A_ALU_CORE of E_ALU_CORE is

    signal resCPR: Word23;
    signal resSET: Word23;
    signal resBIT: Word23;
    signal resADD: Word23;
    signal resSUB: Word23;
    signal resLSL: Word23;
    signal resLSR: Word23;
    signal resAND: Word23;
    signal resOR:  Word23;
    signal resXOR: Word23;
    signal resNOT: Word23;

    signal result_out : Word23;

begin

    cprBlock: ENTITY work.E_ALU_COPY(A_ALU_COPY)
        port map (a, resCPR);

    setBlock: ENTITY work.E_ALU_SET(A_ALU_SET)
        port map (c, resSET);

    bitBlock: ENTITY work.E_ALU_BIT(A_ALU_BIT)
        port map (a, c, resBIT);

    addBlock: ENTITY work.E_ALU_ADDER(A_ALU_ADDER)
        port map (a, b, resADD);

    subBlock: ENTITY work.E_ALU_SUBTRACT(A_ALU_SUBTRACT)
        port map (a, b, resSUB);

    lslBlock: ENTITY work.E_ALU_LSL(A_ALU_LSL)
        port map (a, c, resLSL);

    lsrBlock: ENTITY work.E_ALU_LSR(A_ALU_LSR)
        port map (a, c, resLSR);

    andBlock: ENTITY work.E_ALU_AND(A_ALU_AND)
        port map (a, b, resAND);

    orBlock: ENTITY work.E_ALU_OR(A_ALU_OR)
        port map (a, b, resOR);

    xorBlock: ENTITY work.E_ALU_XOR(A_ALU_XOR)
        port map (a, b, resXOR);

    notBlock: ENTITY work.E_ALU_NOT(A_ALU_NOT)
        port map (a, resNOT);

    switch: ENTITY work.E_ALU_SWITCH(A_ALU_SWITCH)
        port map (
            opSel => op, opCPR => resCPR,
            opSET => resSET, opBIT => resBIT,
            opADD => resADD, opSUB => resSUB,
            opLSL => resLSL, opLSR => resLSR,
            opAND => resAND, opOR  => resOR,
            opXOR => resXOR, opNOT => resNOT,
            res => result_out
        );

    flag_true <= '1' when (result_out = "111111111111111111111111") else '0';
    flag_zero <= '1' when (result_out = "000000000000000000000000") else '0';
    flag_overflow <= '1' when (result_out < a) else '0';
    flag_underflow <= '1' when (result_out > a) else '0';
    flag_carry <= a(23) and b(23);
    flag_equal <= '1' when (a = b) else '0';
    flag_greater <= '1' when (a > b) else '0';
    flag_lesser <= '1' when (a < b) else '0';
    result <= result_out;

end A_ALU_CORE;
