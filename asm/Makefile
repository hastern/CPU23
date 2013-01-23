# ---------------------------------------------	#
# asm23 - CPU23 Assembler			#
# Hanno Sternberg				#
# 						#
# Makefile					#
# ---------------------------------------------	#

# Compiler
CC			= gcc
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
SOURCE=asm23.c cpu23.c
OBJECTS=$(SOURCE:.c=.o)

# Target name
BINARY=asm23

.PHONY: all help clean doc rebuild doc

default: all

all: $(BINARY)

# Compile a single file
%.o : %.c
	@echo ""
	@echo "  - Building $@"
	$(CC) $(CFLAGS) $(INCLUDES) -o $@ $<
	@echo "  ... done"

# Link files to an executable
$(BINARY): $(OBJECTS)
	@echo ""
	@echo "  - linking $@"
	$(CC) $(LDFLAGS) $(OBJECTS) -o $(BINARY)
	@echo "  ... done"

# Clean the project
clean:
	@echo ""
	@echo "  - delete object all files"
	rm -f $(OBJECTS) $(BINARY) *~ doxygen.log
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

	