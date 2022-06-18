#Include %A_ScriptDir%/../
#include MCLib.ahk

C =
( %

#include <stdio.h>

void __main(int Value) {
	FILE* f = fopen("test.txt", "w");

    fputs("Hello world!\n", f);
    fprintf(f, "The number is: %i\n", Value);

    fclose(f);
}

)

pCode := MCLib.FromC(C)

DllCall(pCode, "Int", 2931)