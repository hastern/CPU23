


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_PROGRAM_COUNTER is

    port (
        clk_i         : in std_logic;
        rst_i         : in std_logic;
        -- Control
        next_i        : in std_logic;
        write_en      : in std_logic;
        -- Input and output data
        pc_i          : in Word23;
        pc_o          : out Word23
    );

end entity;

architecture A_PROGRAM_COUNTER of E_PROGRAM_COUNTER is

    signal data_i : Word23;
    signal data_o : Word23;

    signal enable : std_logic;

begin

    enable <= write_en or next_i;

    reg : ENTITY work.E_REGISTER
        port map (  i => data_i,
                    q => data_o,
                    clk => clk_i,
                    en => enable,
                    rst => rst_i );

    process(next_i, data_o, pc_i)
    begin
        pc_o <= data_o;
        if (next_i = '1') then
            data_i <= std_logic_vector(unsigned(data_o) + 1);
        else
            data_i <= pc_i;
        end if;
    end process;


end architecture;
