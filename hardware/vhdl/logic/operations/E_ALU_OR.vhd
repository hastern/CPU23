library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_ALU_OR is

    port (
        opA : in Word23;
        opB : in Word23;

        res : out Word23
    );

end entity;

architecture A_ALU_OR of E_ALU_OR is

begin
    process (opA, OpB)
    begin
        res <= opA or opB;
    end process;
end;
