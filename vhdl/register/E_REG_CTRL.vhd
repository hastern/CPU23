library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use work.constants.all;

entity E_REG_CTRL is
	generic (G_WIDTH: natural := C_DATA_WIDTH);
	port (
		data_i	: in  std_logic_vector(G_WIDTH-1 downto 0);
		data_o	: out std_logic_vector(G_WIDTH-1 downto 0);
		
		sel_i	: in  std_logic_vector(2 downto 0);
		
		newVal  : in std_logic;
		
		clk : in std_logic;
		rst : in std_logic;
		en : in std_logic
	);
end entity;


architecture A_REG_CTRL of E_REG_CTRL is
	
	component E_ALU_ADDER is
		generic(G_WIDTH : natural := C_DATA_WIDTH);
		port (
			opA : in std_logic_vector(G_WIDTH-1 downto 0);
			opB : in std_logic_vector(G_WIDTH-1 downto 0);
			res : out std_logic_vector(G_WIDTH-1 downto 0)
		);
	end component;	
	
	component E_ALU_SUBTRACT is
		generic(G_WIDTH : natural := C_DATA_WIDTH);
		port (
			opA : in std_logic_vector(G_WIDTH-1 downto 0);
			opB : in std_logic_vector(G_WIDTH-1 downto 0);
			res : out std_logic_vector(G_WIDTH-1 downto 0)
		);
	end component;
	
	component E_REGISTER is
		generic(G_WIDTH : natural := C_DATA_WIDTH);
		port ( 
			i : in  std_logic_vector(G_WIDTH-1 downto 0);
			q : out  std_logic_vector(G_WIDTH-1 downto 0);
			clk: in std_logic;
			en: in std_logic;
			rst: in std_logic
		);
	end component;
	
	component E_REG_STREAM_SELECT is
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
	end component;
	
	signal dataRaw : std_logic_vector(G_WIDTH-1 downto 0);
	signal dataInc : std_logic_vector(G_WIDTH-1 downto 0);
	signal dataDec : std_logic_vector(G_WIDTH-1 downto 0);
	
	signal reg_in	: std_logic_vector(G_WIDTH-1 downto 0);
	signal reg_out	: std_logic_vector(G_WIDTH-1 downto 0);
begin

	reg:E_REGISTER
	generic map(G_wIDTH)
	port map(reg_in, reg_out, clk, en, rst);
	
	plus:E_ALU_ADDER
	generic map(G_WIDTH)
	port map(opA => dataRaw, opB => (dataRaw'range => '0') or "1", res => dataInc);
	
	minus:E_ALU_SUBTRACT
	generic map(G_WIDTH)
	port map(opA => dataRaw, opB => (dataRaw'range => '0') or "1", res => dataDec);
	
	dataSel:E_REG_STREAM_SELECT
	generic map(G_WIDTH)
	port map(dataRaw, dataRaw, dataRaw, dataInc, dataDec, dataInc, dataDec, dataRaw, sel_i ,reg_in);
	
	outSel:E_REG_STREAM_SELECT
	generic map(G_WIDTH)
	port map(dataRaw, dataRaw, dataRaw, dataRaw, dataRaw, dataInc, dataDec, dataRaw, sel_i ,data_o);

	dataRaw <= reg_out when newVal = '0' else data_i;

end architecture;