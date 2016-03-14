library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;

entity E_UART_ECHO is
    port (
        rx : in std_logic;
        tx : out std_logic;
        --
        clk : in std_logic;
        rst : in std_logic
    );

end entity;

architecture A_UART_ECHO of E_UART_ECHO is

    signal data : std_logic_vector(7 downto 0);
    signal ready : std_logic;

begin

    uart: ENTITY work.E_UART(A_UART)
        port map (
            rx => rx, rx_busy => open,
            tx => tx, tx_busy => open,
            data_in => data,
            data_write => ready,
            data_send => open,
            data_out => data,
            data_read => ready,
            clk => clk, rst => rst
        );

end architecture;
