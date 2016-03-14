library ieee;
use ieee.std_logic_1164.all;
use work.constants.all;

entity E_REGISTER_BANK is

    port (
        clk_i           : in std_logic;
        rst_i           : in std_logic;
        -- Register Selection
        regsel_i        : in std_logic_vector(5 downto 0);
        regsel_o1       : in std_logic_vector(5 downto 0);
        regsel_o2       : in std_logic_vector(5 downto 0);
        -- Input and output data
        data_i          : in Word23;
        data_o1         : out Word23;
        data_o2         : out Word23;
        -- Interrupts handling
        ir_set          : in std_logic;
        ir_next         : in Word23;
        -- Program Counter
        pc_o            : out Word23;
        pc_inc          : in std_logic;
        pc_set          : in std_logic;
        pc_next         : in Word23;
        -- Status Register
        sr_mask         : in Word23;
        set_equal       : in std_logic;
        set_greater     : in std_logic;
        set_lesser      : in std_logic;
        set_zero        : in std_logic;
        set_true        : in std_logic;
        set_carry       : in std_logic;
        set_overflow    : in std_logic;
        set_underflow   : in std_logic;
        set_interrupt   : in std_logic;
        set_halt        : in std_logic;
        flag_equal      : out std_logic;
        flag_greater    : out std_logic;
        flag_lesser     : out std_logic;
        flag_zero       : out std_logic;
        flag_true       : out std_logic;
        flag_carry      : out std_logic;
        flag_overflow   : out std_logic;
        flag_underflow  : out std_logic;
        flag_interrupt  : out std_logic;
        flag_halt       : out std_logic;
        -- Debug outputs
        debug_reg_out : out std_logic_vector((24*64)-1 downto 0)
    );

end entity;


architecture A_REGISTER_BANK of E_REGISTER_BANK is

    signal regOut : std_logic_vector((24*64)-1 downto 0);
    signal regOut1 : std_logic_vector((24*64)-1 downto 0);
    signal regOut2 : std_logic_vector((24*64)-1 downto 0);
    signal regEn : std_logic_vector(63 downto 0);

    signal sr_data : Word23;
    signal sr_en : std_logic;

    signal pc_data : Word23;
    signal ir_data : Word23;

    signal ir_enable : std_logic;
    signal pc_enable : std_logic;

begin

    regSelector: ENTITY work.E_REGISTER_SELECTOR
        port map (
            regsel_i => regsel_i,
            reg_en_o => regEn
        );

    regMergeOp1: ENTITY work.E_REG_MERGE
        port map ( sel_i => regsel_o1, data_i => regOut1, data_o => data_o1 );
    regMergeOp2: ENTITY work.E_REG_MERGE
        port map ( sel_i => regsel_o2, data_i => regOut2, data_o => data_o2 );


    -- General Purpose Registers R0 - R45
    GEN_REGS:
        for I in 0 to 45 generate
        regRI : ENTITY work.E_REGISTER
          port map ( i => data_i, q => regOut((24*(I+1))-1 downto 24*I), clk => clk_i, en => regEn(I), rst => rst_i );
        end generate;

    -- Special Registers
    regRA: ENTITY work.E_REGISTER
       port map ( i => data_i, q => regOut((24*47)-1 downto 24*46), clk => clk_i, en => regEn(46), rst => rst_i );
    regRB: ENTITY work.E_REGISTER
       port map ( i => data_i, q => regOut((24*48)-1 downto 24*47), clk => clk_i, en => regEn(47), rst => rst_i );
    regRX: ENTITY work.E_REGISTER
       port map ( i => data_i, q => regOut((24*49)-1 downto 24*48), clk => clk_i, en => regEn(48), rst => rst_i );
    regRT: ENTITY work.E_REGISTER
       port map ( i => data_i, q => regOut((24*50)-1 downto 24*49), clk => clk_i, en => regEn(49), rst => rst_i );
    regSR: ENTITY work.E_STATUS_REGISTER
       port map ( clk_i, rst_i,
                  regEn(50),
                  sr_mask,
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
                  flag_equal,
                  flag_greater,
                  flag_lesser,
                  flag_zero,
                  flag_true,
                  flag_carry,
                  flag_overflow,
                  flag_underflow,
                  flag_interrupt,
                  flag_halt,
                  data_i,
                  regOut((24*51)-1 downto 24*50)
                );
    regTR: ENTITY work.E_REGISTER
       port map ( i => data_i, q => regOut((24*52)-1 downto 24*51), clk => clk_i, en => regEn(51), rst => rst_i );
    regPR: ENTITY work.E_REGISTER
       port map ( i => data_i, q => regOut((24*53)-1 downto 24*52), clk => clk_i, en => regEn(52), rst => rst_i );
    regIS: ENTITY work.E_REGISTER
       port map ( i => data_i, q => regOut((24*54)-1 downto 24*53), clk => clk_i, en => regEn(53), rst => rst_i );
    regIM: ENTITY work.E_REGISTER
       port map ( i => data_i, q => regOut((24*55)-1 downto 24*54), clk => clk_i, en => regEn(54), rst => rst_i );
    regIV: ENTITY work.E_REGISTER
       port map ( i => data_i, q => regOut((24*56)-1 downto 24*55), clk => clk_i, en => regEn(55), rst => rst_i );
    regIH: ENTITY work.E_REGISTER
       port map ( i => data_i, q => regOut((24*57)-1 downto 24*56), clk => clk_i, en => regEn(56), rst => rst_i );
    regIR: ENTITY work.E_REGISTER
       port map ( i => ir_data,
                  q => regOut((24*58)-1 downto 24*57),
                  clk => clk_i,
                  en => ir_enable,
                  rst => rst_i
                );
    regFP: ENTITY work.E_REGISTER
       port map ( i => data_i, q => regOut((24*59)-1 downto 24*58), clk => clk_i, en => regEn(58), rst => rst_i );
    regSP: ENTITY work.E_REGISTER
       port map ( i => data_i, q => regOut((24*60)-1 downto 24*59), clk => clk_i, en => regEn(59), rst => rst_i );
    regBP: ENTITY work.E_REGISTER
       port map ( i => data_i, q => regOut((24*61)-1 downto 24*60), clk => clk_i, en => regEn(60), rst => rst_i );
    regDB: ENTITY work.E_REGISTER
       port map ( i => data_i, q => regOut((24*62)-1 downto 24*61), clk => clk_i, en => regEn(61), rst => rst_i );
    regDM: ENTITY work.E_REGISTER
       port map ( i => data_i, q => regOut((24*63)-1 downto 24*62), clk => clk_i, en => regEn(62), rst => rst_i );
    regPC: ENTITY work.E_PROGRAM_COUNTER
       port map ( clk_i => clk_i, rst_i => rst_i,
                  next_i => pc_inc, write_en => pc_enable,
                  pc_i => pc_data, pc_o => regOut((24*64)-1 downto 24*63)
                );

    regOut1 <= regOut;
    regOut2 <= regOut;
    debug_reg_out <= regOut;
    pc_o <= regOut((24*64)-1 downto 24*63);
    pc_data <= pc_next when (pc_set = '1') else data_i;
    ir_data <= ir_next when (ir_set = '1') else data_i;
    ir_enable <= regEn(57) or ir_set;
    pc_enable <= regEn(63) or pc_set;

end architecture;