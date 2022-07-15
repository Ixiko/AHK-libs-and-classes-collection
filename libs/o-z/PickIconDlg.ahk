; © Drugwash 2017.06.18 v1.1
; based on majkinetor's 'Dlg' (formerly CmnDlg) set of functions
; I can't believe the stupid M$ still require the SHORT path as parameter
; in order to correctly navigate to input path on the 'browse' command!

PickIconDlg(ByRef fPath, ByRef idx, hGui=0)
{
Global Ptr, PtrP, AW
IfNotExist, %fPath%
	fPath := A_ScriptDir "\"
Loop, %fPath%
	fPath := A_LoopFileShortPath
if (!A_IsUnicode && A_OSType="WIN32_NT")	; AHK ANSI, Windows NT
	{
	VarSetCapacity(fPathW, sz := 261*2, 0)	; MAX_PATH Unicode style
	DllCall("MultiByteToWideChar", "UInt", 0, "UInt", 0, "Str", fPath, "UInt", -1, Ptr, &fPathW, "UInt", sz)
	if !r := DllCall(DllCall("GetProcAddress", Ptr, DllCall("GetModuleHandleA", "Str", "shell32"), "UInt", 62)
			, Ptr, hGui
			, Ptr, &fPathW
			, "UInt", sz
			, PtrP, --idx)
		return
	VarSetCapacity(fPath, sz := DllCall("lstrlenW", Ptr, &fPathW), 0)
	return DllCall("WideCharToMultiByte", "UInt", 0, "UInt", 0, Ptr, &fPathW, "UInt", -1, "Str", fPath, "Int", sz, "UInt", 0, "UInt", 0)
	}
else if !A_IsUnicode							; AHK ANSI, Windows 9x 
	{
	VarSetCapacity(fPathW, sz := 261, 0)		; MAX_PATH
	DllCall("lstrcpyA", "Str", fPathW, "Str", fPath)
	if !r := DllCall(DllCall("GetProcAddress", Ptr, DllCall("GetModuleHandleA", "Str", "shell32"), "UInt", 62)
			, Ptr, hGui
			, Ptr, &fPathW
			, "UInt", sz-1
			, PtrP, --idx)
		return
	VarSetCapacity(fPathW, -1)
	}
else										; AHK Unicode (Windows NT implied)
	{
	VarSetCapacity(fPathW, sz := 261*2, 0)		; MAX_PATH Unicode style
	DllCall("lstrcpyW", "Str", fPathW, "Str", fPath)
	if !r := DllCall(DllCall("GetProcAddress", Ptr, DllCall("GetModuleHandleW", "Str", "shell32"), "UInt", 62)
			, Ptr, hGui
			, Ptr, &fPathW
			, "UInt", sz//2
			, PtrP, --idx)
		return
	VarSetCapacity(fPathW, -1)
	}
Loop, %fPathW%
	fPath := A_LoopFileLongPath
return TRUE
}
