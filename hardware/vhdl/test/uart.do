add wave /t_uart_test/CLOCK
add wave /t_uart_test/UART_RX_DATA
add wave /t_uart_test/UART_TX_DATA
add wave /t_uart_test/DUT/RXControl/state
add wave /t_uart_test/DUT/TXControl/state

restart -f
run