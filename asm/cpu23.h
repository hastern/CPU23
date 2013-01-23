/**
 * 
 *
 */
 
#ifndef __CPU_23_H__
#define __CPU_23_H__

#include <stdint.h> 

/** OpCode definition */
enum e_OpCode {
	NOP = 0x00, RLS = 0x01, SET = 0x02, RST = 0x03,
	ADD = 0x04, SUB = 0x05,	LSL = 0x06, LSR = 0x07, 
	AND = 0x08, OR  = 0x09,	XOR = 0x0A, NOT = 0x0B, 
	CMP = 0x0C, JMP = 0x0D, BRA = 0x0E, CLL = 0x0F, 
	BRS = 0x10, RTS = 0x11, EMW = 0x12, EMR = 0x13
};
typedef enum e_OpCode OpCode;

/** Register selection */
enum e_RegSel {
	R0 = 0x00, R1 = 0x01, R2 = 0x02, R3 = 0x03, R4 = 0x04, 
	R5 = 0x05, R6 = 0x06, R7 = 0x07, R8 = 0x08, R9 = 0x09, 
	RX = 0x0A, 
	IR = 0x0B, 
	SR = 0x0C, 
	SP = 0x0D,
	DP = 0x0E,
	PC = 0x0F
};
typedef enum e_RegSel RegSel;

/** Displacement */
enum e_Displacement {
	NoDisplacement 	= 0x00,
	WithDisplacement= 0x01,
	PostIncrement	= 0x02,
	PostDecrement	= 0x03,
	PreIncrement	= 0x04,
	PreDecrement	= 0x05,
	BigConst	= 0x07
};
typedef enum e_Displacement Displacement;


typedef uint8_t Constant;

/** Registerselection and displacement */
struct s_RegisterSelect {
	Displacement disp;
	RegSel reg;
	Constant val;
};
typedef struct s_RegisterSelect RegisterSelect;


union u_Instruction {
	struct {
	    Constant C:4;
	    RegSel B:4;
	    Displacement Ib:3;
	    RegSel A:4;
	    Displacement Ia:3;
	    OpCode opcode:5;
	    uint8_t nonExec:1;
	} parts;
	uint32_t word:24;
	uint8_t bytes[3];
};
typedef union u_Instruction Instruction;

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
 * @param c Constant
 */
Instruction buildInstruction(	
	OpCode op, 
	RegisterSelect regA, 
	RegisterSelect regB, 
	Constant c
);

HexFile * newHexFile();

HexFile * freeHexFile(HexFile * hexfile);
int saveHexFile(HexFile * hexfile, char * fname);

int addInstrToHexFile(HexFile * hexfile, Instruction cmd);

int parseFile(char * fname, HexFile * hexfile);


#endif
