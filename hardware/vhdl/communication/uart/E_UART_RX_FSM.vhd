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

entity E_UART_RX_FSM is
    port (
        rx : in std_logic;

        bitc_en : out std_logic; -- enable bitcounter
        bitc_ovf: in std_logic; -- bitcounter overflow
        bitc_rst: out std_logic; -- bitcounter reset
        clock_en : out std_logic; -- Clockdivider for baudrate
        clock_ovf: in std_logic; -- Clock-Tick for baudrate
        clock_rst: out std_logic; -- Clock Reset
        reg_en: out std_logic; -- register enable
        data_ready: out std_logic; -- read a full byte
        busy : out std_logic;

        clk  : in std_logic;
        rst  : in std_logic
    );
end entity E_UART_RX_FSM;


architecture A_UART_RX_FSM of E_UART_RX_FSM is
    type tstate is (
        reset,      -- initial state
        listen,     -- waiting falling edge on RX
        dataA,
        dataARst,
        dataB,
        dataBRst,
        finish
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

    transition: process(clk, rst, state, bitc_ovf, rx, clock_ovf)
    begin
        case state is
            when reset =>
                next_state <= listen;
            when listen =>
                if (rx = '0') then
                    next_state <= dataA;
                else
                    next_state <= listen;
                end if;
            when dataA =>
                if (clock_ovf = '1') then
                    next_state <= dataARst;
                else
                    next_state <= dataA;
                end if;
            when dataARst =>
                next_state <= dataB;
            when dataB =>
                if (clock_ovf = '1') then
                    next_state <= dataBRst;
                else
                    next_state <= dataB;
                end if;
            when dataBRst =>
                if (bitc_ovf = '1') then
                    next_state <= finish;
                else
                    next_state <= dataA;
                end if;
            when finish =>
                next_state <= listen;
        end case;
    end process;

    output: process(clk, rst, state, next_state)
    begin
        bitc_en <= '0';
        bitc_rst <= '0';
        clock_en <= '0';
        clock_rst <= '0';
        reg_en <= '0';
        data_ready <= '0';
        busy <= '1';
        case state is
            when reset =>
                busy <= '0';
            when listen =>
                busy <= '0';
            when dataA =>
                clock_en <= '1';
            when dataARst =>
                reg_en <= '1';
                clock_rst <= '1';
            when dataB =>
                clock_en <= '1';
            when dataBRst =>
                bitc_en <= '1';
                clock_rst <= '1';
            when finish =>
                bitc_rst <= '1';
                data_ready <= '1';
        end case;
    end process;

end architecture A_UART_RX_FSM;
