
; If the AHK.exe is 64 bit, then function will call GetWindowLongPtr
; otherwise  it calls GetWindowLong

getProcessBaseAddress(WindowTitle, MatchMode=3)	;WindowTitle can be anything ahk_exe ahk_class etc
{
	mode :=  A_TitleMatchMode
	SetTitleMatchMode, %MatchMode%	;mode 3 is an exact match
	WinGet, hWnd, ID, %WindowTitle%
	; AHK32Bit A_PtrSize = 4 | AHK64Bit - 8 bytes
	BaseAddress := DllCall(A_PtrSize = 4
		? "GetWindowLong" 
		: "GetWindowLongPtr", "Uint", hWnd, "Uint", -6) 
	SetTitleMatchMode, %mode%	; In case executed in autoexec

	return BaseAddress
}
