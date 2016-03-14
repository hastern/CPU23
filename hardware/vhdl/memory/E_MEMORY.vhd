library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_MEMORY is
    port (
        clk : in std_logic;
        rst : in std_logic;
        addr : in Word23;
        data_i : in Word23;
        write_en : in std_logic;
        data_o : out Word23;
        -- DMA
        dma_addr : in Word23;
        dma_data : in Word23;
        -- bootloader
        bootload : in std_logic;
        bootload_data : in Word23;
        bootload_addr : in Word23
    );
end entity;

architecture A_MEMORY of E_MEMORY is
    constant MEM_TOTAL      : natural := 8388608;
    -- To synthesis the model with quartus reduce the size of the
    -- memory blocks (512, 128, 64, 0 seem to be a good fit)
    -- Modelsim can handle the big blocks (1024, 2048, 256, 3200)
    constant BOB_SIZE       : natural := 1024;
    constant PROG_SIZE      : natural := 2048;
    constant STACK_SIZE     : natural := 256;
    constant DISPLAY_SIZE   : natural := 3200;
    constant BOB_OFFSET     : natural := 0;
    constant PROG_OFFSET    : natural := BOB_OFFSET + PROG_SIZE;
    constant DISPLAY_OFFSET : natural := MEM_TOTAL - DISPLAY_SIZE;
    constant STACK_OFFSET   : natural := DISPLAY_OFFSET - STACK_SIZE;

    type mem_bob is array(0 to BOB_SIZE-1) of Word23;
    type mem_prog is array (0 to PROG_SIZE-1) of Word23;
    type mem_stack is array(0 to STACK_SIZE-1) of Word23;
    type mem_display is array(0 to DISPLAY_SIZE-1) of Word23;
    signal bob : mem_bob;
    signal prog : mem_prog;
    signal stack : mem_stack;
    signal display : mem_display;

begin

    process (clk, addr, data_i, dma_addr, dma_data, bootload, bootload_addr, bootload_data)
    begin
        if (rising_edge(clk)) then
            data_o <= "000000000000000000000000";
            if (bootload = '1') then
                bob(to_integer(unsigned(bootload_addr))) <= bootload_data;
            elsif (dma_addr /= "000000000000000000000000") then
                case dma_addr is
                    when "000000000000000000000001" => bob(36) <= dma_data;
                    when "000000000000000000000010" => bob(37) <= dma_data;
                    when "000000000000000000000100" => bob(38) <= dma_data;
                    when "000000000000000000001000" => bob(39) <= dma_data;
                    when "000000000000000000010000" => bob(40) <= dma_data;
                    when "000000000000000000100000" => bob(41) <= dma_data;
                    when "000000000000000001000000" => bob(42) <= dma_data;
                    when "000000000000000010000000" => bob(43) <= dma_data;
                    when "000000000000000100000000" => bob(44) <= dma_data;
                    when "000000000000001000000000" => bob(45) <= dma_data;
                    when "000000000000010000000000" => bob(46) <= dma_data;
                    when "000000000000100000000000" => bob(47) <= dma_data;
                    when "000000000001000000000000" => bob(48) <= dma_data;
                    when "000000000010000000000000" => bob(49) <= dma_data;
                    when "000000000100000000000000" => bob(50) <= dma_data;
                    when "000000001000000000000000" => bob(51) <= dma_data;
                    when "000000010000000000000000" => bob(52) <= dma_data;
                    when "000000100000000000000000" => bob(53) <= dma_data;
                    when "000001000000000000000000" => bob(54) <= dma_data;
                    when "000010000000000000000000" => bob(55) <= dma_data;
                    when "000100000000000000000000" => bob(56) <= dma_data;
                    when "001000000000000000000000" => bob(57) <= dma_data;
                    when "010000000000000000000000" => bob(58) <= dma_data;
                    when others =>
                end case;
                data_o <= "100110011001100110011001";
            else
                if (write_en = '1') then
                    if (to_integer(unsigned(addr)) < BOB_SIZE) then
                        bob(to_integer(unsigned(addr)) - BOB_OFFSET) <= data_i;
                    elsif (to_integer(unsigned(addr)) < (PROG_OFFSET + PROG_SIZE)) then
                        prog(to_integer(unsigned(addr)) - PROG_OFFSET) <= data_i;
                    elsif (to_integer(unsigned(addr)) >= DISPLAY_OFFSET) then
                        display(to_integer(unsigned(addr)) - DISPLAY_OFFSET) <= data_i;
                    elsif (to_integer(unsigned(addr)) >= STACK_OFFSET) then
                        stack(to_integer(unsigned(addr)) - STACK_OFFSET) <= data_i;
                    end if;
                end if;
                if (to_integer(unsigned(addr)) < BOB_SIZE) then
                    data_o <= bob(to_integer(unsigned(addr)) - BOB_OFFSET);
                elsif (to_integer(unsigned(addr)) < (PROG_OFFSET + PROG_SIZE)) then
                    data_o <= prog(to_integer(unsigned(addr)) - PROG_OFFSET);
                elsif (to_integer(unsigned(addr)) >= DISPLAY_OFFSET) then
                    data_o <= display(to_integer(unsigned(addr)) - DISPLAY_OFFSET);
                elsif (to_integer(unsigned(addr)) >= STACK_OFFSET) then
                    data_o <= stack(to_integer(unsigned(addr)) - STACK_OFFSET);
                end if;
            end if;
        end if;
    end process;

end architecture;
