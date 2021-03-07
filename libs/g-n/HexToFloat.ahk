; Title:   	Convert between float/double and its hex representation - Scripts and Functions
; Link:   	autohotkey.com/board/topic/16846-convert-between-floatdouble-and-its-hex-representation/
; Author:	Lazlo
; Date:
; for:     	AHK_L

/*   ;;;;; TEST CASES ;;;;;

   MsgBox % HexToFloat(0)          ; 0
   MsgBox % HexToFloat(0x3F800000) ; 1
   MsgBox % HexToFloat(0x46EA6000) ; 30000.0
   MsgBox % HexToFloat(0xC2ED4000) ;-118.625
   MsgBox % HexToFloat(0x3C4A4533) ; 0.0123456

   MsgBox % HexToDouble( 0x0 )               ; 0
   MsgBox % HexToDouble( 0x3FF0000000000000) ; 1
   MsgBox % HexToDouble( 0x40DD4C0000000000) ; 30000.0
   MsgBox % HexToDouble(-0x3FA2580000000000) ;-118.625
   MsgBox % HexToDouble( 0x3F8948A661FEF899) ; 0.0123456

   MsgBox % FloatToHex( 0)         ; 0x0
   MsgBox % FloatToHex( 1)         ; 0x3F800000
   MsgBox % FloatToHex( 30000.0)   ; 0x46EA6000
   MsgBox % FloatToHex(-118.625)   ; 0xC2ED4000
   MsgBox % FloatToHex( 0.0123456) ; 0x3C4A4533

   MsgBox % DoubleToHex(0)         ; 0x0
   MsgBox % DoubleToHex(1)         ; 0x3FF0000000000000
   MsgBox % DoubleToHex(30000.0)   ; 0x40DD4C0000000000
   MsgBox % DoubleToHex(-118.625)  ;-0x3FA2580000000000
   MsgBox % DoubleToHex(0.0123456) ; 0x3F8948A661FEF899

*/

HexToFloat(x) {
   Return (1-2*(x>>31)) * (2**((x>>23 & 255)-150)) * (0x800000 | x & 0x7FFFFF)
}

HexToDouble(x) { ; may be wrong at extreme values
   Return (2*(x>0)-1) * (2**((x>>52 & 0x7FF)-1075)) * (0x10000000000000 | x & 0xFFFFFFFFFFFFF)
}

FloatToHex(f) {
   form := A_FormatInteger
   SetFormat Integer, HEX
   v := DllCall("MulDiv", Float,f, Int,1, Int,1, UInt)
   SetFormat Integer, %form%
   Return v
}

DoubleToHex(d) {
   form := A_FormatInteger
   SetFormat Integer, HEX
   v := DllCall("ntdll.dll\RtlLargeIntegerShiftLeft",Double,d, UChar,0, Int64)
   SetFormat Integer, %form%
   Return v
}
