---------------------------------------------------------------------------------------------------
-- Project CPU23
--
-- Hanno Sternberg
--
-- Basis Elemente: Generic counter
-- The Overflowflag remains active until enable is reset to 0
--
----------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE IEEE.numeric_std.all;
use work.constants.all;

Entity E_COUNTER is
    generic (G_COUNTER_RANGE: positive := 32 );
    port (
        clk_i       : in std_logic;        -- clock
        rst_i       : in std_logic;        -- reset
        enable_i    : in std_logic;        -- enable
        srst_i      : in std_logic;        -- sync. reset
        overflow_o  : out std_logic;       -- overflow flag
        value_o     : out integer range 0 to G_COUNTER_RANGE-1
    );
end Entity E_COUNTER;

Architecture A_COUNTER of E_COUNTER is
    subType TCounter is integer range 0 to G_COUNTER_RANGE-1;
    signal count : TCounter;
begin
    counter: process(clk_i, rst_i, enable_i)
    begin
        if(rst_i = C_RESET_VALUE) then
            count <= 0;                        -- async. reset
        elsif(rising_edge(clk_i)) then
            if(enable_i = '1') then
                if(count = G_COUNTER_RANGE-1) then
                    count <= count;
                else
                    count <= count + 1;        -- count
                end if;
            elsif(srst_i = '1') then   -- sync. reset
                count <= 0;
            end if;
        end if;
    end process counter;

    overflow_o <= '1' when (count = G_COUNTER_RANGE-1) else '0';
    value_o <= count;
end Architecture A_COUNTER;
