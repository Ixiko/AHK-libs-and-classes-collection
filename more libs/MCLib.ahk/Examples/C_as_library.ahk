#Include %A_ScriptDir%/../
#include MCLib.ahk

C =
( %

#include <mclib.h>

MCLIB_EXPORT_INLINE(int, Add, (int Left, int Right)) {
    return Left + Right;
}

MCLIB_EXPORT_INLINE(int, Multiply, (int Left, int Right)) {
    return Left * Right;
}

int unused() {
    return 20;
}

)

Code := MCLib.FromC(C)

Added := DllCall(Code.Add, "Int", 300, "Int", -20, "Int")
MsgBox, % Added

Multiplied := DllCall(Code.Multiply, "Int", Added, "Int", 2, "Int")
MsgBox, % Multiplied
