#!/usr/bin/env python
# -*- coding:utf-8 -*-

# asm23 Pre-Processor

import os
import os.path
import sys
import argparse

from pyparsing import *

class Value(object): 
	Prefix = ""
	IsConst = False
	def __init__(self, val, buf = ""):	
		self.val = val
		self.buf = buf
	def __str__(self):
		return "{}{}".format(str(self.Prefix), str(self.val))
	__repr__ = __str__
	isConstant = False
	def __eq__(self, other):
		return self.val == other

class Register(Value):
	GPRegisters = [
		"R0", "R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", 
		"R10", "R11", "R12", "R13", "R14", "R15", "R16", "R17", "R18", "R19", 
		"R20", "R21", "R22", "R23", "R24", "R25", "R26", "R27", "R28", "R29", 
		"R30", "R31", "R32", "R33", "R34", "R35", "R36", "R37", "R38", "R39", 
		"R40", "R41", "R42", "R43", "R44", "R45"]
	SPRegisters = ["RA","RB","RX", "RT", "SR", "IS", "IM", "IV", "IH", "IR", "FP", "SP", "BP", "DB", "DM", "PC"]
	Names = GPRegisters+ SPRegisters
	def __init__(self, name, buf = ""):
		Value.__init__(self, name, buf)
	def __str__(self):
		return str(self.val)
		
class Label(Value):
	Prefix = ":"
	
class Constant(Value):
	Prefix = "#"
	isConstant = True
	def __init__(self, val, buf = ""):
		Value.__init__(self, val if isinstance(val, int) else int(val, 16 if val.startswith("0x") else 10), buf)
	def __str__(self):
		return "#0x{:06X}".format(self.val)

class Address(Value):
	Prefix = "@"
		
class Variable(Value):
	Prefix = "&"
	
class ArgumentType(object):
	Register = 1
	Constant = 2
	Address  = 4
	Value    = 8
	
class Operation(object):
	Names = [
		"NOP", "LDR", "STR", "CPR", "SET", "BIT", 
		"ADD", "SUB", "LSL", "LSR", "AND", "OR" , 
		"XOR", "NOT", "CMP", "BRA", "JMP", "EMW", 
		"EMR", "HLT",
	]
	def __init__(self, name):
		self.name = name
	def __str__(self):
		return str(self.name)
	def __repr__(self):
		return "Operation('{}')".format(self.name)
	def __eq__(self, other):
		return self.name == other
	

class Instruction(object):
	def __init__(self, opcode, *args):
		self.opcode = opcode
		self.args = list(args)
	def __str__(self):
		s  = str(self.opcode)
		s += " "
		s += " ".join(map(str, self.args))
		return s
	def __repr__(self):
		return "Instruction({}, {})".format(repr(self.opcode), ",".join(map(repr, self.args)))
	@property
	def isConstant(self):
		return all(map(lambda arg: isinstance(arg, Register) or arg.buf == "" , self.args))

class CodeObject(object):
	def __init__(self, label, instr, addr = None):
		self.addr  = addr
		self.label = label
		self.instr = instr
		
	@property
	def isConstant(self):
		if self.addr is None:
			return False
		if not self.instr.isConstant:
			return False
		return True
		
	def __str__(self):
		return "  {:06X}  {:7s} {}".format(self.addr if self.addr is not None else 0, self.label if self.label is not None else "", self.instr)
		
	__repr__ = __str__

def a23syntax():
	Comment = ("%" + ZeroOrMore(Word(printables)))
	
	Number = (Word(nums) ^ Combine(Literal("0x") + Word(hexnums)))
	
	File   = Combine(Word(alphanums+"_-/") + Literal(".") + (Word("a23") ^ Word("asm23")))
	
	Label  = (Literal(":").suppress() + Word(alphas))
	
	Addrs  = (Literal("@").suppress() + Word(alphas)).setParseAction(lambda toks: toks.insert(0, "ADDRS"))
	Value  = (Literal("&").suppress() + Word(alphas)).setParseAction(lambda toks: toks.insert(0, "VALUE"))
	Const  = (Literal("#").suppress() + Number      ).setParseAction(lambda toks: toks.insert(0, "CONST"))
	
	GPRegister = oneOf([
		"R0", "R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", 
		"R10", "R11", "R12", "R13", "R14", "R15", "R16", "R17", "R18", "R19", 
		"R20", "R21", "R22", "R23", "R24", "R25", "R26", "R27", "R28", "R29", 
		"R30", "R31", "R32", "R33", "R34", "R35", "R36", "R37", "R38", "R39", 
		"R40", "R41", "R42", "R43", "R44", "R45"])
	SpecialRegister = oneOf(["RA","RB","RX", "RT", "SR", "IS", "IM", "IV", "IH", "IR", "FP", "SP", "BP", "DB", "DM", "PC"])
	Register = (GPRegister ^ SpecialRegister).setParseAction(lambda toks: toks.insert(0, "REG"))
	
	RegA = Group( (Register ^ Value ^ Const).setParseAction(lambda toks:toks.append("RA")) )
	RegB = Group( (Register ^ Value ^ Const).setParseAction(lambda toks:toks.append("RB")) )
	RegX = Group( (Addrs ^ Register).setParseAction(lambda toks:toks.append("RX")) )
	Reg  = Group( Register + Group(Empty()) )
	Cst  = Group( Const    + Group(Empty()) )
	
	Instr = (Literal("NOP") ) \
	      | (Literal("LDR") + Group( RegX + Reg  ) ) \
	      | (Literal("STR") + Group( Reg  + RegX ) ) \
	      | (Literal("CPR") + Group( Reg  + Reg  ) ) \
	      | (Literal("SET") + Group( RegX + Cst  ) ) \
	      | (Literal("BIT") + Group( RegA + RegX + Cst  ) ) \
	      | (Literal("ADD") + Group( RegA + RegB + RegX ) ) \
	      | (Literal("SUB") + Group( RegA + RegB + RegX ) ) \
	      | (Literal("LSL") + Group( RegA + RegB + RegX ) ) \
	      | (Literal("LSR") + Group( RegA + RegB + RegX ) ) \
	      | (Literal("AND") + Group( RegA + RegB + RegX ) ) \
	      | (Literal("OR" ) + Group( RegA + RegB + RegX ) ) \
	      | (Literal("XOR") + Group( RegA + RegB + RegX ) ) \
	      | (Literal("NOT") + Group( RegA + RegX ) ) \
	      | (Literal("CMP") + Group( RegA + RegB ) ) \
	      | (Literal("BRA") + Group( RegX ) ) \
	      | (Literal("JMP") + Group( RegX ) ) \
	      | (Literal("EMW") + Group( RegA + RegB + RegX ) ) \
	      | (Literal("EMR") + Group( RegA + RegB + RegX ) ) \
	      | (Literal("HLT") ) \
	      | (Literal("VAR") + Group( Number ) ) \
	      | (Literal("ORG") + Group( Number ) ) \
	      | (Literal("INC") + Group( File   ) )
	
	Instr.setParseAction(lambda s,l,toks: toks.insert(0, "INSTR"))
	
	Line = Optional(Group(Optional(Label)) + Group(Instr ^ Const ^ Addrs)) + Optional(Comment).suppress()
	
	return Line + StringEnd()
	
def classFromName(name, value, buf):
	if len(buf) == 0:
		buf = ""
	if name == "LABEL":
		return Label(value, buf)
	if name == "ADDRS":
		return Address(value, buf)
	if name == "CONST":
		return Constant(value, buf)
	if name == "VALUE":
		return Variable(value, buf)
	if name == "REG":
		return Register(value, buf)
	raise KeyError(name)
	
class A23Parser(object):
	def __init__(self, fname = None):
		self.clear()
		self.grammar = a23syntax()
		self.filename = "stdin"
		if fname is not None:
			self.read(fname)
			
	def __iter__(self):
		for obj in self.ast:
			yield obj
			
	def clear(self):
		self.labelLoc = {}
		self.ast = []
		
	def read(self, fname):
		fHnd = open(fname)
		self.filename = os.path.basename(fname)
		ast = self.parse(fHnd.readlines())
		fHnd.close()
		return ast
			
	def addInstr(self, label, instr):
		self.ast.append(CodeObject(label, instr))
		
	@property
	def isValid(self):
		return all(map(lambda o: o.isConstant, self.ast))

	def parseLine(self, line, no=0):
		toks = self.grammar.parseString(line.strip())
		if len(toks) == 0:
			return
		label, instr = toks
		lbl = Label(label[0]) if len(label) == 1 else None
		
		if instr[0] == "CONST":
			self.addInstr(lbl, Constant(instr[1]))
		elif instr[0] == "ADDRS":
			self.addInstr(lbl, Address(instr[1]))
		elif instr[0] == "INSTR":
			if instr[1] in Operation.Names:
				op = Operation(instr[1])
				args = [classFromName(t,v,d) for t,v,d in instr[2]] if len(instr) > 2 else []
				self.addInstr(lbl, Instruction(op, *args))
			else:
				self.addInstr(lbl, Instruction(Operation(instr[1]), *instr[2]))
		
		
	def parse(self, code):	
		try:
			for nr,line in enumerate(code):
				self.parseLine(line, nr)
		except ParseException as e:
			sys.stderr.write("{}[{}]: ".format(self.filename, nr,line) + str(e)+ "\n")
		return self.ast
		
	def expandOperations(self):
		ast = []
		for obj in self.ast:
			if isinstance(obj.instr, Instruction) and obj.instr.opcode == "INC":
				fname = obj.instr.args[0]
				for obj in A23Parser(fname):
					ast.append(obj)
			elif isinstance(obj.instr, Instruction):
				lbl = obj.label
				for i in range(len(obj.instr.args)):
					arg = obj.instr.args[i]
					if isinstance(arg, Constant) and arg.buf != "":
						ast.append(CodeObject(lbl, Instruction(Operation("SET"), Register(arg.buf), Constant(arg.val)) ) )
						lbl = ""
						obj.instr.args[i] = Register(arg.buf)
					if isinstance(arg, Variable):
						if arg.buf != "RX":
							ast.append(CodeObject(lbl, Instruction(Operation("SET"), Register("RX"), Address(arg.val))  ) )
							lbl = ""
							ast.append(CodeObject(lbl, Instruction(Operation("LDR"), Register("RX"), Register(arg.buf)) ) )
							obj.instr.args[i] = Register(arg.buf)
					if isinstance(arg, Address):
						ast.append(CodeObject(lbl, Instruction(Operation("SET"), Register("RX"), Address(arg.val))))
						lbl = ""
						obj.instr.args[i] = Register("RX")
				obj.label = lbl
				ast.append(obj)
			else:
				ast.append(obj)
		self.ast = ast
		return self
		
	def calcAddressess(self):
		addr = 0
		ast = []
		for obj in self.ast:
			obj.addr = addr
			if isinstance(obj.instr, Instruction) and obj.instr.opcode == "ORG":
				addr = int(obj.instr.args[0], 16 if obj.instr.args[0].startswith("0x") else 10)
				continue
			if isinstance(obj.instr, Instruction) and obj.instr.opcode == "VAR":
				addr += int(obj.instr.args[0], 16 if obj.instr.args[0].startswith("0x") else 10)
				obj.instr = Constant("0x00000")
			if obj.label is not None and obj.label != "":
				self.labelLoc[obj.label.val] = addr
			ast.append(obj)
			addr += 1
		self.ast = sorted(ast, key=lambda o:obj.addr)
		return self
		
	def resolve(self):
		out = []
		for obj in self.ast:
			if isinstance(obj.instr, Address):
				out.append(CodeObject(obj.label, Constant(self.labelLoc[obj.instr.val]), obj.addr))
			elif isinstance(obj.instr, Instruction):
				obj.instr.args = [Constant(self.labelLoc[arg.val]) if isinstance(arg, Address) else arg for arg in obj.instr.args]	
				out.append(CodeObject(obj.label, obj.instr, obj.addr))
			else:
				out.append(CodeObject(obj.label, obj.instr, obj.addr))
		self.ast = out
		return self
	
	def save(self, fname):
		fHnd = open(fname, "w")
		last = None
		for obj in self.ast:
			if last is not None and last.addr < obj.addr-1: 
				diff = (obj.addr-1) - last.addr
				for i in range(diff):
					fHnd.write("#0x000000 %{}\n".format(i))
			fHnd.write(str(obj.instr))
			fHnd.write("\n")
			last = obj
		fHnd.close()
	
	
	def __str__(self):
		s  = "Offset(h)         Instruction\n"
		s += "---------         -----------\n" 
		s += "\n".join(map(str, self.ast))
		return s
		
if __name__ == "__main__":
	
	args = argparse.ArgumentParser()
	args.add_argument("input", action="store", help="The source code file.")
	args.add_argument("-o", "--output", action="store", help="The hex file.")
	
	opts = vars(args.parse_args())
	
	inputfile = opts['input']
	outputfile = opts['output'] if opts['output'] is not None else (os.path.splitext(inputfile)[0] + ".a23")
	
	p = A23Parser()
	p.read(inputfile)
	p.expandOperations()
	p.calcAddressess()
	p.resolve()
	p.save(outputfile)



