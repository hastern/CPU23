

The CPU23 assembly language.
============================

Each line contains exactly one command.


OpCode
------

The language consists of 32 opcodes, defined be the CPU specifications.
Each opcode is represented by its two or three letter representation.

	NOP 
	LD  STR 
	CP  
	SET RST 
	PSH POP 
	INC DEC 
	ADD SUB 
	LSL LSR 
	AND OR  XOR NOT 
	CMP TST 
	JMP BRA 
	CLL BRS RTS 
	DSP 
	EMW EMR

Register selection	
------------------

A register can be selected by its name.

	R0 R1 R2 R3 R4 R5 R6 R7 R8 R9
	RX IR SR SP DP PC

A displacement can be added by brackets and an optional comma separated 
displacement. The displacement is always positive.

	Example: 
	[R0]	The value at the address stored in R0.
	[R0,1]	The value at the address+1 stored in R0.

Other than an explicit displacement a pre or post increment or decrement can be 
defined by either + oder - before or after the name.

	Example:
	[R0+]	Read the value at the address stored in R0 and increment R0.
	[-R0]	Decrement R0 and read the value at the address stored in R0.
	
Constants
---------

The optional constant in a command word is enclosed in parenthesis.








