library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_ALU_LSR is

	generic (G_WIDTH: natural := C_DATA_WIDTH);
	port (
		op: in std_logic_vector(G_WIDTH-1 downto 0);
		
		amount : in std_logic_vector(6 downto 0);
		
		res : out std_logic_vector(G_WIDTH-1 downto 0)
	);
end entity;

architecture A_ALU_LSR of E_ALU_LSR is

begin
	res <= std_logic_vector(unsigned(op) srl to_integer(unsigned(amount)));
end;
