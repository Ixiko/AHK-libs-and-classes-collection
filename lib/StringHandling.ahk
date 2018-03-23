; ==============================================================================
; ==============================================================================
; String handling functions
; ==============================================================================
; ==============================================================================

; ==============================================================================
; ==============================================================================
; string EscapeVarStr(StringIn)
; converts StringIn to escaped string for saving
; ==============================================================================
; ==============================================================================

EscapeVarStr(StringIn)
{
	tline:=StringIn
	StringReplace, tline, tline, ", "", All
	StringReplace, tline, tline, `,, ```,, All
	StringReplace, tline, tline, `%, ```%, All
	StringReplace, tline, tline, `;, ```;, All
	StringReplace, tline, tline, `::, ```::, All
	StringReplace, tline, tline, `n, ``n, All
	StringReplace, tline, tline, `r, ``r, All
	StringReplace, tline, tline, `b, ``b, All
	StringReplace, tline, tline, `t, ``t, All
	StringReplace, tline, tline, `v, ``v, All
	StringReplace, tline, tline, `a, ``a, All
	StringReplace, tline, tline, `f, ``f, All
	Return, tline
}


; ==============================================================================
; ==============================================================================
; string UnEscapeVarStr(StringIn)
; converts double quotes and special characteres in StringIn and removes outer 
; quotes if present
; ==============================================================================
; ==============================================================================

UnEscapeVarStr(StringIn)
{
	tline:=StringIn
	StringReplace, tline, tline, "", ", All
	StringReplace, tline, tline, ```,, `,, All
	StringReplace, tline, tline, ```%, `%, All
	StringReplace, tline, tline, ```;, `;, All
	StringReplace, tline, tline, ```::, `::, All
	StringReplace, tline, tline, ``n, `n, All
	StringReplace, tline, tline, ``r, `r, All
	StringReplace, tline, tline, ``b, `b, All
	StringReplace, tline, tline, ``t, `t, All
	StringReplace, tline, tline, ``v, `v, All
	StringReplace, tline, tline, ``a, `a, All
	StringReplace, tline, tline, ``f, `f, All
	If (InStr(tline,"""")=1 and InStr(tline, """", False, 0)=StrLen(tline))
		tline:=Substr(tline,2,-1)
	Return, tline
}

; ==============================================================================
; ==============================================================================
; string RangeExpand(StringIn)
; converts double quotes and special characteres in StringIn and removes outer 
; quotes if present
; ==============================================================================
; ==============================================================================

RangeExpand(InStr) 
{
	while RegExMatch(InStr, "(\d+)-(\d+)", f)
	{
		loop % (f2 ? f2-f1 : 0) + 1
			ret .= "," (A_Index-1) + f1
		InStr:=RegExReplace(InStr, "(\d+)-(\d+)", SubStr(ret, 2), "", 1)
	}
	return InStr
}

