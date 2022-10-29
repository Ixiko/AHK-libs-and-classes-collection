TCMatch(aHaystack, aNeedle) {

	chars := "/\[^$.|?*+(){}"

	for i, e in StrSplit(chars)
		aHaystack := StrReplace(aHaystack, e, A_Space)

	; If !RegExMatch(aNeedle, "^[*?<]")
	; aNeedle := "*" aNeedle

	if (A_PtrSize == 8)
		return DllCall("lib\TCMatch64\MatchFileW", "WStr", aNeedle, "WStr", aHaystack)
	else
		return DllCall("lib\TCMatch\MatchFileW", "WStr", aNeedle, "WStr", aHaystack)

}