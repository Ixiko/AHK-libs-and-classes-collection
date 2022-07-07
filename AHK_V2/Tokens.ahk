; This is a library created by TheArkyTekt
;
; Posted on AutoHotKey Forum

; ===========================================================================
; GetTok(sInput,sSep,lToken)
; ===========================================================================
; sInput = "string" or variable set to a string
; sSep   = single char enclosed in "" as separator
; lToken = positive integer or range, ie "2-3".
;		   range must be enclosed in "".
;          To select a range starting from N to last tok
;          use "N-" (not specifying an end in the range).
;
; EXAMPLES:
; Single Token = GetTok("a.b.c" , "." , 2)
;      Returns = b
; Token Range  = GetTok("a.b.c" , "." , "2-3")
;      Returns = b.c
; Token Range2 = GetTok("a.b.c.d" , "." , "2-")
;      Returns = b.c.d
; ===========================================================================
GetTok(sInput,sSep,lToken,bDebugNow:=0) {
	TempArray := StrSplit(sInput,sSep), TempRange := StrSplit(lToken,"-")
	; MsgBox % "TempRange count: " TempRange.Count()
	
	If (TempRange.Length > 2) {
		TempRange := "", TempArray := ""
		Return
	} Else If (TempRange.Length = 1) {
		MinRange := lToken, MaxRange := lToken
		if (MaxRange = 0)
			Return
	} Else If (TempRange.Length = 2) {
		MinRange := TempRange[1], MaxRange := TempRange[2]
		If (MaxRange = 0)
			Return
		MaxRange := MaxRange?MaxRange:TempArray.Length
	}
	
	If (bDebugNow)
		MsgBox("MinRange: " MinRange " / MaxRange: " MaxRange " / lToken: " lToken)
	
	If (MinRange = MaxRange) {
		sOutput := TempArray[MinRange]
	} Else {
		For k, v in TempArray
		{
			If (k >= MinRange And k <= MaxRange)
				sOutput .= v sSep
		}
		sOutput := Trim(sOutput,OmitChars:=sSep)
	}
	
	; MsgBox("Input: " sInput "`r`nsSep: " sSep "`r`nlToken: " lToken "`r`nsOutput: " sOutput)
	TempArray := "", TempRange := ""
	Return sOutput
}

GetLastTok(sInput,sSep) {
	TempArray := StrSplit(sInput,sSep)
	nLast := TempArray.Length
	lastTok := TempArray[nLast]
	TempArray := ""
	return lastTok
}

NumTok(sInput,sSep) {
	TempArray := StrSplit(sInput,sSep)
	Tokens := TempArray.Length ? TempArray.Length : 0
	TempArray := ""
	Return Tokens
}

MatchTok(sInput,sSep,sMatch) {
    MatchResult := 0
    Loop Parse sInput, sSep, " `t`n"
    {
        If (A_LoopField = sMatch)
            MatchResult := A_Index
    }
    return MatchResult
}

MatchTokW(sInput,sSep,sMatch) {
    MatchResult := 0
    Loop Parse sInput, sSep, " `t`n"
    {
        If (InStr(A_LoopField,sMatch))
            MatchResult := A_Index
    }
    return MatchResult
}

DelBlankTok(sInput,sSep) {
	NewStr := ""
    Loop Parse sInput, sSep
    {
        Cnt := A_Index
        If (A_LoopField != "") {
            If (NewStr = "")
                NewStr := A_LoopField
            Else
                NewStr := NewStr sSep A_LoopField
        }
    }
    
    return NewStr
}

DelTok(sInput,sSep,sMatch) { ; sMatch must be an exact match
    Loop Parse sInput, sSep
    {
        If (A_LoopField != "" And A_LoopField != sMatch) {
            If (sOutput = "") {
                sOutput := A_LoopField
            } Else {
                sOutput := sOutput sSep A_LoopField
            }
        }
    }

    return sOutput
}