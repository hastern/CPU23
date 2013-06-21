library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use work.constants.all;

entity E_ALU_SWITCH is

	generic (G_WIDTH: natural := C_DATA_WIDTH);
	port (
		opSel : in std_logic_vector(2 downto 0);
		
		opADD : in std_logic_vector(G_WIDTH-1 downto 0);
		opSUB : in std_logic_vector(G_WIDTH-1 downto 0);
		opLSL : in std_logic_vector(G_WIDTH-1 downto 0);
		opLSR : in std_logic_vector(G_WIDTH-1 downto 0);
		opAND : in std_logic_vector(G_WIDTH-1 downto 0);
		opOR : in std_logic_vector(G_WIDTH-1 downto 0);
		opXOR : in std_logic_vector(G_WIDTH-1 downto 0);
		opNOT : in std_logic_vector(G_WIDTH-1 downto 0);
		
		
		res : out std_logic_vector(G_WIDTH-1 downto 0)
	);
	
end entity;

architecture A_ALU_SWITCH of E_ALU_SWITCH is

begin
	process (opSel, opADD, opSUB, opNOT, opAND, opOR, opXOR)
	begin
			case opSel is
				when "000" => res <= opADD;
				when "001" => res <= opSUB;
				when "010" => res <= opLSL;
				when "011" => res <= opLSR;
				when "100" => res <= opAND;
				when "101" => res <= opOR;
				when "110" => res <= opXOR;
				when "111" => res <= opNOT;
			end case;
	end process;
end;
