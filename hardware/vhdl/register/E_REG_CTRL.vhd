
--
--
--Indexing		Register Input		Register Output
----------		--------------		---------------
--Direct			Value					Value
--Indirect		Value					Value
--Displacement	Value					Value
--Post Inc		Value + 1			Value
--Post Dec		Value - 1			Value
--Pre Inc		Value + 1			Value + 1
--Pre Dec		Value - 1			Value - 1
--Const			Value					Value
--
--



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;
use work.constants.all;

entity E_REG_CTRL is
	generic (G_WIDTH: natural := C_DATA_WIDTH);
	port (
		-- data input
		data_i	: in  std_logic_vector(G_WIDTH-1 downto 0);
		-- Write new data flag
		newVal  : in std_logic;
		-- data output
		data_o	: out std_logic_vector(G_WIDTH-1 downto 0);
		-- Indexing selection
		sel_i	: in  std_logic_vector(2 downto 0);
		
		clk : in std_logic;
		rst : in std_logic;
		en : in std_logic
	);
end entity;


architecture A_REG_CTRL of E_REG_CTRL is
	
	signal dataRaw : std_logic_vector(G_WIDTH-1 downto 0);
	signal dataInc : std_logic_vector(G_WIDTH-1 downto 0);
	signal dataDec : std_logic_vector(G_WIDTH-1 downto 0);
	
	signal reg_in	: std_logic_vector(G_WIDTH-1 downto 0);
	signal reg_out	: std_logic_vector(G_WIDTH-1 downto 0);
begin

	reg:ENTITY work.E_REGISTER
		generic map(G_wIDTH)
		port map(
			i => reg_in, 
			q => reg_out, 
			clk => clk, 
			en => en, 
			rst => rst
		);
	
	plus:ENTITY work.E_ALU_ADDER
		generic map(G_WIDTH)
		port map(opA => dataRaw, opB => (dataRaw'range => '0') or "1", res => dataInc);
	
	minus:ENTITY work.E_ALU_SUBTRACT
		generic map(G_WIDTH)
		port map(opA => dataRaw, opB => (dataRaw'range => '0') or "1", res => dataDec);
	
	-- Input selection
	dataSel: ENTITY work.E_REG_STREAM_SELECT
		generic map(G_WIDTH)
		port map(
			stream_direct_i => dataRaw, 
			stream_indirect_i => dataRaw, 
			stream_displacement_i => dataRaw, 
			stream_postinc_i => dataInc, 
			stream_postdec_i => dataDec, 
			stream_preinc_i => dataInc, 
			stream_predec_i => dataDec, 
			stream_const_i => dataRaw, 
			strSel_i => sel_i,
			stream_o => reg_in
		);
	
	-- output selection
	outSel:ENTITY work.E_REG_STREAM_SELECT
		generic map(G_WIDTH)
		port map(
			stream_direct_i => dataRaw, 
			stream_indirect_i => dataRaw, 
			stream_displacement_i => dataRaw, 
			stream_postinc_i => dataRaw, 
			stream_postdec_i => dataRaw, 
			stream_preinc_i => dataInc, 
			stream_predec_i => dataDec, 
			stream_const_i => dataRaw, 
			strSel_i => sel_i,
			stream_o => data_o
		);

	dataRaw <= reg_out when newVal = '0' else data_i;
	
	
end architecture;