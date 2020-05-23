#include classMemory.ahk


vlc := new _ClassMemory("ahk_exe vlc.exe", "", hProcessCopy)

stringAdress := vlc.processPatternScan( ,, 0x30, 0x30, 0x3a, 0x30, 0x34)

SetFormat, IntegerFast, hex
stringAdress += 0  ; Sets Var (which previously contained 11) to be 0xb.
stringAdress .= ""  ; Necessary due to the "fast" mode.
SetFormat, IntegerFast, d

MsgBox, % stringAdress



pattern := hexStrToAOBPattern("30303a3034")

SetFormat, IntegerFast, hex
pattern += 0  ; Sets Var (which previously contained 11) to be 0xb.
pattern .= ""  ; Necessary due to the "fast" mode.
SetFormat, IntegerFast, d

MsgBox, % pattern


; hexString is a string of hex bytes (2-digits) without the '0x' hex prefix.
; eg.
; DEADBEEF
; A byte can be denoted wild by using two question marks (or any other character that isn't a hex number)
; DEAD??EF - the third byte  is wild
hexStrToAOBPattern(hexString)
{
	AOBPattern := []
	length := StrLen(hexString)
	if !length || Mod(length, 2)
		return -1 ; no str or string is not an even number of characters - 2 characters per byte
	loop, % length/2
	{
		value := "0x" SubStr(hexString, 1 + 2 * (A_index-1), 2)
		if (value + 0 = "")
			value := "?"
		AOBPattern.Insert(value)
	}
	return AOBPattern
}






; AOB is object!
AOB := stringToAOBPattern("00:04", "UTF-8") 
stringAdress2 := vlc.processPatternScan( ,, AOB*)
stringToAOBPattern(string, encoding := "UTF-8", insertNullTerminator := False)
{
	AOBPattern := []
	encodingSize := (encoding = "utf-16" || encoding = "cp1200") ? 2 : 1
	requiredSize := StrPut(string, encoding) * encodingSize - (insertNullTerminator ? 0 : encodingSize)
	VarSetCapacity(buffer, requiredSize)
	StrPut(string, &buffer, StrLen(string) + (insertNullTerminator ?  1 : 0), encoding)	
	loop, % requiredSize
		AOBPattern.Insert(NumGet(buffer, A_Index-1, "UChar"))
	return AOBPattern
}




SetFormat, IntegerFast, hex
stringAdress2 += 0  ; Sets Var (which previously contained 11) to be 0xb.
stringAdress2 .= ""  ; Necessary due to the "fast" mode.
SetFormat, IntegerFast, d

MsgBox, % stringAdress2