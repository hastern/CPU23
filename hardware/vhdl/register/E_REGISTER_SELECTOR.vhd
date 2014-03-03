

library ieee;
use ieee.std_logic_1164.all;


entity E_REGISTER_SELECTOR is

	port ( 
		regsel_i		: in std_logic_vector(5 downto 0);
		reg_en_o		: out std_logic_vector(0 to 63)		
	);

end entity;


architecture A_REGISTER_SELECTOR of E_REGISTER_SELECTOR is

begin

	output_regsel : process( regsel_i )
	begin
		reg_en_o <= (reg_en_o'range => '0');
		case regsel_i(5 downto 0) is
			when "000000" => reg_en_o(0) <= '1';
			when "000001" => reg_en_o(1) <= '1';
			when "000010" => reg_en_o(2) <= '1';
			when "000011" => reg_en_o(3) <= '1';
			when "000100" => reg_en_o(4) <= '1';
			when "000101" => reg_en_o(5) <= '1';
			when "000110" => reg_en_o(6) <= '1';
			when "000111" => reg_en_o(7) <= '1';
			when "001000" => reg_en_o(8) <= '1';
			when "001001" => reg_en_o(9) <= '1';
			when "001010" => reg_en_o(10) <= '1';
			when "001011" => reg_en_o(11) <= '1';
			when "001100" => reg_en_o(12) <= '1';
			when "001101" => reg_en_o(13) <= '1';
			when "001110" => reg_en_o(14) <= '1';
			when "001111" => reg_en_o(15) <= '1';
			when "010000" => reg_en_o(16) <= '1';
			when "010001" => reg_en_o(17) <= '1';
			when "010010" => reg_en_o(18) <= '1';
			when "010011" => reg_en_o(19) <= '1';
			when "010100" => reg_en_o(20) <= '1';
			when "010101" => reg_en_o(21) <= '1';
			when "010110" => reg_en_o(22) <= '1';
			when "010111" => reg_en_o(23) <= '1';
			when "011000" => reg_en_o(24) <= '1';
			when "011001" => reg_en_o(25) <= '1';
			when "011010" => reg_en_o(26) <= '1';
			when "011011" => reg_en_o(27) <= '1';
			when "011100" => reg_en_o(28) <= '1';
			when "011101" => reg_en_o(29) <= '1';
			when "011110" => reg_en_o(30) <= '1';
			when "011111" => reg_en_o(31) <= '1';
			when "100000" => reg_en_o(32) <= '1';
			when "100001" => reg_en_o(33) <= '1';
			when "100010" => reg_en_o(34) <= '1';
			when "100011" => reg_en_o(35) <= '1';
			when "100100" => reg_en_o(36) <= '1';
			when "100101" => reg_en_o(37) <= '1';
			when "100110" => reg_en_o(38) <= '1';
			when "100111" => reg_en_o(39) <= '1';
			when "101000" => reg_en_o(40) <= '1';
			when "101001" => reg_en_o(41) <= '1';
			when "101010" => reg_en_o(42) <= '1';
			when "101011" => reg_en_o(43) <= '1';
			when "101100" => reg_en_o(44) <= '1';
			when "101101" => reg_en_o(45) <= '1';
			when "101110" => reg_en_o(46) <= '1';
			when "101111" => reg_en_o(47) <= '1';
			when "110000" => reg_en_o(48) <= '1';
			when "110001" => reg_en_o(49) <= '1';
			when "110010" => reg_en_o(50) <= '1';
			when "110011" => reg_en_o(51) <= '1';
			when "110100" => reg_en_o(52) <= '1';
			when "110101" => reg_en_o(53) <= '1';
			when "110110" => reg_en_o(54) <= '1';
			when "110111" => reg_en_o(55) <= '1';
			when "111000" => reg_en_o(56) <= '1';
			when "111001" => reg_en_o(57) <= '1';
			when "111010" => reg_en_o(58) <= '1';
			when "111011" => reg_en_o(59) <= '1';
			when "111100" => reg_en_o(60) <= '1';
			when "111101" => reg_en_o(61) <= '1';
			when "111110" => reg_en_o(62) <= '1';
			when "111111" => reg_en_o(63) <= '1';
		end case;
	end process;

end architecture;