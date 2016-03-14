library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;

entity T_UART_ECHO_TEST is
end entity;

architecture Test of T_UART_ECHO_TEST is

    constant PERIOD : time := 20 ps;
    constant BAUDRATE : time := 100 ns;
    signal DATA_IN : std_logic_vector(7 downto 0) := "01101001";

    signal CLOCK : std_logic;
    signal RESET : std_logic;
    signal UART_RX : std_logic;
    signal UART_TX : std_logic;
begin

    DUT: ENTITY work.E_UART_ECHO(A_UART_ECHO)
        port map(
            rx => UART_RX,
            tx => UART_TX,
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
        UART_RX <= '1';
        wait for BAUDRATE;
        wait for BAUDRATE;
        UART_RX <= '0'; -- START BIT
        report "Receiving Start Bit";
        wait for BAUDRATE;

        for bit_no in 7 downto 0 loop
            report "Receiving Bit " & integer'image(bit_no) & ": " & std_logic'image(DATA_IN(bit_no));
            UART_RX <= DATA_IN(bit_no);
            wait for BAUDRATE;
        end loop;

        UART_RX <= '1'; -- STOP BIT
        report "Receiving Stop Bit";
        wait for BAUDRATE;
        report "Sending Start Bit";
        assert UART_TX = '0' report "Missing Start Bit";
        wait for BAUDRATE;
        for bit_no in 7 downto 0 loop
            report "Sending Bit " & integer'image(bit_no) & ": " & std_logic'image(UART_TX);
            assert UART_TX = DATA_IN(bit_no)
                report "Bit mismatch: "
                    & integer'image(bit_no)
                    & " - Expect: "
                    & std_logic'image(DATA_IN(bit_no))
                    & " - Was: "
                    & std_logic'image(UART_TX);
            wait for BAUDRATE;
        end loop;
        wait for BAUDRATE;
        report "Sending Stop Bit";
        assert UART_TX = '1' report "Missing Start Bit";

    end process;

end;