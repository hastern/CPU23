---------------------------------------------------------------------------------------------------
-- Project CPU23
--
-- Hanno Sternberg
--
-- UART Communication Finite State Machine
--
--
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;

entity E_UART_TX_FSM is
    port (
        new_data : in std_logic; -- signal the arrival of new data

        bitc_en : out std_logic; -- enable bitcounter
        bitc_ovf: in std_logic; -- bitcounter overflow
        bitc_rst: out std_logic; -- bitcounter reset
        clock_en : out std_logic; -- Clockdivider for baudrate
        clock_ovf: in std_logic; -- Clock-Tick for baudrate
        clock_rst: out std_logic; -- Clock Reset
        reg_en: out std_logic; -- register enable
        data_send : out std_logic; -- data was send
        busy : out std_logic;


        clk  : in std_logic;
        rst  : in std_logic
    );
end entity E_UART_TX_FSM;


architecture A_UART_TX_FSM of E_UART_TX_FSM is
    type tstate is (
        reset,      -- initial state
        await,      -- waiting for data
        data,       -- sending data bit
        dataRst,    -- Reset baud-clock
        finish      -- data received
    );
    signal state : tstate;
    signal next_state : tstate;
begin


    assign_state: process(clk, rst) is
    begin
        if (rst = C_RESET_VALUE) then
            state <= reset;
        elsif (Rising_Edge(clk)) then
            state <= next_state;
        end if;
    end process;

    transition: process(clk, rst, state, bitc_ovf, clock_ovf, new_data)
    begin
        case state is
            when reset =>
                next_state <= await;
            when await => if (new_data = '1') then
                    next_state <= data;
                else
                    next_state <= await;
                end if;
            when data =>
                if (clock_ovf = '1') then
                    next_state <= dataRst;
                else
                    next_state <= data;
                end if;
            when dataRst =>
                if (bitc_ovf = '1') then
                   next_state <= finish;
               else
                   next_state <= data;
               end if;
            when finish =>
                next_state <= await;
        end case;
    end process;

    output: process(clk, rst, state)
    begin
        bitc_en <= '0';
        bitc_rst <= '0';
        clock_en <= '0';
        clock_rst <= '0';
        reg_en <= '0';
        busy <= '1';
        data_send <= '0';
        case state is
            when reset =>
                busy <= '0';
            when await =>
                busy <= '0';
            when dataRst =>
                clock_en <= '1';
            when data =>
                busy <= '1';
                clock_rst <= '1';
                bitc_en <= '1';
                reg_en <= '1';
            when finish =>
                bitc_rst <= '1';
                data_send <= '1';
        end case;
    end process;

end architecture A_UART_TX_FSM;