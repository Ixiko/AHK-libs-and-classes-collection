; Title:   	
; Link:     	
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

RtlUlongByteSwap64(num){
	; Url: https://autohotkey.com/boards/viewtopic.php?p=181437&sid=ed1119d85377e323927b569b0281d9cd#p181437
	;	- https://msdn.microsoft.com/en-us/library/windows/hardware/ff562886(v=vs.85).aspx (RtlUlongByteSwap routine)
	;	- https://msdn.microsoft.com/en-us/library/e8cxb8tk.aspx (_swab function)
	; For example, if the Source parameter value is 0x12345678, the routine returns 0x78563412.
	; works on both 32 and 64 bit.
	; v1 version
	static dest, src
	static i := varsetcapacity(dest,4) + varsetcapacity(src,4)
	numput(num,src,"uint")
	,DllCall("MSVCRT.dll\_swab", "ptr", &src, "ptr", &dest+2, "int", 2, "cdecl")
	,DllCall("MSVCRT.dll\_swab", "ptr", &src+2, "ptr", &dest, "int", 2, "cdecl")
	return numget(dest,"uint")
}