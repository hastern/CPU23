library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use work.constants.all;

entity E_ALU_CORE is

	generic ( DATA_WIDTH : natural := C_DATA_WIDTH );
	port (
		clk	: in  std_logic;
		rst	: in  std_logic;
		op	: in  std_logic_vector(2 downto 0);
		a	: in  std_logic_vector((DATA_WIDTH-1) downto 0);
		b	: in  std_logic_vector((DATA_WIDTH-1) downto 0);
		result	: out std_logic_vector((DATA_WIDTH-1) downto 0)
	);

end entity;

architecture A_ALU_CORE of E_ALU_CORE is
	
	signal resADD: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal resSUB: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal resLSL: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal resLSR: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal resAND: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal resOR:  std_logic_vector(DATA_WIDTH-1 downto 0);
	signal resXOR: std_logic_vector(DATA_WIDTH-1 downto 0);
	signal resNOT: std_logic_vector(DATA_WIDTH-1 downto 0);
	
begin

	addBlock: ENTITY work.E_ALU_ADDER(A_ALU_ADDER)	
		generic map (DATA_WIDTH)
		port map (a, b, resADD);
	
	subBlock: ENTITY work.E_ALU_SUBTRACT(A_ALU_SUBTRACT)
		generic map (DATA_WIDTH)
		port map (a, b, resSUB);
	
	lslBlock: ENTITY work.E_ALU_LSL(A_ALU_LSL)
		generic map (DATA_WIDTH)
		port map (a, b, resADD);
	
	lsrBlock: ENTITY work.E_ALU_LSR(A_ALU_LSR)
		generic map (DATA_WIDTH)
		port map (a, b, resSUB);
	
	andBlock: ENTITY work.E_ALU_AND(A_ALU_AND)
		generic map (DATA_WIDTH)
		port map (a, b, resAND);
	
	orBlock: ENTITY work.E_ALU_OR(A_ALU_OR)
		generic map (DATA_WIDTH)
		port map (a, b, resOR);
	
	xorBlock: ENTITY work.E_ALU_XOR(A_ALU_XOR)
		generic map (DATA_WIDTH)
		port map (a, b, resXOR);
	
	notBlock: ENTITY work.E_ALU_NOT(A_ALU_NOT)
		generic map (DATA_WIDTH)
		port map (a, resNOT);
	
	switch: ENTITY work.E_ALU_SWITCH(A_ALU_SWITCH)
		generic map (DATA_WIDTH)
		port map (
			opSel => op, 
			opADD => resADD, opSUB => resSUB, 
			opLSL => resLSL, opLSR => resLSR, 
			opAND => resAND, opOR => resOR, 
			opXOR => resXOR, opNOT => resNOT, 
			res => result
		);

end A_ALU_CORE;
