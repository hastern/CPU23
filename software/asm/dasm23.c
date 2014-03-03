/**
 * CPU23 Assembler
 */

#include <stdlib.h>
#include <stdio.h>

#include "cpu23.h"

int main(int argc, char * argv[]) {
	int err = 0;
	if (argc >= 2) {
		printf("HEX file: %s\n", argv[1]);
		{
			HexFile * hf = newHexFile();
			if (hf != NULL) {
				if (!loadHexFile(hf, argv[1])) {
					fprintf(stderr, "ERROR: Can't load Hex file");
					err = 1;
				} else {
					if (argc == 4) {
						printHexFileRegion(hf, stdout, atoi(argv[2]), atoi(argv[3]));
					} else {
						printHexFile(hf, stdout);
					}
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