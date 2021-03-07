; Title:   	Double-float to HEX DllCall failing on AHK 64bit Unicode
; Link:   	autohotkey.com/boards/viewtopic.php?f=76&t=78713
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

Double2HexLE(d) {
	form := A_FormatInteger, oArray := []
	SetFormat Integer, HEX
	vNum := DllCall("ntdll.dll\RtlLargeIntegerShiftLeft", double, d, UChar, 0, Int64)
	SetFormat Integer, %form%
	VarSetCapacity(vData, 18)
	NumPut(vNum, &vData, 0, "Int64")
	Loop % 18
		oArray.Push(NumGet(&vData, A_Index-1, "UChar"))
	leNum := Format("{:02X}{:02X}{:02X}{:02X}{:02X}{:02X}{:02X}{:02X}", oArray*)
	return leNum
}