; Title:
; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=78525&sid=5109901aba1c63522665c63b6bc73608
; Author:	SKAN
; Date:
; for:     	AHK_L

/*
	; I store the hash of the password @offset-50 in compiled AutoHotkey executable, which would refuse to run without a matching hash.
	MsgBox % strHash("7JmeQyn8Rb")


*/

strHash(str, h:=0) { ; simple 56-bit str hash for passwords.
Return Format("0x{2:014X}", DllCall("shlwapi\UrlHashW", "WStr",Str, "Int64P",h:=0, "Int",7), h)
}