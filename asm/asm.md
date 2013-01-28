The CPU23 assembly language.
============================


	<ASM>		::= <LINE>'\n'*
	<LINE>		::= [<LABEL>]\t[<WORD>][<COMMENT>]
	<WORD>		::= <COMMAND>|<VALUE>
	<COMMAND>	::= <OPCODE> <REGSEL> <REGSEL> [<CONSTANT>]
	<OPCODE>	::= 	"NOP" | "RLS" | "SET" | "RST" | 
				"ADD" | "SUB" | "LSL" | "LSR" | 
				"AND" | "OR"  | "XOR" | "NOT" |
				"CMP" | "JMP" | "BRA" | "CLL" | 
				"EMW" | "EMR" 
	<REGSEL>	::= <REGISTER>|<REG_INDIRECT>|<REG_OP>
	<REGISTER>	::= 	"R0" | "R1" | "R2" | "R3" | "R4" | 
				"R5" | "R6" | "R7" | "R8" | "R9" | 
				"RX" | "IR" | "SR" | "SP" | "DP" | "PC"
	<REG_INDIRECT>	::= "["<REGISTER>"]" | "["<REGISTER>,<DISPLACEMENT>"]" 
	<REG_OP>	::= "["<REGISTER><POSTOP>"]" | "["<PREOP><REGISTER>"]"
	<PREOP>		::= <PREPOST>
	<POSTOP>	::= <PREPOST>
	<PREPOST>	::= '+' | '-'
	<DISPLACEMENT>	::= <CONSTANT>
	<CONSTANT>	::= 0 - 16 | 0x0 - 0xF
	<VALUE>		::= <LITERAL>

	<COMMENT>	::= %<STRING>
	<LABEL>		::= :<NAME>
	<LITERAL>	::= #<NUMBER>

	<NAME>		::= [A-Za-z0-9]*
	<NUMBER		::= 0 - 2^23 | 0x000000 - 0x7FFFFF


*Constants*:
The optional constant in a command word is enclosed in parenthesis.

*Values*:
Values can be placed directly between the instructions.
Every value starts with the character #.

*Comments*: 
A comment starts with a '%' and ends with a new line.
	
*OpCodes*:
The language consists of 32 opcodes, defined be the CPU specifications.
Each opcode is represented by its two or three letter representation.

		NOP RLS SET RST ADD SUB LSL LSR AND OR  XOR NOT CMP JMP BRA CLL EMW EMR 

*Register selection*:	
A register can be selected by its name.

	R0 R1 R2 R3 R4 R5 R6 R7 R8 R9 RX IR SR SP DP PC

A displacement can be added by brackets and an optional comma separated 
displacement. The displacement is always positive.

	Example: 
	[R0]	The value at the address stored in R0.
	[R0,1]	The value at the address+1 stored in R0.

Other than an explicit displacement a pre or post increment or decrement can be 
defined by either + oder - before or after the name.

	Example:
	[R0+]	Read the value at the address stored in R0 and increment value of R0 afterwards.
	[-R0]	Decrement R0 and read the value at the resulting address.
	
	



