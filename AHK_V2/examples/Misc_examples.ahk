#include ..\Lib\Misc.ahk

; ----------------- Print ----------------------
Print("Hello") ; Uses OutputDebug to print the string 'Hello'

Print({example:"Object", key:"value"},MsgBox) ; Next calls of Print will use MsgBox to display the value
; ----------------- Range ----------------------

; Loop forwards, equivalent to Loop 10
result := ""
for v in Range(10)
    result .= v "`n"
Print(result)

; Loop backwards, equivalent to Range(1,10,-1)
Print(Range(10,1).ToArray())

; Loop forwards, step 2
Print(Range(-10,10,2).ToArray())

; Nested looping
result := ""
for v in Range(3)
    for k in Range(5,1)
        result .= v " " k "`n"
Print(result)

; ----------------- RegExMatchAll ----------------------

result := ""
matches := RegExMatchAll("a,bb,ccc", "\w+")
for i, match in matches
    result .= "Match " i ": " match[] "`n"
Print(result)