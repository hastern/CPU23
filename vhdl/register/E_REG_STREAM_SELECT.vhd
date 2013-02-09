library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use work.constants.all;

entity E_REG_STREAM_SELECT is 

	generic (G_WIDTH : natural := C_DATA_WIDTH);
	port(
		stream1_i: in std_logic_vector(G_WIDTH-1 downto 0);
		stream2_i: in std_logic_vector(G_WIDTH-1 downto 0);
		stream3_i: in std_logic_vector(G_WIDTH-1 downto 0);
		stream4_i: in std_logic_vector(G_WIDTH-1 downto 0);
		stream5_i: in std_logic_vector(G_WIDTH-1 downto 0);
		stream6_i: in std_logic_vector(G_WIDTH-1 downto 0);
		stream7_i: in std_logic_vector(G_WIDTH-1 downto 0);
		stream8_i: in std_logic_vector(G_WIDTH-1 downto 0);
		
		strSel_i: in std_logic_vector(2 downto 0);
		
		stream_o: out std_logic_vector(G_WIDTH-1 downto 0)
		
	);
	
end entity;

architecture A_REG_STREAM_SELECT of E_REG_STREAM_SELECT is
begin

	sel:process(stream1_i, stream2_i, stream3_i, stream4_i, stream5_i, stream6_i, stream7_i, stream8_i, strSel_i)
	begin
		case strSel_i is
			when "000" => stream_o <= stream1_i;
			when "001" => stream_o <= stream2_i;
			when "010" => stream_o <= stream3_i;
			when "011" => stream_o <= stream4_i;
			when "100" => stream_o <= stream5_i;
			when "101" => stream_o <= stream6_i;
			when "110" => stream_o <= stream7_i;
			when "111" => stream_o <= stream8_i;
		end case;
	end process;

end architecture;