; Title:   	AutoHotkey/LowLevelProc.ahk
; Link:   	https://github.com/Onimuru/AutoHotkey/blob/df5fdfd8af318482c1f4c7b77e8360f955697cb9/test/LowLevelProc.ahk
; Author:
; Date:
; for:     	AHK_L

/*


*/

;* FormatMessage(messageID)
FormatMessage(messageID) {  ;: https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-formatmessage

	Local
	if (!length := DllCall("Kernel32\FormatMessage", "UInt", 0x1100, "Ptr", 0, "UInt", messageID, "UInt", 0, "Ptr*", buffer := 0, "UInt", 0, "Ptr", 0, "UInt"))
		return (FormatMessage(DllCall("Kernel32\GetLastError")))

return (StrGet(buffer, length - 2), DllCall("Kernel32\LocalFree", "Ptr", buffer, "Ptr"))  ;* Account for the newline and carriage return characters.
}