; ===============================================================================================================================
; Function......: GetFileAttributes
; DLL...........: Kernel32.dll
; Library.......: Kernel32.lib
; U/ANSI........: GetFileAttributesW (Unicode) and GetFileAttributesA (ANSI)
; Author........: jNizM
; Modified......:
; Links.........: https://msdn.microsoft.com/en-us/library/aa364944.aspx
;                 https://msdn.microsoft.com/en-us/library/windows/desktop/aa364944.aspx
; ===============================================================================================================================
GetFileAttributes(FileName)
{
    if ((ret := DllCall("kernel32.dll\GetFileAttributes", "Str", FileName)) = -1)
		return "*" DllCall("kernel32.dll\GetLastError")
	return ret
}
; ===============================================================================================================================

MsgBox % GetFileAttributes("C:\Windows\Notepad.exe") "`n"
       . GetFileAttributes("C:\Windows\")

; File Attribute Constants
; https://msdn.microsoft.com/en-us/library/gg258117.aspx
; https://msdn.microsoft.com/en-us/library/windows/desktop/gg258117.aspx





/* C++ ==========================================================================================================================
DWORD WINAPI GetFileAttributes(                                                      // UInt
    _In_  LPCTSTR lpFileName                                                         // Str
);
============================================================================================================================== */