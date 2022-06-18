#include <stdlib.h>

char* __main() {
    char* Memory = malloc(27);

    char NextCharacter = 'A';

    for (int Index = 0; Index < 26; Index++) {
        Memory[Index] = NextCharacter++;
    }

    return Memory;
}