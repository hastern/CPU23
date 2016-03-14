# --------------------------------------------- #
# asm23 - CPU23 Assembler                       #
# Hanno Sternberg                               #
#                                               #
# Makefile                                      #
# --------------------------------------------- #

# Compiler
CC          = gcc
# Linker
LD          = $(CC)

# Include directories
INCLUDES        =
# Compiler flags
CFLAGS_COMMON   = -c -g -Wall -Wextra
CFLAGS          = $(CFLAGS_COMMON) -DNDEBUG
# Linker flags
LDFLAGS         =

PY              = python
PREPROCESSOR    = asm23.py
EMULATOR        = emu23.py
VHT_GENERATOR   = vht23.py
EMULATOR_FLAGS  = --show-display

# Source codes
SOURCE_ASM=asm23.c cpu23.c
OBJECTS_ASM=$(SOURCE_ASM:.c=.o)

SOURCE_DASM=dasm23.c cpu23.c
OBJECTS_DASM=$(SOURCE_DASM:.c=.o)


.PHONY: all help clean doc rebuild doc
.SECONDARY:

default: all

all: $(BINARY_ASM) $(BINARY_DASM)

# Compile a single file
%.o : %.c
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $<

asm23: $(OBJECTS_ASM) ## Build low level assembler
	$(LD) $(LDFLAGS) $(OBJECTS_ASM) -o asm23

dasm23: $(OBJECTS_DASM) ## Build Disassembler
	$(LD) $(LDFLAGS) $(OBJECTS_DASM) -o dasm23

clean: ## Clean the object files
	@rm -f $(OBJECTS_ASM) $(OBJECTS_DASM) *~

rebuild: clean all ## Make a clean build

%.a23: %.asm23 ## Apply the preprocessor to <FILE>
	@$(PY) $(PREPROCESSOR) $<

%.hex: %.a23 ## Assemble a program <FILE>
	@./asm23 $< $@

%.run: %.hex ## Run the program <FILE> in the emuator
	@$(PY) $(EMULATOR) $(EMULATOR_FLAGS) $<

%.vht: %.hex ## Create a Testbench to be used in Modelsim
	@$(PY) $(VHT_GENERATOR) -O $<

help: ## Show this help
	@grep -E '^[a-zA-Z0-9%._-]+:.*?## .*$$' Makefile | sed 's/%/<FILE>/g' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
