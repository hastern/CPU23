library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use work.constants.all;

entity E_REG_STREAM_SELECT is 

	generic (G_WIDTH : natural := C_DATA_WIDTH);
	port(
		stream_direct_i: in std_logic_vector(G_WIDTH-1 downto 0);
		stream_indirect_i: in std_logic_vector(G_WIDTH-1 downto 0);
		stream_displacement_i: in std_logic_vector(G_WIDTH-1 downto 0);
		stream_postinc_i: in std_logic_vector(G_WIDTH-1 downto 0);
		stream_postdec_i: in std_logic_vector(G_WIDTH-1 downto 0);
		stream_preinc_i: in std_logic_vector(G_WIDTH-1 downto 0);
		stream_predec_i: in std_logic_vector(G_WIDTH-1 downto 0);
		stream_const_i: in std_logic_vector(G_WIDTH-1 downto 0);
		
		strSel_i: in std_logic_vector(2 downto 0);
		
		stream_o: out std_logic_vector(G_WIDTH-1 downto 0)
		
	);
	
end entity;

architecture A_REG_STREAM_SELECT of E_REG_STREAM_SELECT is
begin

	sel:process(stream_direct_i, stream_indirect_i, stream_displacement_i, stream_postinc_i, stream_postdec_i, stream_preinc_i, stream_predec_i, stream_const_i, strSel_i)
	begin
		case strSel_i is
			when "000" => stream_o <= stream_direct_i;
			when "001" => stream_o <= stream_indirect_i;
			when "010" => stream_o <= stream_displacement_i;
			when "011" => stream_o <= stream_postinc_i;
			when "100" => stream_o <= stream_postdec_i;
			when "101" => stream_o <= stream_preinc_i;
			when "110" => stream_o <= stream_predec_i;
			when "111" => stream_o <= stream_const_i;
		end case;
	end process;

end architecture;