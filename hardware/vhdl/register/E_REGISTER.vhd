---------------------------------------------------------------------------------------------------
-- Project CPU23 
--
-- Hanno Sternberg
--
-- Basis Element: Register<n>
--
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use work.constants.all;

entity E_REGISTER is
	generic (G_WIDTH: natural := C_DATA_WIDTH);
	port(
		i : in std_logic_vector(G_WIDTH-1 downto 0);	-- Input Data
		q : out std_logic_vector(G_WIDTH-1 downto 0);	-- Output Data
		
		clk: in std_logic;			-- clock
		en : in std_logic;			-- enable
		rst : in std_logic 			-- reset
	);
end entity E_REGISTER;

architecture A_REGISTER of E_REGISTER is
	signal buf_q : std_logic_vector(G_WIDTH-1 downto 0) := (others => '0');
	
begin
	
	store:process(i, clk, en, rst, buf_q)
	begin
		if (rst = C_RESET_VALUE) then
			buf_q <= (buf_q'range => '0');
		elsif (clk'event and clk = '1') then
			if (en = '1') then
				buf_q <= i;
			else
				buf_q <= buf_q;
			end if;
		end if;
		q <= buf_q;
	end process;
	
end architecture A_REGISTER;