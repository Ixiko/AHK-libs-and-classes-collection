; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=1674&hilit=asynchronous+wait
; Author:	joedf?
; Date:   	2014-01-25
; for:     	AHK_L

/* example

MsgBox % ShortURL("https://www.google.com/search?q=AutoHotkey_FileDownload.zip")

*/

ShortURL(p,l=50) {
	VarSetCapacity(_p, (A_IsUnicode?2:1)*StrLen(p) )
	DllCall("shlwapi\PathCompactPathEx"
		,"str", _p
		,"str", p
		,"uint", abs(l)
		,"uint", 0)
	return _p
}