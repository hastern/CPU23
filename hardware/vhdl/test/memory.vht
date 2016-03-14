library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;


entity T_MEMORY_TEST is
end entity;

architecture Test of T_MEMORY_TEST is

    constant PERIOD : time := 20 ps;
    signal CLOCK : std_logic;
    signal RESET : std_logic;

    signal addr : Word23;
    signal data_in : Word23;
    signal write_en : std_logic;
    signal data_out : Word23;
    signal dma_data : Word23;
    signal dma_addr : Word23;
    signal bootload : std_logic;
    signal bootload_data : Word23;
    signal bootload_addr : Word23;

begin

    DUT : ENTITY work.E_MEMORY(A_MEMORY)
        port map (
            clk => CLOCK, rst => RESET,
            addr => addr,
            data_i => data_in,
            write_en => write_en,
            data_o => data_out,
            -- DMA
            dma_addr => dma_addr,
            dma_data => dma_data,
            -- bootloader
            bootload => bootload,
            bootload_data => bootload_data,
            bootload_addr => bootload_addr
        );

    generateclock : process
    begin
        CLOCK <= '0';
        wait for PERIOD/2;
        CLOCK <= '1';
        wait for PERIOD/2;
    end process;

    function_test: process
    begin
        RESET <= '0';
        wait for PERIOD;
        bootload <= '1';
        dma_addr <= "000000000000000000000000";

        bootload_addr <= "000000000000000000000000";
        bootload_data <= "100000000000000001000010";
        wait for PERIOD;

        bootload_addr <= "000000000000000000000001";
        bootload_data <= "101000111100000011011110";
        wait for PERIOD;

        bootload_addr <= "000000000000000000000010";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000000011";
        bootload_data <= "111111111111111111111111";
        wait for PERIOD;

        bootload_addr <= "000000000000000000000100";
        bootload_data <= "100000000001001100110111";
        wait for PERIOD;

        bootload_addr <= "000000000000000000000101";
        bootload_data <= "100000000001001100110111";
        wait for PERIOD;

        bootload_addr <= "000000000000000000000110";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000000111";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000001000";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000001001";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000001010";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000001011";
        bootload_data <= "100000000000000001000010";
        wait for PERIOD;

        bootload_addr <= "000000000000000000001100";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000001101";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000001110";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000001111";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000010000";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000010001";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000010010";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000010011";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000010100";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000010101";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000010110";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000010111";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000011000";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000011001";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000011010";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000011011";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000011100";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000011101";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000011110";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000011111";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000100000";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000100001";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000100010";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000100011";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000100100";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000100101";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000100110";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000100111";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000101000";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000101001";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000101010";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000101011";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000101100";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000101101";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000101110";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000101111";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000110000";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000110001";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000110010";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000110011";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000110100";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000110101";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000110110";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000110111";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000111000";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000111001";
        bootload_data <= "100000000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000000111010";
        bootload_data <= "100000000001110111101010";
        wait for PERIOD;

        bootload_addr <= "000000000000000000111011";
        bootload_data <= "000101110100001110110100";
        wait for PERIOD;

        bootload_addr <= "000000000000000000111100";
        bootload_data <= "000100000000100011110101";
        wait for PERIOD;

        bootload_addr <= "000000000000000000111101";
        bootload_data <= "000001110101000000110111";
        wait for PERIOD;

        bootload_addr <= "000000000000000000111110";
        bootload_data <= "001010110111110110110101";
        wait for PERIOD;

        bootload_addr <= "000000000000000000111111";
        bootload_data <= "001111111001000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000001000000";
        bootload_data <= "010001111000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000001000001";
        bootload_data <= "011111000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000001000010";
        bootload_data <= "000100000000000101000010";
        wait for PERIOD;

        bootload_addr <= "000000000000000001000011";
        bootload_data <= "000100000000000011000011";
        wait for PERIOD;

        bootload_addr <= "000000000000000001000100";
        bootload_data <= "000011111111000000101110";
        wait for PERIOD;

        bootload_addr <= "000000000000000001000101";
        bootload_data <= "000100000000001000101111";
        wait for PERIOD;

        bootload_addr <= "000000000000000001000110";
        bootload_data <= "000110101110101111110000";
        wait for PERIOD;

        bootload_addr <= "000000000000000001000111";
        bootload_data <= "000010110000000000111011";
        wait for PERIOD;

        bootload_addr <= "000000000000000001001000";
        bootload_data <= "000100000000000001110000";
        wait for PERIOD;

        bootload_addr <= "000000000000000001001001";
        bootload_data <= "000111111011110000111011";
        wait for PERIOD;

        bootload_addr <= "000000000000000001001010";
        bootload_data <= "000100000001001101110000";
        wait for PERIOD;

        bootload_addr <= "000000000000000001001011";
        bootload_data <= "010001110000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000001001100";
        bootload_data <= "011111000000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000001001101";
        bootload_data <= "000100000000000000000001";
        wait for PERIOD;

        bootload_addr <= "000000000000000001001110";
        bootload_data <= "000100000000000000101111";
        wait for PERIOD;

        bootload_addr <= "000000000000000001001111";
        bootload_data <= "001110000010101111000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000001010000";
        bootload_data <= "000100000001010111110000";
        wait for PERIOD;

        bootload_addr <= "000000000000000001010001";
        bootload_data <= "001111110000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000001010010";
        bootload_data <= "000110000001000011000001";
        wait for PERIOD;

        bootload_addr <= "000000000000000001010011";
        bootload_data <= "000100000000000001101111";
        wait for PERIOD;

        bootload_addr <= "000000000000000001010100";
        bootload_data <= "000111000010101111000010";
        wait for PERIOD;

        bootload_addr <= "000000000000000001010101";
        bootload_data <= "000100000001001110110000";
        wait for PERIOD;

        bootload_addr <= "000000000000000001010110";
        bootload_data <= "010001110000000000000000";
        wait for PERIOD;

        bootload_addr <= "000000000000000001010111";
        bootload_data <= "000100000000000001110000";
        wait for PERIOD;

        bootload_addr <= "000000000000000001011000";
        bootload_data <= "000110111011110000111011";
        wait for PERIOD;

        bootload_addr <= "000000000000000001011001";
        bootload_data <= "000001111011000000111111";
        wait for PERIOD;

        wait for PERIOD;
        bootload <= '0';

        addr <= "000000000000000000000001";
        wait for PERIOD;
        addr <= "000000000000000000000011";
        wait for PERIOD;
        addr <= "000000000000000000001010";
        wait for PERIOD;
        addr <= "000000000000000000100011";
        wait for PERIOD;
        wait;
    end process;

end architecture;
