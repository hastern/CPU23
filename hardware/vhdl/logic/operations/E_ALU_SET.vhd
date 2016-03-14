library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_ALU_SET is

    port (
        opC : in Constant23;

        res : out Word23
    );

end entity;

architecture A_ALU_SET of E_ALU_SET is

begin
    process (opC)
    begin
        res <= (others => '0');
        res(11 downto 0) <= opC;
    end process;
end;
