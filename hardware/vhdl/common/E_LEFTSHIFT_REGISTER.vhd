---------------------------------------------------------------------------------------------------
-- Basic Element: Left shift register
--        Parallel and serial In / Out
--        Generic width
----------------------------------------------------------------------------------------------------
LIBRARY ieee;
use ieee.std_logic_1164.all;
use work.constants.all;

Entity E_LEFTSHIFT_REGISTER is
    generic(
        G_WIDTH : positive := 8;
        G_RESET_VALUE : std_logic := '0'
    );
    port (  clk         : in std_logic;
            rst         : in std_logic;
            write_en    : in std_logic;
            i           : in std_logic;
            q           : out std_logic;
            parallel_in : in std_logic;
            data_in     : in std_logic_vector(G_WIDTH-1 downto 0);
            data_out    : out std_logic_vector(G_WIDTH-1 downto 0)
    );
end Entity;

Architecture A_LEFTSHIFT_REGISTER of E_LEFTSHIFT_REGISTER is
    signal reg : std_logic_vector(G_WIDTH-1 downto 0);
begin
    process(rst,clk)
    begin
        if(rst = C_RESET_VALUE) then
            reg <= (others => G_RESET_VALUE);
        elsif (rising_edge(clk)) then
            if(write_en = '1') then
                reg <= reg(G_WIDTH-2 downto 0) & i; -- shift
            elsif (parallel_in = '1') then
                reg <= data_in;  -- parallel in
            else
                reg <= reg;    -- keep data
            end if;
        end if;
    end process;

    data_out <= reg;
    q <= reg(G_WIDTH-1);
end Architecture;