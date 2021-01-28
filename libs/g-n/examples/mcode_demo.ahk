; #Include mcode.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; For example, the following line stores the code of the function swapping 
; the bytes of short (16-bit) value.
MCode(BSwap16,"8AE18AC5C3")

; The result is 0x3412 in hex form. These do not involve any external dll's,
; so swapping bytes is almost as fast as if it was a built-in function.
; We can extend the list of built-in function arbitrarily. 
MsgBox % dllcall(&BSwap16, "short",0x1234, "cdecl ushort")
