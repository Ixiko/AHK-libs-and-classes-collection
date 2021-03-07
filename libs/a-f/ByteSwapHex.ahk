; Title:   	Double-float to HEX DllCall failing on AHK 64bit Unicode
; Link:   	autohotkey.com/boards/viewtopic.php?f=76&t=78713
; Author:
; Date:
; for:     	AHK_L
; Rem:		including more functions. I'm not sure some functions working.

/*

	MsgBox, % ByteSwapHex(0xAABBCC00, "UInt")
	MsgBox, % ByteSwapHex(0x8899AABBCCDDEEFF, "UInt64")
	MsgBox, % ByteSwapHex(30000.0, "Double")
	MsgBox, % ByteSwapHex(-118.625, "Float")
	MsgBox, % ByteSwapHex(0xAA00, "UShort")

*/

ByteSwapHexD(Num, byteLen) {
   ; Valid values for byteLen are 2 thru 8
   VarSetCapacity(LE, 8, 0)
   NumPut(Num, LE, "UInt64")
   Loop % byteLen
      Hex .= Format("{:02X}", *(&LE + A_Index - 1))
   Return Hex
}

ByteSwapHex(num, type) { ; type: "Double", "UInt64", "Float", "UInt", "UShort"
   fn  := type = "Double" ? "uint64" : (type = "Float" || type = "UInt") ? "ulong" : Format("{:L}", type)
   ret := type = "Double" ? "uint64" :  type = "Float" ? "UInt" : type
   padding := (type = "Double" || type = "UInt64") ? 16 : type = "UShort" ? 4 : 8
   Return Format("{:0" . padding . "X}", DllCall("msvcr100\_byteswap_" . fn, type, num, ret))
}

fpToHexLE(float) {
   Return Format("{:08X}", DllCall("msvcr100\_byteswap_ulong", "float", float, "UInt"))
}

Num2HexLE(Num, Length := 4) {
	; Valid values for Length are 1 thru 8
	static H := {0: 0, 1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9, 10: "A", 11: "B", 12: "C", 13: "D", 14: "E", 15: "F"}
	VarSetCapacity(LE, 8, 0)
	NumPut(Num, LE, 0, "UInt64")
	Loop, %Length%
		Hex .= H[(X := NumGet(LE, A_Index - 1, "UChar")) >> 4] . H[X & 0xF]
	Return Hex
}
