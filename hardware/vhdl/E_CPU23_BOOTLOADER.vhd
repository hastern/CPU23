library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;


entity E_CPU23_BOOTLOADER is
    port (
        addr : out std_logic_vector(23 downto 0);
        data : out std_logic_vector(23 downto 0);
        active : out std_logic;

        uart_data_in    : in std_logic_vector(23 downto 0);
        uart_data_read  : in std_logic;
        uart_data_out   : out std_logic_vector(23 downto 0);
        uart_data_write : out std_logic;
        uart_data_send  : in std_logic;

        clk : in std_logic;
        rst : in std_logic
    );
end entity;

architecture A_CPU23_BOOTLOADER of E_CPU23_BOOTLOADER is

begin

end architecture;
