;==================================================
;does not support:
;if {
;} else if {
;} else {
;'else DoThis' one-liners
;Label:
;HotkeyLabel::

;note: this function trims any trailing whitespace on a line
;requires: JEE_StrCount/JEE_StrEnds/JEE_StrRept/JEE_StrStarts
;vOpt: c (do not change indent: comments), g (do not change indent: general lines), i (show diagnostic info)
JEE_StrIndent(vText, vIndent:="`t", vOpt:="") {
	static vListIf := "If ,If`t,IfEqual,IfExist,IfGreater,IfGreaterOrEqual,IfInString,IfLess,IfLessOrEqual,IfMsgBox,IfNotEqual,IfNotExist,IfNotInString,IfWinActive,IfWinExist,IfWinNotActive,IfWinNotExist"
	static vListLoop := "For ,For`t,Loop,While"
	static vListTry := "Catch,Finally,Try"
	static vListOp := "&& ,|| ,AND ,OR ,&&`t,||`t,AND`t,OR`t"
	;also: Else, start/end continuation sections, function definitions, labels

	if !InStr(vOpt, "c")
		vDoIndentCommentLines := 1
	if !InStr(vOpt, "g")
		vDoIndentGeneral := 1
	if InStr(vOpt, "i")
		vDoShowInfo := 1

	oArray := StrSplit(vText, "`n", "`r")
	vMem := "", oMemLastIf := [], oConSec := {}, oInfo := {}
	Loop, % oArray.Length()
	{
		vTemp := LTrim(oArray[A_Index])
		if vPos := RegExMatch(vTemp, "[ `t]*;")
			vCode := SubStr(vTemp, 1, vPos-1), vComments := SubStr(vTemp, vPos)
		else
			vCode := vTemp, vComments := ""
		;===============
		;HANDLE CONTINUATION SECTIONS
		if !vIsConSec && (SubStr(vTemp, 1, 1) = "(") && !InStr(vCode, ")")
		{
			vOutput .= JEE_StrRept(vIndent, vCountLast) A_LoopField "`r`n"
			vIsConSec := 1
			continue
		}
		if (SubStr(vTemp, 1, 1) = ")")
		{
			vOutput .= JEE_StrRept(vIndent, vCountLast) A_LoopField "`r`n"
			vIsConSec := 0
			continue
		}
		if vIsConSec
		{
			vOutput .= A_LoopField "`r`n"
			oConSec[A_Index] := "" ;create key
			continue
		}
		;===============
		;IDENTIFY LINE CATEGORY
		if JEE_StrStarts(vTemp, "if") && JEE_StrStarts(vTemp, vListIf, ",")
			vCateg := "i"
		else if JEE_StrStarts(vTemp, vListLoop, ",")
			vCateg := "L"
		else if JEE_StrStarts(vTemp, "else")
			vCateg := "e"
		else if JEE_StrStarts(vTemp, vListTry, ",")
			vCateg := "t"
		else if JEE_StrStarts(vTemp, vListOp, ",")
			vCateg := "o"
		else if JEE_StrStarts(vTemp, "{")
			vCateg := "{"
		else if JEE_StrStarts(vTemp, "}")
			vCateg := "}"
		else if JEE_StrStarts(vTemp, ";") || (vTemp = "") || vIsConSec
			vCateg := ";"
		else
			vCateg := "x"
		;===============
		;BEFORE APPEND TEXT
		if !(vCateg = ";") && !(vCateg = "o") && !(vCateg = "e")
		&& JEE_StrEnds(vMem, "_")
			vMem := SubStr(vMem, 1, -1)
		if !(vCateg = ";") && !(vCateg = "o") && !(vCateg = "e")
		&& JEE_StrEnds(vMem, "t")
		&& ((vCateg = "x") || (vCateg = "i") || (vCateg = "L") || (vCateg = "}"))
			vMem := RTrim(vMem, "t_")
		if JEE_StrEnds(vMem, "t_") && !(vCategLast = "}")
		&& (vCateg = "e")
			vMem := SubStr(vMem, 1, -2)
		if (vCateg = "e")
			vMem := oMemLastIf[JEE_StrCount(vMem, "{")]
		else if (vCateg = "i")
			oMemLastIf[JEE_StrCount(vMem, "{")] := vMem
		;===============
		;APPEND TEXT
		vTabCount := JEE_StrCount(vMem, "t") + JEE_StrCount(vMem, "{") - (vCateg = "o") - (vCateg = "{") - (vCateg = "}") + StrLen(vMem2)
		(vDoShowInfo = 1) && oInfo[A_Index] := vCateg " " vMem "`t"
		if (vDoIndentGeneral && vDoIndentCommentLines)
		|| (vDoIndentGeneral && !vDoIndentCommentLines && !(vCateg = ";"))
		|| (!vDoIndentGeneral && vDoIndentCommentLines && (vCateg = ";"))
			oArray[A_Index] := JEE_StrRept(vIndent, vTabCount) vTemp
		;===============
		;AFTER APPEND TEXT
		if (vCateg = "i") || (vCateg = "L") || (vCateg = "e")
			vMem .= "t__"
		else if (vCateg = "{")
			vMem := SubStr(vMem, 1, -2) "{"
		else if (vCateg = "}")
			vMem := SubStr(vMem, 1, -1)
		else if !(vCateg = ";")
			vCategLast := vCateg
		vCateg2 := "x"
		;===============
	}

	if vDoIndentCommentLines
	{
		vLen := StrLen(vIndent)
		vCountLast := 0
		Loop, % vIndex := oArray.Length()+1
		{
			vIndex--
			vTemp := oArray[vIndex]
			if oConSec.HasKey(vIndex)
				continue
			vCount := 0
			while JEE_StrStarts(vTemp, vIndent)
				vTemp := SubStr(vTemp, vLen+1), vCount += 1
			if JEE_StrStarts(vTemp, ";")
				oArray[vIndex] := JEE_StrRept(vIndent, vCountLast) vTemp
			else if JEE_StrStarts(vTemp, "}")
				vCountLast := vCount+1
			else if !(vTemp = "")
				vCountLast := vCount
		}
	}
	vOutput := ""
	VarSetCapacity(vOutput, StrLen(vText)*2)
	if vDoShowInfo
	{
		Loop, % oArray.Length()
			vOutput .= RTrim((A_Index=1?"":"`r`n") oInfo[A_Index] oArray[A_Index])
	}
	else
	{
		Loop, % oArray.Length()
			vOutput .= RTrim((A_Index=1?"":"`r`n") oArray[A_Index])
	}
	return vOutput
}
;==================================================
JEE_StrCount(ByRef vText, vNeedle, vCaseSen:=0) {
	local vSCS, vCount
	if (vNeedle = "")
		return ""
	vSCS := A_StringCaseSense
	StringCaseSense, % vCaseSen ? "On" : "Off"
	StrReplace(vText, vNeedle, "", vCount) ;seemed to be faster than line below
	;StrReplace(vText, vNeedle, vNeedle, vCount)
	StringCaseSense, % vSCS
	return vCount
}
;==================================================
JEE_StrRept(vText, vNum) {
	if (vNum <= 0)
		return
	return StrReplace(Format("{:" vNum "}","")," ",vText)
	;return StrReplace(Format("{:0" vNum "}",0),0,vText)
}
;==================================================

;e.g. JEE_StrStarts(vText, "http,www", ",")
;e.g. JEE_StrStarts(vText, "http|www", "|")
;e.g. JEE_StrStarts(vText, "http")

JEE_StrStarts(ByRef vText, ByRef vNeedles, vDelim:="", vCaseSen:=0, ByRef vMatch:="") {
	if (vDelim = "")
		if (!vCaseSen && ("" SubStr(vText, 1, StrLen(vNeedles)) = vNeedles))
		|| (vCaseSen && ("" SubStr(vText, 1, StrLen(vNeedles)) == vNeedles))
		{
			if IsByRef(vMatch)
				vMatch := vNeedles
			return 1
		}
		else
			return 0
	Loop, Parse, vNeedles, % vDelim
		if (!vCaseSen && ("" SubStr(vText, 1, StrLen(A_LoopField)) = A_LoopField))
		|| (vCaseSen && ("" SubStr(vText, 1, StrLen(A_LoopField)) == A_LoopField))
		{
			if IsByRef(vMatch)
				vMatch := A_LoopField
			return A_Index
		}
	return 0
}
;==================================================

JEE_StrEnds(ByRef vText, ByRef vNeedles, vDelim:="", vCaseSen:=0, ByRef vMatch:="") {
	local vLen := StrLen(vText)
	if (vDelim = "")
		if (!vCaseSen && ("" SubStr(vText, vLen-StrLen(vNeedles)+1) = vNeedles))
		|| (vCaseSen && ("" SubStr(vText, 1, vLen-StrLen(vNeedles)+1) == vNeedles))
		{
			if IsByRef(vMatch)
				vMatch := vNeedles
			return 1
		}
		else
			return 0
	Loop, Parse, vNeedles, % vDelim
		if (!vCaseSen && ("" SubStr(vText, vLen-StrLen(A_LoopField)+1) = A_LoopField))
		|| (vCaseSen && ("" SubStr(vText, vLen-StrLen(A_LoopField)+1) == A_LoopField))
		{
			if IsByRef(vMatch)
				vMatch := A_LoopField
			return A_Index
		}
	return 0
}
;==================================================