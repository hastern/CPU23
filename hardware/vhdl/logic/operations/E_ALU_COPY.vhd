library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_ALU_COPY is

    port (
        opA : in Word23;

        res : out Word23
    );

end entity;

architecture A_ALU_COPY of E_ALU_COPY is

begin
    process (opA)
    begin
        res <= std_logic_vector(unsigned(opA));
    end process;
end;
