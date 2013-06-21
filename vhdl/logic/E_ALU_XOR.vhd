library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use work.constants.all;

entity E_ALU_XOR is

	generic (G_WIDTH: natural := C_DATA_WIDTH);
	port (
		opA : in std_logic_vector(G_WIDTH-1 downto 0);
		opB : in std_logic_vector(G_WIDTH-1 downto 0);
		
		res : out std_logic_vector(G_WIDTH-1 downto 0)
	);
	
end entity;

architecture A_ALU_XOR of E_ALU_XOR is

begin
	process (opA, OpB)
	begin
		res <= opA xor opB;
	end process;
end;
