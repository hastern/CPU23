#!/usr/bin/env python
# -*- coding:utf-8 -*-

# asm23 Pre-Processor

import os
import os.path
import sys

class ParseError(Exception):	
	Message = "A parsing Error {} occured"
	def __init__(self, val):
		self.val = val
	def __str__(self):
		return self.Message.format(self.val)
		
class InvalidRegister(ParseError):
	Message = "Invalid Register '{}'"
class InvalidOpCode(ParseError):
	Message = "Invalid Op-Code '{}'"
class InvalidArgumentCount(ParseError):
	Message = "Invalid argument count for Operation '{}'"
class InvalidArgumentType(ParseError):
	Message = "Invalid argument type for argument '{}'"

class Value(object): 
	Prefix = ""
	def __init__(self, val):	
		self.val = val
	def __str__(self):
		return "{}{}".format(self.Prefix, self.val)

class Register(Value):
	GPRegisters = [
		"R0", "R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", 
		"R10", "R11", "R12", "R13", "R14", "R15", "R16", "R17", "R18", "R19", 
		"R20", "R21", "R22", "R23", "R24", "R25", "R26", "R27", "R28", "R29", 
		"R30", "R31", "R32", "R33", "R34", "R35", "R36", "R37", "R38", "R39", 
		"R40", "R41", "R42", "R43", "R44", "R45"]
	SPRegisters = ["RA","RB","RX", "RT", "SR", "IS", "IM", "IV", "IH", "IR", "FP", "SP", "BP", "DB", "DM", "PC"]
	Names = GPRegisters+ SPRegisters
	def __init__(self, name):
		if name not in Register.Names:
			raise InvalidRegister(name)
		self.name = name
		
	def __str__(self):
		return self.name
	def __repr__(self):
		return "Register('{}')".format(self.name)
		
class Label(Value):
	Prefix = ":"
	
class Constant(Value):
	Prefix = "#"

class Address(Value):
	Prefix = "@"
		
class Variable(Value):
	Prefix = "$"
	
class ArgumentType(object):
	Register = 1
	Constant = 2
	Address  = 4
	Value    = 8
	
class Operation(object):
	Names = {
		"NOP": [], 
		"LDR": [(ArgumentType.Address | ArgumentType.Register, "RX"), (ArgumentType.Register, "")],
		"STR": [(ArgumentType.Register, ""), (ArgumentType.Address | ArgumentType.Register, "RX")],
		"CPR": [(ArgumentType.Register, ""), (ArgumentType.Register, "")],
		"SET": [(ArgumentType.Register | ArgumentType.Address, "RX"), (ArgumentType.Constant, "")],
		"BIT": [(ArgumentType.Value | ArgumentType.Register | ArgumentType.Constant, "RA"), (ArgumentType.Address | ArgumentType.Register, "RX"), (ArgumentType.Constant, "")],
		"ADD": [(ArgumentType.Value | ArgumentType.Register | ArgumentType.Constant, "RA"), (ArgumentType.Value | ArgumentType.Register | ArgumentType.Constant, "RB"), (ArgumentType.Address | ArgumentType.Register, "RX")],
		"SUB": [(ArgumentType.Value | ArgumentType.Register | ArgumentType.Constant, "RA"), (ArgumentType.Value | ArgumentType.Register | ArgumentType.Constant, "RB"), (ArgumentType.Address | ArgumentType.Register, "RX")],
		"LSL": [(ArgumentType.Value | ArgumentType.Register, "RA"), (ArgumentType.Address | ArgumentType.Register, "RX"), (ArgumentType.Constant, "")],
		"LSR": [(ArgumentType.Value | ArgumentType.Register, "RA"), (ArgumentType.Address | ArgumentType.Register, "RX"), (ArgumentType.Constant, "")],
		"AND": [(ArgumentType.Value | ArgumentType.Register | ArgumentType.Constant, "RA"), (ArgumentType.Value | ArgumentType.Register | ArgumentType.Constant, "RB"), (ArgumentType.Address | ArgumentType.Register, "RX")],
		"OR" : [(ArgumentType.Value | ArgumentType.Register | ArgumentType.Constant, "RA"), (ArgumentType.Value | ArgumentType.Register | ArgumentType.Constant, "RB"), (ArgumentType.Address | ArgumentType.Register, "RX")],
		"XOR": [(ArgumentType.Value | ArgumentType.Register | ArgumentType.Constant, "RA"), (ArgumentType.Value | ArgumentType.Register | ArgumentType.Constant, "RB"), (ArgumentType.Address | ArgumentType.Register, "RX")],
		"NOT": [(ArgumentType.Value | ArgumentType.Register | ArgumentType.Constant, "RA"), (ArgumentType.Address | ArgumentType.Register, "RX")],
		"CMP": [(ArgumentType.Address | ArgumentType.Register | ArgumentType.Constant, "RA"), (ArgumentType.Address | ArgumentType.Register | ArgumentType.Constant, "RX")],
		"BRA": [(ArgumentType.Address | ArgumentType.Register, "RX")],
		"JMP": [(ArgumentType.Address | ArgumentType.Register, "RX")],
		"EMW": [(ArgumentType.Address | ArgumentType.Register, "RA"), (ArgumentType.Address | ArgumentType.Register, "RX"), (ArgumentType.Constant, "")],
		"EMR": [(ArgumentType.Address | ArgumentType.Register, "RA"), (ArgumentType.Address | ArgumentType.Register, "RX"), (ArgumentType.Constant, "")],
		"HLT": [],
		"VAR": [], 
		"ORG": [],
	}
	def __init__(self, name):
		if name not in Operation.Names:
			raise InvalidOpCode(name)
		self.name = name
	def __str__(self):
		return self.name
	def __repr__(self):
		return "Operation('{}')".format(self.name)
	
	def allowedTypes(self, pos):
		return Operation.Names[self.name][pos]
	@property
	def argumentCount(self):
		return len(Operation.Names[self.name])
	
class Instruction(object):
	def __init__(self, opcode, *args):
		self.opcode = opcode
		self.args = args
	def __str__(self):
		return str(self.opcode) + " " + " ".join(map(str, self.args))
	def __repr__(self):
		return "Instruction({}, {})".format(repr(self.opcode), ",".join(map(repr, self.args)))
	
class A23Parser(object):
	def __init__(self, fname = None):
		self.clear()
		self.filename = "stdin"
		self.addr = 0
		if fname is not None:
			self.read(fname)
		
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
		if label != "":
			self.ast.append((self.addr, label.val, instr))
			self.labelLoc[label.val] = self.addr
		else:
			self.ast.append((self.addr, "", instr))
			
		self.addr += 1
		
	def parse(self, code):	
		try:
			for nr,line in enumerate(code):
				if "%" in line:
					code,comment = line.strip().split("%",1)
				else:
					code = line.strip()
				toks = code.split()
				if len(toks) == 0:
					continue
				first = toks.pop(0)
				if first[0] == ':':
					label = Label(first[1:])
					first = toks.pop(0)
				else:
					label = ""
				if first[0] == '#':
					self.addInstr(label, Constant(first[1:]))
				elif first[0] == '@':
					self.addInstr(label, Address(first[1:]))
				else:
					op = Operation(first)
					if len(toks) != op.argumentCount:
						raise InvalidArgumentCount(first)
					args = []
					for idx,tok in enumerate(toks):
						opts, dst = op.allowedTypes(idx)
						if tok[0] == '#':
							if ArgumentType.Constant & opts != 0:
								if dst == "":
									args.append(Constant(tok[1:]))
								else:
									self.addInstr(label, Instruction(Operation("SET"), Register(dst), Constant(tok[1:])))
									label = ""
									args.append(Register(dst))
							else:
								raise InvalidArgumentType(tok)
						elif tok[0] == '@':
							if ArgumentType.Address & opts != 0:
								if tok[1] == '#':
									self.addInstr(label, Instruction(Operation("SET"), Register(dst), Constant(tok[2:])))
								else:
									self.addInstr(label, Instruction(Operation("SET"), Register(dst), Address(tok[1:])))
								label = ""
								args.append(Register(dst))
							else:
								raise InvalidArgumentType(tok)
						elif tok[0] == '&':
							if ArgumentType.Value & opts != 0:
								self.addInstr(label, Instruction(Operation("SET"), Register("RX"), Address(tok[1:])))
								label = ""
								self.addInstr("", Instruction(Operation("LDR"), Register("RX"), Register(dst)))
								args.append(Register(dst))
							else:
								raise InvalidArgumentType(tok)
						elif tok[0] == '$':
							raise InvalidArgumentType(tok)
						else:
							args.append(Register(tok))
					self.addInstr(label, Instruction(op, *args))
		except ParseError as e:
			sys.stderr.write("{}[{}] '{}': ".format(self.filename, nr,code.strip()) + str(e)+ "\n")
		return self.ast
		
	def resolve(self):
		out = []
		for addr, label, instr in self.ast:
			if isinstance(instr, Address):
				out.append(Constant(self.labelLoc[instr.val]))
			elif isinstance(instr, Instruction):
				instr.args = [Constant(self.labelLoc[arg.val]) if isinstance(arg, Address) else arg for arg in instr.args]	
				out.append(instr)
			else:
				out.append(instr)
		return "\n".join(map(str, out))
	
	
	def __str__(self):
		return "Offset(h) Instruction\n--------- -----------\n" + "\n".join(["  {:06X}  {:7s} {}".format(addr, label, line) for addr, label, line in self.ast])
