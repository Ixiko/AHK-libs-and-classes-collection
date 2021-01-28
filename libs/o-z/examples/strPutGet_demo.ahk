; #Include strPut.ahk
; #Include strGet.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

input := ""
output := ""

; Write the string "Hello World!" into variable with default ANSI code page.
; Display how many characters are written.
MsgBox % StrPutVar("Hello World!", input, "cp0")

; Get string from adress of variable "input" with default ANSI code page.
output := StrGet(&input, "cp0")

; Display the output string.
MsgBox %output%

; If you use frequently StrPut() with variables, consider to add this function.
; Function copied from StrPutGet-documentation written by Lexikos.
StrPutVar(string, ByRef var, encoding)
{
    ; Ensure capacity.
    VarSetCapacity( var, StrPut(string, encoding)
        ; StrPut returns char count, but VarSetCapacity needs bytes.
        * ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
    ; Copy or convert the string.
    return StrPut(string, &var, encoding)
}