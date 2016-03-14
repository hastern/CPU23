
library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;


entity E_CPU23_FSM is

    port (
        -- Clock and Reset
        clk    : in  std_logic;
        rst    : in  std_logic;
        -- current instruction
        pc       : in Word23;
        instr    : out Word23;
        opcode   : in OpCode23;
        a        : in Register23;
        b        : in Register23;
        d        : in Register23;
        -- Result Register
        reg_sel  : out Register23;
        reg_override : out std_logic;
        reg_out  : out Word23;
        -- Register Content
        reg_a    : in Word23;
        reg_b    : in Word23;
        reg_d    : in Word23;
        -- Program Counter & Instruction
        pc_inc      : out std_logic;
        pc_set      : out std_logic;
        pc_next     : out Word23;
        fetch_instr : out std_logic;
        -- Interrupts handling
        ir_set    : out std_logic;
        ir_next   : out Word23;
        -- Memory & DMA
        mem_addr : out Word23;
        mem_data_in : out Word23;
        mem_data_out : in Word23;
        mem_write : out std_logic;
        mem_dma_addr : out Word23;
        mem_dma_data : out Word23;
        -- Bootload detection
        bootload : in std_logic;
        -- UART
        uart_rx : in Word23;
        uart_recv : in std_logic; -- Data received
        uart_tx : out Word23;
        uart_transmit : out std_logic; -- Send Data
        uart_send : in std_logic; -- Data was send
        -- Status Flags
        flag_equal    : in std_logic;
        flag_greater  : in std_logic;
        flag_lesser   : in std_logic;
        flag_zero     : in std_logic;
        flag_true     : in std_logic;
        flag_carry    : in std_logic;
        flag_overflow : in std_logic;
        flag_underflow: in std_logic;
        flag_interrupt: in std_logic;
        flag_halt     : in std_logic;
        interrupt     : out std_logic;
        -- Debug
        debug_state   : out pipeline_state
    );
end entity;

architecture A_CPU23_FSM of E_CPU23_FSM is
    signal state: pipeline_state;
    signal next_state: pipeline_state;
begin

    assign_state: process(clk, rst) is
    begin
        if (rst = C_RESET_VALUE) then
            state <= reset;
        elsif (rising_edge(clk)) then
            state <= next_state;
        end if;
    end process;

    transition: process(clk, rst, state, bootload, flag_halt, flag_interrupt, opcode) is
    begin
        case state is
            when reset =>
                if (bootload = '1') then
                    next_state <= bootloader;
                else
                    next_state <= init;
                end if;
            when bootloader =>
                if (bootload = '1') then
                    next_state <= bootloader;
                else
                    next_state <= reset;
                end if;
            when init =>
                if (bootload = '1') then
                    next_state <= bootloader;
                else
                    next_state <= fetch;
                end if;
            when fetch =>
                next_state <= fetch1;
            when fetch1 =>
                next_state <= decode;
            when decode =>
                case opcode is
                    when "00001" =>  -- LDR
                        next_state <= execLoad;
                    when "00010" =>  -- STR
                        next_state <= execStore;
                    when "00011" |   -- CPR
                         "00100" |   -- SET
                         "00101" |   -- BIT
                         "00110" |   -- ADD
                         "00111" |   -- SUB
                         "01000" |   -- LSL
                         "01001" |   -- LSR
                         "01010" |   -- AND
                         "01011" |   -- OR
                         "01100" |   -- XOR
                         "01101" |   -- NOT
                         "01110" =>  -- CMP
                        next_state <= execALU;
                    when "01111" |   -- BRA
                         "10000" =>  -- BNE
                        next_state <= execBranch;
                    when "10001" =>   -- JMP
                        next_state <= execJump;
                    when others =>
                        next_state <= incPC;
                end case;
            when execALU =>
                next_state <= writeBack;
            when execStore =>
                next_state <= incPC;
            when execLoad =>
                next_state <= writeLoad;
            when execBranch =>
                next_state <= check;
            when execJump =>
                next_state <= check;
            when writeBack =>
                next_state <= incPC;
            when writeLoad =>
                next_state <= incPC;
            when incPC =>
                next_state <= check;
            when check =>
                if (flag_halt = '1') then
                    next_state <= halt;
                elsif (flag_interrupt = '1') then
                    next_state <= savePC;
                else
                    next_state <= fetch;
                end if;
            when savePC =>
                next_state <= jumpIR;
            when jumpIR =>
                next_state <= fetch;
            when halt =>
                next_state <= halt; -- You may never leave
        end case;
    end process;

    output: process(state, pc, mem_data_out, reg_a, reg_b, reg_d, opcode, flag_zero, d, uart_recv, uart_send, uart_rx) is
    begin
        pc_set <= '0';
        pc_inc <= '0';
        ir_set <= '0';
        fetch_instr <= '0';
        mem_write <= '0';
        reg_override <= '0';
        mem_addr <= (others => '0');
        mem_data_in <= (others => '0');
        reg_sel <= (others => '0');
        pc_next <= (others => '0');
        ir_next <= (others => '0');
        instr <= (others => '0');
        reg_out <= (others => '0');
        interrupt <= '0';
        uart_transmit <= '0';
        uart_tx <= (others => '0');
        mem_dma_data <= (others => '0');
        mem_dma_addr <= (others => '0');
        debug_state <= state;
        case state is
            when reset =>
                mem_addr <= "000000000000000000000000";
            when bootloader =>
            when init =>
                reg_sel <= "111111";
                reg_override <= '1';
                reg_out <= '0' & mem_data_out(22 downto 0);
            when fetch =>
                mem_addr <= pc;
            when fetch1 =>
                instr <= mem_data_out;
                fetch_instr <= '1';
            when decode =>
            when execALU =>
            when execStore =>
                mem_addr <= reg_d;
                mem_data_in <= reg_a;
                mem_write <= '1';
                if (reg_d = DMA_ADDR_UARTTX_INT) then
                    uart_transmit <= '1';
                    uart_tx <= reg_a;
                end if;
            when execLoad =>
                mem_addr <= reg_a;
            when execBranch =>
                if (opcode = "01111" and flag_zero = '1') then -- BRA
                    pc_set <= '1';
                    pc_next <= reg_a;
                elsif (opcode = "10000" and flag_zero = '0') then -- BNE
                    pc_set <= '1';
                    pc_next <= reg_a;
                else
                    -- WHAT THE FUCK !?!
                end if;
            when execJump =>
                pc_set <= '1';
                pc_next <= reg_a;
            when writeBack =>
                reg_sel <= d;
            when writeLoad =>
                reg_override <= '1';
                reg_out <= mem_data_out;
            when incPC =>
                pc_inc <= '1';
            when check =>
                if (uart_recv = '1') then
                    interrupt <= '1';
                    mem_dma_data <= uart_rx;
                    mem_dma_addr <= DMA_ADDR_UARTRX_INT;
                end if;
                if (uart_send = '1') then
                    interrupt <= '1';
                end if;
            when savePC =>
                ir_next <= pc;
                ir_set <= '1';
            when jumpIR =>
            when halt =>
        end case;
    end process;

end architecture;
