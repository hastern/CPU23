library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity E_CPU23 is
    port (
        -- UART
        uart_rx : in std_logic;
        uart_tx : out std_logic;
        -- Bootloader
        bootload_en : in std_logic;
        bootload_addr : in Word23;
        bootload_data : in Word23;
        -- Debug
        debug_instruction : out Word23;
        debug_pipeline : out pipeline_state;
        debug_registers : out std_logic_vector((24*64)-1 downto 0);
        -- Clock & Reset
        clk    : in  std_logic;
        rst    : in  std_logic
    );
end entity;

architecture A_CPU23 of E_CPU23 is
    -- Encoded instruction
    signal pc : Word23;
    signal instruction : Word23;
    -- decoded instruction
    signal opcode : OpCode23;
    signal op_a   : Register23;
    signal op_b   : Register23;
    signal op_d   : Register23;
    signal cst    : Constant23;
    -- Register selection based on FSM
    signal reg_sel_i: Register23;
    signal reg_override : std_logic;
    signal reg_override_data : Word23;
    signal reg_data : Word23;
    signal fetch_instr: std_logic;
    -- Program Counter
    signal pc_set : std_logic;
    signal pc_inc : std_logic;
    signal pc_next : Word23;
    -- Interrupt Handling
    signal ir_set : std_logic;
    signal ir_next : Word23;
    -- Operand Register value
    signal reg_a : Word23;
    signal reg_b : Word23;
    signal reg_d : Word23;
    signal reg_out : Word23;

    signal memory_addr : Word23;
    signal memory_data_in : Word23;
    signal memory_data_out : Word23;
    signal memory_write : std_logic;

    -- Status Register Flags
    signal sr_mask : Word23;

    signal flag_equal      : std_logic;
    signal flag_greater    : std_logic;
    signal flag_lesser     : std_logic;
    signal flag_zero       : std_logic;
    signal flag_true       : std_logic;
    signal flag_carry      : std_logic;
    signal flag_overflow   : std_logic;
    signal flag_underflow  : std_logic;
    signal flag_interrupt  : std_logic;
    signal flag_halt       : std_logic;

    signal set_equal     : std_logic;
    signal set_greater   : std_logic;
    signal set_lesser    : std_logic;
    signal set_zero      : std_logic;
    signal set_true      : std_logic;
    signal set_carry     : std_logic;
    signal set_overflow  : std_logic;
    signal set_underflow : std_logic;
    signal set_interrupt : std_logic;
    signal set_halt      : std_logic;

    -- UART Peripheral
    signal uart_data_in    : Word23;
    signal uart_data_out   : Word23;
    signal uart_data_read  : std_logic;
    signal uart_data_write : std_logic;
    signal uart_data_send  : std_logic;
    signal uart_rx_busy    : std_logic;
    signal uart_tx_busy    : std_logic;
    signal fsm_tx_data : Word23;
    signal fsm_tx_write : std_logic;
    -- DMA
    signal dma_addr : Word23;
    signal dma_data : Word23;

begin

    Decoder: ENTITY work.E_OPCODE_DECODER(A_OPCODE_DECODER)
        port map (clk, rst,
            instr => instruction,
            write_en => fetch_instr,
            op => opcode,
            a => op_a,
            b => op_b,
            d => op_d,
            c => cst,
            halt => set_halt
        );

    Memory: ENTITY work.E_MEMORY(A_MEMORY)
        port map(clk, rst,
            addr => memory_addr,
            data_i => memory_data_in,
            write_en => memory_write,
            data_o => memory_data_out,
            dma_addr => dma_addr,
            dma_data => dma_data,
            bootload => bootload_en,
            bootload_addr => bootload_addr,
            bootload_data => bootload_data
        );

    StatusMask : ENTITY work.E_STATUS_MASK(A_STATUS_MASK)
        port map (opcode, sr_mask);

    Alu: ENTITY work.E_ALU_CORE(A_ALU_CORE)
        port map (
                    clk, rst,
                    opcode,
                    reg_a, reg_b, cst, reg_d,
                    set_overflow,
                    set_underflow,
                    set_zero,
                    set_true,
                    set_carry,
                    set_equal,
                    set_lesser,
                    set_greater
                );

    Bank: ENTITY work.E_REGISTER_BANK(A_REGISTER_BANK)
        port map(clk_i => clk, rst_i => rst,
                 -- Register Selection
                 regsel_i => reg_sel_i,
                 regsel_o1 => op_a,
                 regsel_o2 => op_b,
                 -- Input and output data
                 data_i => reg_data,
                 data_o1 => reg_a,
                 data_o2 => reg_b,
                 -- Interrupts handling
                 ir_set => ir_set,
                 ir_next => ir_next,
                 -- Program Counter
                 pc_o => pc,
                 pc_set => pc_set,
                 pc_inc => pc_inc,
                 pc_next => pc_next,
                 -- Status Register
                 sr_mask => sr_mask,
                 set_equal => set_equal,
                 set_greater => set_greater,
                 set_lesser => set_lesser,
                 set_zero => set_zero,
                 set_true => set_true,
                 set_carry => set_carry,
                 set_overflow => set_overflow,
                 set_underflow => set_underflow,
                 set_interrupt => set_interrupt,
                 set_halt => set_halt,
                 flag_equal => flag_equal,
                 flag_greater => flag_greater,
                 flag_lesser => flag_lesser,
                 flag_zero => flag_zero,
                 flag_true => flag_true,
                 flag_carry => flag_carry,
                 flag_overflow => flag_overflow,
                 flag_underflow => flag_underflow,
                 flag_interrupt => flag_interrupt,
                 flag_halt => flag_halt,
                 debug_reg_out => debug_registers);

    Control: ENTITY work.E_CPU23_FSM(A_CPU23_FSM)
        port map(
            clk, rst,
            -- current instruction
            pc => pc,
            instr => instruction,
            opcode => opcode,
            a => op_a,
            b => op_b,
            d => op_d,
            -- Result Register
            reg_sel => reg_sel_i,
            reg_override => reg_override,
            reg_out => reg_override_data,
            reg_a => reg_a,
            reg_b => reg_b,
            reg_d => reg_d,
            -- Program Counter Control
            pc_inc => pc_inc,
            pc_set => pc_set,
            pc_next => pc_next,
            fetch_instr => fetch_instr,
            -- Memory
            mem_addr => memory_addr,
            mem_data_in  => memory_data_in,
            mem_data_out => memory_data_out,
            mem_write => memory_write,
            mem_dma_addr => dma_addr,
            mem_dma_data => dma_data,
            bootload => bootload_en,
            -- UART
            uart_rx => uart_data_out,
            uart_recv => uart_data_read,
            uart_tx => uart_data_in,
            uart_transmit => uart_data_write,
            uart_send => uart_data_send,
            -- Status Flags
            flag_equal => flag_equal,
            flag_greater => flag_greater,
            flag_lesser => flag_lesser,
            flag_zero => flag_zero,
            flag_true => flag_true,
            flag_carry => flag_carry,
            flag_overflow => flag_overflow,
            flag_underflow => flag_underflow,
            flag_interrupt => flag_interrupt,
            flag_halt => flag_halt,
            interrupt => set_interrupt,
            debug_state => debug_pipeline
        );

    UART : ENTITY work.E_UART_CONTROLLER(A_UART_CONTROLLER)
        port map(
            rx => uart_rx, rx_busy => uart_rx_busy,
            tx => uart_tx, tx_busy => uart_tx_busy,
            data_in => uart_data_in,
            data_write => uart_data_write,
            data_out => uart_data_out,
            data_read => uart_data_read,
            data_send => uart_data_send,
            clk => clk, rst => rst
        );

    reg_data <= reg_override_data when (reg_override = '1') else reg_d;
    debug_instruction <= instruction;

end architecture;
