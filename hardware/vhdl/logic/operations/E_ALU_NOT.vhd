library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_ALU_NOT is

    port (
        op : in Word23;

        res : out Word23
    );

end entity;

architecture A_ALU_NOT of E_ALU_NOT is

begin
    process (op)
    begin
        res <= not op;
    end process;
end;
