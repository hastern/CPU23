#!/usr/bin/env python
# -*- coding:utf-8 -*-

import operator
import itertools
import random
import sys
import time
import argparse
import threading


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

    def __call__(self):
        return self.impl()


class _GetchUnix:
    def __init__(self):
        import tty
        import sys

    def __call__(self):
        import sys
        import tty
        import termios
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
        ch = msvcrt.getch()
        if ch in ['\r', '\n']:
            return ord('\n')
        if ch == '\xe0':
            ch = msvcrt.getch()
            if ch == 'H':  # Up Arrow
                return 1
            if ch == 'M':  # Right Arrow
                return 4
            if ch == 'P':  # Down Arrow
                return 2
            if ch == 'K':  # Left Arrow
                return 3
            if ch == 'R':  # ins
                return 11
            if ch == 'G':  # home
                return 13
            if ch == 'I':  # pageup
                return 15
            if ch == 'Q':  # pagedown
                return 16
            if ch == 'O':  # end
                return 14
            if ch == 'S':  # del
                return 12
        else:
            return ord(ch)


class KeyListener(object):
    def __init__(self, emulator):
        self.emulator = emulator
        self.thread = threading.Thread(target=self.listen)
        self.thread.daemon = True
        self.thread.start()

    def listen(self):
        getch = _Getch()
        while True:
            ch = getch()
            if ch == 27:
                self.emulator.halt()
                break
            self.emulator.send_key(ch)


class StatusBits(object):
    Fnord      = 21
    New        = 20
    Order      = 19
    Redundant  = 18
    Dirty      = 17
    eXtensions = 16
    World      = 15
    Interrupt  = 14
    True_      = 13
    Halt       = 12
    Greater    = 11
    Equal      = 10
    Lesser     = 9
    Carry      = 8
    Underflow  = 7
    Zero       = 6
    Overflow   = 5


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
    RA  = 0x2E
    RB  = 0x2F
    RX  = 0x30
    RT  = 0x31
    TR  = 0x32
    PR  = 0x33
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
        0x2D: "R45",
        0x2E: "RA ", 0x2F: "RB ", 0x30: "RX ", 0x31: "RT ",
        0x32: "TR ", 0x33: "PR ",
        0x34: "SR ", 0x35: "IS ", 0x36: "IM ", 0x37: "IV ", 0x38: "IH ", 0x39: "IR ",
        0x3A: "FP ", 0x3B: "SP ", 0x3C: "BP ", 0x3D: "DB ", 0x3E: "DM ", 0x3F: "PC ",
    }

    def __init__(self, val=0, id=0):
        self.val = val
        self.id = id

    def set(self, val):
        self.val = val & 0x7FFFFF
        return self

    def get(self):
        return self.val


class InvalidHexFileError(Exception):
    pass


class Memory(object):
    ChunkSize = 128

    def __init__(self, emulator):
        self.chunks = dict()
        self.emulator = emulator

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
            return 0x7FFFFF
        elif addr == 0x000004:  # Random
            return random.getrandbits(23)
        elif addr == 0x000005:  # Pseudo Random
            val = self[addr]
            bit  = ~((val >> 0x16) ^ (val >> 0x11)) & 0x1
            self[addr] = int((val >> 0x1) | (bit << 0x22))
            return val
        else:
            return self[addr]

    def write(self, addr, val, bootload=False):
        if bootload or addr > 0x000004:
            self[addr] = val
        # Quick and dirty UART hack
        if addr == 0x000029 and self.emulator._wrap_uart:
            self.emulator.dma.interrupt(5)
            data = self.read(0x000029)
            print "{}{}{}".format(
                chr((data >> 16) >> 0xFF),
                chr((data >> 8) >> 0xFF),
                chr((data >> 0) & 0xFF)
            ),
        return self

    def open(self, filename):
        fHnd = open(filename, "rb")
        magic = fHnd.read(3)
        if all(itertools.starmap(operator.eq, zip(magic, [0x23, 0xC0, 0xDE]))):
            raise InvalidHexFileError()
        raw = fHnd.read(3)
        length = (ord(raw[0]) << 16) + (ord(raw[1]) << 8) + (ord(raw[2]) << 0)
        for offset in xrange(length):
            raw = fHnd.read(3)
            word = (ord(raw[0]) << 16) + (ord(raw[1]) << 8) + (ord(raw[2]) << 0)
            self.write(offset, word, bootload=True)
        return self


class DMA(object):
    Addresses = [0x000023, 0x000024, 0x000025, 0x000026, 0x000027,
                 0x000028, 0x000029, 0x00002A, 0x00002B, 0x00002C,
                 0x00002D, 0x00002E, 0x00002F, 0x000030, 0x000031,
                 0x000032, 0x000033, 0x000034, 0x000035, 0x000036,
                 0x000037, 0x000038, 0x000039,
                 ]

    def __init__(self, emulator):
        self.emulator = emulator

    def access(self, addr, data=None):
        try:
            assert addr < 23
            self.interrupt(addr)
            if data is None:
                data = self.emulator.memory.read(DMA.Addresses[addr + 1]) & 0x7FFFFF
            else:
                self.emulator.memory.write(DMA.Addresses[addr + 1], data | 0x800000)
            return data
        except:
            self.emulator.registers[Register.SR].set(self.emulator.registers[Register.SR].get() | (1 << StatusBits.Halt))

    def interrupt(self, addr):
        self.emulator.registers[Register.SR].set(self.emulator.registers[Register.SR].get() | (1 << StatusBits.Interrupt))
        self.emulator.registers[Register.IH].set(self.emulator.memory.read(DMA.Addresses[addr] - 0x18) & 0x7FFFFF)
        self.emulator.memory.write(0x000023, (1 << addr))


class NonExecutionError(Exception):
    pass


class InvalidInstructionError(Exception):
    pass


class Instruction(object):
    TypeAC  = 0
    TypeDC  = 1
    TypeACD = 2
    TypeABD = 3
    TypeZ   = 4
    TypeAD  = 5
    Names = {0x00: "NOP", 0x01: "LDR", 0x02: "STR", 0x03: "CPR",
             0x04: "SET", 0x05: "BIT", 0x06: "ADD", 0x07: "SUB",
             0x08: "LSL", 0x09: "LSR", 0x0A: "AND", 0x0B: "OR",
             0x0C: "XOR", 0x0D: "NOT", 0x0E: "CMP", 0x0F: "BRA",
             0x10: "BNE", 0x11: "JMP", 0x12: "EMW", 0x13: "EMR",
             0x1F: "HLT",
             }
    RegisterUsage = [
        (False, False, False, False, TypeZ),   # NOP
        (True, False, True, False, TypeABD),  # LDR
        (True, False, True, False, TypeABD),  # STR
        (True, False, True, False, TypeAD),  # CPR
        (False, False, True, True, TypeDC),  # SET
        (True, False, True, True, TypeACD),  # BIT
        (True, True, True, False, TypeABD),  # ADD
        (True, True, True, False, TypeABD),  # SUB
        (True, True, True, False, TypeABD),  # LSL
        (True, True, True, False, TypeABD),  # LSR
        (True, True, True, False, TypeABD),  # AND
        (True, True, True, False, TypeABD),  # OR
        (True, True, True, False, TypeABD),  # XOR
        (True, False, True, False, TypeAD),  # NOT
        (True, True, False, False, TypeABD),  # CMP
        (True, False, False, False, TypeAC),  # BRA
        (True, False, False, False, TypeAC),  # BNE
        (True, False, False, False, TypeAC),  # JMP
        (True, True, True, False, TypeABD),  # EMW
        (True, True, True, False, TypeABD),  # EMR
        (False, False, False, False, TypeABD),  # RC0
        (False, False, False, False, TypeABD),  # RC1
        (False, False, False, False, TypeABD),  # RC2
        (False, False, False, False, TypeABD),  # RC3
        (False, False, False, False, TypeABD),  # RC4
        (False, False, False, False, TypeABD),  # RC5
        (False, False, False, False, TypeABD),  # RC6
        (False, False, False, False, TypeABD),  # RC7
        (False, False, False, False, TypeABD),  # RC8
        (False, False, False, False, TypeABD),  # RC9
        (False, False, False, False, TypeABD),  # RCA
        (False, False, False, False, TypeZ)     # HLT
    ]

    @staticmethod
    def parse(emulator, bytecode):
        if (bytecode >> 23) & 0x1 == 1:
            raise NonExecutionError("{:6X} @0x{:06X} ".format(bytecode, emulator.registers[Register.PC].get()))
        opcode = (bytecode >> 18) & 0x1F
        if Instruction.RegisterUsage[opcode][4] == Instruction.TypeAC:
            return Instruction(
                opcode,
                a=emulator.registers[(bytecode >> 12) & 0x3F],
                c=(bytecode >> 0) & 0xFFF
            )
        if Instruction.RegisterUsage[opcode][4] == Instruction.TypeDC:
            return Instruction(
                opcode,
                c=(bytecode >> 6) & 0xFFF,
                d=emulator.registers[(bytecode >> 0) & 0x3F]
            )
        if Instruction.RegisterUsage[opcode][4] == Instruction.TypeACD:
            return Instruction(
                opcode,
                a=emulator.registers[(bytecode >> 12) & 0x3F],
                c=(bytecode >> 6) & 0x3F,
                d=emulator.registers[(bytecode >> 0) & 0x3F],
            )
        if Instruction.RegisterUsage[opcode][4] == Instruction.TypeABD:
            return Instruction(
                opcode,
                a=emulator.registers[(bytecode >> 12) & 0x3F],
                b=emulator.registers[(bytecode >> 6) & 0x3F],
                d=emulator.registers[(bytecode >> 0) & 0x3F],
            )
        if Instruction.RegisterUsage[opcode][4] == Instruction.TypeAD:
            return Instruction(
                opcode,
                a=emulator.registers[(bytecode >> 12) & 0x3F],
                d=emulator.registers[(bytecode >> 0) & 0x3F],
            )
        if Instruction.RegisterUsage[opcode][4] == Instruction.TypeZ:
            return Instruction(opcode)
        raise InvalidInstructionError()

    def __init__(self, op=0, a=None, b=None, d=None, c=None):
        self.op = op
        self.a = a
        self.b = b
        self.c = c
        self.d = d

    def execute(self, emu):
        args = [reg for nr, reg in enumerate([self.a, self.b, self.d, self.c]) if Instruction.RegisterUsage[self.op][nr]]
        return emu.operations[self.op](*args)

    def __str__(self):
        return "{op} {a:<3} {b:<3} {d:<3} {c:>6}".format(
            op=self.Names[self.op],
            a="" if self.a is None else Register.Names[self.a.id],
            b="" if self.b is None else Register.Names[self.b.id],
            d="" if self.d is None else Register.Names[self.d.id],
            c="" if self.c is None else self.c
        )


class HaltError(Exception):
    pass


class Emu23(object):
    RegisterCount = 64

    def __init__(self, debug=False, timeout=None, instr_list=False, emulate_display=False, wrap_uart=False):
        self._showdebug = debug
        self._timeout = timeout
        self._instr_list = instr_list
        self._emulate_display = emulate_display
        self._wrap_uart = wrap_uart
        self.debug = ""
        self.registers = [Register(id=i) for i in xrange(Emu23.RegisterCount)]
        self.operations = [
            lambda: None,  # NOP
            lambda a, d: d.set(self.memory.read(a.get())),  # LDR
            lambda a, b: self.memory.write(b.get(), a.get()),  # STR
            lambda a, d: d.set(a.get()),  # CPR
            lambda d, c: d.set(c),  # SET
            lambda a, d, c: d.set(self.setBit(a.get(), c & 0x1F, c & 0x20)),
            lambda a, b, d: d.set(self.binOperation(a.get(), b.get(), operator.add, (1 << StatusBits.Carry) | (1 << StatusBits.True_) | (1 << StatusBits.Zero) | (1 << StatusBits.Overflow))),  # ADD
            lambda a, b, d: d.set(self.binOperation(a.get(), b.get(), operator.sub, (1 << StatusBits.Carry) | (1 << StatusBits.True_) | (1 << StatusBits.Zero) | (1 << StatusBits.Underflow))),  # SUB
            lambda a, b, d: d.set(self.binOperation(a.get(), b.get(), operator.lshift, (1 << StatusBits.Carry) | (1 << StatusBits.True_) | (1 << StatusBits.Zero))),  # LSL
            lambda a, b, d: d.set(self.binOperation(a.get(), b.get(), operator.rshift, (1 << StatusBits.Carry) | (1 << StatusBits.True_) | (1 << StatusBits.Zero))),  # LSR
            lambda a, b, d: d.set(self.binOperation(a.get(), b.get(), operator.and_, (1 << StatusBits.True_) | (1 << StatusBits.Zero))),  # AND
            lambda a, b, d: d.set(self.binOperation(a.get(), b.get(), operator.or_, (1 << StatusBits.True_) | (1 << StatusBits.Zero))),  # OR
            lambda a, b, d: d.set(self.binOperation(a.get(), b.get(), operator.xor, (1 << StatusBits.True_) | (1 << StatusBits.Zero))),  # XOR
            lambda a, d: d.set(self.unaryOperation(a.get(), operator.inv, (1 << StatusBits.True_) | (1 << StatusBits.Zero))),  # NOT
            self.compare,  # CMP
            self.branch,  # BRA
            self.branch_not_equal,  # BNE
            self.jump,  # JMP
            lambda: None,  # EMW
            lambda: None,  # EMR
            lambda: None,  # 0x13
            lambda: None,  # 0x14
            lambda: None,  # 0x15
            lambda: None,  # 0x16
            lambda: None,  # 0x17
            lambda: None,  # 0x18
            lambda: None,  # 0x19
            lambda: None,  # 0x1A
            lambda: None,  # 0x1B
            lambda: None,  # 0x1C
            lambda: None,  # 0x1D
            self.halt,  # HLT
        ]
        self.memory = Memory(self)
        self.dma = DMA(self)

    def _setFlags(self, res, mask):
        sr = self.registers[Register.SR].get()
        # clear flags
        sr = sr & (mask ^ 0x7FFFFF)
        # True Flag
        if ((res & 0x7FFFFF) == 0x7FFFFF) and (mask & (0x1 << StatusBits.True_) == (0x1 << StatusBits.True_)):
            sr = sr | (0x1 << StatusBits.True_)
        # Zero Flag
        if ((res & 0x7FFFFF) == 0x000000) and (mask & (0x1 << StatusBits.Zero) == (0x1 << StatusBits.Zero)):
            sr = sr | (0x1 << StatusBits.Zero)
        # Overflow Flag
        if ((res & 0x7FFFFF) < res) and (mask & (0x1 << StatusBits.Overflow) == (0x1 << StatusBits.Overflow)):
            sr = sr | (0x1 << StatusBits.Overflow)
        # Underflow Flag
        if (res < 0) and (mask & (0x1 << StatusBits.Underflow) == (0x1 << StatusBits.Underflow)):
            sr = sr | (0x1 << StatusBits.Underflow)
        # Carry Flag
        sr = sr | (((res >> 23) & 0x1) << StatusBits.Carry)
        self.registers[Register.SR].set(sr)

    def binOperation(self, a, b, op, mask):
        res = op(a, b)
        self._setFlags(res, mask)
        return res

    def unaryOperation(self, a, op, mask):
        res = op(a)
        self._setFlags(res, mask)
        return res

    def halt(self):
        self.registers[Register.SR].set(self.registers[Register.SR].get() | (1 << StatusBits.Halt))

    def setBit(self, org, bit, val):
        if not val:
            return org & ~(1 << bit)
        else:
            return org | (1 << bit)

    def compare(self, a, b):
        sr = self.registers[Register.SR].get()
        # clear flags
        sr = sr & (0x002E40 ^ 0x7FFFFF)
        if (a.get() > b.get()):
            sr = sr | (0x1 << StatusBits.Greater)
        if (a.get() < b.get()):
            sr = sr | (0x1 << StatusBits.Lesser)
        if (a.get() == b.get()):
            sr = sr | (0x1 << StatusBits.Equal)
            sr = sr | (0x1 << StatusBits.Zero)
        self.registers[Register.SR].set(sr)
        return self.registers[Register.SR]

    def jump(self, a):
        return self.registers[Register.PC].set(a.get())

    def branch(self, a):
        if ((self.registers[Register.SR].get() >> StatusBits.Zero) & 0x1) == 1:
            return self.jump(a)
        return None

    def branch_not_equal(self, a):
        if ((self.registers[Register.SR].get() >> StatusBits.Zero) & 0x1) == 0:
            return self.jump(a)
        return None

    def _run(self, filename):
        self.memory.open(filename)
        sys.stdout.write("\033[s")  # Save Cursor Position
        self.registers[Register.DB].set(0x7FF000)
        self.registers[Register.DM].set(0x7FF000)
        self.registers[Register.BP].set(0x7FEFFF)
        self.registers[Register.SP].set(0x7FEFFF)
        try:
            timer = 0
            # --- Initialize: Load Reset Address and start Programm
            self.registers[Register.PC].set(self.memory.read(0) & 0x1FFFFF)
            while True:
                # --- 1 Fetch
                word = self.memory.read(self.registers[Register.PC].get())
                # --- 2 Decode
                self.last_instr = Instruction.parse(self, word)
                if self._instr_list:
                    sys.stderr.write("{:30}\r".format(str(self.last_instr)))
                yield word
                # --- 3 Execute
                dest = self.last_instr.execute(self)
                # --- 4 Increment PC, if the instruction is not a jump
                if dest != self.registers[Register.PC]:
                    self.registers[Register.PC].set(self.registers[Register.PC].get() + 1)
                # ---   Check if the CPU was halted
                if (self.registers[Register.SR].get() & (1 << StatusBits.Halt)) != 0:
                    raise HaltError()
                # ---   Check if an interrupt has happpend
                if (dest != self.registers[Register.RX]) and (self.registers[Register.SR].get() & (1 << StatusBits.Interrupt)) != 0:
                    # Save PC to IR
                    self.registers[Register.IR].set(self.registers[Register.PC].get())
                    # Set PC to basic interrupt handling routine
                    self.registers[Register.PC].set(0x00003B)
                # --- Timer
                timer += 1
                pr = self.registers[Register.PR].get()
                tr = self.registers[Register.TR].get()
                if pr > 0 and pr >= timer:
                    timer = 0
                    if tr > 0:
                        self.registers[Register.TR].set(tr - 1)
        except HaltError:
            self.display()

    def singleStep(self, filename):
        getch = _Getch()
        for word in self._run(filename):
            self.display()
            ch = getch()

    def run(self, filename):
        instr_count = 0
        start = time.time()
        for word in self._run(filename):
            instr_count += 1
            if self._emulate_display:
                self.display()
            if self._timeout is not None:
                time.sleep(self._timeout)
        stop = time.time()
        diff = stop - start
        print "Executed {} Instructions in {:.03f} sec. ({:.01f}/sec)".format(
            instr_count,
            diff,
            instr_count / diff,
        )

    def _writeText(self, offset, text, color=0x70):
        for addr, char in enumerate(text, start=offset):
            self.memory.write(addr, (color << 15) | ord(char))

    def send_key(self, ch):
        if self._wrap_uart:
            print ch,
            self.dma.access(6, ch)
        else:
            self.dma.access(3, ch)

    def display(self):
        db = self.registers[Register.DB].get()
        buf = []
        for y in xrange(30):
            line = []
            for x in xrange(80):
                word = self.memory.read(db + x + (y * 80))
                char = word & 0x7F
                if char == 0:
                    line.append("\033[0m ")
                else:
                    fg   = (word >> 19) & 0xF
                    bg   = (word >> 15) & 0xF
                    line.append("\033[{};3{};4{}m{}".format(((fg >> 3) & 0x1), fg & 0x7, bg & 0x7, chr(char)))
            line.append("\033[0m")
            buf.append("".join(line))
        sr = self.registers[Register.SR].get()
        status = []
        for i, c in zip(range(21, 0, -1), "FNORDXWITHGELCUZV"):
            status.append("\033[1;3{}m{}".format(7 if ((sr >> i) & 0x1) == 1 else 0, c))
        bp = self.registers[Register.BP].get()
        stack_addrs = range(bp - 6, bp + 1)
        print """\033[u
           .---------------.                        EMULATOR 23                             .-----------------.
           |    Screen     |                                                                |    Registers    |
+----------+---------------+----------------------------------------------------------------+-----------------+-----------------------.
| 0x{addr[0]:06X} |{line[0]:80}| \033[31m      0_     1_     2_     3_     4_   \033[0m |
| 0x{addr[1]:06X} |{line[1]:80}| \033[31mR_0\033[0m \033[36m{Reg[0]:06X} {Reg[10]:06X} {Reg[20]:06X} {Reg[30]:06X} {Reg[40]:06X} \033[0m |
| 0x{addr[2]:06X} |{line[2]:80}| \033[31mR_1\033[0m \033[36m{Reg[1]:06X} {Reg[11]:06X} {Reg[21]:06X} {Reg[31]:06X} {Reg[41]:06X} \033[0m |
| 0x{addr[3]:06X} |{line[3]:80}| \033[31mR_2\033[0m \033[36m{Reg[2]:06X} {Reg[12]:06X} {Reg[22]:06X} {Reg[32]:06X} {Reg[42]:06X} \033[0m |
| 0x{addr[4]:06X} |{line[4]:80}| \033[31mR_3\033[0m \033[36m{Reg[3]:06X} {Reg[13]:06X} {Reg[23]:06X} {Reg[33]:06X} {Reg[43]:06X} \033[0m |
| 0x{addr[5]:06X} |{line[5]:80}| \033[31mR_4\033[0m \033[36m{Reg[4]:06X} {Reg[14]:06X} {Reg[24]:06X} {Reg[34]:06X} {Reg[44]:06X} \033[0m |
| 0x{addr[6]:06X} |{line[6]:80}| \033[31mR_5\033[0m \033[36m{Reg[5]:06X} {Reg[15]:06X} {Reg[25]:06X} {Reg[35]:06X} {Reg[45]:06X} \033[0m |
| 0x{addr[7]:06X} |{line[7]:80}| \033[31mR_6\033[0m \033[36m{Reg[6]:06X} {Reg[16]:06X} {Reg[26]:06X} {Reg[36]:06X}        \033[0m |
| 0x{addr[8]:06X} |{line[8]:80}| \033[31mR_7\033[0m \033[36m{Reg[7]:06X} {Reg[17]:06X} {Reg[27]:06X} {Reg[37]:06X}        \033[0m |
| 0x{addr[9]:06X} |{line[9]:80}| \033[31mR_8\033[0m \033[36m{Reg[8]:06X} {Reg[18]:06X} {Reg[28]:06X} {Reg[38]:06X}        \033[0m |
| 0x{addr[10]:06X} |{line[10]:80}| \033[31mR_9\033[0m \033[36m{Reg[9]:06X} {Reg[19]:06X} {Reg[29]:06X} {Reg[39]:06X}        \033[0m |
| 0x{addr[11]:06X} |{line[11]:80}|                                         |
| 0x{addr[12]:06X} |{line[12]:80}| \033[35mPC\033[0m {PC:06X} \033[32m{opcode:3}\033[0m \033[33m{opa:3} {opb:3} {opd:3}\033[0m \033[35m{cst:9}\033[0m     |
| 0x{addr[13]:06X} |{line[13]:80}| \033[35mSR\033[0m {SR:21}00000\033[0m               |
| 0x{addr[14]:06X} |{line[14]:80}|                                         |
| 0x{addr[15]:06X} |{line[15]:80}| \033[35mRA\033[0m \033[33m{RA:06X}\033[0m \033[35mRB\033[0m \033[33m{RB:06X}\033[0m \033[35mRX\033[0m \033[33m{RX:06X}\033[0m \033[35mRT\033[0m \033[33m{RT:06X}\033[0m |
| 0x{addr[16]:06X} |{line[16]:80}| \033[35mTR\033[0m \033[33m{TR:06X}\033[0m \033[35mPR\033[0m \033[33m{PR:06X}\033[0m \033[35m  \033[0m \033[32m      \033[0m \033[35m  \033[0m \033[32m      \033[0m |
| 0x{addr[17]:06X} |{line[17]:80}| \033[35mFP\033[0m \033[33m{FP:06X}\033[0m \033[35mSP\033[0m \033[33m{SP:06X}\033[0m \033[35mBP\033[0m \033[33m{BP:06X}\033[0m \033[35m  \033[0m \033[32m      \033[0m |
| 0x{addr[18]:06X} |{line[18]:80}| \033[35mDB\033[0m \033[33m{DB:06X}\033[0m \033[35mDM\033[0m \033[33m{DM:06X}\033[0m \033[35m  \033[0m \033[32m      \033[0m \033[35m  \033[0m \033[32m      \033[0m |
| 0x{addr[19]:06X} |{line[19]:80}| \033[35mIS\033[0m \033[33m{IS:06X}\033[0m \033[35mIM\033[0m \033[33m{IM:06X}\033[0m \033[35mIV\033[0m \033[33m{IV:06X}\033[0m \033[35m  \033[0m \033[32m      \033[0m |
| 0x{addr[20]:06X} |{line[20]:80}| \033[35mIH\033[0m \033[33m{IH:06X}\033[0m \033[35mIR\033[0m \033[33m{IR:06X}\033[0m \033[35m  \033[0m \033[32m      \033[0m \033[35m  \033[0m \033[32m      \033[0m |
| 0x{addr[21]:06X} |{line[21]:80}|                                         |
| 0x{addr[22]:06X} |{line[22]:80}|  Stack                                  |
| 0x{addr[23]:06X} |{line[23]:80}|  0x{stack_addr[6]:06X} 0x{stack_data[6]:06X}                      |
| 0x{addr[24]:06X} |{line[24]:80}|  0x{stack_addr[5]:06X} 0x{stack_data[5]:06X}                      |
| 0x{addr[25]:06X} |{line[25]:80}|  0x{stack_addr[4]:06X} 0x{stack_data[4]:06X}                      |
| 0x{addr[26]:06X} |{line[26]:80}|  0x{stack_addr[3]:06X} 0x{stack_data[3]:06X}                      |
| 0x{addr[27]:06X} |{line[27]:80}|  0x{stack_addr[2]:06X} 0x{stack_data[2]:06X}                      |
| 0x{addr[28]:06X} |{line[28]:80}|  0x{stack_addr[1]:06X} 0x{stack_data[1]:06X}                      |
| 0x{addr[29]:06X} |{line[29]:80}|  0x{stack_addr[0]:06X} 0x{stack_data[0]:06X}                      |
'----------+--------------------------------------------------------------------------------+-----------------------------------------'
{debug}""".format(addr=[db + (y * 80) for y in xrange(30)],
                  line=buf,
                  Reg=[self.registers[n].get() for n in xrange(46)],
                  PC=self.registers[Register.PC].get(),
                  opcode=Instruction.Names[self.last_instr.op],
                  opa=Register.Names[self.last_instr.a.id] if Instruction.RegisterUsage[self.last_instr.op][0] else "",
                  opb=Register.Names[self.last_instr.b.id] if Instruction.RegisterUsage[self.last_instr.op][1] else "",
                  opd=Register.Names[self.last_instr.d.id] if Instruction.RegisterUsage[self.last_instr.op][2] else "",
                  cst="#0x{:X}".format(self.last_instr.c) if Instruction.RegisterUsage[self.last_instr.op][3] else "",
                  SR="".join(status),
                  RA=self.registers[Register.RA].get(),
                  RB=self.registers[Register.RB].get(),
                  RX=self.registers[Register.RX].get(),
                  RT=self.registers[Register.RT].get(),
                  TR=self.registers[Register.TR].get(),
                  PR=self.registers[Register.PR].get(),
                  FP=self.registers[Register.FP].get(),
                  SP=self.registers[Register.SP].get(),
                  BP=self.registers[Register.BP].get(),
                  DB=self.registers[Register.DB].get(),
                  DM=self.registers[Register.DM].get(),
                  IS=self.registers[Register.IS].get(),
                  IM=self.registers[Register.IM].get(),
                  IV=self.registers[Register.IV].get(),
                  IH=self.registers[Register.IH].get(),
                  IR=self.registers[Register.IR].get(),
                  debug=self.debug,
                  stack_addr=stack_addrs,
                  stack_data=map(self.memory.read, stack_addrs)
                  ),


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("file", action="store", help="The file containing the bytecode.")
    parser.add_argument("--single-step", "-s", action="store_true", default=False, help="Wait after execution of one command.")
    parser.add_argument("--debug", action="store_true", default=False, help="Display debugging Information.")
    parser.add_argument("--timeout", "-t", type=float, default=None, help="Timeout between two instructions.")
    parser.add_argument("--list", "-l", action="store_true", default=False, help="List all operations as the get executed.")
    parser.add_argument("--show-display", action="store_true", default=False, help="Emulate the display inside the console.")
    parser.add_argument("--wrap-uart", action="store_true", default=False, help="Emulate a UART Interface in the console.")

    args = parser.parse_args()
    e = Emu23(args.debug, args.timeout, args.list, args.show_display, args.wrap_uart)
    KeyListener(e)
    if args.single_step:
        e.singleStep(args.file)
    else:
        e.run(args.file)
