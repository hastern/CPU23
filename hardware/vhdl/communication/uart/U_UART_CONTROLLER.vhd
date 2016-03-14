library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;

entity E_UART_CONTROLLER is
    port (
        -- Transmission and receive lines
        rx      : in std_logic;
        rx_busy : out std_logic;
        tx      : out std_logic;
        tx_busy : out std_logic;
        -- Input Data
        data_in : in Word23;
        data_write : in std_logic; -- Send new data
        data_send : out std_logic; -- Data was send
        -- Output Data
        data_out : out Word23;
        data_read : out std_logic; -- Data was received
        --
        clk  : in  std_logic;
        rst  : in  std_logic
    );
end entity;

architecture A_UART_CONTROLLER of E_UART_CONTROLLER is

    signal rx_buffer : Word23;
    signal tx_buffer : Word23;
    signal rx_data_recv : std_logic;
    signal tx_data_send : std_logic;

    signal uart_data_in : std_logic_vector(7 downto 0);
    signal uart_data_write : std_logic;
    signal uart_data_send : std_logic;
    signal uart_data_out : std_logic_vector(7 downto 0);
    signal uart_data_read : std_logic;
    signal uart_rx_busy : std_logic;
    signal uart_tx_busy : std_logic;

    type state is (
        reset,      -- initial state
        await,      -- waiting for data
        data0,      -- bits 23 - 16
        data1,      -- bits 15 - 8
        data2,      -- bits 7 - 0
        finish
    );
    signal rx_state : state;
    signal rx_next_state : state;
    signal tx_state : state;
    signal tx_next_state : state;

begin

    UART : ENTITY work.E_UART(A_UART)
        port map(
            rx => rx, rx_busy => uart_rx_busy,
            tx => tx, tx_busy => uart_tx_busy,
            data_in => uart_data_in,
            data_write => uart_data_write,
            data_send => uart_data_send,
            data_out => uart_data_out,
            data_read => uart_data_read,
            clk => clk, rst => rst
        );


    assign_state: process(
            clk, rst,
            uart_data_out,
            rx_state, rx_next_state,
            tx_state, tx_next_state
        ) is
    begin
        if (rst = C_RESET_VALUE) then
            rx_state <= reset;
            tx_state <= reset;
        elsif (Rising_Edge(clk)) then
            case rx_next_state is
                when data0 =>
                    rx_buffer(23 downto 16) <= uart_data_out;
                when data1 =>
                    rx_buffer(15 downto 8) <= uart_data_out;
                when data2 =>
                    rx_buffer(7 downto 0) <= uart_data_out;
                when finish =>
                    data_out <= rx_buffer;
                    rx_buffer <= rx_buffer;
                when others =>
                    rx_buffer <= rx_buffer;
            end case;
            case tx_next_state is
                when await =>
                    tx_buffer <= data_in;
                when data0 =>
                    uart_data_in <= tx_buffer(23 downto 16);
                    tx_buffer <= tx_buffer;
                when data1 =>
                    uart_data_in <= tx_buffer(15 downto 8);
                    tx_buffer <= tx_buffer;
                when data2 =>
                    uart_data_in <= tx_buffer(7 downto 0);
                    tx_buffer <= tx_buffer;
                when others =>
                    tx_buffer <= tx_buffer;
                    uart_data_in <= uart_data_in;
            end case;
            rx_state <= rx_next_state;
            tx_state <= tx_next_state;
        end if;
    end process;

    rx_transition: process(clk, rst, rx_state, uart_data_read)
    begin
        case rx_state is
            when reset =>
                rx_next_state <= await;
            when await =>
                if (uart_data_read = '1') then
                    rx_next_state <= data0;
                else
                    rx_next_state <= await;
                end if;
            when data0 =>
                if (uart_data_read = '1') then
                    rx_next_state <= data1;
                else
                    rx_next_state <= data0;
                end if;
            when data1 =>
                if (uart_data_read = '1') then
                    rx_next_state <= data2;
                else
                    rx_next_state <= data1;
                end if;
            when data2 =>
                rx_next_state <= finish;
            when finish =>
                rx_next_state <= await;
        end case;
    end process;

    rx_output: process(clk, rst, rx_state)
    begin
        data_read <= '0';
        case rx_state is
            when reset =>
            when await =>
            when data0 =>
            when data1 =>
            when data2 =>
            when finish =>
                data_read <= '1';
        end case;
    end process;

    tx_transition: process(clk, rst, tx_state, data_write, uart_data_send)
    begin
        case tx_state is
            when reset =>
                tx_next_state <= await;
            when await =>
                if (data_write = '1') then
                    tx_next_state <= data0;
                else
                    tx_next_state <= await;
                end if;
            when data0 =>
                if (uart_data_send = '1') then
                    tx_next_state <= data1;
                else
                    tx_next_state <= data0;
                end if;
            when data1 =>
                if (uart_data_send = '1') then
                    tx_next_state <= data2;
                else
                    tx_next_state <= data1;
                end if;
            when data2 =>
                if (uart_data_send = '1') then
                    tx_next_state <= finish;
                else
                    tx_next_state <= data2;
                end if;
            when finish =>
                tx_next_state <= await;
        end case;
    end process;

    tx_output: process(clk, rst, tx_state)
    begin
        uart_data_write <= '0';
		  data_send <= '0';
        case tx_state is
            when reset =>
            when await =>
            when data0 =>
                uart_data_write <= '1';
            when data1 =>
                uart_data_write <= '1';
            when data2 =>
                uart_data_write <= '1';
            when finish =>
                data_send <= '1';
        end case;
    end process;

end architecture;
