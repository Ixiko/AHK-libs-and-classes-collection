; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=5&t=27023&p=151285#p151285
; Author:
; Date:
; for:     	AHK_L

/*

	q:: ;examples: html to text / text to html
	;TEST 1 - html to text
	vHtml := "a & b"
	MsgBox % JEE_StrHtmlToText(vHtml)

	;TEST 2 - text to html
	vText := "c & d"
	MsgBox % JEE_StrTextToHtml(vText)

	;TEST 3 - text (255 chars) to html to text
	;(final text should be the same as original text but isn't)(issues with 6 chars: 9,10,11,12,13,160)
	vText := ""
	Loop, 255
		vText .= Chr(A_Index)
	vHtml := JEE_StrTextToHtml(vText)
	MsgBox % (vText = JEE_StrHtmlToText(vHtml))
	;Clipboard := vText "`r`n`r`n" JEE_StrHtmlToText(vHtml)

	;TEST 4 - text (255 chars, 6 chars removed) to html to text
	;(final text is the same as original text)
	Loop, 255
		vText .= Chr(A_Index)
	vList := "9,10,11,12,13,160"
	Loop, Parse, vList, `,
		vText := StrReplace(vText, Chr(A_LoopField), "")
	vHtml := JEE_StrTextToHtml(vText)
	MsgBox % (vText = JEE_StrHtmlToText(vHtml))
	;Clipboard := vText "`r`n`r`n" JEE_StrHtmlToText(vHtml)
	Return

*/

;1 list - frequency count
;1 list - remove duplicates
;2 lists - compare (unique to A/unique to B/present in both)

;list of functions:
;JEE_StrFreqCIA(ByRef vText)
;JEE_StrFreqCID(ByRef vText)
;JEE_StrFreqCID2(ByRef vText)
;JEE_StrFreqCSA(ByRef vText)
;JEE_StrFreqCSD(ByRef vText)
;JEE_StrRemoveDupsCIA(ByRef vText)
;JEE_StrRemoveDupsCID(ByRef vText)
;JEE_StrRemoveDupsCID2(ByRef vText)
;JEE_StrRemoveDupsCSA(ByRef vText)
;JEE_StrRemoveDupsCSD(ByRef vText)
;JEE_StrListCompareCIA(ByRef vText1, ByRef vText2, ByRef vOutputAB, ByRef vOutputA, ByRef vOutputB)
;JEE_StrListCompareCID(ByRef vText1, ByRef vText2, ByRef vOutputAB, ByRef vOutputA, ByRef vOutputB)
;JEE_StrListCompareCID2(ByRef vText1, ByRef vText2, ByRef vOutputAB, ByRef vOutputA, ByRef vOutputB)
;JEE_StrListCompareCSA(ByRef vText1, ByRef vText2, ByRef vOutputAB, ByRef vOutputA, ByRef vOutputB)
;JEE_StrListCompareCSD(ByRef vText1, ByRef vText2, ByRef vOutputAB, ByRef vOutputA, ByRef vOutputB)

;some functions require:
;JEE_SortCasIns

;==================================================

;ARRAY TYPE 1: 'CIA', case insensitive, alphabetical order
;ARRAY TYPE 2: 'CID', case insensitive, date creation order
;ARRAY TYPE 3: 'CSA', case sensitive, alphabetical order
;ARRAY TYPE 4: 'CSD', case sensitive, date creation order

;==================================================
;list line frequency ('CIA', case insensitive, alphabetical order)
JEE_StrFreqCIA(ByRef vText){
	oArray := {}
	StrReplace(vText, "`n", "", vCount)
	oArray.SetCapacity(vCount+1)
	Loop, Parse, vText, `n, `r
		if oArray.HasKey("" A_LoopField)
			oArray["" A_LoopField]++
		else
			oArray["" A_LoopField] := 1
	vOutput := ""
	VarSetCapacity(vOutput, StrLen(vText)*2*2)
	for vKey, vValue in oArray
		vOutput .= vValue "`t" vKey "`r`n"
	oArray := ""
	return vOutput
}

;==================================================
;list line frequency ('CID', case insensitive, date creation order)
JEE_StrFreqCID(ByRef vText){
	oArray := ComObjCreate("Scripting.Dictionary"), oArray2 := {}
	Loop, Parse, vText, `n, `r
		if oArray2.HasKey("" A_LoopField)
			oArray.item(oArray2["" A_LoopField])++
		else
			oArray.item("" A_LoopField) := 1, oArray2["" A_LoopField] := "" A_LoopField
	vOutput := ""
	VarSetCapacity(vOutput, StrLen(vText)*2*2)
	for vKey, vValue in oArray
		vOutput .= oArray.item(vKey) "`t" vKey "`r`n"
	oArray := oArray2 := ""
	return vOutput
}

;==================================================
;list line frequency ('CID', case insensitive, date creation order)
;slower alternative to JEE_StrFreqCID
JEE_StrFreqCID2(ByRef vText){
	oArray := {}, oArray2 := {}
	StrReplace(vText, "`n", "", vCount)
	oArray.SetCapacity(vCount+1)
	oArray2.SetCapacity(vCount+1)
	Loop, Parse, vText, `n, `r
		if oArray.HasKey("" A_LoopField)
			oArray["" A_LoopField]++
		else
			oArray["" A_LoopField] := 1, oArray2.Push("" A_LoopField)
	vOutput := ""
	VarSetCapacity(vOutput, StrLen(vText)*2*2)
	for _, vValue in oArray2
		vOutput .= oArray["" vValue] "`t" vValue "`r`n"
	oArray := oArray2 := ""
	return vOutput
}

;==================================================
;list line frequency ('CSA', case sensitive, alphabetical order)
JEE_StrFreqCSA(ByRef vText, vCSWithinCI=0){
	oArray := ComObjCreate("Scripting.Dictionary")
	vText2 := StrReplace(vText, "`r`n", "`n")
	Sort, vText2, CS
	;e.g. case sensitive: 'A,B,C,a,b,c'
	;e.g. 'CS within CI': 'A,a,B,b,C,c'
	if vCSWithinCI
		Sort, vText2, F JEE_SortCasIns
	Loop, Parse, vText2, `n, `r
		oArray.item("" A_LoopField) := 0
	Loop, Parse, vText, `n, `r
		oArray.item("" A_LoopField)++
	vOutput := ""
	VarSetCapacity(vOutput, StrLen(vText)*2*2)
	for vKey in oArray
		vOutput .= oArray.item(vKey) "`t" vKey "`r`n"
	oArray := ""
	return vOutput
}

;==================================================
;list line frequency ('CSD', case sensitive, date creation order)
JEE_StrFreqCSD(ByRef vText){
	oArray := ComObjCreate("Scripting.Dictionary")
	Loop, Parse, vText, `n, `r
		if !(oArray.item("" A_LoopField) = "")
			oArray.item("" A_LoopField)++
		else
			oArray.item("" A_LoopField) := 1
	vOutput := ""
	VarSetCapacity(vOutput, StrLen(vText)*2*2)
	for vKey in oArray
		vOutput .= oArray.item(vKey) "`t" vKey "`r`n"
	oArray := ""
	return vOutput
}

;==================================================
JEE_StrRemoveDupsCIA(ByRef vText){
	oArray := {}
	Loop, Parse, vText, `n, `r
		if !oArray.HasKey("" A_LoopField)
			oArray["" A_LoopField] := 1
	vOutput := ""
	VarSetCapacity(vOutput, StrLen(vText)*2+2)
	for vKey in oArray
		vOutput .= vKey "`n"
	oArray := ""
	return SubStr(vOutput, 1, -1)
}

;==================================================

;list line frequency ('CID', case insensitive, date creation order)
JEE_StrRemoveDupsCID(ByRef vText){
	oArray := ComObjCreate("Scripting.Dictionary"), oArray2 := {}
	Loop, Parse, vText, `n, `r
		if !oArray2.HasKey("" A_LoopField)
			oArray.item("" A_LoopField) := "", oArray2["" A_LoopField] := ""
	vOutput := ""
	VarSetCapacity(vOutput, StrLen(vText)*2*2)
	for vKey in oArray
		vOutput .= vKey "`n"
	oArray := oArray2 := ""
	return SubStr(vOutput, 1, -1)
}

;==================================================

;list line frequency ('CID', case insensitive, date creation order)
;roughly equal speed alternative to JEE_StrRemoveDupsCID based on JEE_StrFreqCID
JEE_StrRemoveDupsCID2(ByRef vText){
	oArray := {}, oArray2 := {}
	StrReplace(vText, "`n", "", vCount)
	oArray.SetCapacity(vCount+1)
	oArray2.SetCapacity(vCount+1)
	Loop, Parse, vText, `n, `r
		if !oArray.HasKey("" A_LoopField)
			oArray["" A_LoopField] := "", oArray2.Push("" A_LoopField)
	vOutput := ""
	VarSetCapacity(vOutput, StrLen(vText)*2+2)
	for _, vValue in oArray2
		vOutput .= vValue "`n"
	oArray := oArray2 := ""
	return SubStr(vOutput, 1, -1)
}

;==================================================

JEE_StrRemoveDupsCSA(ByRef vText, vCSWithinCI=0){
	vOutput := vText
	Sort, vOutput, U CS
	;e.g. case sensitive: 'A,B,C,a,b,c'
	;e.g. 'CS within CI': 'A,a,B,b,C,c'
	if vCSWithinCI
		Sort, vOutput, F JEE_SortCasIns
	return vOutput
}

;==================================================

;list line frequency ('CSD', case sensitive, date creation order)
JEE_StrRemoveDupsCSD(ByRef vText){
	oArray := ComObjCreate("Scripting.Dictionary")
	Loop, Parse, vText, `n, `r
		if !oArray.Exists("" A_LoopField)
			oArray.item("" A_LoopField) := ""
	vOutput := ""
	VarSetCapacity(vOutput, StrLen(vText)*2+2)
	for vKey in oArray
		vOutput .= vKey "`n"
	oArray := ""
	return SubStr(vOutput, 1, -1)
}

;==================================================

;17:17 11/05/2017
;stage 1, list A:
;for each item, add key with value 1

;stage 2, list B:
;if item exists and has value 1, set value to 0
;if item exists and has value 0, do nothing
;if item doesn't exist, add key with value - 1

;stage 3:
;1/0/-1 = unique to A/present in both (in the list A's order)/unique to B

;==================================================

;list line frequency ('CIA', case insensitive, alphabetical order)
JEE_StrListCompareCIA(ByRef vText1, ByRef vText2, ByRef vOutputAB, ByRef vOutputA, ByRef vOutputB){
	oArray := {}
	StrReplace(vText1, "`n", "", vCount1)
	StrReplace(vText2, "`n", "", vCount2)
	vMax := StrLen(vNum1) > StrLen(vNum2) ? StrLen(vNum1) : StrLen(vNum2)
	oArray.SetCapacity(vCount1+vCount2+2)
	Loop, Parse, vText1, `n, `r
		if !oArray.HasKey("" A_LoopField)
			oArray["" A_LoopField] := 1
	Loop, Parse, vText2, `n, `r
		if !oArray.HasKey("" A_LoopField)
			oArray["" A_LoopField] := -1
		else if (oArray["" A_LoopField] = 1)
			oArray["" A_LoopField] := 0
	VarSetCapacity(vOutputAB, vMax*2)
	VarSetCapacity(vOutputA, vMax*2)
	VarSetCapacity(vOutputB, vMax*2)
	for vKey, vValue in oArray
		if (vValue = 0)
			vOutputAB .= vKey "`r`n"
		else if (vValue = 1)
			vOutputA .= vKey "`r`n"
		else
			vOutputB .= vKey "`r`n"
	oArray := ""
}

;==================================================

;list line frequency ('CID', case insensitive, date creation order)
JEE_StrListCompareCID(ByRef vText1, ByRef vText2, ByRef vOutputAB, ByRef vOutputA, ByRef vOutputB){
	oArray := ComObjCreate("Scripting.Dictionary"), oArray2 := {}
	Loop, Parse, vText1, `n, `r
		if !oArray2.HasKey("" A_LoopField)
			oArray.item("" A_LoopField) := 1, oArray2["" A_LoopField] := "" A_LoopField
	Loop, Parse, vText2, `n, `r
		if !oArray2.HasKey("" A_LoopField)
			oArray.item("" A_LoopField) := -1, oArray2["" A_LoopField] := "" A_LoopField
		else if (oArray.item("" oArray2["" A_LoopField]) = 1)
			oArray.item("" A_LoopField) := 0
	VarSetCapacity(vOutputAB, vMax*2)
	VarSetCapacity(vOutputA, vMax*2)
	VarSetCapacity(vOutputB, vMax*2)
	for _, vValue in oArray2
		if ((vValue2 := oArray.item("" vValue)) = 0)
			vOutputAB .= vValue "`r`n"
		else if (vValue2 = 1)
			vOutputA .= vValue "`r`n"
		else
			vOutputB .= vValue "`r`n"
	oArray := oArray2 := ""
}

;==================================================

;list line frequency ('CID', case insensitive, date creation order)
;slower alternative to JEE_StrListCompareCID
JEE_StrListCompareCID2(ByRef vText1, ByRef vText2, ByRef vOutputAB, ByRef vOutputA, ByRef vOutputB){
	oArray := {}, oArray2 := {}
	StrReplace(vText1, "`n", "", vCount1)
	StrReplace(vText2, "`n", "", vCount2)
	oArray.SetCapacity(vCount1+vCount2+2)
	oArray2.SetCapacity(vCount1+vCount2+2)
	Loop, Parse, vText1, `n, `r
		if !oArray.HasKey("" A_LoopField)
			oArray["" A_LoopField] := 1, oArray2.Push("" A_LoopField)
	Loop, Parse, vText2, `n, `r
		if !oArray.HasKey("" A_LoopField)
			oArray["" A_LoopField] := -1, oArray2.Push("" A_LoopField)
		else if (oArray["" A_LoopField] = 1)
			oArray["" A_LoopField] := 0
	vOutput := ""
	VarSetCapacity(vOutputAB, vMax*2)
	VarSetCapacity(vOutputA, vMax*2)
	VarSetCapacity(vOutputB, vMax*2)
	for _, vValue in oArray2
		if ((vValue2 := oArray["" vValue]) = 0)
			vOutputAB .= vValue "`r`n"
		else if (vValue2 = 1)
			vOutputA .= vValue "`r`n"
		else
			vOutputB .= vValue "`r`n"
	oArray := oArray2 := ""
}

;==================================================

;list line frequency ('CSA', case sensitive, alphabetical order)
JEE_StrListCompareCSA(ByRef vText1, ByRef vText2, ByRef vOutputAB, ByRef vOutputA, ByRef vOutputB, vCSWithinCI=0){
	oArray := ComObjCreate("Scripting.Dictionary")
	vText1X := StrReplace(vText1, "`r`n", "`n")
	vText1X := StrReplace(vText2, "`r`n", "`n")
	Sort, vText1X, CS
	Sort, vText2X, CS
	;e.g. case sensitive: 'A,B,C,a,b,c'
	;e.g. 'CS within CI': 'A,a,B,b,C,c'
	if vCSWithinCI
	{
		Sort, vText1X, F JEE_SortCasIns
		Sort, vText2X, F JEE_SortCasIns
	}
	Loop, Parse, vText1X, `n, `r
		if !oArray.Exists("" A_LoopField)
			oArray.item("" A_LoopField) := 1
	Loop, Parse, vText2X, `n, `r
		if !oArray.Exists("" A_LoopField)
			oArray.item("" A_LoopField) := -1
		else if (oArray.item("" A_LoopField) = 1)
			oArray.item("" A_LoopField) := 0
	VarSetCapacity(vOutputAB, vMax*2)
	VarSetCapacity(vOutputA, vMax*2)
	VarSetCapacity(vOutputB, vMax*2)
	for vKey in oArray
		if ((vValue := oArray.item(vKey)) = 0)
			vOutputAB .= vKey "`r`n"
		else if (vValue = 1)
			vOutputA .= vKey "`r`n"
		else
			vOutputB .= vKey "`r`n"
	oArray := ""
}

;==================================================

;list line frequency ('CSD', case sensitive, date creation order)
JEE_StrListCompareCSD(ByRef vText1, ByRef vText2, ByRef vOutputAB, ByRef vOutputA, ByRef vOutputB){
	oArray := ComObjCreate("Scripting.Dictionary")
	Loop, Parse, vText1, `n, `r
		if !oArray.Exists("" A_LoopField)
			oArray.item("" A_LoopField) := 1
	Loop, Parse, vText2, `n, `r
		if !oArray.Exists("" A_LoopField)
			oArray.item("" A_LoopField) := -1
		else if (oArray.item("" A_LoopField) = 1)
			oArray.item("" A_LoopField) := 0
	VarSetCapacity(vOutputAB, vMax*2)
	VarSetCapacity(vOutputA, vMax*2)
	VarSetCapacity(vOutputB, vMax*2)
	for vKey in oArray
		if ((vValue := oArray.item(vKey)) = 0)
			vOutputAB .= vKey "`r`n"
		else if (vValue = 1)
			vOutputA .= vKey "`r`n"
		else
			vOutputB .= vKey "`r`n"
	oArray := ""
}

;==================================================

JEE_SortCasIns(vTextA, vTextB, vOffset) { ;for use with AHK's Sort command

	vSCS := A_StringCaseSense
	StringCaseSense, Off
	vRet := ("" vTextA) > ("" vTextB) ? 1 : ("" vTextA) < ("" vTextB) ? -1 : -vOffset
	StringCaseSense, % vSCS
	return vRet
}

;==================================================

JEE_StrIndentCode(vText){
vOutput := ""
VarSetCapacity(vOutput, StrLen(vText)*2)
vText := StrReplace(vText, "`r`n", "`n")
vCount := 0 ;number of tabs to prepend to line
vAdjNow := 0 ;'adjust now': alter number of tabs for this line
vAdjMode := 0 ;'adjust mode': alter number of tabs for future lines
;vList := "if ,else,Loop,IfWin,for "
vList := "Catch,Else,Finally,For ,If,Loop,Try,While"
vList := StrReplace(vList, ",", "|")

Loop, Parse, vText, `n
{
	vAdjNow := vAdjMode
	vTemp := LTrim(A_LoopField)

	if (vTemp = "")
	{
		vOutput .= "`r`n"
		continue
	}

	vType := 0
	if !vType && (SubStr(vTemp, 1, 1) = "{")
		vType := 2
	if !vType && (SubStr(vTemp, 1, 1) = "}")
		vType := 3
	;if !vType && JEE_StrStarts(vTemp, vList, "|")
	if !vType && RegExMatch(vTemp, "i)^(" vList ")")
		vType := 1

	;CRITERIA - line is 'if/else...'
	if (vType = 1)
		vCount := vCount+1, vAdjNow := -1, vAdjMode := 1

	;CRITERIA - line is '{'
	if (vType = 2)
		vAdjNow := -1
	if (vType = 2) && vAdjMode
		vAdjMode := 0

	;CRITERIA - line is '}'
	if (vType = 3)
		vCount := vCount-1

	;CRITERIA - line is not '{' or '}' or 'if/else...'
	if (vType = 0) && vAdjMode
		vCount := vCount-1, vAdjMode := 0, vAdjNow := 1

	;vOutput .= JEE_StrRept("`t", vCount+vAdjNow) vTemp "`r`n"
	Loop, % vCount+vAdjNow
		vOutput .= "`t"
	vOutput .= vTemp "`r`n"
}

vOutput := SubStr(vOutput, 1, -2)
Return vOutput
}
;==================================================

;==================================================

;if vNum is negative, the nth-to-last line positions are retrieved
;vRange1 and vRange2 allow you get the nth line with minimum/maximum length
;assumes CRLF line breaks
;e.g. 'aaabbbccc', for aaa the caret positions before/after it are (0,3)
;e.g. 'aaabbbccc', for bbb the caret positions before/after it are (3,6)
JEE_StrGetLinePos(ByRef vText, vNum, ByRef vPos1, ByRef vPos2, vRange1=0, vRange2=""){
	vPos1 := vPos2 := 0
	if !RegExMatch(vNum, "^(-|)\d+$") || (vNum = 0)
		return 0
	vLen := StrLen(vText)
	vIsAhkV1 := !!SubStr(1,0)

	;get nth/nth-to-last line of any length
	if (vRange1=0) && (vRange2="")
	{
		if (vNum = 1)
		{
			vPos1 := 1, vPos2 := InStr(vText, "`n")-2
			if (vPos2 = -2)
				vPos2 := vLen
			vPos1-- ;it should be one below the matching char
			return 1
		}
		if (vNum > 1)
		{
			if !(vPos1 := InStr(vText, "`n", 0, 1, vNum-1))
				return 0
			vPos1 := vPos1+1, vPos2 := InStr(vText, "`n", 0, vPos1)-2
			if (vPos2 = -2)
				vPos2 := vLen
			vPos1-- ;it should be one below the matching char
			return 1
		}
		if (vNum = -1)
		{
			vPos2 := vLen, vPos1 := InStr(vText, "`n", 0, vIsAhkV1-1)+1
			vPos1-- ;it should be one below the matching char
			return 1
		}
		if (vNum < 0)
		{
			if !(vPos2 := InStr(vText, "`n", 0, vIsAhkV1-1, -vNum-1))
				return 0
			vPos2 -= 2, vPos1 := InStr(vText, "`n", 0, vIsAhkV1-vLen+vPos2-1)+1
			{
				vPos1-- ;it should be one below the matching char
				return 1
			}
		}
	}

	;==============================

	;get nth line of specified length
	if (vNum > 0)
	{
		vCount := 0, vPos1 := 1
		Loop
		{
			vPos2 := InStr(vText, "`n", 0, vPos1)-2
			if (vPos2 = -2)
				vPos2 := vLen, vDoEnd := 1
			vDiff := vPos2-vPos1+1
			if (vDiff >= vRange1) && ((vRange2 = "") || (vDiff <= vRange2))
				vCount++
			if (vCount = vNum)
			{
				vPos1-- ;it should be one below the matching char
				return 1
			}
			if vDoEnd
			{
				vPos1 := vPos2 := 0
				return 0
			}
			vPos1 := vPos2+3
		}
	}

	;==============================

	;get nth-to-last line of specified length
	if (vNum < 0)
	{
		vCount := 0, vPos2 := vLen
		Loop
		{
			vPos1 := InStr(vText, "`n", 0, vIsAhkV1-vLen+vPos2-1)+1
			if (vPos1 = 1)
				vDoEnd := 1
			vDiff := vPos2-vPos1+1
			if (vDiff >= vRange1) && ((vRange2 = "") || (vDiff <= vRange2))
				vCount++
			if (vCount = -vNum)
			{
				vPos1-- ;it should be one below the matching char
				return 1
			}
			if vDoEnd
			{
				vPos1 := vPos2 := 0
				return 0
			}
			vPos2 := vPos1-3
		}
	}

	;==============================

	return 0
}

;==================================================
;simpler slower(?) version of the same function
JEE_StrGetLinePos2(vText, vNum, ByRef vPos1, ByRef vPos2, vRange1=0, vRange2=""){
	if (vNum = 0)
	{
		vPos1 := vPos2 := 0
		return
	}

	vText := StrReplace(vText, "`r`n", "`n")
	oArray := StrSplit(vText, "`n")
	vMax := oArray.MaxIndex()

	vDiff := (vNum>0) ? 1 : -1
	vIndex := (vNum>0) ? 1 : vMax
	vCount := 0
	vNum2 := Abs(vNum)
	vRet := 0

	Loop, % vMax
	{
		vTemp := oArray[vIndex]
		vLen := StrLen(vTemp)
		if (vLen >= vRange1) && ((vRange2 = "") || (vLen <= vRange2))
			vCount++
		if (vCount = vNum2)
		{
			vRet := 1
			break
		}
		vIndex += vDiff
	}

	vChars := 0
	vPos1 := vPos2 := 0
	Loop, % vMax
	{
		vTemp := oArray[A_Index]
		vChars1 := vChars
		vLen := StrLen(vTemp)
		vChars += vLen
		vChars2 := vChars
		if (A_Index = vIndex)
		{
			vPos1 := vChars1, vPos2 := vChars2
			break
		}
		vChars += 2
	}

	return vRet
}

/*

q:: ;sort paths by both orders
;vText := "A,A\A,A\B,A\C,B,B\A,B\B,B\C,C,C\A,C\B,C\C"
vText := "A,A\A,A\B,B,B\A,B\B,A\A\A,A\A\B,A\B\A,A\B\B,B\A\A,B\A\B,B\B\A,B\B\B"
vText := StrReplace(vText, ",", "`n")
Sort, vText, Random
Sort, vText, F JEE_SortPathFindNextFile
MsgBox, % vText
Sort, vText, F JEE_SortPathRegEdit
MsgBox, % vText
return

;==================================================

;q:: ;regedit - backup registry (you may get a User Account Control prompt for each root key)
vList := "HKEY_CLASSES_ROOT,HKEY_CURRENT_USER,HKEY_LOCAL_MACHINE,HKEY_USERS,HKEY_CURRENT_CONFIG"

;e.g. sizes (MB):
;69	HKEY_CLASSES_ROOT
;47	HKEY_CURRENT_USER
;309	HKEY_LOCAL_MACHINE
;99	HKEY_USERS
;0	HKEY_CURRENT_CONFIG

vDir = %A_Desktop%
vNow := A_Now
Loop, Parse, vList, `,
{
	vRegKey := A_LoopField
	vTarget = %ComSpec% /c regedit /e "%vDir%\%vRegKey% %vNow%.hiv" %vRegKey%,, HIDE
	;MsgBox, % vTarget
	RunWait, %ComSpec% /c regedit /e "%vDir%\%vRegKey% %vNow%.hiv" %vRegKey%,, HIDE
}
MsgBox, % "done"
return

;==================================================

;q:: ;sort registry keys
vPathNeedle = %A_Desktop%\HKEY_CURRENT_CONFIG *.hiv
vPathNeedle = %A_Desktop%\HKEY_CURRENT_USER *.hiv
vPathNeedle = %A_Desktop%\HKEY_CLASSES_ROOT *.hiv
vPathNeedle = %A_Desktop%\HKEY_USERS *.hiv
vPathNeedle = %A_Desktop%\HKEY_LOCAL_MACHINE *.hiv
Loop, Files, % vPathNeedle, F
	vPath := A_LoopFileFullPath
if !FileExist(vPath)
{
	MsgBox, % "error: file not found:`r`n" vPathNeedle
	return
}
else
	MsgBox, % vPath

FileRead, vText, % vPath
vOutput := ""
VarSetCapacity(vOutput, 1000000*2)
vIsV1 := !!SubStr(1,0)
Loop, Parse, vText, `n, `r
{
	vTemp := A_LoopField
	if !(SubStr(vTemp, 1, 1) = "[") || !(SubStr(vTemp, vIsV1-1) = "]")
		continue
	vOutput .= SubStr(vTemp, 2, -1) "`n"
}

vOutput := SubStr(vOutput, 1, -1)
;MsgBox, % vOutput
vOutput2 := vOutput
Sort, vOutput2, Random
Sort, vOutput2, F JEE_SortPathRegEdit
;JEE_WinMergeCompareStrings("1`n" vOutput, "2`n" vOutput2)

MsgBox, % StrLen(vOutput)
MsgBox, % (vOutput = vOutput2)
return

;==================================================

;q:: ;sort paths
vDir1 = C:\Program Files
;vDir1 = %A_Desktop%
vOutput := ""
VarSetCapacity(vOutput, 1000000*2)
Loop, Files, % vDir1 "\*", FDR
	vOutput .= A_LoopFileFullPath "`n"
vOutput := SubStr(vOutput, 1, -1)
vOutput2 := vOutput
Sort, vOutput2, Random
Sort, vOutput2, F JEE_SortPathFindNextFile
;JEE_WinMergeCompareStrings(vOutput, vOutput2)

MsgBox, % StrLen(vOutput)
MsgBox, % (vOutput = vOutput2)
return

*/
;==================================================
JEE_SortPathFindNextFile(vTextA, vTextB, vOffset) {;for use with AHK's Sort command

	StringUpper, vTextA, vTextA
	StringUpper, vTextB, vTextB
	if ("" vTextA = "" vTextB)
		return -vOffset

	oTempA := StrSplit(vTextA, "\")
	oTempB := StrSplit(vTextB, "\")
	vMin := oTempA.Length() < oTempB.Length() ? oTempA.Length() : oTempB.Length()

	Loop, % vMin
		if !(oTempA[A_Index] = oTempB[A_Index])
		{
			vTextA := oTempA[A_Index], vTextB := oTempB[A_Index], vIndex := A_Index
			break
		}

	if (vIndex = vMin) && !(oTempA.Length() = oTempB.Length())
		if (oTempA.Length() = vMin)
			return -1
		else if (oTempB.Length() = vMin)
			return 1

	vSCS := A_StringCaseSense
	StringCaseSense, On
	vRet := ("" vTextA) > ("" vTextB) ? 1 : ("" vTextA) < ("" vTextB) ? -1 : -vOffset
	StringCaseSense, % vSCS
	return vRet
}

JEE_SortPathRegEdit(vTextA, vTextB, vOffset) {;for use with AHK's Sort command

	StringUpper, vTextA, vTextA
	StringUpper, vTextB, vTextB
	if ("" vTextA = "" vTextB)
		return -vOffset

	oTempA := StrSplit(vTextA, "\")
	oTempB := StrSplit(vTextB, "\")
	vMin := oTempA.Length() < oTempB.Length() ? oTempA.Length() : oTempB.Length()

	Loop, % vMin
		if !(oTempA[A_Index] = oTempB[A_Index])
		{
			vTextA := oTempA[A_Index], vTextB := oTempB[A_Index], vIndex := A_Index
			break
		}

	if (vIndex = vMin) && (vTextA = vTextB)
		if (oTempA.Length() = vMin)
			return -1
		else if (oTempB.Length() = vMin)
			return 1

	vSCS := A_StringCaseSense
	StringCaseSense, On
	vRet := ("" vTextA) > ("" vTextB) ? 1 : ("" vTextA) < ("" vTextB) ? -1 : -vOffset
	StringCaseSense, % vSCS
	return vRet
}
;==================================================

JEE_StrHtmlToText(vHtml){
oHTML := ComObjCreate("HTMLFile")
oHTML.write("<title>" vHtml "</title>")
vText := oHTML.getElementsByTagName("title")[0].innerText
oHTML := ""
Return vText
}

JEE_StrTextToHtml(vText){
oHTML := ComObjCreate("HTMLFile")
oHTML.write("<title></title>")
oHTML.getElementsByTagName("title")[0].value := vText
vHtml := oHTML.getElementsByTagName("title")[0].outerHTML
oHTML := ""
Return SubStr(vHtml, 15, -10)
}








