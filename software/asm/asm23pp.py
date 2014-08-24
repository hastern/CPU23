#!/usr/bin/env python
# -*- coding:utf-8 -*-

# asm23 Pre-Processor

from pyparsing import *
import argparse


def a23Syntax():
	ParserElement.setDefaultWhitespaceChars(' \t')
	LN = LineEnd().suppress()
	Comment = Optional(Word("%", exact=1).suppress() + ZeroOrMore(Word(printables))).suppress()
	
	Number = Combine(( Word(nums) ^ (Literal("0x") + Word(hexnums))))
	Label = (Word(":", exact=1).suppress() + Word(alphas)).setParseAction(lambda s,l,toks: toks.insert(0, "LABEL"))
	Addr = Group((Word("@", exact=1).suppress() + Word(alphas)).setParseAction(lambda s,l,toks: toks.insert(0, "ADDR")))
	
	GPRegister = oneOf([
		"R0", "R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", 
		"R10", "R11", "R12", "R13", "R14", "R15", "R16", "R17", "R18", "R19", 
		"R20", "R21", "R22", "R23", "R24", "R25", "R26", "R27", "R28", "R29", 
		"R30", "R31", "R32", "R33", "R34", "R35", "R36", "R37", "R38", "R39", 
		"R40", "R41", "R42", "R43", "R44", "R45"])
	SpecialRegister = oneOf(["RX", "RT", "SR", "IS", "IM", "IV", "IH", "IR", "FP", "SP", "BP", "DB", "DM", "PC"])
	Constant = (Word("#", exact=1).suppress() + Number).setParseAction(lambda s,l,toks: toks.insert(0, "CNST"))
	Register = Group((GPRegister ^ SpecialRegister).setParseAction(lambda s,l,toks: toks.insert(0, "REG")))
	
	
	Instruction_ = oneOf(["NOP","HLT"])
	InstructionRRR = oneOf(["ADD", "SUB", "AND", "OR", "XOR"]) + Register + Register + Register
	InstructionRR = oneOf(["CMP", "LDR", "STR", "CPR", "NOT"]) + Register + Register
	InstructionRRC = oneOf(["LSL", "LSR"]) + Register + Register + Group(Constant)
	InstructionRC = oneOf(["SET"]) + Register + Group(Constant)
	InstructionR = oneOf(["BRA","JMP"]) + (Register ^ Addr)
	
	Instruction = Optional(Label) + (Instruction_ ^ InstructionR ^ InstructionRR ^ InstructionRRR ^ InstructionRC ^ InstructionRRC)
	Instruction.setParseAction(lambda s,l,toks: toks.insert(0, "INSTR"))
	
	Line = Group(Optional(Instruction ^ Constant) + Comment)
	
	return OneOrMore(Line + LN)
	
