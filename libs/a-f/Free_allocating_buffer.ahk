; Title:
; Link:
; Author:
; Date:
; for:     	AHK_L

/*


*/

#NoEnv
#Warn
#SingleInstance, Force

FileOpen("A:\non-existent-path\non-existent.file", "r")
Err := A_LastError

DllCall("Kernel32.dll\FormatMessage", "Int",0x1100, "Ptr",0, "Int",Err, "Int",0, "PtrP",hMem:=0, "Int",0, "Ptr",0)
ErrMsg  := StrGet(hMem)
hMem := DllCall("Kernel32.dll\LocalFree", "Ptr",hMem, "Ptr")
;~ MsgBox % Err " : " ErrMsg

if (!DllCall("GetConsoleScreenBufferInfo", "Ptr", 0, "Ptr", 0, "UInt")) {
	MsgBox, %  (Exception(Format("0x{:U}", DllCall("msvcrt\_i64tow", "Int64", Err, "Ptr*", 0, "UInt", 16, "Str")), -1, FormatMessage(Err)))
}

FormatMessage(messageID) {
	if (!length := DllCall("Kernel32\FormatMessage", "UInt", 0x1100, "Ptr", 0, "UInt", messageID, "UInt", 0, "Ptr*", buffer := 0, "UInt", 0, "Ptr", 0, "UInt")) {
		return (FormatMessage(DllCall("Kernel32\GetLastError")))
	}

	return (StrGet(buffer, length - 2), DllCall("Kernel32\LocalFree", "Ptr", buffer, "Ptr"))
}

