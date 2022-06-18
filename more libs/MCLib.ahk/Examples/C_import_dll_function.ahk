#Include %A_ScriptDir%/../
#include MCLib.ahk

C =
( %

#include <stdint.h>
#include <mclib.h>

MCLIB_IMPORT(int, User32, MessageBoxA, (uint64_t, char*, char*, uint32_t))

void __main() {
	MessageBoxA(0, "Hello world from C!", "Wow", 0);
}

)

Code := MCLib.AHKFromC(C, false) ; Compile and stringify the code, but don't format it as an AHK string literal (since we're going to load it again momentarily)

pCode := MCLib.FromString(Code)

DllCall(pCode)