library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_ALU_BIT is

    port (
        opA : in Word23;
        opC : in Constant23;

        res : out Word23
    );

end entity;

architecture A_ALU_BIT of E_ALU_BIT is
    signal onehot : Word23;
begin

    process (opC)
    begin
        case opC(4 downto 0) is
            when "00000" => onehot <= "000000000000000000000001";
            when "00001" => onehot <= "000000000000000000000010";
            when "00010" => onehot <= "000000000000000000000100";
            when "00011" => onehot <= "000000000000000000001000";
            when "00100" => onehot <= "000000000000000000010000";
            when "00101" => onehot <= "000000000000000000100000";
            when "00110" => onehot <= "000000000000000001000000";
            when "00111" => onehot <= "000000000000000010000000";
            when "01000" => onehot <= "000000000000000100000000";
            when "01001" => onehot <= "000000000000001000000000";
            when "01010" => onehot <= "000000000000010000000000";
            when "01011" => onehot <= "000000000000100000000000";
            when "01100" => onehot <= "000000000001000000000000";
            when "01101" => onehot <= "000000000010000000000000";
            when "01110" => onehot <= "000000000100000000000000";
            when "01111" => onehot <= "000000001000000000000000";
            when "10000" => onehot <= "000000010000000000000000";
            when "10001" => onehot <= "000000100000000000000000";
            when "10010" => onehot <= "000001000000000000000000";
            when "10011" => onehot <= "000010000000000000000000";
            when "10100" => onehot <= "000100000000000000000000";
            when "10101" => onehot <= "001000000000000000000000";
            when "10110" => onehot <= "010000000000000000000000";
            when "10111" => onehot <= "100000000000000000000000";
            when others  => onehot <= "000000000000000000000000";
        end case;
    end process;

    process (opA, OpC, onehot)
    begin
       if (opC(5) = '1') then
            res <= opA or onehot;
        else
            res <= opA and not onehot;
        end if;
    end process;
end;
