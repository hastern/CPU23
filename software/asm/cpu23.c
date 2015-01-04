/***
 * CPU23 Assembler
 */

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <limits.h>

#include <assert.h>

#include "cpu23.h"


#define BUFFERSIZE 80
#define CHUNKSIZE 10

char * opCodeToString(OpCode o) {
	switch (o) {
		case 0x00: return "NOP";
		case 0x01: return "LDR";
		case 0x02: return "STR";
		case 0x03: return "CPR";
		case 0x04: return "SET";
		case 0x05: return "BIT";
		case 0x06: return "ADD";
		case 0x07: return "SUB";
		case 0x08: return "LSL";
		case 0x09: return "LSR";
		case 0x0A: return "AND";
		case 0x0B: return "OR";
		case 0x0C: return "XOR";
		case 0x0D: return "NOT";
		case 0x0E: return "CMP";
		case 0x0F: return "BRA";
		case 0x10: return "JMP";
		case 0x11: return "EMW";
		case 0x12: return "EMR";
		case 0x1F: return "HLT";
		default: return NULL;
	}
}

char * registerToString(RegisterSelect r) {
	switch(r & 0x3F) {
		case 0x00: return "R0"; 
		case 0x01: return "R1"; 
		case 0x02: return "R2"; 
		case 0x03: return "R3"; 
		case 0x04: return "R4"; 
		case 0x05: return "R5"; 
		case 0x06: return "R6"; 
		case 0x07: return "R7"; 
		case 0x08: return "R8"; 
		case 0x09: return "R9"; 
		case 0x0A: return "R10";
		case 0x0B: return "R11";
		case 0x0C: return "R12";
		case 0x0D: return "R13";
		case 0x0E: return "R14";
		case 0x0F: return "R15";
		case 0x10: return "R16";
		case 0x11: return "R17";
		case 0x12: return "R18";
		case 0x13: return "R19";
		case 0x14: return "R20";
		case 0x15: return "R21";
		case 0x16: return "R22";
		case 0x17: return "R23";
		case 0x18: return "R24";
		case 0x19: return "R25";
		case 0x1A: return "R26";
		case 0x1B: return "R27";
		case 0x1C: return "R28";
		case 0x1D: return "R29";
		case 0x1E: return "R30";
		case 0x1F: return "R31";
		case 0x20: return "R32";
		case 0x21: return "R33";
		case 0x22: return "R34";
		case 0x23: return "R35";
		case 0x24: return "R36";
		case 0x25: return "R37";
		case 0x26: return "R38";
		case 0x27: return "R39";
		case 0x28: return "R40";
		case 0x29: return "R41";
		case 0x2A: return "R42";
		case 0x2B: return "R43";
		case 0x2C: return "R44";
		case 0x2D: return "R45";
		case 0x2E: return "RX"; 
		case 0x2F: return "0x2F"; 
		case 0x30: return "0x30"; 
		case 0x31: return "0x31"; 
		case 0x32: return "0x32"; 
		case 0x33: return "RT"; 
		case 0x34: return "SR"; 
		case 0x35: return "IS"; 
		case 0x36: return "IM"; 
		case 0x37: return "IV"; 
		case 0x38: return "IH"; 
		case 0x39: return "IR"; 
		case 0x3A: return "FP"; 
		case 0x3B: return "SP"; 
		case 0x3C: return "BP"; 
		case 0x3D: return "DB"; 
		case 0x3E: return "DM"; 
		case 0x3F: return "PC"; 
		default: return NULL;
	}
}
 
static void fprintRegister(RegisterSelect r, FILE * stream) {
	if (r < 45) {
		fprintf(stream, "\033[33m%s\033[0m ", registerToString(r));
	} else {
		fprintf(stream, "\033[31m%s\033[0m ", registerToString(r));
	}
}

static void fprintConstant(Constant c, FILE* stream) {
	fprintf(stream, "\033[35m#0x%X\033[0m ", c);
}
static void fprintConstantFull(Constant c, FILE* stream) {
	fprintf(stream, "\033[35m#0x%06X\033[0m ", c);
}

static void printInstruction(Instruction instr, FILE* stream) {
	if (instr.info.nonExec == 0) {
		fprintf(stream, "\033[32m%s\033[0m ", opCodeToString(instr.info.opcode));
		switch(InstructionTypeTable[instr.info.opcode]) {
			case 0:
				if (RegisterUseTable[instr.info.opcode].regA) {
					fprintRegister(instr.singleOpA.A, stream);
				} 
				if (RegisterUseTable[instr.info.opcode].cnst) {
					fprintConstant(instr.singleOpA.C, stream);
				}
				break;
			case 1: 
				if (RegisterUseTable[instr.info.opcode].regD) {
					fprintRegister(instr.singleOpD.D, stream);
				} 
				if (RegisterUseTable[instr.info.opcode].cnst) {
					fprintConstant(instr.singleOpD.C, stream);
				}
				break;
			case 2:
				if (RegisterUseTable[instr.info.opcode].regA) {
					fprintRegister(instr.doubleOp.A, stream);
				} 
				if (RegisterUseTable[instr.info.opcode].cnst) {
					fprintConstant(instr.doubleOp.C, stream);
				} 
				if (RegisterUseTable[instr.info.opcode].regD) {
					fprintRegister(instr.doubleOp.D, stream);
				}
				break;
			case 3:
				if (RegisterUseTable[instr.info.opcode].regA) {
					fprintRegister(instr.tripleOp.A, stream);
				} 
				if (RegisterUseTable[instr.info.opcode].regB) {
					fprintRegister(instr.tripleOp.B, stream);
				}
				if (RegisterUseTable[instr.info.opcode].regD) {
					fprintRegister(instr.tripleOp.D, stream);
				}
				break;
			case 4:
				break;
			default:
				break;
		}
	} else {
		fprintConstantFull(instr.word, stream);
	}
}

Instruction buildTripleInstruction(OpCode op, RegisterSelect regA, RegisterSelect regB, RegisterSelect regD) {
	Instruction instr = {.word = 0};
	instr.tripleOp.A = regA;
	instr.tripleOp.B = regB;
	instr.tripleOp.D = regD;
	instr.tripleOp.opcode = op;
	instr.tripleOp.nonExec = 0;
	return instr;
}

Instruction buildDoubleInstruction(OpCode op, RegisterSelect regA, Constant C, RegisterSelect regD) {
	Instruction instr = {.word = 0};
	instr.doubleOp.A = regA;
	instr.doubleOp.C = C   ;
	instr.doubleOp.D = regD;
	instr.doubleOp.opcode = op;
	instr.doubleOp.nonExec = 0;
	return instr;
}
Instruction buildSingleAInstruction(OpCode op, RegisterSelect regA, Constant C) {
	Instruction instr = {.word = 0};
	instr.singleOpA.A = regA;
	instr.singleOpA.C = C   ;
	instr.singleOpA.opcode = op;
	instr.singleOpA.nonExec = 0;
	return instr;
}
Instruction buildSingleDInstruction(OpCode op, Constant C, RegisterSelect regD) {
	Instruction instr;
	instr.word = 0;
	instr.singleOpD.C = C   ;
	instr.singleOpD.D = regD;
	instr.singleOpD.opcode = op;
	instr.singleOpD.nonExec = 0;
	return instr;
}
	
HexFile * newHexFile() {
	HexFile * hf = malloc(sizeof(HexFile));
	hf->len = 0;
	hf->chunks = 0;
	hf->instructions = NULL;
	return hf;
}

HexFile * freeHexFile(HexFile * hf) {
	if(hf != NULL)
	{
		if (hf->instructions != NULL)
			free(hf->instructions);
		free(hf);
	}
	return hf;
}

int addInstrToHexFile(HexFile * hf, Instruction cmd) {
	assert(hf != NULL);
	{
		if (hf->chunks == 0) {
			hf->instructions = realloc(hf->instructions, sizeof(Instruction)*((hf->len)+CHUNKSIZE));
			hf->chunks = CHUNKSIZE;	
		}
		if (hf->instructions != NULL) {
			/*printf("\t-> 0x%02X%02X%02X\n", cmd.byte[2], cmd.byte[1], cmd.byte[0]);*/
			hf->instructions[((hf->len)++)] = cmd;
			hf->chunks--;
			return 0;
		} else {
			printf("ERROR: No Instruction list\n");
			return 1;
		}
	}
}

int parseOpCode(char ** line, OpCode * op) {
	int i = 0;
	char cmd[4] = {0};
	while (**line == ' ' || **line == '\t') {
		(*line)++;
	}
	for (i = 0; **line != ' ' && i < 3; (*line)++){
		cmd[i++] = **line;
	}
	line += i;
	for (i = 0; i <= 0x1F; i++) {
		char * opLine = opCodeToString(i);
		if ((opLine != NULL) && (strcmp(cmd, opLine)==0)) {
			*op = (OpCode) i;
			return 1;
		}
	}
	return 0;
	
}

int parseRegisterSelect(char ** line, RegisterSelect * reg) {
	int i = 0;
	char buf[4] = {0};
	while (**line == ' ' || **line == '\t') {
		(*line)++;
	}
	for (i = 0; **line != ' ' && i < 3; (*line)++){
		buf[i++] = **line;
	}
	line += i;
	for (i = 0; i <= 0x3F; i++) {
		char * regLine = registerToString(i);
		if ((regLine != NULL) && (strcmp(buf, regLine)==0)) {
			*reg = (RegisterSelect) i;
			return 1;
		}
	}
	return 0;
}

int parseConstant(char ** line, Constant * cnst) {
	while (**line == ' ' || **line == '\t') {
		(*line)++;
	}
	if (sscanf(*line, "#%i", (int *)cnst) == 0) {
		*cnst = 0;
	}
	return 1;
}

int parseLine(char * line, Instruction * cmd) {
	assert(line != NULL);
	{
		OpCode op = NOP;
		RegisterSelect rA = 0, rB = 0, rD = 0;
		Constant cnst = 0;
	
		while (*line == ' ' || *line == '\t') {
			(line)++;
		}
		/*fprintf(stdout, "%s\n", line);*/
	
	
		/* Constant */
		if (*line == '#') {
			parseConstant(&line, &cnst);
			cmd->word = cnst;
			cmd->info.nonExec = 1;
		/* Comment */
		} else if (*line == '%') {
			/* Since this is a comment just skip it and do nothing*/
			cmd = NULL;
		/* Command */
		} else {
			if (strlen(line) > 2 && 
			    parseOpCode(&line, &op) &&
			    (!(RegisterUseTable[op].regA) || parseRegisterSelect(&line, &rA)) &&
			    (!(RegisterUseTable[op].regB) || parseRegisterSelect(&line, &rB)) &&
			    (!(RegisterUseTable[op].regD) || parseRegisterSelect(&line, &rD)) &&
			    (!(RegisterUseTable[op].cnst) || parseConstant(&line, &cnst))
			   ) {
				switch (InstructionTypeTable[op]) {
					case 0:
						*cmd = buildSingleAInstruction(op, rA, cnst);
						break;
					case 1:
						*cmd = buildSingleDInstruction(op, cnst, rD);
						break;
					case 2:
						*cmd = buildDoubleInstruction(op, rA, cnst, rD);
						break;
					case 3:
					case 4:
						*cmd = buildTripleInstruction(op, rA, rB, rD);
						break;
					default: cmd = NULL;
						break;
				}
			} else {
				fprintf(stderr, "Failed to parse: '%s'\n", line);
				cmd = NULL;
			}
		}
		/*
		if (cmd != NULL) {
			fprintf(stdout, " -> ");
			printInstruction(*cmd, stdout);
			fprintf(stdout, "\n");
		}
		*/
		return cmd != NULL;
	}
}


int parseFile(char * fname, HexFile * hf) {
	FILE * fHnd = fopen(fname, "r");
	int err = 0;
	if (fHnd != NULL) {
		char buf[BUFFERSIZE+1] = {0};
		char * buf_p = &(buf[0]);
		while (!feof(fHnd) && !err) {
			*buf_p = fgetc(fHnd);
			if (*buf_p == '\n') {
				Instruction c;
				*buf_p = '\0';
				if (parseLine(&(buf[0]), &c)) {
					err = addInstrToHexFile(hf, c);
				}
				buf_p = &(buf[0]);
			} else {
				buf_p++;
			}
		}
		fclose(fHnd);
	}
	return !err;
}

int saveHexFile(HexFile * hf, char * fname) {
	assert(hf != NULL);
	{
		unsigned int i = 0;
		FILE * fHnd = fopen(fname, "wb");
		if (fHnd != NULL) {
			fputc(0x23, fHnd);
			fputc(0xC0, fHnd);
			fputc(0xDE, fHnd);
			fputc((hf->len >> 16) & 0xFF, fHnd);
			fputc((hf->len >>  8) & 0xFF, fHnd);
			fputc((hf->len >>  0) & 0xFF, fHnd);
			for (i = 0; i < hf->len; i++) {
				fputc(hf->instructions[i].byte[2], fHnd);
				fputc(hf->instructions[i].byte[1], fHnd);
				fputc(hf->instructions[i].byte[0], fHnd);
			}
			fclose(fHnd);
			return 1;
		} else {
			return 0;
		}
	}
}

int loadHexFile(HexFile * hf, char * fname) {
	assert(hf != NULL && hf->len == 0);
	{
		int err = 0;
		FILE * fHnd = fopen(fname,"rb");
		if (fHnd != NULL) {
			Instruction instr;
			err = !(fgetc(fHnd) == 0x23 && fgetc(fHnd) == 0xC0 && fgetc(fHnd) == 0xDE);
			if (!(err || feof(fHnd))){
				unsigned int len = 0;
				len |= (fgetc(fHnd)&0xFF) << 16;
				len |= (fgetc(fHnd)&0xFF) <<  8;
				len |= (fgetc(fHnd)&0xFF) <<  0;
				do {
					int i = 0;
					for (i = 2; i >= 0; i--) {
						int ch = fgetc(fHnd);
						instr.byte[i] = ch;
					}
					if (!feof(fHnd))
						addInstrToHexFile(hf, instr);
				} while(!feof(fHnd) && hf->len <= len && !err);
			}
			fclose(fHnd);
		} else {
			err = 1;
		}
		return err == 0;
	}
}

void printHexFileRegion(HexFile * hf, FILE* stream, uint32_t start, uint32_t stop) {
	assert(hf != NULL && stream != NULL);
	{
		unsigned int i = 0;
		printf("Offset  Word  Value        \n");
		printf("------ ------ -------------\n");
		for (i = start; i< stop; i++) {
			Instruction instr = hf->instructions[i];
			printf("\033[36m%06X\033[0m %06X ", i, instr.word);
			if (instr.info.nonExec == 1) {
				fprintConstantFull(instr.word & 0x7FFFFF, stream);
				fprintf(stream, "\n");
			} else {
				printInstruction(instr, stream);
				fprintf(stream, "\n");
			}
		}
	}
}

void printHexFile(HexFile * hf, FILE* stream) {
	assert(hf != NULL && stream != NULL);
	printHexFileRegion(hf, stream, 0, hf->len);
}

