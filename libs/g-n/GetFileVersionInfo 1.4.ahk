; v1.4 July 2017
; #include updates.ahk, run updates() before calling the function
;================================================================
FileGetVersionInfo(peFile="", StringFileInfo="")	; by SKAN (thank you), improved by Drugwash
;================================================================
{
Global AStr, WStr, Ptr, PtrP, AW, w9x, A_CharSize
FSz := DllCall("Version\GetFileVersionInfoSize" AW, "Str", peFile, "UInt", 0)
IfLess, FSz,1, Return -1
VarSetCapacity(FVI, FSz, 0), VarSetCapacity(Trans, 8*A_CharSize, 0)
DllCall("Version\GetFileVersionInfo" AW, "Str", peFile, "Int", 0, "UInt", FSz, Ptr, &FVI)
If ! DllCall("Version\VerQueryValue" AW
		, Ptr		, &FVI
		, "Str"	, "\VarFileInfo\Translation"
		, PtrP	, Translation
		, "UInt"	, 0)
	Return -2
f := (w9x OR !A_IsUnicode) ? "msvcrt\sprintf" : "msvcrt\swprintf"
If ! DllCall(f, "Str", Trans, %AW%Str, "%04X%04X"
	, "UShort", NumGet(Translation+0, 0, "UShort")
	, "UShort", NumGet(Translation+0, 2, "UShort")
	, "CDecl")
	Return -4
i := SubStr(Trans, 1, 4)
if StringFileInfo = Lang
	{
	j := GetLocaleInfo("0x" i, 0x2)
	return (i = "0000" ? "Neutral" : j < 0 ? "0x" i : j)
	}
if StringFileInfo = LangN
	return "0x" i
subBlock := "\StringFileInfo\" Trans "\" StringFileInfo
If ! DllCall("Version\VerQueryValue" AW, Ptr, &FVI, "Str", subBlock, PtrP, InfoPtr, "UInt", 0)
	{
	OutputDebug, %A_ThisFunc%() => Trans=%Trans% subBlock=%subBlock%
	Return
	}
VarSetCapacity(Info, DllCall( "lstrlen" AW, Ptr, InfoPtr )*A_CharSize)
DllCall("lstrcpy" AW, "Str", Info, Ptr, InfoPtr)
Return Info
}
;================================================================
GetLocaleInfo(LCID=0x800, type=0x1)
;================================================================
{
; LOCALE_SYSTEM_DEFAULT=MAKELCID(MAKELANGID(0, 2), 0) 0x800
; LOCALE_USER_DEFAULT=MAKELCID(MAKELANGID(0, 1), 0) 0x400
; LOCALE_IDEFAULTLANGUAGE=0x9, LOCALE_ILANGUAGE=0x1
Global Ptr, AW, A_CharSize
if !sz := DllCall("GetLocaleInfo" AW, "UInt", LCID, "UInt", type, Ptr, &data, "UInt", 0)
	{
	OutputDebug, % "Error " DllCall("GetLastError", "UInt") " in " A_ThisFunc "`nLCID=" LCID " , type=" type
	return -1
	}
VarSetCapacity(data, sz*A_CharSize, 0)	; sz includes terminating null
if !DllCall("GetLocaleInfo" AW, "UInt", LCID, "UInt", type, Ptr, &data, "UInt", sz)
	return -1
VarSetCapacity(data, -1)
return data
}
