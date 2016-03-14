---------------------------------------------------------------------------------------------------
-- Project CPU23
--
-- Hanno Sternberg
--
-- Basic constants
--
----------------------------------------------------------------------------------------------------
LIBRARY ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Package constants is
    --General Constants

    --C_RESET_VALUE: defines if Reset is HIGH- or LOW-Active
    constant C_RESET_VALUE : std_logic := '1';

    constant MaxCoordX: natural := 640;
    constant MaxCoordY: natural := 480;

    constant C_VGA_X_MAX    : std_logic_vector(11 downto 0) := x"320"; --800
    constant C_VGA_Y_MAX    : std_logic_vector(11 downto 0) := x"209"; --521
    constant C_VGA_HS_DELAY : std_logic_vector(11 downto 0) := "0000" & x"61"; --97
    constant C_VGA_VS_DELAY : std_logic_vector(11 downto 0) := "00000000"& x"3"; --3
    constant C_VGA_VISX_MIN : std_logic_vector(9 downto 0) := "0010010000";  -- 144
    constant C_VGA_VISX_MAX : std_logic_vector(9 downto 0) := "1100010000";  -- 784
    constant C_VGA_VISY_MIN : std_logic_vector(9 downto 0) := "0000100111";  -- 39
    constant C_VGA_VISY_MAX : std_logic_vector(9 downto 0) := "1000000111";  -- 519

    constant C_DATA_WIDTH : natural := 24;
    constant C_CONSTANT_WIDTH : natural := 12;
    constant C_REG_COUNT  : natural := 64;

    constant C_CLOCK_FREQ : natural := 50000000;

    subtype Word23 is std_logic_vector(23 downto 0);
    subtype OpCode23 is std_logic_vector(4 downto 0);
    subtype Register23 is std_logic_vector(5 downto 0);
    subtype Constant23 is std_logic_vector(11 downto 0);

    type pipeline_state is (
        reset,          -- reset everything
        bootloader,     -- bootloader is active
        init,           -- Initialize everything
        fetch,          -- Fetch the next instruction
        fetch1,
        decode,         -- Decode the current instruction
        execALU,        -- Execute ALU operation
        execStore,      -- Store a value the the memory
        execLoad,       -- Load a value from the memory
        execBranch,     -- Execute branching operation
        execJump,       -- Execute jump operation
        writeBack,      -- Write back the result from the ALU
        writeLoad,      -- Write back the loaded value
        incPC,          -- Increment the program counter
        check,          -- Check for interrupts
        savePC,         -- Save the Program counter
        jumpIR,         -- Jump to interrupts handler
        halt            -- Halt the CPU
    );

    constant DMA_ADDR00_EXT : Word23 := "000000000000000000000001";
    constant DMA_ADDR01_EXT : Word23 := "000000000000000000000010";
    constant DMA_ADDR02_EXT : Word23 := "000000000000000000000100";
    constant DMA_ADDR03_EXT : Word23 := "000000000000000000001000";
    constant DMA_ADDR04_EXT : Word23 := "000000000000000000010000";
    constant DMA_ADDR05_EXT : Word23 := "000000000000000000100000";
    constant DMA_ADDR06_EXT : Word23 := "000000000000000001000000";
    constant DMA_ADDR07_EXT : Word23 := "000000000000000010000000";
    constant DMA_ADDR08_EXT : Word23 := "000000000000000100000000";
    constant DMA_ADDR09_EXT : Word23 := "000000000000001000000000";
    constant DMA_ADDR10_EXT : Word23 := "000000000000010000000000";
    constant DMA_ADDR11_EXT : Word23 := "000000000000100000000000";
    constant DMA_ADDR12_EXT : Word23 := "000000000001000000000000";
    constant DMA_ADDR13_EXT : Word23 := "000000000010000000000000";
    constant DMA_ADDR14_EXT : Word23 := "000000000100000000000000";
    constant DMA_ADDR15_EXT : Word23 := "000000001000000000000000";
    constant DMA_ADDR16_EXT : Word23 := "000000010000000000000000";
    constant DMA_ADDR17_EXT : Word23 := "000000100000000000000000";
    constant DMA_ADDR18_EXT : Word23 := "000001000000000000000000";
    constant DMA_ADDR19_EXT : Word23 := "000010000000000000000000";
    constant DMA_ADDR20_EXT : Word23 := "000100000000000000000000";
    constant DMA_ADDR21_EXT : Word23 := "001000000000000000000000";
    constant DMA_ADDR22_EXT : Word23 := "010000000000000000000000";

    constant DMA_ADDR00_INT : Word23 := "000000000000000000100100";
    constant DMA_ADDR01_INT : Word23 := "000000000000000000100101";
    constant DMA_ADDR02_INT : Word23 := "000000000000000000100110";
    constant DMA_ADDR03_INT : Word23 := "000000000000000000100111";
    constant DMA_ADDR04_INT : Word23 := "000000000000000000101000";
    constant DMA_ADDR05_INT : Word23 := "000000000000000000101001";
    constant DMA_ADDR06_INT : Word23 := "000000000000000000101010";
    constant DMA_ADDR07_INT : Word23 := "000000000000000000101011";
    constant DMA_ADDR08_INT : Word23 := "000000000000000000101100";
    constant DMA_ADDR09_INT : Word23 := "000000000000000000101101";
    constant DMA_ADDR10_INT : Word23 := "000000000000000000101110";
    constant DMA_ADDR11_INT : Word23 := "000000000000000000101111";
    constant DMA_ADDR12_INT : Word23 := "000000000000000000110000";
    constant DMA_ADDR13_INT : Word23 := "000000000000000000110001";
    constant DMA_ADDR14_INT : Word23 := "000000000000000000110010";
    constant DMA_ADDR15_INT : Word23 := "000000000000000000110011";
    constant DMA_ADDR16_INT : Word23 := "000000000000000000110100";
    constant DMA_ADDR17_INT : Word23 := "000000000000000000110101";
    constant DMA_ADDR18_INT : Word23 := "000000000000000000110110";
    constant DMA_ADDR19_INT : Word23 := "000000000000000000110111";
    constant DMA_ADDR20_INT : Word23 := "000000000000000000111000";
    constant DMA_ADDR21_INT : Word23 := "000000000000000000111001";
    constant DMA_ADDR22_INT : Word23 := "010000000000000000111010";

    constant DMA_ADDR_RESET_EXT    : Word23 := DMA_ADDR00_EXT;
    constant DMA_ADDR_TIMER_EXT    : Word23 := DMA_ADDR01_EXT;
    constant DMA_ADDR_KEYBOARD_EXT : Word23 := DMA_ADDR03_EXT;
    constant DMA_ADDR_MOUSE_EXT    : Word23 := DMA_ADDR04_EXT;
    constant DMA_ADDR_UARTTX_EXT   : Word23 := DMA_ADDR05_EXT;
    constant DMA_ADDR_UARTRX_EXT   : Word23 := DMA_ADDR06_EXT;

    constant DMA_ADDR_RESET_INT    : Word23 := DMA_ADDR00_INT;
    constant DMA_ADDR_TIMER_INT    : Word23 := DMA_ADDR01_INT;
    constant DMA_ADDR_KEYBOARD_INT : Word23 := DMA_ADDR03_INT;
    constant DMA_ADDR_MOUSE_INT    : Word23 := DMA_ADDR04_INT;
    constant DMA_ADDR_UARTTX_INT   : Word23 := DMA_ADDR05_INT;
    constant DMA_ADDR_UARTRX_INT   : Word23 := DMA_ADDR06_INT;


end Package;
