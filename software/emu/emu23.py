#!/usr/bin/env python
# -*- coding:utf-8 -*-

import operator
import itertools
import random
import sys
import time

class _Getch:
	"""Gets a single character from standard input.  Does not echo to the
	screen.
	Source: http://code.activestate.com/recipes/134892/
	"""
	def __init__(self):
		try:
			self.impl = _GetchWindows()
		except ImportError:
			self.impl = _GetchUnix()

	def __call__(self): return self.impl()


class _GetchUnix:
	def __init__(self):
		import tty, sys

	def __call__(self):
		import sys, tty, termios
		fd = sys.stdin.fileno()
		old_settings = termios.tcgetattr(fd)
		try:
			tty.setraw(sys.stdin.fileno())
			ch = sys.stdin.read(1)
		finally:
			termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)
		return ch


class _GetchWindows:
	def __init__(self):
		import msvcrt

	def __call__(self):
		import msvcrt
		return msvcrt.getch()

class Register(object):
	R0  = 0x00
	R1  = 0x01
	R2  = 0x02
	R3  = 0x03
	R4  = 0x04
	R5  = 0x05
	R6  = 0x06
	R7  = 0x07
	R8  = 0x08
	R9  = 0x09
	R10 = 0x0A
	R11 = 0x0B
	R12 = 0x0C
	R13 = 0x0D
	R14 = 0x0E
	R15 = 0x0F
	R16 = 0x10
	R17 = 0x11
	R18 = 0x12
	R19 = 0x13
	R20 = 0x14
	R21 = 0x15
	R22 = 0x16
	R23 = 0x17
	R24 = 0x18
	R25 = 0x19
	R26 = 0x1A
	R27 = 0x1B
	R28 = 0x1C
	R29 = 0x1D
	R30 = 0x1E
	R31 = 0x1F
	R32 = 0x20
	R33 = 0x21
	R34 = 0x22
	R35 = 0x23
	R36 = 0x24
	R37 = 0x25
	R38 = 0x26
	R39 = 0x27
	R40 = 0x28
	R41 = 0x29
	R42 = 0x2A
	R43 = 0x2B
	R44 = 0x2C
	R45 = 0x2D
	RX  = 0x2E
	RT  = 0x33
	SR  = 0x34
	IS  = 0x35
	IM  = 0x36
	IV  = 0x37
	IH  = 0x38
	IR  = 0x39
	FP  = 0x3A
	SP  = 0x3B
	BP  = 0x3C
	DB  = 0x3D
	DM  = 0x3E
	PC  = 0x3F
	Names = {
		0x00: "R0 ", 0x01: "R1 ", 0x02: "R2 ", 0x03: "R3 ", 0x04: "R4 ", 
		0x05: "R5 ", 0x06: "R6 ", 0x07: "R7 ", 0x08: "R8 ", 0x09: "R9 ",
		0x0A: "R10", 0x0B: "R11", 0x0C: "R12", 0x0D: "R13", 0x0E: "R14", 
		0x0F: "R15", 0x10: "R16", 0x11: "R17", 0x12: "R18", 0x13: "R19", 
		0x14: "R20", 0x15: "R21", 0x16: "R22", 0x17: "R23", 0x18: "R24",
		0x19: "R25", 0x1A: "R26", 0x1B: "R27", 0x1C: "R28", 0x1D: "R29",
		0x1E: "R30", 0x1F: "R31", 0x20: "R32", 0x21: "R33", 0x22: "R34",
		0x23: "R35", 0x24: "R36", 0x25: "R37", 0x26: "R38", 0x27: "R39",
		0x28: "R40", 0x29: "R41", 0x2A: "R42", 0x2B: "R43", 0x2C: "R44",
		0x2D: "R45", 0x2E: "RX ", 0x33: "RT ", 0x34: "SR ", 0x35: "IS ",
		0x36: "IM ", 0x37: "IV ", 0x38: "IH ", 0x39: "IR ", 0x3A: "FP ",
		0x3B: "SP ", 0x3C: "BP ", 0x3D: "DB ", 0x3E: "DM ", 0x3F: "PC ",
	}
	
	def __init__(self, val = 0, id = 0):
		self.val = val
		self.id = id
	def set(self, val):
		self.val = val
		return self
	def get(self):
		return self.val

class InvalidHexFileError(Exception):
	pass
		

class Memory(object):
	ChunkSize = 128
	def __init__(self):
		self.chunks = dict()
		self
	
	def getChunk(self, addr):
		start = addr - (addr % Memory.ChunkSize)
		if start not in self.chunks:
			self.chunks[start] = [0 for _ in xrange(Memory.ChunkSize)]
		return self.chunks[start]
	
	def __getitem__(self, addr):
		chunk = self.getChunk(addr)
		return chunk[addr % Memory.ChunkSize]
	def __setitem__(self, addr, val):
		chunk = self.getChunk(addr)
		chunk[addr % Memory.ChunkSize] = val
		return self
	
	def read(self, addr):
		if addr == 0x000001:
			return 0x23C0DE
		elif addr == 0x000002:
			return 0x000000
		elif addr == 0x000003:
			return 0x3FFFFF
		elif addr == 0x000004: # Random
			return random.getrandbits(23)
		elif addr == 0x000005: # Pseudo Random
			val = self[addr]
			bit  = ~((val >> 0x16) ^ (val >> 0x11)) & 0x1;
			self[addr] = int((val >> 0x1) | (bit << 0x22));
			return val
		else:
			return self[addr]
		
	def write(self, addr, val, bootload = False):
		if bootload or addr > 0x000004:
			self[addr] = val
		return self
		
	def open(self, filename):
		fHnd = open(filename, "rb")
		magic = fHnd.read(3)
		if all(itertools.starmap(operator.eq, zip(magic,[0x23,0xC0,0xDE]))):
			raise InvalidHexFileError()
		raw = fHnd.read(3)
		length = (ord(raw[0]) << 16) + (ord(raw[1]) << 16) + (ord(raw[2]) << 0)
		for offset in xrange(length):
			raw = fHnd.read(3)
			word = (ord(raw[0]) << 16) + (ord(raw[1]) << 8) + (ord(raw[2]) << 0)
			self.write(offset, word, bootload = True)
		return self
			
		

class NonExecutionError(Exception):
	pass
	
class InvalidInstructionError(Exception):
	pass
		
class Instruction(object):
	Names = {	
		0x00: "NOP", 0x01: "LDR", 0x02: "STR", 0x03: "CPR",
		0x04: "SET", 0x05: "BIT", 0x06: "ADD", 0x07: "SUB",
		0x08: "LSL", 0x09: "LSR", 0x0A: "AND", 0x0B: "OR" ,
		0x0C: "XOR", 0x0D: "NOT", 0x0E: "CMP", 0x0F: "BRA",
		0x10: "JMP", 0x11: "EMW", 0x12: "EMR", 
		0x1F: "HLT",
	}
	RegisterUsage = [
		(False, False, False, False, 4), 
		(True , False, True , False, 2), 
		(True , False, True , False, 2), 
		(True , False, True , False, 2), 
		(False, False, True , True , 1), 
		(True , False, True , True , 2), 
		(True , True , True , False, 3), 
		(True , True , True , False, 3), 
		(True , False, True , True , 2), 
		(True , False, True , True , 2), 
		(True , True , True , False, 3), 
		(True , True , True , False, 3), 
		(True , True , True , False, 3), 
		(True , False, True , False, 2), 
		(True , True , False, False, 3), 
		(True , False, False, False, 0), 
		(True , False, False, False, 0), 
		(True , False, True , True , 2), 
		(True , False, True , True , 2), 
		(False, False, False, False, 3), 
		(False, False, False, False, 3), 
		(False, False, False, False, 3), 
		(False, False, False, False, 3), 
		(False, False, False, False, 3), 
		(False, False, False, False, 3), 
		(False, False, False, False, 3), 
		(False, False, False, False, 3), 
		(False, False, False, False, 3), 
		(False, False, False, False, 3), 
		(False, False, False, False, 3), 
		(False, False, False, False, 3), 
		(False, False, False, False, 4) 
	]
	
	@staticmethod
	def parse(emulator, bytecode):
		if (bytecode >> 23) & 0x1 == 1:
			raise NonExecutionError()
		opcode = (bytecode >> 18) & 0x1F
		if Instruction.RegisterUsage[opcode][4] == 0:
			return Instruction(
				opcode,
				a = emulator.registers[(bytecode >> 12) & 0x3F],
				c = (bytecode >> 0) & 0xFFF	
			)
		if Instruction.RegisterUsage[opcode][4] == 1:
			return Instruction(
				opcode,
				c = (bytecode >> 6) & 0xFFF,
				d = emulator.registers[(bytecode >> 0) & 0x3F]	
			)
		if Instruction.RegisterUsage[opcode][4] == 2:
			return Instruction(
				opcode,
				a = emulator.registers[(bytecode >> 12) & 0x3F],
				c =(bytecode >> 6) & 0x3F,
				d = emulator.registers[(bytecode >> 0) & 0x3F],
			)
		if Instruction.RegisterUsage[opcode][4] == 3:
			return Instruction(
				opcode,
				a = emulator.registers[(bytecode >> 12) & 0x3F],
				b = emulator.registers[(bytecode >> 6) & 0x3F],
				d = emulator.registers[(bytecode >> 0) & 0x3F],
			)
		if Instruction.RegisterUsage[opcode][4] == 4:
			return Instruction(opcode)
		raise InvalidInstructionError()	
	
	def __init__(self, op = 0, a = None, b = None, d = None, c = None):
		self.op = op
		self.a = a
		self.b = b
		self.c = c
		self.d = d
		
	def execute(self, emu):
		args = [reg for nr,reg in enumerate([self.a, self.b, self.d, self.c]) if Instruction.RegisterUsage[self.op][nr]]
		return emu.operations[self.op](*args)
	
		
class HaltError(Exception):
	pass
		
class Emu23(object):
	RegisterCount = 64

	def __init__(self):
		self.registers = [Register(id = i) for i in xrange(Emu23.RegisterCount)]
		self.operations = [
			lambda : None , # NOP  
			lambda a,d: d.set(self.memory.read(a)), # LDR  
			lambda a,d: self.memory.write(a, d.get()), # STR  
			lambda a,d: d.set(a.get()), # CPR  
			lambda d,c: d.set(c), # SET  
			lambda d,c: d.set(0x1 << c), # BIT  
			lambda a,b,d: d.set(self.binOperation(a.get(),b.get(),operator.add, 0x002160)), # ADD  
			lambda a,d,c: d.set(self.binOperation(a.get(),b.get(),operator.sub, 0x0021C0)), # SUB  
			lambda a,d,c: d.set(self.binOperation(a.get(), c, operation.lshift, 0x002140)), # LSL  
			lambda a,d,c: d.set(self.binOperation(a.get(), c, operation.rshift, 0x002140)), # LSR  
			lambda a,b,d: d.set(self.binOperation(a.get(), b.get(), operation.and_, 0x002040)), # AND  
			lambda a,b,d: d.set(self.binOperation(a.get(), b.get(), operation.or_, 0x002040)), # OR   
			lambda a,b,d: d.set(self.binOperation(a.get(), b.get(), operation.xor, 0x002040)), # XOR  
			lambda a,b,d: d.set(self.unaryOperation(a.get(), operation.inv, 0x002040)), # NOT  
			self.compare, # CMP  
			self.branch, # BRA  
			self.jump, # JMP  
			lambda : None, # EMW  
			lambda : None, # EMR  
			lambda : None, # 0x13 
			lambda : None, # 0x14 
			lambda : None, # 0x15 
			lambda : None, # 0x16 
			lambda : None, # 0x17 
			lambda : None, # 0x18 
			lambda : None, # 0x19 
			lambda : None, # 0x1A 
			lambda : None, # 0x1B 
			lambda : None, # 0x1C 
			lambda : None, # 0x1D 
			lambda : None, # 0x1E 
			self.halt, # HLT 
		]
		self.memory = Memory()
		
	def _setFlags(self, res, mask):
		sr = self.registers[Register.SR].get()
		# clear flags
		sr = sr & (mask ^ 0x3FFFFF)
		# True Flag
		if ((res & 0x3FFFFF) == 0x3FFFFF) and (mask & (0x1 << 13) == (0x1 << 13)):
			sr = sr | (0x1 << 13)
		# Zero Flag
		if ((res & 0x3FFFFF) == 0x000000) and (mask & (0x1 << 6) == (0x1 << 6)):
			sr = sr | (0x1 << 6)
		# Overflow Flag
		if ((res & 0x3FFFFF) < res) and (mask & (0x1 << 5) == (0x1 << 5)):
			sr = sr | (0x1 << 5)
		# Underflow Flag
		if (res < 0) and (mask & (0x1 << 7) == (0x1 << 7)):
			sr = sr | (0x1 << 7)
		# Carry Flag
		sr = sr | ( ((res >> 23) & 0x1) << 8)
		self.registers[Register.SR].set(sr)
		
	def binOperation(self, a,b, op, mask):
		res = op(a,b)
		self._setFlags(res, mask)
		return res	
	def unaryOperation(self, a, op, mask):
		res = op(a)
		self._setFlags(res, mask)
		return res
		
	def halt(self):
		raise HaltError()
		
	def compare(self, a,b):
		sr = self.registers[Register.SR].get()
		# clear flags
		sr = sr & (0x002E40 ^ 0x3FFFFF)
		if (a.get() > b.get()):
			sr = sr | (0x1 << 11)
		if (a.get() < b.get()):
			sr = sr | (0x1 <<  9)
		if (a.get() == b.get()):
			sr = sr | (0x1 << 10)
			sr = sr | (0x1 <<  6)
		self.registers[Register.SR].set(sr)
		return self.registers[Register.SR]
		
	def jump(self, a):
		return self.registers[Register.PC].set(a.get())
		
	def branch(self, a):
		if ((self.registers[Register.SR].get() >> 6) & 0x1) == 1:
			return self.jump(a)
		return None
		
	def _run(self, filename):
		self.memory.open(filename)
		sys.stdout.write("\033[s") # Save Cursor Position
		self.registers[Register.DB].set(0x7FF600)
		self.registers[Register.DM].set(0x7FF600)
		self.registers[Register.BP].set(0x7FF600)
		self.registers[Register.SP].set(0x7FF600)
		try:
			# --- Initialize: Load Reset Address and start Programm
			self.registers[Register.PC].set(self.memory.read(0) & 0x1FFFFF)
			while True:
				# --- 1 Fetch
				word = self.memory.read(self.registers[Register.PC].get())
				# --- 2 Decode
				instr = Instruction.parse(self, word)
				self.writeDebugInfo(word, instr)
				yield word
				# --- 3 Execute
				dest = instr.execute(self)
				# --- 4 Increment PC, if the instruction is not a jump
				if dest != self.registers[Register.PC]:
					self.registers[Register.PC].set(self.registers[Register.PC].get() +1)
				
		except HaltError:
			pass
			
	def singleStep(self, filename):
		getch = _Getch()
		for word in self._run(filename, True):
			self.display()
			ch = getch()		
			
	def run(self, filename):
		for word in self._run(filename):
			self.display()
			
	def _writeText(self, offset, text, color = 0x70):
		for addr,char in enumerate(text, start=offset):
			self.memory.write(addr, (color << 15) | ord(char))
		
			
	def writeDebugInfo(self, word, instr):
		# 0x7FF600       _0     _1     _2     _3     _4     _5     _6     _7     _8     _9    
		# 0x7FF650 R0_ 000000 000000 000000 000000 000000 000000 000000 000000 000000 000000 
		# 0x7FF6A0 R1_ 000000 000000 000000 000000 000000 000000 000000 000000 000000 000000 
		# 0x7FF6F0 R2_ 000000 000000 000000 000000 000000 000000 000000 000000 000000 000000 
		# 0x7FF740 R3_ 000000 000000 000000 000000 000000 000000 000000 000000 000000 000000 
		# 0x7FF790 R4_ 000000 000000 000000 000000 000000 000000
		# 0x7FF7E0
		# 0x7FF830 PC 000000 opc rga rgb rgd #0xcccccc     SR FNORDXWITHGELCUZV000000  
		# 0x7FF880 RX 000000 RT 000000 FP 000000 SP 000000 BP 000000 DB 000000 DM 000000 
		# 0x7FFD00 IS 000000 IM 000000 IV 000000 IH 000000 IR 000000 
		# 
		self._writeText(0x7FF600, "      _0     _1     _2     _3     _4     _5     _6     _7     _8     _9  ", 0x10)
		self._writeText(0x7FF650, "R0_ ", 0x10) 
		self._writeText(0x7FF654, " ".join(map(lambda r:"{:06X}".format(r.get()), self.registers[0:10])), 0x60) 
		self._writeText(0x7FF6A0, "R1_ ", 0x10) 
		self._writeText(0x7FF6A4, " ".join(map(lambda r:"{:06X}".format(r.get()), self.registers[10:20])), 0x60) 
		self._writeText(0x7FF6F0, "R2_ ", 0x10) 
		self._writeText(0x7FF6F4, " ".join(map(lambda r:"{:06X}".format(r.get()), self.registers[20:30])), 0x60) 
		self._writeText(0x7FF740, "R3_ ", 0x10) 
		self._writeText(0x7FF744, " ".join(map(lambda r:"{:06X}".format(r.get()), self.registers[30:40])), 0x60) 
		self._writeText(0x7FF790, "R4_ ", 0x10) 
		self._writeText(0x7FF794, " ".join(map(lambda r:"{:06X}".format(r.get()), self.registers[40:46])), 0x60) 
		self._writeText(0x7FF830, "PC", 0x50)
		self._writeText(0x7FF833, "{:06X}".format(self.registers[Register.PC].get()))
		self._writeText(0x7FF83A, Instruction.Names[instr.op], 0x20)
		self._writeText(0x7FF83E, Register.Names[instr.a.id] if Instruction.RegisterUsage[instr.op][0] else "   ", 0x30 if Instruction.RegisterUsage[instr.op][0] and instr.a.id <= 45 else 0x90)
		self._writeText(0x7FF842, Register.Names[instr.b.id] if Instruction.RegisterUsage[instr.op][1] else "   ", 0x30 if Instruction.RegisterUsage[instr.op][1] and instr.b.id <= 45 else 0x90)
		self._writeText(0x7FF846, Register.Names[instr.d.id] if Instruction.RegisterUsage[instr.op][2] else "   ", 0x30 if Instruction.RegisterUsage[instr.op][2] and instr.d.id <= 45 else 0x90)
		self._writeText(0x7FF84A, "#0x{:X}".format(instr.c)  if Instruction.RegisterUsage[instr.op][3] else "        ", 0x50)
		self._writeText(0x7FF858, "SR", 0x50)
		sr = self.registers[Register.SR].get()
		for i,c in zip(range(21,0,-1),"FNORDXWITHGELCUZV"):
			self._writeText(0x7FF85B+(21-i), c, 0xF0 if ((sr >> i) & 0x1) == 1 else 0x80)
		self._writeText(0x7FF880, "RX", 0x50) 
		self._writeText(0x7FF883, "{:06X}".format(self.registers[Register.RX].get()), 0x30)
		self._writeText(0x7FF88A, "RT", 0x50) 
		self._writeText(0x7FF88D, "{:06X}".format(self.registers[Register.RT].get()), 0x30)
		self._writeText(0x7FF894, "FP", 0x50) 
		self._writeText(0x7FF897, "{:06X}".format(self.registers[Register.FP].get()), 0x30)
		self._writeText(0x7FF89E, "SP", 0x50) 
		self._writeText(0x7FF8A1, "{:06X}".format(self.registers[Register.SP].get()), 0x30)
		self._writeText(0x7FF8A8, "BP", 0x50) 
		self._writeText(0x7FF8AB, "{:06X}".format(self.registers[Register.BP].get()), 0x30)
		self._writeText(0x7FF8B2, "DB", 0x50) 
		self._writeText(0x7FF8B5, "{:06X}".format(self.registers[Register.DB].get()), 0x30)
		self._writeText(0x7FF8BC, "DM", 0x50) 
		self._writeText(0x7FF8BF, "{:06X}".format(self.registers[Register.DM].get()), 0x30)
		self._writeText(0x7FF8D0, "IS", 0x50)
		self._writeText(0x7FF8D3, "{:06X}".format(self.registers[Register.IS].get()), 0x30)
		self._writeText(0x7FF8DA, "IM", 0x50)
		self._writeText(0x7FF8DD, "{:06X}".format(self.registers[Register.IM].get()), 0x30) 
		self._writeText(0x7FF8E4, "IV", 0x50) 
		self._writeText(0x7FF8E7, "{:06X}".format(self.registers[Register.IV].get()), 0x30) 
		self._writeText(0x7FF8EE, "IH", 0x50) 
		self._writeText(0x7FF8F1, "{:06X}".format(self.registers[Register.IH].get()), 0x30) 
		self._writeText(0x7FF8F8, "IR", 0x50)
		self._writeText(0x7FF8FB, "{:06X}".format(self.registers[Register.IR].get()), 0x30)
			
	def display(self):
		db = self.registers[Register.DB].get()
		sys.stdout.write("\033[u") # Restore Cursor Position
		print ".---------------------."
		print "|    EMULATOR 23      |"
		print "+---------------------+----------------------------------------------------------+"
		for y in xrange(30):
			sys.stdout.write("|")
			for x in xrange(80):
				word = self.memory.read(db+x+(y*80))
				char = word & 0x7F
				fg   = (word >> 19) & 0xF
				bg   = (word >> 15) & 0xF
				sys.stdout.write("\033[{};3{};4{}m".format(((fg >> 3) & 0x1), fg & 0x7, bg & 0x7))
				sys.stdout.write(chr(char))
			sys.stdout.write("\033[0m")
			print "|"
		print "'--------------------------------------------------------------------------------'"
		
	
	
e = Emu23()	
e.run("../asm/test.hex")