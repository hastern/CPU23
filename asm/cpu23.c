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
		case 0x01: return "RLS";
		case 0x02: return "SET";
		case 0x03: return "RST";
		case 0x04: return "ADD";
		case 0x05: return "SUB";
		case 0x06: return "LSL";
		case 0x07: return "LSR";
		case 0x08: return "AND";
		case 0x09: return "OR";
		case 0x0A: return "XOR";
		case 0x0B: return "NOT";
		case 0x0C: return "CMP";
		case 0x0D: return "JMP";
		case 0x0E: return "BRA";
		case 0x0F: return "CLL";
		case 0x10: return "BRS";
		case 0x11: return "RTS";
		case 0x12: return "EMW";
		case 0x13: return "EMR";
		default: return NULL;
	}
}

char * registerToString(RegSel r) {
	switch(r & 0xF) {
		case 0x0: return "R0";
		case 0x1: return "R1";
		case 0x2: return "R2";
		case 0x3: return "R3";
		case 0x4: return "R4";
		case 0x5: return "R5";
		case 0x6: return "R6";
		case 0x7: return "R7";
		case 0x8: return "R8";
		case 0x9: return "R9";
		case 0xA: return "RX";
		case 0xB: return "IR";
		case 0xC: return "SR";
		case 0xD: return "SP";
		case 0xE: return "DP";
		case 0xF: return "PC";
		default: return NULL;
	}
}
 

Instruction buildInstruction(OpCode op, RegisterSelect regA, RegisterSelect regB, Constant c) {
	Instruction instr;
	instr.parts.C = c;
	instr.parts.B = regB.reg;
	instr.parts.Ib = regB.disp;
	instr.parts.A = regA.reg;
	instr.parts.Ia = regA.disp;
	instr.parts.opcode = op;
	instr.parts.nonExec = 0;
	return instr;
}
	
HexFile * newHexFile() {
	HexFile * hexfile = malloc(sizeof(HexFile));
	hexfile->len = 0;
	hexfile->chunks = 0;
	hexfile->instructions = NULL;
	return hexfile;
}

HexFile * freeHexFile(HexFile * hexfile) {
	if(hexfile != NULL)
	{
		if (hexfile->instructions != NULL)
			free(hexfile->instructions);
		free(hexfile);
	}
	return hexfile;
}

int addInstrToHexFile(HexFile * hexfile, Instruction cmd) {
	assert(hexfile != NULL);
	{
		if (hexfile->chunks == 0) {
			hexfile->instructions = realloc(hexfile->instructions, sizeof(Instruction)*((hexfile->len)+CHUNKSIZE));
			hexfile->chunks = CHUNKSIZE;	
		}
		if (hexfile->instructions != NULL) {
			printf("\t-> 0x%.6X\n", cmd.word);
			hexfile->instructions[((hexfile->len)++)] = cmd;
			hexfile->chunks--;
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

int charToRegSel(char * c, RegSel * r) {
	int i;
	for(i = 0; i < 16; i++) {
		char * regLine = registerToString(i);
		if ((regLine != NULL) && (strcmp(c, regLine)==0)) {
			*r = (RegSel) i;
			return 1;
		}
	}
	return 0;
}

int parseRegisterSelect(char ** line, RegisterSelect * reg) {
	char r[4] = {0};
	int chars = 0, disp;
	reg->disp = NoDisplacement;
	reg->reg =  RX;
	
	if (sscanf(*line, "[%c%c]%n", &(r[0]), &(r[1]), &chars) >= 2) {
		r[2] = '\0';
		charToRegSel(&(r[0]), &(reg->reg) );
		reg->disp = WithDisplacement;
	} else if (sscanf(*line, "[%c%c,%d]%n", &(r[0]), &(r[1]), &disp, &chars) >= 3) {
		r[2] = '\0';
		charToRegSel(&(r[0]), &(reg->reg) );
		reg->disp = WithDisplacement;
	} else if (sscanf(*line, "[%c%c%c]%n", &(r[0]), &(r[1]), &(r[2]), &chars) >= 3) {
		if (r[0] == '+' || r[0] == '-') {
			r[3] = '\0';
			charToRegSel(&(r[1]), &(reg->reg) );
			if (r[0] == '+')
				reg->disp = PreIncrement;
			else if (r[0] == '-')
				reg->disp = PreDecrement;
		} else if (r[2] == '+' || r[2] == '-'){
			if (r[0] == '+')
				reg->disp = PostIncrement;
			else if (r[0] == '-')
				reg->disp = PostDecrement;
			r[2] = '\0';
			charToRegSel(&(r[0]), &(reg->reg) );
			
		}
	} else if (sscanf(*line, "%c%c%n", &(r[0]), &(r[1]), &chars) >= 3) {
		r[2] = '\0';
		charToRegSel(&(r[0]), &(reg->reg) );
	}
	
	line += chars;
	return 1;
}

int parseConstant(char * line, Constant * cnst) {
	if (sscanf(line, "%i", (int *)cnst) == 0) {
		cnst = 0;
	}
	return 1;
}

int parseLine(char * line, Instruction * cmd) {
	assert(line != NULL);
	{
		OpCode 
			op = NOP
			;
		RegisterSelect 
			rA = {NoDisplacement, RX, 0}, 
			rB = {NoDisplacement, RX, 0}
			;
		Constant 
			cnst = 0
			;
		
		/* Constant */
		printf("%s", line);
		if (*line == '#') {
			int val = 0;
			sscanf(line, "#%i", &val);
			cmd->word = val & 0x7FFFFF;
		} else {
			if (strlen(line) > 2 && 
				parseOpCode(&line, &op) && 
				parseRegisterSelect(&line, &rA) && 
				parseRegisterSelect(&line, &rB) && 
				parseConstant(line, &cnst)) {
				*cmd = buildInstruction(op, rA, rB, cnst);
			} else {
				cmd = NULL;
			}
		}
		return cmd != NULL;
	}
}


int parseFile(char * fname, HexFile * hexfile) {
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
				if (parseLine(&(buf[0]), &c))
					err = addInstrToHexFile(hexfile, c);
				buf_p = &(buf[0]);
			} else {
				buf_p++;
			}
		}
		fclose(fHnd);
	}
	return !err;
}

int saveHexFile(HexFile * hexfile, char * fname) {
	assert(hexfile != NULL);
	{
		unsigned int i = 0;
		FILE * fHnd = fopen(fname, "w");
		if (fHnd != NULL) {
			fputc(0x23, fHnd);
			fputc((hexfile->len >> 16) & 0xFF, fHnd);
			fputc((hexfile->len >> 8) & 0xFF, fHnd);
			fputc((hexfile->len >> 0) & 0xFF, fHnd);
			for (i = 0; i < hexfile->len; i++) {
				fputc(hexfile->instructions[i].bytes[2], fHnd);
				fputc(hexfile->instructions[i].bytes[1], fHnd);
				fputc(hexfile->instructions[i].bytes[0], fHnd);
			}
			fclose(fHnd);
			return 1;
		} else {
			return 0;
		}
	}
}


