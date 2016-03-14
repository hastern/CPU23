library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_ALU_SWITCH is

    port (
        opSel : in OpCode23;

        opCPR : in Word23;
        opSET : in Word23;
        opBIT : in Word23;
        opADD : in Word23;
        opSUB : in Word23;
        opLSL : in Word23;
        opLSR : in Word23;
        opAND : in Word23;
        opOR  : in Word23;
        opXOR : in Word23;
        opNOT : in Word23;


        res : out Word23
    );

end entity;

architecture A_ALU_SWITCH of E_ALU_SWITCH is

begin
    process (opSel,opCPR, opSET, opBIT, opADD, opSUB, opNOT, opAND, opOR, opXOR, opLSL, opLSR)
    begin
            case opSel is
                when "00011" => res <= opCPR;
                when "00100" => res <= opSET;
                when "00101" => res <= opBIT;
                when "00110" => res <= opADD;
                when "00111" => res <= opSUB;
                when "01000" => res <= opLSL;
                when "01001" => res <= opLSR;
                when "01010" => res <= opAND;
                when "01011" => res <= opOR;
                when "01100" => res <= opXOR;
                when "01101" => res <= opNOT;
                when others  => res <= (others => '0');
            end case;
    end process;
end;
