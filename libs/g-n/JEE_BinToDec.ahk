; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=74&t=63650&p=272709&hilit=Negative+exponent#p272709
; Author:	jeeswg
; Date:
; for:     	AHK_L

/*


*/

;==================================================

;JEE_Bin2Dec
JEE_BinToDec(vBin){
	local
	vIndex := StrLen(vBin)
	vOutput := 0
	Loop, Parse, vBin
	{
		vIndex--
		if (A_LoopField = "0")
			continue
		else if (A_LoopField = "1")
			vOutput += 2 ** vIndex
		else
			return
	}
	return vOutput
}

;==================================================

;where vLen is the minimum length of the number to return (i.e. pad it with zeros if necessary)
;JEE_Dec2Bin
JEE_DecToBin(vNum, vLen:=1){
	local
	;convert '0x' form to dec
	if !RegExMatch(vNum, "^\d+$")
		vNum += 0
	if !RegExMatch(vNum, "^\d+$")
		return
	vBin := ""
	while vNum
		vBin := (vNum & 1) vBin, vNum >>= 1
	return Format("{:0" vLen "}", vBin)

	;if (StrLen(vBin) < vLen)
	;	Loop, % vLen - StrLen(vBin)
	;		vBin := "0" vBin
	;return vBin
}

;==================================================

;e.g. MsgBox, % JEE_FloatToBin(-123.456) ;1 10000101 11101101110100101111001
JEE_FloatToBin(vNum){
	local
	VarSetCapacity(vData, 4)
	NumPut(vNum, &vData, 0, "Float")
	vBin := ""
	Loop, 4
		vBin .= JEE_DecToBin(NumGet(&vData, 4-A_Index, "UChar"), 8)
	return RegExReplace(vBin, "^(.)(.{8})", "$1 $2 ")
}

;==================================================

;e.g. MsgBox, % JEE_DoubleToBin(-123.456) ;1 10000000101 1110110111010010111100011010100111111011111001110111
JEE_DoubleToBin(vNum){
	local
	VarSetCapacity(vData, 8)
	NumPut(vNum, &vData, 0, "Double")
	vBin := ""
	Loop, 8
		vBin .= JEE_DecToBin(NumGet(&vData, 8-A_Index, "UChar"), 8)
	return RegExReplace(vBin, "^(.)(.{11})", "$1 $2 ")
}

;==================================================

;e.g. MsgBox, % JEE_BinToFloat("1 10000101 11101101110100101111001") ;-123.456001
JEE_BinToFloat(vBin){
	local
	vBin := StrReplace(vBin, " ")
	VarSetCapacity(vData, 4)
	Loop, 4
	{
		vNum := JEE_BinToDec(SubStr(vBin, A_Index*8-7, 8))
		, NumPut(vNum, &vData, 4-A_Index, "UChar")
	}
	return NumGet(&vData, 0, "Float")
}

;==================================================

;e.g. MsgBox, % JEE_BinToDouble("1 10000000101 1110110111010010111100011010100111111011111001110111") ;-123.456000
JEE_BinToDouble(vBin){
	local
	vBin := StrReplace(vBin, " ")
	VarSetCapacity(vData, 8)
	Loop, 8
		vNum := JEE_BinToDec(SubStr(vBin, A_Index*8-7, 8))
		, NumPut(vNum, &vData, 8-A_Index, "UChar")
	return NumGet(&vData, 0, "Double")
}

;==================================================