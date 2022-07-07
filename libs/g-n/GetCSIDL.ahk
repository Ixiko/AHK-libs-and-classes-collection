; Retrieves known CSIDL paths
; v1.0 © Drugwash June 2015, inspired by majkinetor's GetCommonPath() function
; at http://www.autohotkey.com/board/topic/9399-function-getcommonpath-get-path-to-standard-system-folder/
 ;#include ..\updates.ahk

GetCSIDL(p, e="", t=0)
{
Global Ptr, AW, w9x
Static apilib
StringUpper, e, e
if e not in A,W
	e := AW
t := t ? 1 : 0
if !apilib
	apilib := w9x ? "SHFolder" : "shell32"
sz := 256*2**(e="W")
VarSetCapacity(sp, sz, 0)
DllCall(apilib "\SHGetFolderPath" e
	, "UInt", 0	; hwndOwner
	, "UInt", p	; nFolder
	, "UInt", 0	; hToken
	, "UInt", t		; dwFlags (SHGFP_TYPE_CURRENT=0, SHGFP_TYPE_DEFAULT=1)
	, "UInt", &sp)	; pszPath
VarSetCapacity(sp, -1)
return sp
}
