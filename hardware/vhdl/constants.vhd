---------------------------------------------------------------------------------------------------
-- Project CPU23 
--
-- Hanno Sternberg
--
-- Basic constants
--
----------------------------------------------------------------------------------------------------
LIBRARY ieee;
use ieee.std_logic_1164.all;

Package constants is
	--General Constants
	
	--C_RESET_VALUE: defines if Reset is HIGH- or LOW-Active
	constant C_RESET_VALUE : std_logic := '1';
	
	constant MaxCoordX: NATURAL := 640;
	constant MaxCoordY: NATURAL := 480;
	
	constant C_VGA_X_MAX 	: STD_LOGIC_VECTOR(11 downto 0) := x"320"; --800
	constant C_VGA_Y_MAX 	: STD_LOGIC_VECTOR(11 downto 0) := x"209"; --521
	constant C_VGA_HS_DELAY : STD_LOGIC_VECTOR(11 downto 0) := "0000" & x"61"; --97
	constant C_VGA_VS_DELAY : STD_LOGIC_VECTOR(11 downto 0) := "00000000"& x"3"; --3
	constant C_VGA_VISX_MIN : STD_LOGIC_VECTOR(9 downto 0) := "0010010000";  -- 144
	constant C_VGA_VISX_MAX : STD_LOGIC_VECTOR(9 downto 0) := "1100010000";  -- 784
	constant C_VGA_VISY_MIN : STD_LOGIC_VECTOR(9 downto 0) := "0000100111";  -- 39
	constant C_VGA_VISY_MAX : STD_LOGIC_VECTOR(9 downto 0) := "1000000111";  -- 519
	
	constant C_DATA_WIDTH : NATURAL := 24;
	constant C_REG_COUNT  : NATURAL := 64;
	
end Package;

