#!/usr/bin/env python
# -*- coding:utf-8 -*-

import operator
import itertools


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
	RX  = 0x33
	RT  = 0x34
	SR  = 0x35
	IS  = 0x36
	IM  = 0x37
	IV  = 0x38
	IH  = 0x39
	IR  = 0x3A
	FP  = 0x3B
	SP  = 0x3C
	BP  = 0x3D
	DM  = 0x3E
	PC  = 0x3F
	
	def __init__(self, val = 0):
		self.val = val
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
		return self[addr]
		
	def write(self, addr, val):
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
			word = (ord(raw[0]) << 16) + (ord(raw[1]) << 16) + (ord(raw[2]) << 0)
			self.write(offset, word)
		return self
			
		

class NonExecutionError(Exception):
	pass
	
class InvalidInstructionError(Exception):
	pass
		
class Instruction(object):
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
		(False, False, False, False, 3), 
		(False, False, False, False, 4) 
	]
	
	@staticmethod
	def parse(emulator, bytecode):
		if (bytecode >> 23) & 0x01 == 1:
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
		self.registers = [Register() for _ in xrange(Emu23.RegisterCount)]
		self.operations = [
			lambda : None , # NOP  
			lambda a,d: d.set(self.memory.read(a)), # LDR  
			lambda a,d: self.memory.write(a, d.get()), # STR  
			lambda a,d: d.set(a.get()), # CPR  
			lambda d,c: d.set(c), # SET  
			lambda d,c: d.set(0x1 << c), # BIT  
			lambda a,b,d: d.set(a.get() + b.get()), # ADD  
			lambda a,d,c: d.set(a.get() - b.get()), # SUB  
			lambda a,d,c: d.set(a.get() << c), # LSL  
			lambda a,d,c: d.set(a.get() >> c), # LSR  
			lambda a,b,d: d.set(a.get() & b.get()), # AND  
			lambda a,b,d: d.set(a.get() | b.get()), # OR   
			lambda a,b,d: d.set(a.get() ^ b.get()), # XOR  
			lambda a,b,d: d.set(~ a.get()), # NOT  
			lambda : None, # CMP  
			lambda : None, # BRA  
			lambda : None, # EMW  
			lambda : None, # EMR  
			lambda : None, # 0x12 
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
		
	def halt(self):
		raise HaltError()
		
	def run(self, filename):
		self.memory.open(filename)
		try:
			# --- Initialize: Load Reset Address and start Programm
			self.registers[Register.PC].set(self.memory.read(0) & 0x1FFFFF)
			while True:
				# --- 1 Fetch
				word = self.memory.read(self.registers[Register.PC].get())
				# --- 2 Decode
				instr = Instruction.parse(self, word)
				# --- 3 Execute
				if instr.execute(self) != self.registers[Register.PC]:
					self.registers[Register.PC].set(self.registers[Register.PC].get() +1)
		except HaltError:
			pass
	