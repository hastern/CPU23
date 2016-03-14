library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;

entity T_UART_TEST is
end entity;

architecture Test of T_UART_TEST is

    constant PERIOD : time := 20 ps;
    constant BAUDRATE : time := 100 ns;
    signal DATA_IN : std_logic_vector(7 downto 0) := "01101001";

    signal CLOCK : std_logic;
    signal RESET : std_logic;
    signal UART_RX : std_logic;
    signal UART_RX_DATA : std_logic_vector(7 downto 0);
    signal UART_RX_DATA_READY : std_logic;

    signal UART_TX_DATA : std_logic_vector(7 downto 0);
    signal UART_TX_DATA_WRITE : std_logic;

begin

    DUT: ENTITY work.E_UART(A_UART)
        port map(
            rx => UART_RX,
            tx => open,
            data_in => UART_TX_DATA,
            data_write => UART_TX_DATA_WRITE,
            data_out => UART_RX_DATA,
            data_read => UART_RX_DATA_READY,
            clk => CLOCK,
            rst => RESET
        );

    generateclock : process
    begin
        CLOCK <= '0';
        wait for PERIOD/2;
        CLOCK <= '1';
        wait for PERIOD/2;
    end process;

    receive_test: process
    begin
        RESET <= '0';
        wait for PERIOD;
        UART_RX <= '1';
        wait for BAUDRATE;
        wait for BAUDRATE;
        wait for BAUDRATE;
        wait for BAUDRATE;
        wait for BAUDRATE;
        UART_RX <= '0'; -- START BIT
        wait for BAUDRATE;

        for bit_no in 7 downto 0 loop
            UART_RX <= DATA_IN(bit_no);
            wait for BAUDRATE;
        end loop;

        UART_RX <= '1'; -- STOP BIT
        wait for BAUDRATE;
        wait for BAUDRATE;
        wait for BAUDRATE;
        assert UART_RX_DATA = DATA_IN;
        wait for BAUDRATE;
        wait for BAUDRATE;
    end process;

    send_test: process
    begin
        wait for BAUDRATE;
        wait for BAUDRATE;
        wait for BAUDRATE;
        wait for BAUDRATE;
        UART_TX_DATA_WRITE <= '1';
        UART_TX_DATA <= DATA_IN;
        wait for BAUDRATE;
        UART_TX_DATA_WRITE <= '0';
        wait for BAUDRATE;
        for bit_no in 7 downto 0 loop
            wait for BAUDRATE;
        end loop;
        wait for BAUDRATE;
    end process;

end;