library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_ALU_AND is

    port (
        opA : in Word23;
        opB : in Word23;

        res : out Word23
    );

end entity;

architecture A_ALU_AND of E_ALU_AND is

begin
    process (opA, OpB)
    begin
        res <= opA and opB;
    end process;
end;
