/**
 *
 *
 */

#ifndef __CPU_23_H__
#define __CPU_23_H__

#include <stdint.h>
#include <stdio.h>

/** OpCode definition */
enum e_OpCode {
    NOP = 0x00, LDR = 0x01, STR = 0x02, CPR = 0x03,
    SET = 0x04, BIT = 0x05, ADD = 0x06, SUB = 0x07,
    LSL = 0x08, LSR = 0x09, AND = 0x0A, OR  = 0x0B,
    XOR = 0x0C, NOT = 0x0D, CMP = 0x0E, BRA = 0x0F,
    BNE = 0x10, JMP = 0x11, EMW = 0x12, EMR = 0x13,
    HLT = 0x1F
};
typedef unsigned OpCode;

/** Register selection */
enum e_RegisterSelect {
    R0  = 0x00, R1  = 0x01, R2  = 0x02, R3  = 0x03, R4  = 0x04,
    R5  = 0x05, R6  = 0x06, R7  = 0x07, R8  = 0x08, R9  = 0x09,
    R10 = 0x0A, R11 = 0x0B, R12 = 0x0C, R13 = 0x0D, R14 = 0x0E,
    R15 = 0x0F, R16 = 0x10, R17 = 0x11, R18 = 0x12, R19 = 0x13,
    R20 = 0x14, R21 = 0x15, R22 = 0x16, R23 = 0x17, R24 = 0x18,
    R25 = 0x19, R26 = 0x1A, R27 = 0x1B, R28 = 0x1C, R29 = 0x1D,
    R30 = 0x1E, R31 = 0x1F, R32 = 0x20, R33 = 0x21, R34 = 0x22,
    R35 = 0x23, R36 = 0x24, R37 = 0x25, R38 = 0x26, R39 = 0x27,
    R40 = 0x28, R41 = 0x29, R42 = 0x2A, R43 = 0x2B, R44 = 0x2C,
    R45 = 0x2D,
    RA  = 0x2E, RB  = 0x2F, RX  = 0x30,
    RT  = 0x31,
    SR  = 0x32,
    TR  = 0x33,
    PR  = 0x34,
    IS  = 0x35, IM  = 0x36, IV  = 0x37, IH  = 0x38, IR  = 0x39,
    FP  = 0x3A,
    SP  = 0x3B,
    BP  = 0x3C,
    DB = 0x03D,
    DM  = 0x3E,
    PC  = 0x3F,
};
typedef unsigned RegisterSelect;

typedef unsigned Constant;
typedef unsigned Byte;
typedef unsigned Word;

union u_Instruction {
    struct tripleOp{
        RegisterSelect D:6;
        RegisterSelect B:6;
        RegisterSelect A:6;
        OpCode opcode:5;
        Byte nonExec:1;
    } tripleOp;
    struct doubleOp{
        RegisterSelect D:6;
        Constant C:6;
        RegisterSelect A:6;
        OpCode opcode:5;
        Byte nonExec:1;
    } doubleOp;
    struct singleOpA{
        Constant C:12;
        RegisterSelect A:6;
        OpCode opcode:5;
        Byte nonExec:1;
    } singleOpA;
    struct singleOpD{
        RegisterSelect D:6;
        Constant C:12;
        OpCode opcode:5;
        Byte nonExec:1;
    } singleOpD;
    struct info{
        unsigned int data:18;
        OpCode opcode:5;
        Byte nonExec:1;
    } info;
    Word word:24;
    char byte[3];
};
typedef union u_Instruction Instruction;

/* Define the registers used by the instruction */
struct s_RegisterUse {
    int regA;
    int regB;
    int regD;
    int cnst;
};
typedef struct s_RegisterUse RegisterUse;

static RegisterUse RegisterUseTable[] = {
    /* NOP = */ {0, 0, 0, 0},
    /* LDR = */ {1, 0, 1, 0},
    /* STR = */ {1, 0, 1, 0},
    /* CPR = */ {1, 0, 1, 0},
    /* SET = */ {0, 0, 1, 1},
    /* BIT = */ {1, 0, 1, 1},
    /* ADD = */ {1, 1, 1, 0},
    /* SUB = */ {1, 1, 1, 0},
    /* LSL = */ {1, 1, 1, 0},
    /* LSR = */ {1, 1, 1, 0},
    /* AND = */ {1, 1, 1, 0},
    /* OR  = */ {1, 1, 1, 0},
    /* XOR = */ {1, 1, 1, 0},
    /* NOT = */ {1, 0, 1, 0},
    /* CMP = */ {1, 1, 0, 0},
    /* BRA = */ {1, 0, 0, 0},
    /* BNE = */ {1, 0, 0, 0},
    /* JMP = */ {1, 0, 0, 0},
    /* EMW = */ {1, 0, 1, 1},
    /* EMR = */ {1, 0, 1, 1},
    /* 0x13= */ {0, 0, 0, 0},
    /* 0x14= */ {0, 0, 0, 0},
    /* 0x15= */ {0, 0, 0, 0},
    /* 0x16= */ {0, 0, 0, 0},
    /* 0x17= */ {0, 0, 0, 0},
    /* 0x18= */ {0, 0, 0, 0},
    /* 0x19= */ {0, 0, 0, 0},
    /* 0x1A= */ {0, 0, 0, 0},
    /* 0x1B= */ {0, 0, 0, 0},
    /* 0x1C= */ {0, 0, 0, 0},
    /* 0x1D= */ {0, 0, 0, 0},
    /* HLT = */ {0, 0, 0, 0}
};

/* Instruction length table */
static int InstructionTypeTable[] = {
    /* NOP = */ 4,
    /* LDR = */ 2,
    /* STR = */ 2,
    /* CPR = */ 2,
    /* SET = */ 1,
    /* BIT = */ 2,
    /* ADD = */ 3,
    /* SUB = */ 3,
    /* LSL = */ 3,
    /* LSR = */ 3,
    /* AND = */ 3,
    /* OR  = */ 3,
    /* XOR = */ 3,
    /* NOT = */ 2,
    /* CMP = */ 3,
    /* BRA = */ 0,
    /* BNE = */ 0,
    /* JMP = */ 0,
    /* EMW = */ 2,
    /* EMR = */ 2,
    /* 0x13= */ 3,
    /* 0x14= */ 3,
    /* 0x15= */ 3,
    /* 0x16= */ 3,
    /* 0x17= */ 3,
    /* 0x18= */ 3,
    /* 0x19= */ 3,
    /* 0x1A= */ 3,
    /* 0x1B= */ 3,
    /* 0x1C= */ 3,
    /* 0x1D= */ 3,
    /* HLT = */ 4
};

struct s_HexFile {
    unsigned int len;
    unsigned int chunks;
    Instruction * instructions;
};
typedef struct s_HexFile HexFile;

/**
 * build a Instruction word
 *
 * @param op OpCode
 * @param regA Register A
 * @param regB Register B
 * @param regB Register D
 * @param c Constant
 */
Instruction buildTripleInstruction(OpCode op, RegisterSelect regA, RegisterSelect regB, RegisterSelect regD);
Instruction buildDoubleInstruction(OpCode op, RegisterSelect regA, Constant C, RegisterSelect regD);
Instruction buildSingleAInstruction(OpCode op, RegisterSelect regA, Constant C);
Instruction buildSingleDInstruction(OpCode op, Constant C, RegisterSelect regD);

HexFile * newHexFile();

HexFile * freeHexFile(HexFile * hf);
int saveHexFile(HexFile * hf, char * fname);
int loadHexFile(HexFile * hf, char * fname);

int addInstrToHexFile(HexFile * hf, Instruction cmd);

void printHexFileRegion(HexFile * hf, FILE* stream, unsigned int start, unsigned int stop);
void printHexFile(HexFile * hf, FILE* stream);

int parseFile(char * fname, HexFile * hf);


#endif
