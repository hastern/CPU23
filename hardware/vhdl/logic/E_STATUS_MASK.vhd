library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_STATUS_MASK is

    port (
        op  : in OpCode23;
        mask: out Word23
    );

end entity;

architecture A_STATUS_MASK of E_STATUS_MASK is
begin

    process (op) is
    begin
        case op is                --   FNORDXWITHGELCUZV00000
            when "00110" => mask <= "000000000010000101100000"; -- ADD
            when "00111" => mask <= "000000000010000111000000"; -- SUB
            when "01000" => mask <= "000000000010000101000000"; -- LSL
            when "01001" => mask <= "000000000010000101000000"; -- LSR
            when "01010" => mask <= "000000000010000001000000"; -- AND
            when "01011" => mask <= "000000000010000001000000"; -- OR
            when "01100" => mask <= "000000000010000001000000"; -- XOR
            when "01101" => mask <= "000000000010000001000000"; -- NOT
            when "01110" => mask <= "000000000010111001000000"; -- CMP
            when others  => mask <= "000000000000000000000000";
        end case;
    end process;

end architecture;
