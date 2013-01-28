/**
 * CPU23 Assembler
 */

#include <stdio.h>

#include "cpu23.h"

int main(int argc, char * argv[]) {
	int err = 0;
	if (argc == 3) {
		printf("ASM file: %s\n", argv[1]);
		printf("HEX file: %s\n", argv[2]);
		{
			HexFile * hf = newHexFile();
			if (hf != NULL) {
				if (parseFile(argv[1], hf)) {
					if (!saveHexFile(hf, argv[2])) {
						fprintf(stderr, "ERROR: Can't save Hex file");
						err = 1;
					}
				} else {
					fprintf(stderr, "ERROR: Can't parse asm file");
					err = 1;
				}
				hf = freeHexFile(hf);
			} else {
				fprintf(stderr, "ERROR: Hex file is NULL");
				err = 1;
			}
		}
	} else {
		fprintf(stderr, "ERROR: Not enough arguments");
		err = 1;
	}
	return err;
}