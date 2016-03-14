---------------------------------------------------------------------------------------------------
-- Project CPU23
--
-- Hanno Sternberg
--
-- UART Communication
--
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;

entity E_UART is
    generic (
        BAUDRATE : positive := 9600
    );
    port (
        -- Transmission and receive lines
        rx      : in std_logic;
        rx_busy : out std_logic;
        tx      : out std_logic;
        tx_busy : out std_logic;
        -- Input Data
        data_in : in std_logic_vector(7 downto 0);
        data_write : in std_logic; -- send new data
        data_send : out std_logic; -- data was send
        -- Output Data
        data_out : out std_logic_vector(7 downto 0);
        data_read : out std_logic; -- data was received
        --
        clk  : in  std_logic;
        rst  : in  std_logic
    );
end entity E_UART;

architecture A_UART of E_UART is

    signal data_clock  : std_logic;
    signal rx_bitc_en  : std_logic;
    signal rx_bitc_ovf : std_logic;
    signal rx_bitc_rst : std_logic;
    signal rx_reg_en   : std_logic;
    signal rx_clock_en : std_logic;
    signal rx_clock_ovf: std_logic;
    signal rx_clock_rst: std_logic;
    signal rx_data     : std_logic_vector(9 downto 0);

    signal tx_new_data : std_logic;
    signal tx_bitc_en  : std_logic;
    signal tx_bitc_ovf : std_logic;
    signal tx_bitc_rst : std_logic;
    signal tx_reg_en   : std_logic;
    signal tx_clock_en : std_logic;
    signal tx_clock_ovf: std_logic;
    signal tx_clock_rst: std_logic;
    signal tx_data     : std_logic_vector(11 downto 0);

begin

    RXClock: ENTITY work.E_COUNTER(A_COUNTER)
        generic map (
            G_COUNTER_RANGE => C_CLOCK_FREQ / BAUDRATE / 2
        )
        port map (
            enable_i => rx_clock_en,
            overflow_o => rx_clock_ovf,
            value_o => open,
            srst_i => rx_clock_rst,
            clk_i => clk, rst_i => rst
        );

    RXControl: ENTITY work.E_UART_RX_FSM(A_UART_RX_FSM)
        port map(rx,
            busy => rx_busy,
            bitc_en => rx_bitc_en,
            bitc_ovf => rx_bitc_ovf,
            bitc_rst => rx_bitc_rst,
            clock_en => rx_clock_en,
            clock_ovf => rx_clock_ovf,
            clock_rst => rx_clock_rst,
            reg_en => rx_reg_en,
            data_ready => data_read,
            clk => clk, rst => rst
        );

    RXBitCounter: ENTITY work.E_COUNTER(A_COUNTER)
        generic map(G_COUNTER_RANGE => 10)
        port map(
            enable_i => rx_bitc_en,
            overflow_o => rx_bitc_ovf,
            value_o => open,
            srst_i => rx_bitc_rst,
            clk_i => clk, rst_i => rst
        );

    RXRegister: ENTITY work.E_LEFTSHIFT_REGISTER(A_LEFTSHIFT_REGISTER)
        generic map(G_WIDTH => 10)
        port map(
            i => rx, q => open,
            parallel_in => '0',
            data_out => rx_data,
            data_in => "0000000000",
            write_en => rx_reg_en,
            clk => clk, rst => rst
        );

    TXClock: ENTITY work.E_COUNTER(A_COUNTER)
        generic map (
            G_COUNTER_RANGE => C_CLOCK_FREQ / BAUDRATE
        )
        port map (
            enable_i => tx_clock_en,
            overflow_o => tx_clock_ovf,
            value_o => open,
            srst_i => tx_clock_rst,
            clk_i => clk, rst_i => rst
        );

    TXControl: ENTITY work.E_UART_TX_FSM(A_UART_TX_FSM)
        port map(
            new_data => data_write,
            busy => tx_busy,
            bitc_en => tx_bitc_en,
            bitc_ovf => tx_bitc_ovf,
            bitc_rst => tx_bitc_rst,
            clock_en => tx_clock_en,
            clock_ovf => tx_clock_ovf,
            clock_rst => tx_clock_rst,
            data_send => data_send,
            reg_en => tx_reg_en,
            clk => clk, rst => rst
        );

    TXBitCounter: ENTITY work.E_COUNTER(A_COUNTER)
        generic map(G_COUNTER_RANGE => 12)
        port map(
            enable_i => tx_bitc_en,
            overflow_o => tx_bitc_ovf,
            value_o => open,
            srst_i => tx_bitc_rst,
            clk_i => clk, rst_i => rst
        );

    TXRegister: ENTITY work.E_LEFTSHIFT_REGISTER(A_LEFTSHIFT_REGISTER)
        generic map(G_WIDTH => 12, G_RESET_VALUE => '1')
        port map(
            i => '1', q => tx,
            parallel_in => data_write,
            data_out => open,
            data_in => tx_data,
            write_en => tx_reg_en,
            clk => clk, rst => rst
        );

    tx_data <= '0' & data_in & "111";
    data_out <= rx_data(8 downto 1);

end architecture;