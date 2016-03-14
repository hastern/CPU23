library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_ALU_LSR is

    port (
        op: in Word23;

        amount : in Constant23;

        res : out Word23
    );
end entity;

architecture A_ALU_LSR of E_ALU_LSR is

begin
    res <= std_logic_vector(unsigned(op) srl to_integer(unsigned(amount)));
end;
