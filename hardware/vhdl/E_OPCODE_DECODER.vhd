


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_OPCODE_DECODER is

    port (
        clk_i : in std_logic;
        rst_i : in std_logic;
        -- one word of instructions
        instr    : in Word23;
        write_en : in std_logic;
        -- output
        op     : out  OpCode23;
        a      : out  Register23;
        b      : out  Register23;
        d      : out  Register23;
        c      : out  Constant23;
        -- halt
        halt   : out std_logic
    );


end entity;

architecture A_OPCODE_DECODER of E_OPCODE_DECODER is
    signal instruction: Word23;
begin

    InstrBuffer: ENTITY work.E_REGISTER(A_REGISTER)
        port map(instr, instruction, clk_i, write_en, rst_i);

    process(instruction)
    begin
        op <= instruction(22 downto 18);
        case instruction(22 downto 18) is
            when "00001" |   -- LDR
                 "00010" |   -- STR
                 "00011" |   -- CPR
                 "00110" |   -- ADD
                 "00111" |   -- SUB
                 "01000" |   -- LSL
                 "01001" |   -- LSR
                 "01010" |   -- AND
                 "01011" |   -- OR
                 "01100" |   -- XOR
                 "01101" |   -- NOT
                 "01110" =>  -- CMP
                    --- TYPE ABD
                    a <= instruction(17 downto 12);
                    b <= instruction(11 downto 6);
                    d <= instruction(5 downto 0);
                    c <= "000000000000";
            when "00101" =>  --> BIT
                    --- TYPE ACD
                    a <= instruction(17 downto 12);
                    b <= "000000";
                    d <= instruction(5 downto 0);
                    c(11 downto 6) <= "000000";
                    c(5 downto 0) <= instruction(11 downto 6);
            when "01111" |   -- BRA
                 "10000" |   -- BNE
                 "10001" =>  -- JMP
                    --- TYPE AC
                    a <= instruction(17 downto 12);
                    b <= "000000";
                    d <= "000000";
                    c <= instruction(11 downto 0);
            when "00100" =>  -- SET
                    --- TYPE AD
                    a <= "000000";
                    b <= "000000";
                    d <= instruction(5 downto 0);
                    c <= instruction(17 downto 6);
            when others =>
                     a <= "000000";
                     b <= "000000";
                     d <= "000000";
                     c <= "000000000000";
        end case;
    end process;

    halt <= instruction(23);

end architecture;
