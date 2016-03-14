


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_STATUS_REGISTER is

    port (
        clk_i         : in std_logic;
        rst_i         : in std_logic;
        -- Control
        write_en      : in std_logic;
        mask          : in Word23;
        -- flags_in
        set_equal    : in std_logic;
        set_greater  : in std_logic;
        set_lesser   : in std_logic;
        set_zero     : in std_logic;
        set_true     : in std_logic;
        set_carry    : in std_logic;
        set_overflow : in std_logic;
        set_underflow: in std_logic;
        set_interrupt: in std_logic;
        set_halt     : in std_logic;
        -- flags out
        flag_equal    : out std_logic;
        flag_greater  : out std_logic;
        flag_lesser   : out std_logic;
        flag_zero     : out std_logic;
        flag_true     : out std_logic;
        flag_carry    : out std_logic;
        flag_overflow : out std_logic;
        flag_underflow: out std_logic;
        flag_interrupt: out std_logic;
        flag_halt     : out std_logic;
        -- Input and output data
        sr_i          : in Word23;
        sr_o          : out Word23
    );

end entity;

architecture A_STATUS_REGISTER of E_STATUS_REGISTER is

    signal data_i : Word23;
    signal data_o : Word23;

    signal enable : std_logic;

begin

    reg : ENTITY work.E_REGISTER
        port map (  i => data_i,
                    q => data_o,
                    clk => clk_i,
                    en => enable,
                    rst => rst_i );

    process(mask,
            data_o,
            set_equal,
            set_greater,
            set_lesser,
            set_zero,
            set_true,
            set_carry,
            set_overflow,
            set_underflow,
            set_interrupt,
            set_halt,
            sr_i,
            write_en)
    begin
        if (mask /= "000000000000000000000000") then
            data_i(0)  <=  data_o(0)  and (not mask(0));
            data_i(1)  <=  data_o(1)  and (not mask(1));
            data_i(2)  <=  data_o(2)  and (not mask(2));
            data_i(3)  <=  data_o(3)  and (not mask(3));
            data_i(4)  <=  data_o(4)  and (not mask(4));
            data_i(5)  <= (data_o(5)  and (not mask(5)))  or set_overflow;
            data_i(6)  <= (data_o(6)  and (not mask(6)))  or set_zero;
            data_i(7)  <= (data_o(7)  and (not mask(7)))  or set_underflow;
            data_i(8)  <= (data_o(8)  and (not mask(8)))  or set_carry;
            data_i(9)  <= (data_o(9)  and (not mask(9)))  or set_lesser;
            data_i(10) <= (data_o(10) and (not mask(10))) or set_equal;
            data_i(11) <= (data_o(11) and (not mask(11))) or set_greater;
            data_i(12) <= (data_o(12) and (not mask(12))) or set_halt;
            data_i(13) <= (data_o(13) and (not mask(13))) or set_true;
            data_i(14) <= (data_o(14) and (not mask(14))) or set_interrupt;
            data_i(15) <=  data_o(15) and (not mask(15));
            data_i(16) <=  data_o(16) and (not mask(16));
            data_i(17) <=  data_o(17) and (not mask(17));
            data_i(18) <=  data_o(18) and (not mask(18));
            data_i(19) <=  data_o(19) and (not mask(19));
            data_i(20) <=  data_o(20) and (not mask(20));
            data_i(21) <=  data_o(21) and (not mask(21));
            data_i(22) <=  data_o(22) and (not mask(22));
            data_i(23) <=  data_o(23) and (not mask(23));
            enable <= '1';
        else
            data_i <= sr_i;
            enable <= write_en;
        end if;
    end process;

    process (data_o) is
    begin
        sr_o <= data_o;
        flag_overflow  <= data_o(5);
        flag_zero      <= data_o(6);
        flag_underflow <= data_o(7);
        flag_carry     <= data_o(8);
        flag_lesser    <= data_o(9);
        flag_equal     <= data_o(10);
        flag_greater   <= data_o(11);
        flag_halt      <= data_o(12);
        flag_true      <= data_o(13);
        flag_interrupt <= data_o(14);
    end process;

end architecture;
