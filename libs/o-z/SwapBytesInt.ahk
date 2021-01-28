;MsgBox, % vBGR := Format("{:06X}", JEE_SwapBytesInt("0x" (vRGB:="AABBCC"), 1432)) ;CCBBAA
;MsgBox, % vBGR := Format("0x{:06X}", JEE_SwapBytesInt(vRGB:=0xAABBCC, 1432)) ;0xCCBBAA
;MsgBox, % vBGR := Format("0x{:06X}", JEE_SwapBytesInt(vRGB:=0xAABBCCDD, 1432)) ;0xAADDCCBB
;MsgBox, % vBGRA := Format("0x{:08X}", JEE_SwapBytesInt(vARGB:=0xAABBCCDD, 4321)) ;0xDDCCBBAA
;MsgBox, % Format("0x{:08X}", JEE_SwapBytesInt(0xAABBCCDDEE, 43)) ;0xEEDD
;MsgBox, % Format("0x{:08X}", JEE_SwapBytesInt(0xDDEE, 43)) ;0xEEDD
;MsgBox, % Format("0x{:08X}", JEE_SwapBytesInt(0xAABBCCDD, 1004)) ;0xAA0000DD
;MsgBox, % Format("0x{:08X}", JEE_SwapBytesInt(0xAABBCCDD, 1122)) ;0xAAAABBBB
;MsgBox, % Format("0x{:08X}", JEE_SwapBytesInt(0xAABBCCDD, 1212)) ;0xAABBAABB
;vOrder should be a number of between 0 and 4 characters
;vOrder should contain any of the digits 0/1/2/3/4, any number of times
;note: a vOrder of 43 is equivalent to a vOrder of "0043"
JEE_SwapBytesInt(vNum, vOrder)
{
	if (StrLen(vOrder) > 4)
		return
	Loop % (StrLen(vOrder) - 4)
		vNum := "0" vNum
	vNum2 := 0
	Loop Parse, vOrder
	{
		if (A_LoopField = 0)
			vNum2 <<= 8
		else
			vNum2 <<= 8, vNum2 |= 0xFF & (vNum >> 8*(4-A_LoopField))
	}
	return vNum2
}