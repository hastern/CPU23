

library ieee;
use ieee.std_logic_1164.all;


entity E_REGISTER_SELECTOR is

	port ( 
		regsel_i		: in std_logic_vector(6 downto 0);
		
		reg_en_o		: out std_logic_vector(0 to 15);
		
		reg_op_o		: out std_logic_vector(3 downto 0)
		
	);

end entity;


architecture A_REGISTER_SELECTOR of E_REGISTER_SELECTOR is

	

begin

	output_regsel : process( regsel_i )
	begin
		reg_en_o <= (reg_en_o'range => '0');
		case regsel_i(3 to 0) is
			when "0000" => reg_en_o(0) <= '1';
			when "0001" => reg_en_o(1) <= '1';
			when "0010" => reg_en_o(2) <= '1';
			when "0011" => reg_en_o(3) <= '1';
			when "0100" => reg_en_o(4) <= '1';
			when "0101" => reg_en_o(5) <= '1';
			when "0110" => reg_en_o(6) <= '1';
			when "0111" => reg_en_o(7) <= '1';
			when "1000" => reg_en_o(8) <= '1';
			when "1001" => reg_en_o(9) <= '1';
			when "1010" => reg_en_o(10) <= '1';
			when "1011" => reg_en_o(11) <= '1';
			when "1100" => reg_en_o(12) <= '1';
			when "1101" => reg_en_o(13) <= '1';
			when "1110" => reg_en_o(14) <= '1';
			when "1111" => reg_en_o(15) <= '1';
		end case;
	end process;
	
	output_special : process (regsel_i)
	begin
		reg_op_o <= regsel_i(6 downto 4);
	end process;



end architecture;