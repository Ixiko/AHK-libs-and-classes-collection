RelToAbs(d1, d2, s = "\") {
	d0 := SubStr(d1, 1, len := InStr(d1, s, "", InStr(d1, s . s) + 2) - 1)
		, d1 := SubStr(d1, len + 1), off := 0
	Loop, 2
		If InStr(d%A_Index%, s, "", 0) = StrLen(d%A_Index%)
			StringTrimRight, d%A_Index%, d%A_Index%, 1
	Loop, Parse, d2, %s%
		If InStr(A_LoopField, "..") = 1
			d1 := SubStr(d1, 1, InStr(d1, s, "", 0) - 1)
		Else If InStr(A_LoopField, ".") = 1
			StringTrimLeft, d2, d2, 2
		Else If A_LoopField =
		{
			d1 =
			StringTrimLeft, d2, d2, 1
		}
	StringReplace, d2, d2, ..%s%, , All
	Return, d0 . d1 . s . d2
}