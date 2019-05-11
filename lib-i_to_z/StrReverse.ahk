; StrReverse(fnString)
; {
	; ReversedString := ""
	; Loop, Parse, fnString
		; ReversedString := A_LoopField ReversedString
	; Return ReversedString
; }

; https://autohotkey.com/board/topic/42396-fastest-way-to-reverse-a-string/
StrReverse(fnString)
{
    VarSetCapacity(ReversedString, n := StrLen(fnString))
    Loop, %n%
        ReversedString .= SubStr(fnString, n--, 1)
    return ReversedString
}


/* ; testing
String := "abcdef ghi, jkl"
ReturnValue := StrReverse(String)
MsgBox, StrReverse`n`nString: %String%`nReturnValue: %ReturnValue%
*/