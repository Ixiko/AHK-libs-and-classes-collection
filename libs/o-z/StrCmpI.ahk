; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=23&t=61602&p=297807#p297807
; Author: 	jeeswg
; Date:
; for:     	AHK_L

/*

	;q:: ;compare strings case insensitive (and get 1-based char index where differ)
	vText1 := StrReplace(Format("{:20100100}", ""), " ", "a")
	vText2 := vText1
	vText1 .= "A"
	vText2 .= "b"
	;vText2 .= "a"

	;vText1 := "abc", vText2 := "abd"
	;vText1 := "abc", vText2 := "abcd"
	;vText1 := "abc", vText2 := "abC"
	;JEE_Swap(vText1, vText2)

	vTickCount1 := A_TickCount
	vRet := StrCmpI(vText1, vText2,, vOffsetDiff)
	vTickCount2 := A_TickCount
	MsgBox, % Clipboard := (vTickCount2 - vTickCount1) "`r`n" vRet " " vOffsetDiff
	return

	;e.g. results:
	;47
	;47
	;31

*/


;==================================================

;principles:
;use _wcsnicmp/_strnicmp to compare blocks of characters, find the first difference
;use memmove to copy blocks
;use CharLowerBuff to make them lower case
;use RtlCompareMemory to compare characters, find the first difference (its char index)

;note: vOffsetParam is for use with comparator functions for AHK's Sort command
;note: vText1/vText2 are ByRef for better performance (to avoid copying massive strings)
StrCmpI(ByRef vText1, ByRef vText2, vOffsetParam:=0, ByRef vOffsetOut:=0){
	local
	static vChrSize := A_IsUnicode ? 2 : 1
	static vFunc := A_IsUnicode ? "msvcrt\_wcsnicmp" : "msvcrt\_strnicmp"
	static vBlockLen := 1000000
	vLen1 := StrLen(vText1)
	vLen2 := StrLen(vText2)
	if !(vLen := Min(vLen1, vLen2))
		return -vOffsetParam ;return 0/-vOffsetParam if both empty strings
	vRem := Mod(vLen, vBlockLen)
	vOffset := vOffsetOut := vRet := 0
	Loop % Floor(vLen/vBlockLen)
	{
		if vRet := DllCall(vFunc, "Ptr",&vText1+vOffset*vChrSize, "Ptr",&vText2+vOffset*vChrSize, "Ptr",vBlockLen, "Cdecl")
			break
		vOffset += vBlockLen
	}
	if !vRet && (vBlockLen := vRem)
		vRet := DllCall(vFunc, "Ptr",&vText1+vOffset*vChrSize, "Ptr",&vText2+vOffset*vChrSize, "Ptr",vRem, "Cdecl")
	if !vRet
	{
		if (vLen1 = vLen2)
			return -vOffsetParam ;return 0/-vOffsetParam if equal
		vOffsetOut := vLen + 1
		return (vLen1 > vLen2) ? 1 : -1
	}
	VarSetCapacity(vTemp1, vBlockLen*vChrSize)
	VarSetCapacity(vTemp2, vBlockLen*vChrSize)
	DllCall("msvcrt\memmove", "Ptr",&vTemp1, "Ptr",&vText1+vOffset*vChrSize, "UPtr",vBlockLen*vChrSize, "Cdecl Ptr")
	DllCall("msvcrt\memmove", "Ptr",&vTemp2, "Ptr",&vText2+vOffset*vChrSize, "UPtr",vBlockLen*vChrSize, "Cdecl Ptr")
	DllCall("user32\CharLowerBuff", "Ptr",&vTemp1, "UInt",vBlockLen, "UInt")
	DllCall("user32\CharLowerBuff", "Ptr",&vTemp2, "UInt",vBlockLen, "UInt")
	vOffset2 := DllCall("ntdll\RtlCompareMemory", "Ptr",&vTemp1, "Ptr",&vTemp2, "UPtr",vBlockLen*vChrSize, "UPtr")
	;note: use Floor, since, for a Unicode string, the first byte that differs could be at an odd offset:
	vOffsetOut := vOffset + Floor(vOffset2/vChrSize) + 1
	return (vRet > 0) ? 1 : -1
}

;==================================================