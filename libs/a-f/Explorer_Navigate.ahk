; Link:   	https://www.autohotkey.com/boards/viewtopic.php?p=4568#p4568
; Author:	Learning one
; Date:
; for:     	AHK_L

/*

	;=== Hotkeys for testing ===
	F1::Explorer_Navigate("C:\")
	F2::Explorer_Navigate(A_WinDir)
	F3::Explorer_Navigate(A_MyDocuments)

*/


;=== Function ===
Explorer_Navigate(FullPath, hwnd="") {  ; by Learning one. Credits: JnLlnd
	; http://ahkscript.org/boards/viewtopic.php?p=4568#p4568
	; http://ahkscript.org/boards/viewtopic.php?p=4864#p4864
	; http://msdn.microsoft.com/en-us/library/windows/desktop/bb774096%28v=vs.85%29.aspx
	; http://msdn.microsoft.com/en-us/library/aa752094
	hwnd := (hwnd="") ? WinExist("A") : hwnd ; if omitted, use active window
	WinGet, ProcessName, ProcessName, % "ahk_id " hwnd
	if (ProcessName != "explorer.exe")  ; not Windows explorer
		return
	For pExp in ComObjCreate("Shell.Application").Windows
	{
		if (pExp.hwnd = hwnd) { ; matching window found
			if FullPath is integer	; ShellSpecialFolderConstant. Example: "17" (My Computer)
				pExp.Navigate2(FullPath)
			else if (InStr(FullPath, "\\") = 1) ; network path (UNC). Example: "\\my.server.com@SSL\DavWWWRoot\Folder"
				pExp.Navigate(FullPath)
			else
				pExp.Navigate("file:///" FullPath)	; example: "C:\My folder"
			return
		}
	}
}