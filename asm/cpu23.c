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
			/*printf("\t-> 0x%02X%02X%02X\n", cmd.bytes[2], cmd.bytes[1], cmd.bytes[0]);*/
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
	char l[7] = {0};
	char r[7] = {0};
	int chars = 0, disp = 0, err = 0;
	reg->disp = NoDisplacement;
	reg->reg =  RX;
	if (**line == ' ')(*line)++;
	while((*line)[chars] != ' ' && (*line)[chars] != '\0' ) {
		l[chars] = (*line)[chars];
		chars++;
	}
	if (sscanf(l, "[%[RISDP]%[0-9XRPC]]%n", r, r+1, &chars) >= 2) {
		reg->disp = Indirect;
		r[2] = '\0';
		err = !charToRegSel(r, &(reg->reg) );
	} else if (sscanf(l, "[%[RISDP]%[0-9XRPC],%d]%n", r, r+1, &disp, &chars) >= 3) {
		reg->disp = WithDisplacement;
		r[2] = '\0';
		err = !charToRegSel(r, &(reg->reg) );
	} else if (sscanf(l, "[%[+-]%[RISDP]%[0-9XRPC]]%n", r, r+1, r+2, &chars) >= 3) {
		if (r[0] == '+')
			reg->disp = PreIncrement;
		else if (r[0] == '-')
			reg->disp = PreDecrement;
		r[3] = '\0';
		err = !charToRegSel(r+1, &(reg->reg) );
	} else if (sscanf(l, "[%[RISDP]%[0-9XRPC]%[+-]]%n", r, r+1, r+2, &chars) >= 3) {
		if (r[2] == '+')
			reg->disp = PostIncrement;
		else if (r[2] == '-')
			reg->disp = PostDecrement;
		r[2] = '\0';
		err = !charToRegSel(r+1, &(reg->reg) );
	} else if (sscanf(l, "%[RISDP]%[0-9XRPC]%n", r, r+1, &chars) >= 2) {
		r[2] = '\0';
		err = !charToRegSel(r, &(reg->reg) );
	} else {
		err = 1;
		chars = 0;
	}
	if (err == 0) {
		*line += chars;
	} else {
		printf("Warning: Register %s doesn't exists\n", l);
	}
	return err == 0;
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
		/*printf("%s", line);*/
		if (*line == '#') {
			int val = 0;
			sscanf(line, "#%i", &val);
			cmd->bytes[2] = (val >> 16) & 0xFF;
			cmd->bytes[1] = (val >>  8) & 0xFF;
			cmd->bytes[0] = (val >>  0) & 0xFF;
			cmd->parts.nonExec = 1;
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
		FILE * fHnd = fopen(fname, "w");
		if (fHnd != NULL) {
			fputc(0x23, fHnd);
			fputc(0x00, fHnd);
			fputc(0x00, fHnd);
			fputc((hf->len >> 16) & 0xFF, fHnd);
			fputc((hf->len >>  8) & 0xFF, fHnd);
			fputc((hf->len >>  0) & 0xFF, fHnd);
			for (i = 0; i < hf->len; i++) {
				fputc(hf->instructions[i].bytes[2], fHnd);
				fputc(hf->instructions[i].bytes[1], fHnd);
				fputc(hf->instructions[i].bytes[0], fHnd);
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
		FILE * fHnd = fopen(fname,"r");
		if (fHnd != NULL) {
			Instruction instr;
			err = !(fgetc(fHnd) == 0x23 && fgetc(fHnd) == 0 && fgetc(fHnd) == 0);
			if (!(err || feof(fHnd))){
				unsigned int len = 0;
				len |= (fgetc(fHnd)&0xFF) << 16;
				len |= (fgetc(fHnd)&0xFF) <<  8;
				len |= (fgetc(fHnd)&0xFF) <<  0;
				do {
					instr.bytes[2] = fgetc(fHnd);
					instr.bytes[1] = fgetc(fHnd);
					instr.bytes[0] = fgetc(fHnd);
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

static void fprintRegister(RegSel r, Displacement d, FILE * stream) {
	switch(d) 
	{
		case NoDisplacement:
			fprintf(stream, "%s ", registerToString(r));
			break;
		case Indirect:
			fprintf(stream, "[%s,%d] ", registerToString(r), 0);
			break;
		case WithDisplacement:
			fprintf(stream, "[%s] ", registerToString(r));
			break;
		case PostIncrement:
			fprintf(stream, "[%s+] ", registerToString(r));
			break;
		case PostDecrement:
			fprintf(stream, "[%s-] ", registerToString(r));
			break;
		case PreIncrement:
			fprintf(stream, "[+%s] ", registerToString(r));
			break;
		case PreDecrement:
			fprintf(stream, "[-%s] ", registerToString(r));
			break;
		default:
			break;
	}	
}

void printHexFileRegion(HexFile * hf, FILE* stream, uint32_t start, uint32_t stop) {
	assert(hf != NULL && stream != NULL);
	{
		unsigned int i = 0;
		printf("Address\tWord\tValue\n");
		printf("-------\t----\t-----\n");
		for (i = start; i< stop; i++) {
			Instruction instr = hf->instructions[i];
			printf("%06X\t%06X\t", i, instr.word);
			if (instr.parts.nonExec == 1) {
				fprintf(stream, "#0x%06X\n", instr.word & 0x3FFFFF);
			} else {
				fprintf(stream, "%s ", opCodeToString(instr.parts.opcode));
				fprintRegister(instr.parts.A, instr.parts.Ia, stream);
				fprintRegister(instr.parts.B, instr.parts.Ib, stream);
				fprintf(stream, "\n");
			}
		}
	}
}

void printHexFile(HexFile * hf, FILE* stream) {
	assert(hf != NULL && stream != NULL);
	printHexFileRegion(hf, stream, 0, hf->len);
}

