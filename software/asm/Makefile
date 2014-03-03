# ---------------------------------------------	#
# asm23 - CPU23 Assembler			#
# Hanno Sternberg				#
# 						#
# Makefile					#
# ---------------------------------------------	#

# Compiler
CC			= gcc
# Linker
LD			= gcc
# Doc generator
DOC			= doxygen

# Include directories
INCLUDES	=
# Compiler flags
CFLAGS_COMMON   = -c -g -Wall -Wextra
CFLAGS		= $(CFLAGS_COMMON) -DNDEBUG
# Linker flags
LDFLAGS		=



# Source codes
SOURCE_ASM=asm23.c cpu23.c
OBJECTS_ASM=$(SOURCE_ASM:.c=.o)

SOURCE_DASM=dasm23.c cpu23.c
OBJECTS_DASM=$(SOURCE_DASM:.c=.o)

# Target name
BINARY_ASM=asm23
BINARY_DASM=dasm23

.PHONY: all help clean doc rebuild doc

default: all

all: $(BINARY_ASM) $(BINARY_DASM)

# Compile a single file
%.o : %.c
	@echo ""
	@echo "  - Building $@"
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $<
	@echo "  ... done"

# Link files to an executable
$(BINARY_ASM): $(OBJECTS_ASM)
	@echo ""
	@echo "  - linking $@"
	$(LD) $(LDFLAGS) $(OBJECTS_ASM) -o $(BINARY_ASM)
	@echo "  ... done"
	
# Link files to an executable
$(BINARY_DASM): $(OBJECTS_DASM)
	@echo ""
	@echo "  - linking $@"
	$(LD) $(LDFLAGS) $(OBJECTS_DASM) -o $(BINARY_DASM)
	@echo "  ... done"

# Clean the project
clean:
	@echo ""
	@echo "  - delete object all files"
	rm -f $(OBJECTS_ASM) $(BINARY_ASM) $(OBJECTS_DASM) $(BINARY_DASM) *~ doxygen.log
	rm -rf doc/
	@echo "  ... done"

doc:
	@echo ""
	@echo "  - creating documentation"
	$(DOC)
	@echo "  ... done"

# Rebuild: Clean build
rebuild: clean all

# Show help
help:
	@echo "Options:"
	@echo "make all      - create program"
	@echo "make clean    - clean up"
	@echo "make doc      - create documentation"
	@echo "make debug    - create program with DEBUG enabled"

	